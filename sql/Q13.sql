USE ygeiopolis;

WITH RECURSIVE supervisor_hierarchy AS (
  SELECT
    d.staff_id AS doctor_id,
    d.supervisor_id,
    1 AS hierarchy_level
  FROM doctor d
  WHERE d.supervisor_id IS NOT NULL
  UNION ALL
  SELECT
    sh.doctor_id,
    d.supervisor_id,
    sh.hierarchy_level + 1
  FROM supervisor_hierarchy sh
  JOIN doctor d ON d.staff_id = sh.supervisor_id
  WHERE d.supervisor_id IS NOT NULL
)
SELECT
  sh.doctor_id,
  ds.first_name AS doctor_first_name,
  ds.last_name AS doctor_last_name,
  sh.hierarchy_level,
  sh.supervisor_id,
  ss.first_name AS supervisor_first_name,
  ss.last_name AS supervisor_last_name,
  sd.doctor_rank AS supervisor_rank
FROM supervisor_hierarchy sh
JOIN staff ds ON ds.staff_id = sh.doctor_id
JOIN doctor sd ON sd.staff_id = sh.supervisor_id
JOIN staff ss ON ss.staff_id = sh.supervisor_id
ORDER BY sh.doctor_id, sh.hierarchy_level;
