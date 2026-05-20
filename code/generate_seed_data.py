#!/usr/bin/env python3
"""Generate deterministic CSV seed data for the Ygeiopolis MariaDB schema.

The generator intentionally writes plain CSV files consumed by sql/load.sql.
Reference rows here are small demonstration fallbacks. For final submission,
replace them by running prepare_reference_data.py against the official raw
files described in README.md.
"""

from __future__ import annotations

import csv
import math
import random
from datetime import date, datetime, timedelta
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "data" / "processed"
RANDOM = random.Random(20260518)
DOCTOR_COUNT = 95
NURSE_START = DOCTOR_COUNT + 1
NURSE_COUNT = 180
ADMIN_START = NURSE_START + NURSE_COUNT
ADMIN_COUNT = 60


def write_csv(name: str, headers: list[str], rows: list[dict[str, object]]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    with (OUT / name).open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=headers, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def dt(value: datetime | date | None) -> str:
    if value is None:
        return r"\N"
    if isinstance(value, datetime):
        return value.strftime("%Y-%m-%d %H:%M:%S")
    return value.isoformat()


def generate() -> None:
    departments = [
        "Καρδιολογία", "Χειρουργική", "ΜΕΘ", "Επείγοντα", "Παθολογική",
        "Ορθοπαιδική", "Νευρολογία", "Παιδιατρική", "Μαιευτική",
        "Ογκολογία", "Πνευμονολογία", "Νεφρολογία", "Γαστρεντερολογία",
        "ΩΡΛ", "Οφθαλμολογία",
    ]
    specialties = [
        "Καρδιολογία", "Χειρουργική", "Εντατικολογία", "Επείγουσα Ιατρική",
        "Παθολογία", "Ορθοπαιδική", "Νευρολογία", "Παιδιατρική",
        "Μαιευτική", "Ογκολογία", "Πνευμονολογία", "Νεφρολογία",
        "Γαστρεντερολογία", "ΩΡΛ", "Οφθαλμολογία",
    ]
    first_names = [
        "Γιώργος", "Μαρία", "Νίκος", "Ελένη", "Κώστας", "Άννα", "Πέτρος",
        "Σοφία", "Δημήτρης", "Ιωάννα", "Αλέξανδρος", "Κατερίνα",
    ]
    last_names = [
        "Παπαδόπουλος", "Γεωργίου", "Νικολάου", "Ιωάννου", "Δημητρίου",
        "Κωνσταντίνου", "Αθανασίου", "Παναγιώτου", "Αλεξίου", "Μαρίνου",
    ]

    insurance_rows = [
        {"insurance_provider_id": 1, "name": "ΕΦΚΑ"},
        {"insurance_provider_id": 2, "name": "Ιδιωτική Ασφάλεια"},
        {"insurance_provider_id": 3, "name": "Ανασφάλιστος"},
    ]
    write_csv("insurance_provider.csv", ["insurance_provider_id", "name"], insurance_rows)

    staff_rows: list[dict[str, object]] = []
    doctor_rows: list[dict[str, object]] = []
    nurse_rows: list[dict[str, object]] = []
    admin_rows: list[dict[str, object]] = []

    for i in range(1, DOCTOR_COUNT + 1):
        if i <= 15:
            rank, supervisor = "Διευθυντής", r"\N"
        elif i <= 50:
            rank, supervisor = "Επιμελητής Α", 1 + ((i - 16) % 15)
        elif i <= 75:
            rank, supervisor = "Επιμελητής Β", 16 + ((i - 51) % 35)
        else:
            rank, supervisor = "Ειδικευόμενος", 16 + ((i - 76) % 35)
        age = 31 + (i % 28)
        if 16 <= i <= 25:
            age = 30 + (i % 5)
        staff_rows.append({
            "staff_id": i,
            "amka": f"1{i:010d}",
            "first_name": first_names[i % len(first_names)],
            "last_name": last_names[i % len(last_names)],
            "age": age,
            "email": f"doctor{i}@ygeiopolis.test",
            "phone": f"210100{i:04d}",
            "hire_date": dt(date(2010 + (i % 12), 1 + (i % 12), 1 + (i % 20))),
            "staff_type": "DOCTOR",
        })
        doctor_rows.append({
            "staff_id": i,
            "license_number": f"MED-{i:05d}",
            "specialty": specialties[(i - 1) % len(specialties)],
            "doctor_rank": rank,
            "supervisor_id": supervisor,
        })

    for offset in range(NURSE_COUNT):
        i = NURSE_START + offset
        dept = 1 + (offset % 15)
        staff_rows.append({
            "staff_id": i,
            "amka": f"2{i:010d}",
            "first_name": first_names[i % len(first_names)],
            "last_name": last_names[i % len(last_names)],
            "age": 24 + (i % 35),
            "email": f"nurse{i}@ygeiopolis.test",
            "phone": f"210200{i:04d}",
            "hire_date": dt(date(2014 + (i % 10), 1 + (i % 12), 1 + (i % 20))),
            "staff_type": "NURSE",
        })
        nurse_rows.append({
            "staff_id": i,
            "nurse_rank": ["Βοηθός Νοσηλευτή", "Νοσηλευτής", "Προϊστάμενος"][offset % 3],
            "department_id": dept,
        })

    roles = ["Γραμματέας", "Λογιστής", "Υποδοχή", "Διοικητικός Υπεύθυνος"]
    for offset in range(ADMIN_COUNT):
        i = ADMIN_START + offset
        dept = 1 + (offset % 15)
        staff_rows.append({
            "staff_id": i,
            "amka": f"3{i:010d}",
            "first_name": first_names[i % len(first_names)],
            "last_name": last_names[i % len(last_names)],
            "age": 25 + (i % 35),
            "email": f"admin{i}@ygeiopolis.test",
            "phone": f"210300{i:04d}",
            "hire_date": dt(date(2013 + (i % 11), 1 + (i % 12), 1 + (i % 20))),
            "staff_type": "ADMIN",
        })
        admin_rows.append({
            "staff_id": i,
            "admin_role": roles[offset % len(roles)],
            "office": f"Γραφείο {dept}-{1 + offset // 15}",
            "department_id": dept,
        })

    write_csv("staff.csv", list(staff_rows[0].keys()), staff_rows)
    write_csv("doctor.csv", list(doctor_rows[0].keys()), doctor_rows)

    department_rows = [{
        "department_id": i,
        "name": name,
        "description": f"Τμήμα {name} του Γενικού Νοσοκομείου Υγειόπολης.",
        "beds_count": 20,
        "floor_building": f"Κτίριο {chr(64 + ((i - 1) % 4) + 1)}, Όροφος {1 + ((i - 1) % 5)}",
        "director_doctor_id": i,
    } for i, name in enumerate(departments, 1)]
    write_csv("department.csv", list(department_rows[0].keys()), department_rows)

    doctor_department_rows = []
    for i in range(1, DOCTOR_COUNT + 1):
        primary = 1 + ((i - 1) % 15)
        doctor_department_rows.append({"doctor_id": i, "department_id": primary})
        if i > 15:
            doctor_department_rows.append({"doctor_id": i, "department_id": 1 + ((primary + 4) % 15)})
    write_csv("doctor_department.csv", ["doctor_id", "department_id"], doctor_department_rows)
    write_csv("nurse.csv", list(nurse_rows[0].keys()), nurse_rows)
    write_csv("admin_staff.csv", list(admin_rows[0].keys()), admin_rows)

    bed_rows = []
    bed_id = 1
    for dept in range(1, 16):
        for n in range(1, 21):
            bed_rows.append({
                "bed_id": bed_id,
                "department_id": dept,
                "bed_number": f"D{dept:02d}-B{n:03d}",
                "bed_type": "ΜΕΘ" if dept == 3 and n <= 10 else ("Μονόκλινο" if n % 5 == 0 else "Πολύκλινο"),
                "bed_status": "Κατειλημμένη" if n % 7 == 0 else ("Υπό συντήρηση" if n % 19 == 0 else "Διαθέσιμη"),
            })
            bed_id += 1
    write_csv("bed.csv", list(bed_rows[0].keys()), bed_rows)

    patient_rows, contact_rows = [], []
    for i in range(1, 201):
        patient_rows.append({
            "patient_id": i,
            "amka": f"9{i:010d}",
            "first_name": first_names[(i + 3) % len(first_names)],
            "last_name": last_names[(i + 5) % len(last_names)],
            "father_name": first_names[(i + 7) % len(first_names)],
            "age": 1 + (i % 95),
            "gender": ["Άνδρας", "Γυναίκα", "Άλλο"][i % 3],
            "weight_kg": f"{45 + (i % 60)}.0",
            "height_cm": f"{145 + (i % 45)}.0",
            "address": f"Οδός Υγείας {i}, Υγειόπολη",
            "phone": f"690000{i:04d}",
            "email": f"patient{i}@example.test",
            "profession": ["Μηχανικός", "Εκπαιδευτικός", "Φοιτητής", "Συνταξιούχος"][i % 4],
            "nationality": "Ελληνική",
            "insurance_provider_id": 1 + (i % 3),
        })
        contact_rows.append({
            "contact_id": i,
            "patient_id": i,
            "full_name": f"{first_names[i % len(first_names)]} {last_names[i % len(last_names)]}",
            "relationship": ["Σύζυγος", "Γονέας", "Τέκνο", "Αδελφός/ή"][i % 4],
            "phone": f"697000{i:04d}",
        })
    write_csv("patient.csv", list(patient_rows[0].keys()), patient_rows)
    write_csv("patient_emergency_contact.csv", list(contact_rows[0].keys()), contact_rows)

    icd_rows = [
        {"icd10_code": "I21", "category_code": "I", "description": "Οξύ έμφραγμα του μυοκαρδίου"},
        {"icd10_code": "K35", "category_code": "K", "description": "Οξεία σκωληκοειδίτιδα"},
        {"icd10_code": "J18", "category_code": "J", "description": "Πνευμονία, μη καθορισμένη"},
        {"icd10_code": "E11", "category_code": "E", "description": "Σακχαρώδης διαβήτης τύπου 2"},
        {"icd10_code": "S72", "category_code": "S", "description": "Κάταγμα μηριαίου οστού"},
        {"icd10_code": "N18", "category_code": "N", "description": "Χρόνια νεφρική νόσος"},
        {"icd10_code": "C50", "category_code": "C", "description": "Κακοήθης νεοπλασία μαστού"},
        {"icd10_code": "G45", "category_code": "G", "description": "Παροδικά εγκεφαλικά ισχαιμικά επεισόδια"},
        {"icd10_code": "H25", "category_code": "H", "description": "Γεροντικός καταρράκτης"},
        {"icd10_code": "O80", "category_code": "O", "description": "Μονήρης αυτόματος τοκετός"},
        {"icd10_code": "Z00", "category_code": "Z", "description": "Γενική εξέταση και διερεύνηση ατόμων χωρίς συμπτώματα"},
    ]
    ken_rows = [
        {"ken_code": "KEN001", "description": "Νοσηλεία καρδιολογικού περιστατικού", "base_cost": "1800.00", "mdn_days": 4, "daily_extra_cost": "250.00"},
        {"ken_code": "KEN002", "description": "Γενική χειρουργική νοσηλεία", "base_cost": "2200.00", "mdn_days": 5, "daily_extra_cost": "300.00"},
        {"ken_code": "KEN003", "description": "Νοσηλεία ΜΕΘ", "base_cost": "5000.00", "mdn_days": 7, "daily_extra_cost": "700.00"},
        {"ken_code": "KEN004", "description": "Παθολογική νοσηλεία", "base_cost": "1200.00", "mdn_days": 3, "daily_extra_cost": "180.00"},
        {"ken_code": "KEN005", "description": "Ορθοπαιδική νοσηλεία", "base_cost": "2600.00", "mdn_days": 6, "daily_extra_cost": "320.00"},
        {"ken_code": "KEN006", "description": "Παιδιατρική νοσηλεία", "base_cost": "900.00", "mdn_days": 2, "daily_extra_cost": "130.00"},
        {"ken_code": "KEN007", "description": "Ογκολογική νοσηλεία", "base_cost": "3200.00", "mdn_days": 6, "daily_extra_cost": "450.00"},
        {"ken_code": "KEN008", "description": "Οφθαλμολογική νοσηλεία", "base_cost": "1000.00", "mdn_days": 1, "daily_extra_cost": "120.00"},
    ]
    write_csv("icd10_code.csv", list(icd_rows[0].keys()), icd_rows)
    write_csv("ken_code.csv", list(ken_rows[0].keys()), ken_rows)

    hosp_rows = []
    cyclic_icd_rows = icd_rows[:10]
    for i in range(1, 501):
        patient_id = 1 if i <= 4 else 1 + ((i - 1) % 200)
        dept = 1 if i <= 4 else 1 + ((i - 1) % 15)
        bed = ((dept - 1) * 20) + 1 + ((i - 1) % 20)
        admission = datetime(2025 + (i % 2), 1 + ((i * 3) % 12), 1 + ((i * 7) % 24), 10, 0)
        if i <= 40:
            admission = datetime(2025, 2, 1, 9, 0) + timedelta(days=i)
        if 41 <= i <= 80:
            admission = datetime(2026, 2, 1, 9, 0) + timedelta(days=i - 40)
        admission_icd = cyclic_icd_rows[(i - 1) % len(cyclic_icd_rows)]["icd10_code"]
        discharge_icd = cyclic_icd_rows[i % len(cyclic_icd_rows)]["icd10_code"]
        if i <= 10:
            admission = datetime(2025, 1, 1, 9, 0) + timedelta(days=i)
            admission_icd = "Z00"
        elif i <= 20:
            admission = datetime(2026, 1, 1, 9, 0) + timedelta(days=i - 10)
            admission_icd = "Z00"
        stay = 2 + (i % 12)
        discharge = None if i % 50 == 0 else admission + timedelta(days=stay)
        ken = ken_rows[(i - 1) % len(ken_rows)]
        extra_days = max(0, stay - int(ken["mdn_days"]))
        total = float(ken["base_cost"]) + extra_days * float(ken["daily_extra_cost"])
        hosp_rows.append({
            "hospitalization_id": i,
            "patient_id": patient_id,
            "department_id": dept,
            "bed_id": bed,
            "admission_date": dt(admission),
            "discharge_date": dt(discharge),
            "admission_icd10_code": admission_icd,
            "discharge_icd10_code": discharge_icd if discharge else r"\N",
            "ken_code": ken["ken_code"],
            "total_cost": f"{total:.2f}",
        })
    write_csv("hospitalization.csv", list(hosp_rows[0].keys()), hosp_rows)

    triage_rows = []
    for i in range(1, 201):
        arrival = datetime(2026, 3, 1, 7, 0) + timedelta(minutes=i * 11)
        urgency = 1 + (i % 5)
        wait = urgency * 8 + (i % 6)
        hosp_id = i if i % 3 != 0 else r"\N"
        referred = hosp_rows[i - 1]["department_id"] if hosp_id != r"\N" else r"\N"
        triage_rows.append({
            "triage_id": i,
            "patient_id": 1 + ((i - 1) % 200),
            "triage_nurse_id": NURSE_START + (i % NURSE_COUNT),
            "arrival_time": dt(arrival),
            "triage_time": dt(arrival + timedelta(minutes=5)),
            "symptoms": ["πόνος στο στήθος", "πυρετός", "κάταγμα", "δύσπνοια", "κεφαλαλγία"][i % 5],
            "urgency_level": urgency,
            "service_start_time": dt(arrival + timedelta(minutes=5 + wait)),
            "outcome": "Παραπομπή για νοσηλεία" if hosp_id != r"\N" else "Οδηγίες και έξοδος",
            "hospitalization_id": hosp_id,
            "referred_department_id": referred,
        })
    write_csv("triage_case.csv", list(triage_rows[0].keys()), triage_rows)

    proc_catalog = []
    for i in range(1, 21):
        proc_catalog.append({
            "procedure_code": f"PROC{i:03d}",
            "name": ["Σκωληκοειδεκτομή", "Αγγειοπλαστική", "Αρθροσκόπηση", "Βιοψία", "Καθετηριασμός"][i % 5] + f" {i}",
            "category": ["Χειρουργική", "Διαγνωστική", "Θεραπευτική"][i % 3],
            "duration_minutes": 45 + (i % 6) * 20,
            "cost": f"{450 + i * 75:.2f}",
            "required_room_type": "Χειρουργείο" if i % 2 == 0 else "Αίθουσα επέμβασης",
        })
    rooms = [{
        "room_id": i,
        "name": f"{'Χειρουργείο' if i <= 6 else 'Αίθουσα επέμβασης'} {i}",
        "room_type": "Χειρουργείο" if i <= 6 else "Αίθουσα επέμβασης",
    } for i in range(1, 11)]
    write_csv("procedure_catalog.csv", list(proc_catalog[0].keys()), proc_catalog)
    write_csv("procedure_room.csv", list(rooms[0].keys()), rooms)

    medproc_rows, assistant_rows = [], []
    for i in range(1, 151):
        proc = proc_catalog[(i - 1) % len(proc_catalog)]
        compatible_rooms = [r for r in rooms if r["room_type"] == proc["required_room_type"]]
        room = compatible_rooms[(i - 1) % len(compatible_rooms)]
        start = datetime(2026, 1, 1, 8, 0) + timedelta(days=i - 1)
        end = start + timedelta(minutes=int(proc["duration_minutes"]))
        surgeon = 16 + ((i - 1) % 20)
        medproc_rows.append({
            "medical_procedure_id": i,
            "hospitalization_id": 1 + ((i - 1) % 480),
            "procedure_code": proc["procedure_code"],
            "room_id": room["room_id"],
            "start_time": dt(start),
            "end_time": dt(end),
            "main_surgeon_id": surgeon,
        })
        assistant_rows.append({
            "medical_procedure_id": i,
            "staff_id": NURSE_START + ((i - 1) % NURSE_COUNT),
            "assistant_role": "Βοηθός επέμβασης",
        })
    write_csv("medical_procedure.csv", list(medproc_rows[0].keys()), medproc_rows)
    write_csv("procedure_assistant.csv", list(assistant_rows[0].keys()), assistant_rows)

    lab_rows = []
    for i in range(1, 201):
        lab_rows.append({
            "lab_test_id": i,
            "hospitalization_id": 1 + ((i - 1) % 500),
            "test_code": f"LAB{i:04d}",
            "test_type": ["Αιματολογική", "Βιοχημική", "Απεικονιστική"][i % 3],
            "test_date": dt(datetime(2026, 1, 1, 9, 0) + timedelta(days=i)),
            "result_text": "Εντός αναμενόμενων ορίων",
            "result_value": f"{10 + (i % 90)}.00",
            "unit": ["mg/dL", "mmol/L", "μονάδες"][i % 3],
            "cost": f"{20 + (i % 12) * 5:.2f}",
            "ordered_by_doctor_id": 1 + (i % DOCTOR_COUNT),
        })
    write_csv("lab_test.csv", list(lab_rows[0].keys()), lab_rows)

    substances = [
        "Paracetamol", "Ibuprofen", "Amoxicillin", "Metformin", "Atorvastatin",
        "Omeprazole", "Aspirin", "Salbutamol", "Cefuroxime", "Insulin",
        "Losartan", "Furosemide",
    ]
    substance_rows = [{"substance_id": i, "substance_name": s, "normalized_name": s.lower()} for i, s in enumerate(substances, 1)]
    drug_rows = [{"drug_id": i, "ema_product_id": f"EMA-DEMO-{i:04d}", "drug_name": f"{substances[i - 1]} Demo"} for i in range(1, 13)]
    drug_sub_rows = [{"drug_id": i, "substance_id": i} for i in range(1, 13)]
    allergy_rows = [{"patient_id": i, "substance_id": 1 + (i % 12)} for i in range(1, 81)]
    write_csv("active_substance.csv", list(substance_rows[0].keys()), substance_rows)
    write_csv("drug.csv", list(drug_rows[0].keys()), drug_rows)
    write_csv("drug_active_substance.csv", list(drug_sub_rows[0].keys()), drug_sub_rows)
    write_csv("patient_allergy.csv", list(allergy_rows[0].keys()), allergy_rows)

    prescription_rows = []
    pid = 1
    for i in range(1, 61):
        for drug_id in (2, 3, 4):
            patient_id = hosp_rows[i - 1]["patient_id"]
            if patient_id <= 80 and (1 + (patient_id % 12)) == drug_id:
                drug_id = 5
            prescription_rows.append({
                "prescription_id": pid,
                "hospitalization_id": i,
                "doctor_id": 1 + (i % DOCTOR_COUNT),
                "patient_id": patient_id,
                "drug_id": drug_id,
                "dosage": "1 δισκίο",
                "frequency": "2 φορές ημερησίως",
                "start_date": dt(datetime.strptime(str(hosp_rows[i - 1]["admission_date"]), "%Y-%m-%d %H:%M:%S").date()),
                "end_date": dt(datetime.strptime(str(hosp_rows[i - 1]["admission_date"]), "%Y-%m-%d %H:%M:%S").date() + timedelta(days=5)),
            })
            pid += 1
    while pid <= 320:
        hosp = hosp_rows[(pid - 1) % 500]
        patient_id = int(hosp["patient_id"])
        drug_id = 1 + (pid % 12)
        allergic = patient_id <= 80 and (1 + (patient_id % 12)) == drug_id
        if allergic:
            drug_id = 12 if drug_id != 12 else 11
        start_date = datetime.strptime(str(hosp["admission_date"]), "%Y-%m-%d %H:%M:%S").date() + timedelta(days=pid % 3)
        prescription_rows.append({
            "prescription_id": pid,
            "hospitalization_id": hosp["hospitalization_id"],
            "doctor_id": 1 + (pid % DOCTOR_COUNT),
            "patient_id": patient_id,
            "drug_id": drug_id,
            "dosage": f"{1 + (pid % 3)} δισκίο/α",
            "frequency": ["1 φορά ημερησίως", "2 φορές ημερησίως", "ανά 8 ώρες"][pid % 3],
            "start_date": dt(start_date),
            "end_date": dt(start_date + timedelta(days=4 + (pid % 8))),
        })
        pid += 1
    write_csv("prescription.csv", list(prescription_rows[0].keys()), prescription_rows)

    hreview_rows, dreview_rows = [], []
    reviewed_hosp = [h for h in hosp_rows if h["discharge_date"] != r"\N"][:180]
    for i, hosp in enumerate(reviewed_hosp, 1):
        discharge_day = datetime.strptime(str(hosp["discharge_date"]), "%Y-%m-%d %H:%M:%S").date()
        hreview_rows.append({
            "review_id": i,
            "hospitalization_id": hosp["hospitalization_id"],
            "patient_id": hosp["patient_id"],
            "nursing_care_rating": 3 + (i % 3),
            "cleanliness_rating": 3 + ((i + 1) % 3),
            "food_rating": 2 + (i % 4),
            "overall_experience_rating": 3 + ((i + 2) % 3),
            "review_date": dt(discharge_day + timedelta(days=2)),
        })
    drid = 1
    prescribed_pairs = {(int(p["hospitalization_id"]), int(p["doctor_id"]), int(p["patient_id"])) for p in prescription_rows}
    for hosp_id, doctor_id, patient_id in sorted(prescribed_pairs)[:220]:
        hosp = hosp_rows[hosp_id - 1]
        if hosp["discharge_date"] == r"\N":
            continue
        discharge_day = datetime.strptime(str(hosp["discharge_date"]), "%Y-%m-%d %H:%M:%S").date()
        dreview_rows.append({
            "review_id": drid,
            "hospitalization_id": hosp_id,
            "patient_id": patient_id,
            "doctor_id": doctor_id,
            "medical_care_rating": 3 + (drid % 3),
            "review_date": dt(discharge_day + timedelta(days=3)),
        })
        drid += 1
    write_csv("hospitalization_review.csv", list(hreview_rows[0].keys()), hreview_rows)
    write_csv("doctor_review.csv", list(dreview_rows[0].keys()), dreview_rows)

    shift_rows, shift_staff_rows = make_shifts()
    write_csv("shift.csv", list(shift_rows[0].keys()), shift_rows)
    write_csv("shift_staff.csv", list(shift_staff_rows[0].keys()), shift_staff_rows)

    image_rows = []
    image_id = 1
    for dept in range(1, 16):
        image_rows.append({
            "image_id": image_id,
            "entity_type": "department",
            "entity_id": dept,
            "image_url": f"https://example.test/images/departments/{dept}.jpg",
            "alt_text": f"Ενδεικτική φωτογραφία τμήματος {departments[dept - 1]}",
        })
        image_id += 1
    for doctor_id in range(1, DOCTOR_COUNT + 1):
        image_rows.append({
            "image_id": image_id,
            "entity_type": "doctor",
            "entity_id": doctor_id,
            "image_url": f"https://example.test/images/doctors/{doctor_id}.jpg",
            "alt_text": f"Πορτρέτο ιατρού με κωδικό προσωπικού {doctor_id}",
        })
        image_id += 1
    write_csv("entity_image.csv", list(image_rows[0].keys()), image_rows)


def make_shifts() -> tuple[list[dict[str, object]], list[dict[str, object]]]:
    shifts: list[dict[str, object]] = []
    assignments: list[dict[str, object]] = []
    shift_id = 1
    start_day = date(2026, 5, 4)
    shift_defs = [
        ("Πρωινή", 7, 15),
        ("Απογευματινή", 15, 23),
        ("Νυχτερινή", 23, 31),
    ]

    doctor_groups = [list(range(1, 46)), list(range(46, 91))]
    nurse_groups = [
        list(range(NURSE_START, NURSE_START + 90)),
        list(range(NURSE_START + 90, NURSE_START + 180)),
    ]
    admin_groups = [
        list(range(ADMIN_START, ADMIN_START + 30)),
        list(range(ADMIN_START + 30, ADMIN_START + 60)),
    ]

    def chunk(pool: list[int], department_id: int, width: int) -> list[int]:
        start = (department_id - 1) * width
        return pool[start:start + width]

    for day_offset in range(7):
        sdate = start_day + timedelta(days=day_offset)
        for department_id in range(1, 16):
            for kind, start_hour, end_hour in shift_defs:
                start = datetime.combine(sdate, datetime.min.time()) + timedelta(hours=start_hour)
                end = datetime.combine(sdate, datetime.min.time()) + timedelta(hours=end_hour)
                shifts.append({
                    "shift_id": shift_id,
                    "department_id": department_id,
                    "shift_date": dt(sdate),
                    "shift_type": kind,
                    "start_at": dt(start),
                    "end_at": dt(end),
                    "is_finalized": 0,
                })
                group_index = day_offset % 2
                if kind == "Απογευματινή":
                    group_index = 1 - group_index
                selected = []
                selected += chunk(doctor_groups[group_index], department_id, 3)
                selected += chunk(nurse_groups[group_index], department_id, 6)
                selected += chunk(admin_groups[group_index], department_id, 2)
                for staff_id in selected:
                    assignments.append({"shift_id": shift_id, "staff_id": staff_id})
                shift_id += 1
    return shifts, assignments


if __name__ == "__main__":
    generate()
    print(f"Wrote CSV files to {OUT}")
