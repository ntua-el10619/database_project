USE ygeiopolis;

SELECT
  p.patient_id,
  p.amka,
  p.first_name,
  p.last_name,
  d.name AS department,
  COUNT(*) AS hospitalizations_in_department,
  SUM(h.total_cost) AS total_hospitalization_cost
FROM hospitalization h
JOIN patient p ON p.patient_id = h.patient_id
JOIN department d ON d.department_id = h.department_id
GROUP BY p.patient_id, p.amka, p.first_name, p.last_name, d.department_id, d.name
HAVING COUNT(*) > 3
ORDER BY hospitalizations_in_department DESC, total_hospitalization_cost DESC;
