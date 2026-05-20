USE ygeiopolis;
SET @specialty := 'Καρδιολογία';

SELECT
  d.staff_id AS doctor_id,
  s.first_name,
  s.last_name,
  d.specialty,
  d.doctor_rank,
  CASE WHEN COUNT(DISTINCT sh.shift_id) > 0 THEN 'Ναι' ELSE 'Όχι' END AS had_shift_current_year,
  COUNT(DISTINCT mp.medical_procedure_id) AS main_surgeon_procedures
FROM doctor d
JOIN staff s ON s.staff_id = d.staff_id
LEFT JOIN shift_staff ss ON ss.staff_id = d.staff_id
LEFT JOIN shift sh ON sh.shift_id = ss.shift_id AND YEAR(sh.shift_date) = YEAR(CURRENT_DATE())
LEFT JOIN medical_procedure mp ON mp.main_surgeon_id = d.staff_id
WHERE d.specialty = @specialty
GROUP BY d.staff_id, s.first_name, s.last_name, d.specialty, d.doctor_rank
ORDER BY main_surgeon_procedures DESC, s.last_name, s.first_name;
