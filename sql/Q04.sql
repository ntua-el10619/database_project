USE ygeiopolis;
SET @doctor_id := 2;

SELECT
  dr.doctor_id,
  ds.first_name AS doctor_first_name,
  ds.last_name AS doctor_last_name,
  AVG(dr.medical_care_rating) AS avg_medical_care_rating,
  AVG(hr.overall_experience_rating) AS avg_hospitalization_overall_rating,
  COUNT(DISTINCT dr.review_id) AS doctor_review_count
FROM doctor_review dr
JOIN staff ds ON ds.staff_id = dr.doctor_id
JOIN hospitalization_review hr
  ON hr.hospitalization_id = dr.hospitalization_id
WHERE dr.doctor_id = @doctor_id
GROUP BY dr.doctor_id, ds.first_name, ds.last_name;
