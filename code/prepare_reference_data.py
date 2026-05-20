#!/usr/bin/env python3
"""Prepare official reference CSV files for the hospital project.

Expected inputs in data/raw:
  - icd10.csv with columns: icd10_code, category_code, description
  - ken.csv with columns: ken_code, description, base_cost, mdn_days, daily_extra_cost
  - procedures.csv with columns: procedure_code, name, category, duration_minutes, cost, required_room_type
  - ema_article57.csv with columns: ema_product_id, drug_name, active_substances

EMA active substances may be separated with '|'. The script normalizes them
into active_substance.csv and drug_active_substance.csv.
"""

from __future__ import annotations

import csv
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
OUT = ROOT / "data" / "processed"


def normalize(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().lower())


def read_csv(name: str) -> list[dict[str, str]]:
    path = RAW / name
    if not path.exists():
        raise SystemExit(f"Missing {path}. Put the official reference file in data/raw first.")
    with path.open(newline="", encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))


def write_csv(name: str, headers: list[str], rows: list[dict[str, object]]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    with (OUT / name).open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=headers, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    write_csv(
        "icd10_code.csv",
        ["icd10_code", "category_code", "description"],
        read_csv("icd10.csv"),
    )
    write_csv(
        "ken_code.csv",
        ["ken_code", "description", "base_cost", "mdn_days", "daily_extra_cost"],
        read_csv("ken.csv"),
    )
    write_csv(
        "procedure_catalog.csv",
        ["procedure_code", "name", "category", "duration_minutes", "cost", "required_room_type"],
        read_csv("procedures.csv"),
    )

    ema_rows = read_csv("ema_article57.csv")
    drug_rows: list[dict[str, object]] = []
    substance_by_norm: dict[str, int] = {}
    substance_rows: list[dict[str, object]] = []
    drug_substance_rows: list[dict[str, object]] = []

    for idx, row in enumerate(ema_rows, 1):
        drug_rows.append({
            "drug_id": idx,
            "ema_product_id": row["ema_product_id"].strip(),
            "drug_name": row["drug_name"].strip(),
        })
        raw_substances = row.get("active_substances", "")
        for substance in [s.strip() for s in raw_substances.split("|") if s.strip()]:
            norm = normalize(substance)
            if norm not in substance_by_norm:
                substance_by_norm[norm] = len(substance_by_norm) + 1
                substance_rows.append({
                    "substance_id": substance_by_norm[norm],
                    "substance_name": substance,
                    "normalized_name": norm,
                })
            drug_substance_rows.append({
                "drug_id": idx,
                "substance_id": substance_by_norm[norm],
            })

    write_csv("drug.csv", ["drug_id", "ema_product_id", "drug_name"], drug_rows)
    write_csv("active_substance.csv", ["substance_id", "substance_name", "normalized_name"], substance_rows)
    write_csv("drug_active_substance.csv", ["drug_id", "substance_id"], drug_substance_rows)
    print(f"Wrote official reference CSV files to {OUT}")


if __name__ == "__main__":
    main()
