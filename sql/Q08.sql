USE ygeiopolis;
SET @target_date := DATE('2026-05-04');
SET @department_id := 1;

SELECT
  st.staff_id,
  st.first_name,
  st.last_name,
  st.staff_type,
  COALESCE(d.specialty, n.nurse_rank, a.admin_role) AS subclass
FROM staff st
LEFT JOIN doctor d ON d.staff_id = st.staff_id
LEFT JOIN nurse n ON n.staff_id = st.staff_id
LEFT JOIN admin_staff a ON a.staff_id = st.staff_id
WHERE NOT EXISTS (
  SELECT 1
  FROM shift_staff ss
  JOIN shift sh ON sh.shift_id = ss.shift_id
  WHERE ss.staff_id = st.staff_id
    AND sh.shift_date = @target_date
    AND sh.department_id = @department_id
)
ORDER BY st.staff_type, st.last_name, st.first_name;
