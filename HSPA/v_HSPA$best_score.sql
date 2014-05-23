USE KIPP_NJ
GO

ALTER VIEW HSPA$best_score AS

WITH hspa_math AS (
  SELECT SID
        ,MAX(math_scale_score) AS math_scale_score        
  FROM HSPA$scaled_scores_roster hspa WITH(NOLOCK)
  WHERE Math_scale_score IS NOT NULL
  GROUP BY SID
 )
 
,hspa_reading AS (
  SELECT SID
        ,MAX(LAL_scale_score) AS lal_scale_score        
  FROM HSPA$scaled_scores_roster hspa WITH(NOLOCK)
  WHERE LAL_scale_score IS NOT NULL
  GROUP BY SID
 )
 
SELECT cs.SID
      ,hspa_math.math_scale_score
      ,CASE
        WHEN hspa_math.math_scale_score >= 250 THEN 'Advanced Proficient'
        WHEN hspa_math.math_scale_score >= 200 AND hspa_math.math_scale_score < 250 THEN 'Proficient'
        WHEN hspa_math.math_scale_score < 200 THEN 'Partially Proficient'        
       END AS Math_proficiency
      ,hspa_reading.lal_scale_score
      ,CASE
        WHEN hspa_reading.lal_scale_score >= 250 THEN 'Advanced Proficient'
        WHEN hspa_reading.lal_scale_score >= 200 AND hspa_reading.lal_scale_score < 250 THEN 'Proficient'
        WHEN hspa_reading.lal_scale_score < 200 THEN 'Partially Proficient'        
       END AS lal_proficiency
FROM STUDENTS s WITH(NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.ID = cs.STUDENTID 
LEFT OUTER JOIN hspa_math WITH(NOLOCK)
  ON cs.SID = hspa_math.SID
LEFT OUTER JOIN hspa_reading WITH(NOLOCK)
  ON cs.SID = hspa_reading.SID
WHERE s.SCHOOLID = 73253
  AND s.GRADE_LEVEL >= 11
  AND cs.SID IS NOT NULL