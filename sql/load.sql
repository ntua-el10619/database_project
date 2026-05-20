USE ygeiopolis;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 1;

LOAD DATA LOCAL INFILE 'data/processed/insurance_provider.csv'
INTO TABLE insurance_provider CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(insurance_provider_id, name);

LOAD DATA LOCAL INFILE 'data/processed/staff.csv'
INTO TABLE staff CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(staff_id, amka, first_name, last_name, age, email, phone, hire_date, staff_type);

/*LOAD DATA LOCAL INFILE 'data/processed/doctor.csv'
INTO TABLE doctor CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\n' IGNORE 1 LINES
(staff_id, license_number, specialty, doctor_rank, supervisor_id);*/

LOAD DATA LOCAL INFILE 'data/processed/doctor.csv'
INTO TABLE doctor CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(staff_id, license_number, specialty, doctor_rank, @supervisor_id)
SET supervisor_id = CASE
  WHEN TRIM(@supervisor_id) REGEXP '^[0-9]+$' THEN CAST(TRIM(@supervisor_id) AS UNSIGNED)
  ELSE NULL
END;

LOAD DATA LOCAL INFILE 'data/processed/department.csv'
INTO TABLE department CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(department_id, name, description, beds_count, floor_building, director_doctor_id);

LOAD DATA LOCAL INFILE 'data/processed/doctor_department.csv'
INTO TABLE doctor_department CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(doctor_id, department_id);

LOAD DATA LOCAL INFILE 'data/processed/nurse.csv'
INTO TABLE nurse CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(staff_id, nurse_rank, department_id);

LOAD DATA LOCAL INFILE 'data/processed/admin_staff.csv'
INTO TABLE admin_staff CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(staff_id, admin_role, office, department_id);

LOAD DATA LOCAL INFILE 'data/processed/bed.csv'
INTO TABLE bed CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(bed_id, department_id, bed_number, bed_type, bed_status);

LOAD DATA LOCAL INFILE 'data/processed/patient.csv'
INTO TABLE patient CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(patient_id, amka, first_name, last_name, father_name, age, gender, weight_kg, height_cm, address, phone, email, profession, nationality, insurance_provider_id);

LOAD DATA LOCAL INFILE 'data/processed/patient_emergency_contact.csv'
INTO TABLE patient_emergency_contact CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(contact_id, patient_id, full_name, relationship, phone);

LOAD DATA LOCAL INFILE 'data/processed/icd10_code.csv'
INTO TABLE icd10_code CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(icd10_code, category_code, description);

LOAD DATA LOCAL INFILE 'data/processed/ken_code.csv'
INTO TABLE ken_code CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(ken_code, description, base_cost, mdn_days, daily_extra_cost);

LOAD DATA LOCAL INFILE 'data/processed/hospitalization.csv'
INTO TABLE hospitalization CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(hospitalization_id, patient_id, department_id, bed_id, admission_date, discharge_date, admission_icd10_code, discharge_icd10_code, ken_code, total_cost);

LOAD DATA LOCAL INFILE 'data/processed/triage_case.csv'
INTO TABLE triage_case CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(triage_id, patient_id, triage_nurse_id, arrival_time, triage_time, symptoms, urgency_level, service_start_time, outcome, hospitalization_id, referred_department_id);

LOAD DATA LOCAL INFILE 'data/processed/procedure_catalog.csv'
INTO TABLE procedure_catalog CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(procedure_code, name, category, duration_minutes, cost, required_room_type);

LOAD DATA LOCAL INFILE 'data/processed/procedure_room.csv'
INTO TABLE procedure_room CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(room_id, name, room_type);

LOAD DATA LOCAL INFILE 'data/processed/medical_procedure.csv'
INTO TABLE medical_procedure CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(medical_procedure_id, hospitalization_id, procedure_code, room_id, start_time, end_time, main_surgeon_id);

LOAD DATA LOCAL INFILE 'data/processed/procedure_assistant.csv'
INTO TABLE procedure_assistant CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(medical_procedure_id, staff_id, assistant_role);

LOAD DATA LOCAL INFILE 'data/processed/lab_test.csv'
INTO TABLE lab_test CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(lab_test_id, hospitalization_id, test_code, test_type, test_date, result_text, result_value, unit, cost, ordered_by_doctor_id);

LOAD DATA LOCAL INFILE 'data/processed/active_substance.csv'
INTO TABLE active_substance CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(substance_id, substance_name, normalized_name);

LOAD DATA LOCAL INFILE 'data/processed/drug.csv'
INTO TABLE drug CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(drug_id, ema_product_id, drug_name);

LOAD DATA LOCAL INFILE 'data/processed/drug_active_substance.csv'
INTO TABLE drug_active_substance CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(drug_id, substance_id);

LOAD DATA LOCAL INFILE 'data/processed/patient_allergy.csv'
INTO TABLE patient_allergy CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(patient_id, substance_id);

LOAD DATA LOCAL INFILE 'data/processed/prescription.csv'
INTO TABLE prescription CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(prescription_id, hospitalization_id, doctor_id, patient_id, drug_id, dosage, frequency, start_date, end_date);

LOAD DATA LOCAL INFILE 'data/processed/hospitalization_review.csv'
INTO TABLE hospitalization_review CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(review_id, hospitalization_id, patient_id, nursing_care_rating, cleanliness_rating, food_rating, overall_experience_rating, review_date);

LOAD DATA LOCAL INFILE 'data/processed/doctor_review.csv'
INTO TABLE doctor_review CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(review_id, hospitalization_id, patient_id, doctor_id, medical_care_rating, review_date);

LOAD DATA LOCAL INFILE 'data/processed/shift.csv'
INTO TABLE shift CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(shift_id, department_id, shift_date, shift_type, start_at, end_at, is_finalized);

LOAD DATA LOCAL INFILE 'data/processed/shift_staff.csv'
INTO TABLE shift_staff CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(shift_id, staff_id);

--UPDATE shift SET is_finalized = 1;

LOAD DATA LOCAL INFILE 'data/processed/entity_image.csv'
INTO TABLE entity_image CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(image_id, entity_type, entity_id, image_url, alt_text);
