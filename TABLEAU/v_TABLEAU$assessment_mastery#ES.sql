USE KIPP_NJ
GO

ALTER VIEW TABLEAU$assessment_mastery#ES AS

SELECT m.student_number
      ,co.school_name
      ,co.lastfirst
      ,co.grade_level
      ,co.TEAM
      ,co.SPEDLEP
      ,m.academic_year
      ,m.term
      ,m.TA_subject
      ,ROUND(AVG(CONVERT(FLOAT,m.is_mastery)) * 100,0) AS pct_stds_mastered
      ,CASE WHEN ROUND(AVG(CONVERT(FLOAT,m.is_mastery)) * 100,0) >= 80 THEN 1 ELSE 0 END AS is_8080
FROM ILLUMINATE$TA_standards_mastery m WITH(NOLOCK)
JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
  ON m.student_number = co.student_number
 AND co.year = m.academic_year
 AND co.rn = 1
GROUP BY m.student_number
        ,co.school_name
        ,co.lastfirst
        ,co.grade_level
        ,co.TEAM
        ,co.SPEDLEP
        ,m.academic_year
        ,m.term
        ,m.TA_subject
