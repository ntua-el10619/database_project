DROP DATABASE IF EXISTS ygeiopolis;
CREATE DATABASE ygeiopolis CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ygeiopolis;

SET sql_mode = 'STRICT_ALL_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE TABLE staff (
  staff_id INT AUTO_INCREMENT PRIMARY KEY,
  amka VARCHAR(11) NOT NULL UNIQUE,
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  age INT NOT NULL CHECK (age BETWEEN 18 AND 75),
  email VARCHAR(160) NOT NULL UNIQUE,
  phone VARCHAR(40) NOT NULL,
  hire_date DATE NOT NULL,
  staff_type VARCHAR(20) NOT NULL CHECK (staff_type IN ('DOCTOR','NURSE','ADMIN'))
) ENGINE=InnoDB;

CREATE TABLE doctor (
  staff_id INT PRIMARY KEY,
  license_number VARCHAR(40) NOT NULL UNIQUE,
  specialty VARCHAR(80) NOT NULL,
  doctor_rank VARCHAR(40) NOT NULL CHECK (doctor_rank IN ('Ειδικευόμενος','Επιμελητής Β','Επιμελητής Α','Διευθυντής')),
  supervisor_id INT NULL,
  CONSTRAINT fk_doctor_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE,
  CONSTRAINT fk_doctor_supervisor FOREIGN KEY (supervisor_id) REFERENCES doctor(staff_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE department (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NOT NULL,
  beds_count INT NOT NULL CHECK (beds_count >= 0),
  floor_building VARCHAR(80) NOT NULL,
  director_doctor_id INT NULL,
  CONSTRAINT fk_department_director FOREIGN KEY (director_doctor_id) REFERENCES doctor(staff_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE doctor_department (
  doctor_id INT NOT NULL,
  department_id INT NOT NULL,
  PRIMARY KEY (doctor_id, department_id),
  CONSTRAINT fk_docdep_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(staff_id) ON DELETE CASCADE,
  CONSTRAINT fk_docdep_department FOREIGN KEY (department_id) REFERENCES department(department_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE nurse (
  staff_id INT PRIMARY KEY,
  nurse_rank VARCHAR(40) NOT NULL CHECK (nurse_rank IN ('Βοηθός Νοσηλευτή','Νοσηλευτής','Προϊστάμενος')),
  department_id INT NOT NULL,
  CONSTRAINT fk_nurse_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE,
  CONSTRAINT fk_nurse_department FOREIGN KEY (department_id) REFERENCES department(department_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE admin_staff (
  staff_id INT PRIMARY KEY,
  admin_role VARCHAR(80) NOT NULL,
  office VARCHAR(80) NOT NULL,
  department_id INT NOT NULL,
  CONSTRAINT fk_admin_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE,
  CONSTRAINT fk_admin_department FOREIGN KEY (department_id) REFERENCES department(department_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE bed (
  bed_id INT AUTO_INCREMENT PRIMARY KEY,
  department_id INT NOT NULL,
  bed_number VARCHAR(40) NOT NULL UNIQUE,
  bed_type VARCHAR(40) NOT NULL CHECK (bed_type IN ('ΜΕΘ','Μονόκλινο','Πολύκλινο')),
  bed_status VARCHAR(40) NOT NULL CHECK (bed_status IN ('Διαθέσιμη','Κατειλημμένη','Υπό συντήρηση')),
  CONSTRAINT fk_bed_department FOREIGN KEY (department_id) REFERENCES department(department_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE insurance_provider (
  insurance_provider_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE patient (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  amka VARCHAR(11) NOT NULL UNIQUE,
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  father_name VARCHAR(80) NOT NULL,
  age INT NOT NULL CHECK (age BETWEEN 0 AND 120),
  gender VARCHAR(20) NOT NULL CHECK (gender IN ('Άνδρας','Γυναίκα','Άλλο')),
  weight_kg DECIMAL(5,2) NOT NULL CHECK (weight_kg > 0),
  height_cm DECIMAL(5,2) NOT NULL CHECK (height_cm > 0),
  address VARCHAR(220) NOT NULL,
  phone VARCHAR(40) NOT NULL,
  email VARCHAR(160) NOT NULL,
  profession VARCHAR(100) NOT NULL,
  nationality VARCHAR(80) NOT NULL,
  insurance_provider_id INT NOT NULL,
  CONSTRAINT fk_patient_insurance FOREIGN KEY (insurance_provider_id) REFERENCES insurance_provider(insurance_provider_id)
) ENGINE=InnoDB;

CREATE TABLE patient_emergency_contact (
  contact_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  full_name VARCHAR(160) NOT NULL,
  relationship VARCHAR(80) NOT NULL,
  phone VARCHAR(40) NOT NULL,
  CONSTRAINT fk_contact_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE icd10_code (
  icd10_code VARCHAR(12) PRIMARY KEY,
  category_code VARCHAR(8) NOT NULL,
  description VARCHAR(500) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE ken_code (
  ken_code VARCHAR(20) PRIMARY KEY,
  description VARCHAR(500) NOT NULL,
  base_cost DECIMAL(12,2) NOT NULL CHECK (base_cost >= 0),
  mdn_days INT NOT NULL CHECK (mdn_days > 0),
  daily_extra_cost DECIMAL(12,2) NOT NULL CHECK (daily_extra_cost >= 0)
) ENGINE=InnoDB;

CREATE TABLE hospitalization (
  hospitalization_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  department_id INT NOT NULL,
  bed_id INT NOT NULL,
  admission_date DATETIME NOT NULL,
  discharge_date DATETIME NULL,
  admission_icd10_code VARCHAR(12) NOT NULL,
  discharge_icd10_code VARCHAR(12) NULL,
  ken_code VARCHAR(20) NOT NULL,
  total_cost DECIMAL(12,2) NOT NULL CHECK (total_cost >= 0),
  CHECK (discharge_date IS NULL OR discharge_date > admission_date),
  CONSTRAINT fk_hosp_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
  CONSTRAINT fk_hosp_department FOREIGN KEY (department_id) REFERENCES department(department_id),
  CONSTRAINT fk_hosp_bed FOREIGN KEY (bed_id) REFERENCES bed(bed_id),
  CONSTRAINT fk_hosp_adm_icd FOREIGN KEY (admission_icd10_code) REFERENCES icd10_code(icd10_code),
  CONSTRAINT fk_hosp_dis_icd FOREIGN KEY (discharge_icd10_code) REFERENCES icd10_code(icd10_code),
  CONSTRAINT fk_hosp_ken FOREIGN KEY (ken_code) REFERENCES ken_code(ken_code)
) ENGINE=InnoDB;

CREATE TABLE triage_case (
  triage_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  triage_nurse_id INT NOT NULL,
  arrival_time DATETIME NOT NULL,
  triage_time DATETIME NOT NULL,
  symptoms TEXT NOT NULL,
  urgency_level INT NOT NULL CHECK (urgency_level BETWEEN 1 AND 5),
  service_start_time DATETIME NOT NULL,
  outcome VARCHAR(40) NOT NULL CHECK (outcome IN ('Οδηγίες και έξοδος','Παραπομπή για νοσηλεία')),
  hospitalization_id INT NULL,
  referred_department_id INT NULL,
  CHECK (triage_time >= arrival_time),
  CHECK (service_start_time >= triage_time),
  CONSTRAINT fk_triage_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
  CONSTRAINT fk_triage_nurse FOREIGN KEY (triage_nurse_id) REFERENCES nurse(staff_id),
  CONSTRAINT fk_triage_hosp FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
  CONSTRAINT fk_triage_department FOREIGN KEY (referred_department_id) REFERENCES department(department_id)
) ENGINE=InnoDB;

CREATE TABLE lab_test (
  lab_test_id INT AUTO_INCREMENT PRIMARY KEY,
  hospitalization_id INT NOT NULL,
  test_code VARCHAR(40) NOT NULL,
  test_type VARCHAR(80) NOT NULL,
  test_date DATETIME NOT NULL,
  result_text TEXT NULL,
  result_value DECIMAL(12,4) NULL,
  unit VARCHAR(40) NULL,
  cost DECIMAL(12,2) NOT NULL CHECK (cost >= 0),
  ordered_by_doctor_id INT NOT NULL,
  CONSTRAINT fk_lab_hosp FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id) ON DELETE CASCADE,
  CONSTRAINT fk_lab_doctor FOREIGN KEY (ordered_by_doctor_id) REFERENCES doctor(staff_id)
) ENGINE=InnoDB;

CREATE TABLE procedure_catalog (
  procedure_code VARCHAR(40) PRIMARY KEY,
  name VARCHAR(300) NOT NULL,
  category VARCHAR(40) NOT NULL CHECK (category IN ('Χειρουργική','Διαγνωστική','Θεραπευτική')),
  duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
  cost DECIMAL(12,2) NOT NULL CHECK (cost >= 0),
  required_room_type VARCHAR(40) NOT NULL CHECK (required_room_type IN ('Χειρουργείο','Αίθουσα επέμβασης'))
) ENGINE=InnoDB;

CREATE TABLE procedure_room (
  room_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  room_type VARCHAR(40) NOT NULL CHECK (room_type IN ('Χειρουργείο','Αίθουσα επέμβασης'))
) ENGINE=InnoDB;

CREATE TABLE medical_procedure (
  medical_procedure_id INT AUTO_INCREMENT PRIMARY KEY,
  hospitalization_id INT NOT NULL,
  procedure_code VARCHAR(40) NOT NULL,
  room_id INT NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  main_surgeon_id INT NOT NULL,
  CHECK (end_time > start_time),
  CONSTRAINT fk_medproc_hosp FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id) ON DELETE CASCADE,
  CONSTRAINT fk_medproc_catalog FOREIGN KEY (procedure_code) REFERENCES procedure_catalog(procedure_code),
  CONSTRAINT fk_medproc_room FOREIGN KEY (room_id) REFERENCES procedure_room(room_id),
  CONSTRAINT fk_medproc_surgeon FOREIGN KEY (main_surgeon_id) REFERENCES doctor(staff_id)
) ENGINE=InnoDB;

CREATE TABLE procedure_assistant (
  medical_procedure_id INT NOT NULL,
  staff_id INT NOT NULL,
  assistant_role VARCHAR(80) NOT NULL,
  PRIMARY KEY (medical_procedure_id, staff_id),
  CONSTRAINT fk_assistant_proc FOREIGN KEY (medical_procedure_id) REFERENCES medical_procedure(medical_procedure_id) ON DELETE CASCADE,
  CONSTRAINT fk_assistant_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
) ENGINE=InnoDB;

CREATE TABLE drug (
  drug_id INT AUTO_INCREMENT PRIMARY KEY,
  ema_product_id VARCHAR(80) NOT NULL UNIQUE,
  drug_name VARCHAR(300) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE active_substance (
  substance_id INT AUTO_INCREMENT PRIMARY KEY,
  substance_name VARCHAR(220) NOT NULL UNIQUE,
  normalized_name VARCHAR(220) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE drug_active_substance (
  drug_id INT NOT NULL,
  substance_id INT NOT NULL,
  PRIMARY KEY (drug_id, substance_id),
  CONSTRAINT fk_drug_sub_drug FOREIGN KEY (drug_id) REFERENCES drug(drug_id) ON DELETE CASCADE,
  CONSTRAINT fk_drug_sub_substance FOREIGN KEY (substance_id) REFERENCES active_substance(substance_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE patient_allergy (
  patient_id INT NOT NULL,
  substance_id INT NOT NULL,
  PRIMARY KEY (patient_id, substance_id),
  CONSTRAINT fk_allergy_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE,
  CONSTRAINT fk_allergy_substance FOREIGN KEY (substance_id) REFERENCES active_substance(substance_id)
) ENGINE=InnoDB;

CREATE TABLE prescription (
  prescription_id INT AUTO_INCREMENT PRIMARY KEY,
  hospitalization_id INT NOT NULL,
  doctor_id INT NOT NULL,
  patient_id INT NOT NULL,
  drug_id INT NOT NULL,
  dosage VARCHAR(100) NOT NULL,
  frequency VARCHAR(100) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NULL,
  CHECK (end_date IS NULL OR end_date >= start_date),
  UNIQUE KEY uq_prescription_identity (doctor_id, patient_id, drug_id, start_date),
  CONSTRAINT fk_presc_hosp FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id) ON DELETE CASCADE,
  CONSTRAINT fk_presc_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(staff_id),
  CONSTRAINT fk_presc_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
  CONSTRAINT fk_presc_drug FOREIGN KEY (drug_id) REFERENCES drug(drug_id)
) ENGINE=InnoDB;

CREATE TABLE hospitalization_review (
  review_id INT AUTO_INCREMENT PRIMARY KEY,
  hospitalization_id INT NOT NULL UNIQUE,
  patient_id INT NOT NULL,
  nursing_care_rating INT NOT NULL CHECK (nursing_care_rating BETWEEN 1 AND 5),
  cleanliness_rating INT NOT NULL CHECK (cleanliness_rating BETWEEN 1 AND 5),
  food_rating INT NOT NULL CHECK (food_rating BETWEEN 1 AND 5),
  overall_experience_rating INT NOT NULL CHECK (overall_experience_rating BETWEEN 1 AND 5),
  review_date DATE NOT NULL,
  CONSTRAINT fk_hreview_hosp FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id) ON DELETE CASCADE,
  CONSTRAINT fk_hreview_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
) ENGINE=InnoDB;

CREATE TABLE doctor_review (
  review_id INT AUTO_INCREMENT PRIMARY KEY,
  hospitalization_id INT NOT NULL,
  patient_id INT NOT NULL,
  doctor_id INT NOT NULL,
  medical_care_rating INT NOT NULL CHECK (medical_care_rating BETWEEN 1 AND 5),
  review_date DATE NOT NULL,
  UNIQUE KEY uq_doctor_review (hospitalization_id, doctor_id),
  CONSTRAINT fk_dreview_hosp FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id) ON DELETE CASCADE,
  CONSTRAINT fk_dreview_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
  CONSTRAINT fk_dreview_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(staff_id)
) ENGINE=InnoDB;

CREATE TABLE shift (
  shift_id INT AUTO_INCREMENT PRIMARY KEY,
  department_id INT NOT NULL,
  shift_date DATE NOT NULL,
  shift_type VARCHAR(20) NOT NULL CHECK (shift_type IN ('Πρωινή','Απογευματινή','Νυχτερινή')),
  start_at DATETIME NOT NULL,
  end_at DATETIME NOT NULL,
  is_finalized TINYINT NOT NULL DEFAULT 0 CHECK (is_finalized IN (0,1)),
  UNIQUE KEY uq_department_shift (department_id, shift_date, shift_type),
  CHECK (end_at > start_at),
  CONSTRAINT fk_shift_department FOREIGN KEY (department_id) REFERENCES department(department_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE shift_staff (
  shift_id INT NOT NULL,
  staff_id INT NOT NULL,
  PRIMARY KEY (shift_id, staff_id),
  CONSTRAINT fk_shift_staff_shift FOREIGN KEY (shift_id) REFERENCES shift(shift_id) ON DELETE CASCADE,
  CONSTRAINT fk_shift_staff_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE entity_image (
  image_id INT AUTO_INCREMENT PRIMARY KEY,
  entity_type VARCHAR(60) NOT NULL,
  entity_id INT NOT NULL,
  image_url VARCHAR(500) NOT NULL,
  alt_text VARCHAR(500) NOT NULL
) ENGINE=InnoDB;

CREATE INDEX idx_staff_type ON staff(staff_type);
CREATE INDEX idx_doctor_specialty ON doctor(specialty);
CREATE INDEX idx_doctor_rank ON doctor(doctor_rank);
CREATE INDEX idx_doctor_supervisor ON doctor(supervisor_id);
CREATE INDEX idx_hosp_patient_date ON hospitalization(patient_id, admission_date);
CREATE INDEX idx_hosp_department_date ON hospitalization(department_id, admission_date);
CREATE INDEX idx_hosp_ken ON hospitalization(ken_code);
CREATE INDEX idx_hosp_admission_icd ON hospitalization(admission_icd10_code);
CREATE INDEX idx_triage_priority ON triage_case(urgency_level, arrival_time);
CREATE INDEX idx_lab_hosp_date ON lab_test(hospitalization_id, test_date);
CREATE INDEX idx_medproc_surgeon_start ON medical_procedure(main_surgeon_id, start_time);
CREATE INDEX idx_medproc_room_time ON medical_procedure(room_id, start_time, end_time);
CREATE INDEX idx_presc_doctor_start ON prescription(doctor_id, start_date);
CREATE INDEX idx_presc_patient_hosp ON prescription(patient_id, hospitalization_id);
CREATE INDEX idx_review_doctor ON doctor_review(doctor_id, medical_care_rating);
CREATE INDEX idx_review_hosp_patient ON hospitalization_review(patient_id, overall_experience_rating);
CREATE INDEX idx_hreview_hosp_overall ON hospitalization_review(hospitalization_id, overall_experience_rating);
CREATE INDEX idx_shift_date_department ON shift(shift_date, department_id);
CREATE INDEX idx_shift_staff_staff ON shift_staff(staff_id, shift_id);
CREATE INDEX idx_substance_normalized ON active_substance(normalized_name);

DELIMITER $$

CREATE PROCEDURE assert_doctor_supervisor(
  IN p_doctor_id INT,
  IN p_supervisor_id INT,
  IN p_rank VARCHAR(40)
)
BEGIN
  DECLARE v_current_supervisor INT;
  DECLARE v_next_supervisor INT;
  IF p_rank = 'Ειδικευόμενος' AND p_supervisor_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Resident doctors must have a supervisor';
  END IF;
  IF p_rank = 'Διευθυντής' AND p_supervisor_id IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Director doctors cannot have a supervisor';
  END IF;
  IF p_supervisor_id = p_doctor_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor cannot supervise self';
  END IF;
  SET v_current_supervisor = p_supervisor_id;
  WHILE v_current_supervisor IS NOT NULL DO
    IF v_current_supervisor = p_doctor_id THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Circular doctor supervision is forbidden';
    END IF;
    SELECT supervisor_id INTO v_next_supervisor
    FROM doctor
    WHERE staff_id = v_current_supervisor;
    SET v_current_supervisor = v_next_supervisor;
  END WHILE;
END$$

CREATE TRIGGER trg_doctor_bi BEFORE INSERT ON doctor
FOR EACH ROW
BEGIN
  CALL assert_doctor_supervisor(NEW.staff_id, NEW.supervisor_id, NEW.doctor_rank);
END$$

CREATE TRIGGER trg_doctor_bu BEFORE UPDATE ON doctor
FOR EACH ROW
BEGIN
  CALL assert_doctor_supervisor(NEW.staff_id, NEW.supervisor_id, NEW.doctor_rank);
END$$

CREATE PROCEDURE assert_prescription_allowed(
  IN p_hospitalization_id INT,
  IN p_patient_id INT,
  IN p_drug_id INT
)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM hospitalization h
    WHERE h.hospitalization_id = p_hospitalization_id AND h.patient_id = p_patient_id
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Prescription patient must match hospitalization patient';
  END IF;
  IF EXISTS (
    SELECT 1
    FROM drug_active_substance das
    JOIN patient_allergy pa ON pa.substance_id = das.substance_id
    WHERE das.drug_id = p_drug_id AND pa.patient_id = p_patient_id
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Drug contains an active substance listed as patient allergy';
  END IF;
END$$

CREATE TRIGGER trg_prescription_bi BEFORE INSERT ON prescription
FOR EACH ROW
BEGIN
  CALL assert_prescription_allowed(NEW.hospitalization_id, NEW.patient_id, NEW.drug_id);
END$$

CREATE TRIGGER trg_prescription_bu BEFORE UPDATE ON prescription
FOR EACH ROW
BEGIN
  CALL assert_prescription_allowed(NEW.hospitalization_id, NEW.patient_id, NEW.drug_id);
END$$

CREATE PROCEDURE assert_review_hospitalization(
  IN p_hospitalization_id INT,
  IN p_patient_id INT
)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM hospitalization
    WHERE hospitalization_id = p_hospitalization_id
      AND patient_id = p_patient_id
      AND discharge_date IS NOT NULL
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Review is allowed only after completed hospitalization';
  END IF;
END$$

CREATE TRIGGER trg_hreview_bi BEFORE INSERT ON hospitalization_review
FOR EACH ROW
BEGIN
  CALL assert_review_hospitalization(NEW.hospitalization_id, NEW.patient_id);
END$$

CREATE TRIGGER trg_dreview_bi BEFORE INSERT ON doctor_review
FOR EACH ROW
BEGIN
  CALL assert_review_hospitalization(NEW.hospitalization_id, NEW.patient_id);
  IF NOT EXISTS (
    SELECT 1 FROM prescription
    WHERE hospitalization_id = NEW.hospitalization_id
      AND patient_id = NEW.patient_id
      AND doctor_id = NEW.doctor_id
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor review requires a prescription by that doctor in the hospitalization';
  END IF;
END$$

CREATE PROCEDURE assert_medical_procedure_slot(
  IN p_medical_procedure_id INT,
  IN p_room_id INT,
  IN p_start_time DATETIME,
  IN p_end_time DATETIME,
  IN p_main_surgeon_id INT
)
BEGIN
  IF EXISTS (
    SELECT 1 FROM medical_procedure mp
    WHERE mp.room_id = p_room_id
      AND mp.medical_procedure_id <> COALESCE(p_medical_procedure_id, -1)
      AND mp.start_time < p_end_time
      AND p_start_time < mp.end_time
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Procedure room has overlapping procedure';
  END IF;
  IF EXISTS (
    SELECT 1 FROM medical_procedure mp
    WHERE mp.medical_procedure_id <> COALESCE(p_medical_procedure_id, -1)
      AND mp.start_time < p_end_time
      AND p_start_time < mp.end_time
      AND (
        mp.main_surgeon_id = p_main_surgeon_id
        OR EXISTS (
          SELECT 1 FROM procedure_assistant pa
          WHERE pa.medical_procedure_id = mp.medical_procedure_id
            AND pa.staff_id = p_main_surgeon_id
        )
      )
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor has overlapping procedure';
  END IF;
END$$

CREATE TRIGGER trg_medproc_bi BEFORE INSERT ON medical_procedure
FOR EACH ROW
BEGIN
  CALL assert_medical_procedure_slot(NULL, NEW.room_id, NEW.start_time, NEW.end_time, NEW.main_surgeon_id);
END$$

CREATE TRIGGER trg_medproc_bu BEFORE UPDATE ON medical_procedure
FOR EACH ROW
BEGIN
  CALL assert_medical_procedure_slot(NEW.medical_procedure_id, NEW.room_id, NEW.start_time, NEW.end_time, NEW.main_surgeon_id);
END$$

CREATE TRIGGER trg_assistant_bi BEFORE INSERT ON procedure_assistant
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
    FROM medical_procedure target_proc
    JOIN medical_procedure other_proc
      ON other_proc.medical_procedure_id <> target_proc.medical_procedure_id
     AND other_proc.start_time < target_proc.end_time
     AND target_proc.start_time < other_proc.end_time
    WHERE target_proc.medical_procedure_id = NEW.medical_procedure_id
      AND (
        other_proc.main_surgeon_id = NEW.staff_id
        OR EXISTS (
          SELECT 1 FROM procedure_assistant pa
          WHERE pa.medical_procedure_id = other_proc.medical_procedure_id
            AND pa.staff_id = NEW.staff_id
        )
      )
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Assistant has overlapping procedure';
  END IF;
END$$

CREATE PROCEDURE assert_shift_staff_allowed(
  IN p_shift_id INT,
  IN p_staff_id INT
)
BEGIN
  DECLARE v_staff_type VARCHAR(20);
  DECLARE v_start DATETIME;
  DECLARE v_end DATETIME;
  DECLARE v_shift_date DATE;
  DECLARE v_shift_type VARCHAR(20);
  DECLARE v_month_count INT;
  DECLARE v_month_limit INT;

  SELECT staff_type INTO v_staff_type FROM staff WHERE staff_id = p_staff_id;
  SELECT start_at, end_at, shift_date, shift_type INTO v_start, v_end, v_shift_date, v_shift_type
  FROM shift WHERE shift_id = p_shift_id;

  SET v_month_limit = CASE v_staff_type WHEN 'DOCTOR' THEN 15 WHEN 'NURSE' THEN 20 ELSE 25 END;
  SELECT COUNT(*) INTO v_month_count
  FROM shift_staff ss
  JOIN shift s ON s.shift_id = ss.shift_id
  WHERE ss.staff_id = p_staff_id
    AND ss.shift_id <> p_shift_id
    AND YEAR(s.shift_date) = YEAR(v_shift_date)
    AND MONTH(s.shift_date) = MONTH(v_shift_date);
  IF v_month_count + 1 > v_month_limit THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Monthly shift limit exceeded';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM shift_staff ss
    JOIN shift s ON s.shift_id = ss.shift_id
    WHERE ss.staff_id = p_staff_id
      AND ss.shift_id <> p_shift_id
      AND s.end_at > DATE_SUB(v_start, INTERVAL 8 HOUR)
      AND s.start_at < DATE_ADD(v_end, INTERVAL 8 HOUR)
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Minimum 8-hour rest interval violated';
  END IF;

  IF v_shift_type = 'Νυχτερινή'
     AND EXISTS (
       SELECT 1
       FROM shift_staff ss1
       JOIN shift s1 ON s1.shift_id = ss1.shift_id
       JOIN shift_staff ss2 ON ss2.staff_id = ss1.staff_id
       JOIN shift s2 ON s2.shift_id = ss2.shift_id
       JOIN shift_staff ss3 ON ss3.staff_id = ss1.staff_id
       JOIN shift s3 ON s3.shift_id = ss3.shift_id
       WHERE ss1.staff_id = p_staff_id
         AND s1.shift_type = 'Νυχτερινή'
         AND s2.shift_type = 'Νυχτερινή'
         AND s3.shift_type = 'Νυχτερινή'
         AND s1.shift_date = DATE_SUB(v_shift_date, INTERVAL 1 DAY)
         AND s2.shift_date = DATE_SUB(v_shift_date, INTERVAL 2 DAY)
         AND s3.shift_date = DATE_SUB(v_shift_date, INTERVAL 3 DAY)
     ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'More than 3 consecutive night shifts are forbidden';
  END IF;
END$$

CREATE TRIGGER trg_shift_staff_bi BEFORE INSERT ON shift_staff
FOR EACH ROW
BEGIN
  CALL assert_shift_staff_allowed(NEW.shift_id, NEW.staff_id);
END$$

CREATE TRIGGER trg_shift_bu BEFORE UPDATE ON shift
FOR EACH ROW
BEGIN
  IF OLD.is_finalized = 0 AND NEW.is_finalized = 1 THEN
    IF (SELECT COUNT(*) FROM shift_staff ss JOIN staff st ON st.staff_id = ss.staff_id WHERE ss.shift_id = NEW.shift_id AND st.staff_type = 'DOCTOR') < 3 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Finalized shift needs at least 3 doctors';
    END IF;
    IF (SELECT COUNT(*) FROM shift_staff ss JOIN staff st ON st.staff_id = ss.staff_id WHERE ss.shift_id = NEW.shift_id AND st.staff_type = 'NURSE') < 6 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Finalized shift needs at least 6 nurses';
    END IF;
    IF (SELECT COUNT(*) FROM shift_staff ss JOIN staff st ON st.staff_id = ss.staff_id WHERE ss.shift_id = NEW.shift_id AND st.staff_type = 'ADMIN') < 2 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Finalized shift needs at least 2 administrators';
    END IF;
    IF EXISTS (
      SELECT 1 FROM shift_staff ss JOIN doctor d ON d.staff_id = ss.staff_id
      WHERE ss.shift_id = NEW.shift_id AND d.doctor_rank = 'Ειδικευόμενος'
    ) AND NOT EXISTS (
      SELECT 1 FROM shift_staff ss JOIN doctor d ON d.staff_id = ss.staff_id
      WHERE ss.shift_id = NEW.shift_id AND d.doctor_rank IN ('Επιμελητής Α','Διευθυντής')
    ) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Resident shift needs senior doctor present';
    END IF;
  END IF;
END$$

DELIMITER ;
