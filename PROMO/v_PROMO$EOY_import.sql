USE KIPP_NJ
GO

ALTER VIEW PROMO$EOY_import AS

WITH promo_all AS (
  SELECT student_number        
        ,promo_status_final_dirty AS promo_status_final
  FROM KIPP_NJ..PROMO$final_status#MS WITH(NOLOCK)

  UNION ALL

  SELECT STUDENT_NUMBER        
        ,promo_status
  FROM KIPP_NJ..PROMO$final_status#NCA WITH(NOLOCK)

  UNION ALL

  SELECT student_number        
        ,promo_status_final
  FROM KIPP_NJ..PROMO$final_status#ES WITH(NOLOCK)
 )

SELECT *
      ,(GRADE_LEVEL + next_grade_modifier) AS SCHED_nextyeargrade
      ,CASE 
        WHEN (GRADE_LEVEL + next_grade_modifier) = 13 THEN 999999
        WHEN (GRADE_LEVEL + next_grade_modifier) = 9 AND transfer_flag = 1 THEN 999999        
        WHEN (GRADE_LEVEL + next_grade_modifier) = 9 THEN 73253
        WHEN (GRADE_LEVEL + next_grade_modifier) = 5 AND SCHOOLID = 73254 THEN 133570965
        WHEN (GRADE_LEVEL + next_grade_modifier) = 5 AND SCHOOLID = 73257 THEN 73252
        ELSE SCHOOLID
       END AS next_school
FROM
    (
     SELECT s.STUDENT_NUMBER
           ,s.LASTFIRST
           ,s.SCHOOLID
           ,s.GRADE_LEVEL
           ,p.promo_status_final
           ,CASE
             WHEN p.promo_status_final IS NULL THEN 1
             WHEN p.promo_status_final LIKE '%promo%' THEN 1
             WHEN p.promo_status_final LIKE '%retain%' THEN 0
             WHEN p.promo_status_final LIKE '%demo%' THEN -1        
            END AS next_grade_modifier
           ,CASE WHEN p.promo_status_final LIKE '%transf%' THEN 1 ELSE 0 END AS transfer_flag
     FROM KIPP_NJ..STUDENTS s WITH(NOLOCK)
     LEFT OUTER JOIN promo_all p
       ON s.STUDENT_NUMBER = p.student_number
     WHERE s.ENROLL_STATUS = 0
    ) sub