USE ygeiopolis;

SELECT
  d.name AS department,
  YEAR(h.discharge_date) AS revenue_year,
  h.ken_code,
  kc.description AS ken_description,
  ip.name AS insurance_provider,
  COUNT(*) AS hospitalization_count,
  SUM(kc.base_cost) AS base_revenue,
  SUM(GREATEST(0, DATEDIFF(h.discharge_date, h.admission_date) - kc.mdn_days) * kc.daily_extra_cost) AS extra_revenue,
  SUM(h.total_cost) AS total_revenue
FROM hospitalization h
JOIN department d ON d.department_id = h.department_id
JOIN ken_code kc ON kc.ken_code = h.ken_code
JOIN patient p ON p.patient_id = h.patient_id
JOIN insurance_provider ip ON ip.insurance_provider_id = p.insurance_provider_id
WHERE h.discharge_date IS NOT NULL
GROUP BY d.department_id, d.name, YEAR(h.discharge_date), h.ken_code, kc.description, ip.name
ORDER BY revenue_year, d.name, h.ken_code, ip.name;
