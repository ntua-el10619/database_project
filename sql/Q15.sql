USE ygeiopolis;

SELECT
  tc.urgency_level,
  COUNT(*) AS triage_case_count,
  AVG(TIMESTAMPDIFF(MINUTE, tc.arrival_time, tc.service_start_time)) AS avg_wait_minutes,
  ROUND(100 * AVG(CASE WHEN tc.hospitalization_id IS NOT NULL THEN 1 ELSE 0 END), 2) AS hospitalization_percentage,
  COALESCE(dep.name, 'Χωρίς παραπομπή') AS referral_department,
  COUNT(tc.referred_department_id) AS referral_count
FROM triage_case tc
LEFT JOIN department dep ON dep.department_id = tc.referred_department_id
GROUP BY tc.urgency_level, COALESCE(dep.name, 'Χωρίς παραπομπή')
ORDER BY tc.urgency_level, referral_count DESC, referral_department;
