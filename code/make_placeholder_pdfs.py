#!/usr/bin/env python3
"""Create tiny valid PDF placeholders for deliverable paths.

They are intentionally simple; regenerate proper diagram/report PDFs from the
Mermaid and Markdown sources before final submission if visual quality matters.
"""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def escape(text: str) -> str:
    return text.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")


def write_pdf(path: Path, title: str, lines: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    stream_lines = ["BT", "/F1 16 Tf", "72 760 Td", f"({escape(title)}) Tj", "/F1 10 Tf"]
    for line in lines:
        stream_lines.append("0 -18 Td")
        stream_lines.append(f"({escape(line)}) Tj")
    stream_lines.append("ET")
    stream = "\n".join(stream_lines).encode("latin-1", errors="replace")
    objects = [
        b"<< /Type /Catalog /Pages 2 0 R >>",
        b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>",
        b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
        b"<< /Length " + str(len(stream)).encode("ascii") + b" >>\nstream\n" + stream + b"\nendstream",
    ]
    output = bytearray(b"%PDF-1.4\n")
    offsets = [0]
    for index, obj in enumerate(objects, 1):
        offsets.append(len(output))
        output.extend(f"{index} 0 obj\n".encode("ascii"))
        output.extend(obj)
        output.extend(b"\nendobj\n")
    xref = len(output)
    output.extend(f"xref\n0 {len(objects) + 1}\n".encode("ascii"))
    output.extend(b"0000000000 65535 f \n")
    for offset in offsets[1:]:
        output.extend(f"{offset:010d} 00000 n \n".encode("ascii"))
    output.extend(f"trailer << /Size {len(objects) + 1} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n".encode("ascii"))
    path.write_bytes(output)


def main() -> None:
    write_pdf(ROOT / "diagrams" / "er.pdf", "ER Diagram Placeholder", [
        "Source: diagrams/er.mmd",
        "Open the Mermaid source to render the full ER diagram.",
    ])
    write_pdf(ROOT / "diagrams" / "relational.pdf", "Relational Diagram Placeholder", [
        "Source: diagrams/relational.mmd",
        "Open the Mermaid source to render the relational diagram.",
    ])
    write_pdf(ROOT / "docs" / "report.pdf", "Report Placeholder", [
        "Source: docs/report.md",
        "Replace this PDF after running Q04/Q06 EXPLAIN ANALYZE screenshots.",
    ])


if __name__ == "__main__":
    main()
