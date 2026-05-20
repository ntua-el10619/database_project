USE ygeiopolis;
SET @target_year := 2026;

WITH patient_year_days AS (
  SELECT
    h.patient_id,
    SUM(DATEDIFF(COALESCE(h.discharge_date, CURRENT_DATE()), h.admission_date)) AS total_days
  FROM hospitalization h
  WHERE YEAR(h.admission_date) = @target_year
  GROUP BY h.patient_id
  HAVING total_days > 15
)
SELECT
  pyd.total_days,
  p.patient_id,
  p.amka,
  p.first_name,
  p.last_name
FROM patient_year_days pyd
JOIN patient p ON p.patient_id = pyd.patient_id
WHERE EXISTS (
  SELECT 1
  FROM patient_year_days other_pyd
  WHERE other_pyd.total_days = pyd.total_days
    AND other_pyd.patient_id <> pyd.patient_id
)
ORDER BY pyd.total_days DESC, p.last_name, p.first_name;
