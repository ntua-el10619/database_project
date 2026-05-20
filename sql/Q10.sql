USE ygeiopolis;

WITH hospitalization_substances AS (
  SELECT DISTINCT
    pr.hospitalization_id,
    pr.patient_id,
    das.substance_id,
    a.substance_name
  FROM prescription pr
  JOIN drug_active_substance das ON das.drug_id = pr.drug_id
  JOIN active_substance a ON a.substance_id = das.substance_id
),
substance_pairs AS (
  SELECT
    hs1.substance_id AS substance_id_1,
    hs1.substance_name AS substance_1,
    hs2.substance_id AS substance_id_2,
    hs2.substance_name AS substance_2,
    COUNT(*) AS co_prescription_frequency
  FROM hospitalization_substances hs1
  JOIN hospitalization_substances hs2
    ON hs2.hospitalization_id = hs1.hospitalization_id
   AND hs2.patient_id = hs1.patient_id
   AND hs1.substance_id < hs2.substance_id
  GROUP BY hs1.substance_id, hs1.substance_name, hs2.substance_id, hs2.substance_name
)
SELECT substance_1, substance_2, co_prescription_frequency
FROM substance_pairs
ORDER BY co_prescription_frequency DESC, substance_1, substance_2
LIMIT 3;
