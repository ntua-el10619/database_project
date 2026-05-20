USE ygeiopolis;
SET @patient_id := 1;

SELECT
  h.hospitalization_id,
  h.admission_date,
  h.discharge_date,
  dep.name AS department,
  h.admission_icd10_code,
  adm.description AS admission_diagnosis,
  h.discharge_icd10_code,
  dis.description AS discharge_diagnosis,
  h.total_cost,
  AVG(hr.overall_experience_rating) AS patient_avg_hospitalization_rating
FROM hospitalization h
JOIN department dep ON dep.department_id = h.department_id
JOIN icd10_code adm ON adm.icd10_code = h.admission_icd10_code
LEFT JOIN icd10_code dis ON dis.icd10_code = h.discharge_icd10_code
LEFT JOIN hospitalization_review hr ON hr.hospitalization_id = h.hospitalization_id
WHERE h.patient_id = @patient_id
GROUP BY h.hospitalization_id, h.admission_date, h.discharge_date, dep.name,
         h.admission_icd10_code, adm.description, h.discharge_icd10_code,
         dis.description, h.total_cost
ORDER BY h.admission_date;
