USE ygeiopolis;

SELECT
  d.staff_id AS doctor_id,
  s.first_name,
  s.last_name,
  s.age,
  d.specialty,
  COUNT(mp.medical_procedure_id) AS surgical_procedures_as_main_surgeon
FROM doctor d
JOIN staff s ON s.staff_id = d.staff_id
JOIN medical_procedure mp ON mp.main_surgeon_id = d.staff_id
JOIN procedure_catalog pc ON pc.procedure_code = mp.procedure_code
WHERE s.age < 35
  AND pc.category = 'Χειρουργική'
GROUP BY d.staff_id, s.first_name, s.last_name, s.age, d.specialty
ORDER BY surgical_procedures_as_main_surgeon DESC, s.last_name, s.first_name;
