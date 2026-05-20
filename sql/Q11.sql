USE ygeiopolis;

WITH current_year_counts AS (
  SELECT
    d.staff_id AS doctor_id,
    s.first_name,
    s.last_name,
    COUNT(mp.medical_procedure_id) AS procedure_count
  FROM doctor d
  JOIN staff s ON s.staff_id = d.staff_id
  LEFT JOIN medical_procedure mp
    ON mp.main_surgeon_id = d.staff_id
   AND YEAR(mp.start_time) = YEAR(CURRENT_DATE())
  GROUP BY d.staff_id, s.first_name, s.last_name
)
SELECT
  doctor_id,
  first_name,
  last_name,
  procedure_count,
  (SELECT MAX(procedure_count) FROM current_year_counts) AS top_doctor_procedure_count
FROM current_year_counts
WHERE procedure_count <= (SELECT MAX(procedure_count) FROM current_year_counts) - 5
ORDER BY procedure_count DESC, last_name, first_name;
