USE ygeiopolis;

SELECT
  a.substance_id,
  a.substance_name,
  COUNT(DISTINCT pa.patient_id) AS allergic_patient_count,
  COUNT(DISTINCT das.drug_id) AS containing_drug_count
FROM active_substance a
LEFT JOIN patient_allergy pa ON pa.substance_id = a.substance_id
LEFT JOIN drug_active_substance das ON das.substance_id = a.substance_id
GROUP BY a.substance_id, a.substance_name
ORDER BY allergic_patient_count DESC, containing_drug_count DESC, a.substance_name;
