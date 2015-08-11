USE Khan
GO

ALTER VIEW exercise$status_long#identifiers AS

WITH scaffold AS (
  SELECT c.studentid
        ,c.grade_level
        ,c.lastfirst
        ,c.full_name AS stu_name
        ,c.school_name AS abbreviation
  FROM KIPP_NJ..COHORT$identifiers_long#static c WITH(NOLOCK)  
  WHERE c.year = 2014
    AND c.rn = 1
    AND c.enroll_status = 0
 )

,khan_obj AS (
  SELECT DISTINCT e.exercise
  FROM Khan..composite_exercises e WITH(NOLOCK)
 )

,exer_status AS (
  SELECT c.*
        ,s.exercise_status
        ,s.date
        ,m.mastery_flag
        ,ROW_NUMBER() OVER (
           PARTITION BY c.studentid, c.exercise
             ORDER BY m.ex_level DESC) AS rn
  FROM Khan..composite_exercises#identifiers c WITH(NOLOCK)
  JOIN Khan..exercise_states s WITH(NOLOCK)
    ON c.exercise = s.exercise
  JOIN Khan..KHAN$mastery_status m WITH(NOLOCK)
    ON s.exercise_status = m.ex_status
 ) 

SELECT sub.*
FROM
    (
     SELECT scaffold.*
           ,khan_obj.*
     FROM scaffold WITH(NOLOCK)
     CROSS JOIN khan_obj WITH(NOLOCK)       
    ) sub
LEFT OUTER JOIN exer_status
  ON sub.studentid = exer_status.studentid
 AND sub.exercise = exer_status.exercise
 AND exer_status.rn = 1