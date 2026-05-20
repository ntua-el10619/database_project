USE ygeiopolis;

WITH yearly_category_counts AS (
  SELECT
    ic.category_code,
    YEAR(h.admission_date) AS admission_year,
    COUNT(*) AS admission_count
  FROM hospitalization h
  JOIN icd10_code ic ON ic.icd10_code = h.admission_icd10_code
  GROUP BY ic.category_code, YEAR(h.admission_date)
  HAVING COUNT(*) >= 5
)
SELECT
  y1.category_code,
  y1.admission_year AS year_1,
  y2.admission_year AS year_2,
  y1.admission_count AS admissions_each_year
FROM yearly_category_counts y1
JOIN yearly_category_counts y2
  ON y2.category_code = y1.category_code
 AND y2.admission_year = y1.admission_year + 1
 AND y2.admission_count = y1.admission_count
ORDER BY y1.category_code, y1.admission_year;
