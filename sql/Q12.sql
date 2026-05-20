USE ygeiopolis;
SET @week_start := DATE('2026-05-04');

SELECT
  dep.name AS department,
  sh.shift_date,
  sh.shift_type,
  CASE
    WHEN st.staff_type = 'DOCTOR' THEN CONCAT('Ιατροί - ', d.specialty)
    WHEN st.staff_type = 'NURSE' THEN CONCAT('Νοσηλευτές - ', n.nurse_rank)
    ELSE CONCAT('Διοικητικοί - ', a.admin_role)
  END AS staff_subclass,
  COUNT(*) AS required_staff_count
FROM shift sh
JOIN department dep ON dep.department_id = sh.department_id
JOIN shift_staff ss ON ss.shift_id = sh.shift_id
JOIN staff st ON st.staff_id = ss.staff_id
LEFT JOIN doctor d ON d.staff_id = st.staff_id
LEFT JOIN nurse n ON n.staff_id = st.staff_id
LEFT JOIN admin_staff a ON a.staff_id = st.staff_id
WHERE sh.shift_date >= @week_start
  AND sh.shift_date < DATE_ADD(@week_start, INTERVAL 7 DAY)
GROUP BY dep.name, sh.shift_date, sh.shift_type, staff_subclass
ORDER BY dep.name, sh.shift_date, sh.shift_type, staff_subclass;
