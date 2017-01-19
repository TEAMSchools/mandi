USE KIPP_NJ
GO

ALTER VIEW DL$map_scores#extract AS

SELECT co.student_number      
      ,CASE WHEN terms.term = 'Fall' THEN co.year ELSE co.year + 1 END AS test_year
      ,terms.term
      ,subjects.subject  
      ,map.percentile_2015_norms AS map_percentile
      ,map.testritscore AS map_ritscore
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, subjects.subject
           ORDER BY CASE WHEN terms.term = 'Fall' THEN co.year ELSE co.year + 1 END
                   ,CASE 
                     WHEN terms.term = 'Fall' THEN 3
                     WHEN terms.term = 'Winter' THEN 1
                     WHEN terms.term = 'Spring' THEN 2
                    END) AS map_index
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
CROSS JOIN (
  SELECT 'Fall' UNION  
  SELECT 'Winter' UNION
  SELECT 'Spring'
 ) terms (term)
CROSS JOIN (
  SELECT 'Mathematics' UNION  
  SELECT 'Reading' UNION
  SELECT 'Science - General Science' UNION
  SELECT 'Language Usage'
 ) subjects (subject)
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map WITH(NOLOCK)
  ON co.student_number = map.student_number
 AND co.year = map.academic_year
 AND terms.term = map.term
 AND subjects.subject = map.measurementscale
 AND map.rn = 1
WHERE co.grade_level <= 8
  AND co.enroll_status = 0
  AND co.rn = 1