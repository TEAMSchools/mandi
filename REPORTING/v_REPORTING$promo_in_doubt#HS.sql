USE KIPP_NJ
GO

ALTER VIEW REPORTING$promo_in_doubt#HS AS

WITH roster AS (
  SELECT s.ID
        ,s.lastfirst
        ,cs.ADVISOR
        ,s.GRADE_LEVEL
        ,gpa.GPA_Y1
  FROM students s WITH(NOLOCK)
  LEFT OUTER JOIN custom_students cs WITH(NOLOCK)
    ON s.id = cs.studentid
  LEFT OUTER JOIN GPA$detail#NCA gpa WITH(NOLOCK)
    ON s.id = gpa.studentid  
  WHERE s.ENROLL_STATUS = 0
    AND s.SCHOOLID = 73253
 )    

,grades AS (
  SELECT studentid
        ,[rc1_course_name]
        ,[rc1_exam]
        ,[rc1_need_c]
        ,[rc1_q1_term_pct]
        ,[rc1_q2_term_pct]
        ,[rc1_q3_term_pct]
        ,[rc1_y1_pct]
        ,[rc2_course_name]
        ,[rc2_exam]
        ,[rc2_need_c]
        ,[rc2_q1_term_pct]
        ,[rc2_q2_term_pct]
        ,[rc2_q3_term_pct]
        ,[rc2_y1_pct]
        ,[rc3_course_name]
        ,[rc3_exam]
        ,[rc3_need_c]
        ,[rc3_q1_term_pct]
        ,[rc3_q2_term_pct]
        ,[rc3_q3_term_pct]
        ,[rc3_y1_pct]
        ,[rc4_course_name]
        ,[rc4_exam]
        ,[rc4_need_c]
        ,[rc4_q1_term_pct]
        ,[rc4_q2_term_pct]
        ,[rc4_q3_term_pct]
        ,[rc4_y1_pct]
        ,[rc5_course_name]
        ,[rc5_exam]
        ,[rc5_need_c]
        ,[rc5_q1_term_pct]
        ,[rc5_q2_term_pct]
        ,[rc5_q3_term_pct]
        ,[rc5_y1_pct]
        ,[rc6_course_name]
        ,[rc6_exam]
        ,[rc6_need_c]
        ,[rc6_q1_term_pct]
        ,[rc6_q2_term_pct]
        ,[rc6_q3_term_pct]
        ,[rc6_y1_pct]
        ,[rc7_course_name]
        ,[rc7_exam]
        ,[rc7_need_c]
        ,[rc7_q1_term_pct]
        ,[rc7_q2_term_pct]
        ,[rc7_q3_term_pct]
        ,[rc7_y1_pct]
        ,[rc8_course_name]
        ,[rc8_exam]
        ,[rc8_need_c]
        ,[rc8_q1_term_pct]
        ,[rc8_q2_term_pct]
        ,[rc8_q3_term_pct]
        ,[rc8_y1_pct]
  FROM
      (
       SELECT studentid
             ,'rc' + CONVERT(VARCHAR,rn) + '_' + field AS identifier      
             ,value      
       FROM
           ( 
            SELECT studentid
                  ,CONVERT(VARCHAR,CONVERT(VARCHAR,LEFT(course_name,20)) + ' (' + CONVERT(VARCHAR,ISNULL(credit_hours,'')) + ')') AS course_name
                  ,CONVERT(VARCHAR,q1) AS q1_term_pct
                  ,CONVERT(VARCHAR,q2) AS q2_term_pct
                  ,CONVERT(VARCHAR,q3) AS q3_term_pct
                  ,CONVERT(VARCHAR,e1) AS exam
                  ,CONVERT(VARCHAR,y1) AS y1_pct                  
                  ,CASE
                    WHEN CONVERT(FLOAT,need_c) < 70 THEN '70'
                    WHEN CONVERT(FLOAT,need_c) > 100 THEN '100'
                    ELSE CONVERT(VARCHAR,ROUND(need_c,0))
                   END AS need_c
                  ,ROW_NUMBER() OVER(
                      PARTITION BY studentid
                          ORDER BY credittype, course_number) AS rn
            FROM GRADES$DETAIL#NCA gr WITH(NOLOCK)
            WHERE gr.Promo_Test = 1
           ) sub
           
       UNPIVOT(
         value
         FOR field IN ([course_name], [q1_term_pct], [q2_term_pct], [q3_term_pct], [exam], [y1_pct], [need_c])
        ) unpiv  
      ) sub2  

  PIVOT(
    MAX(value)
    FOR identifier IN ([rc1_course_name]
                      ,[rc1_exam]
                      ,[rc1_need_c]
                      ,[rc1_q1_term_pct]
                      ,[rc1_q2_term_pct]
                      ,[rc1_q3_term_pct]
                      ,[rc1_y1_pct]
                      ,[rc2_course_name]
                      ,[rc2_exam]
                      ,[rc2_need_c]
                      ,[rc2_q1_term_pct]
                      ,[rc2_q2_term_pct]
                      ,[rc2_q3_term_pct]
                      ,[rc2_y1_pct]
                      ,[rc3_course_name]
                      ,[rc3_exam]
                      ,[rc3_need_c]
                      ,[rc3_q1_term_pct]
                      ,[rc3_q2_term_pct]
                      ,[rc3_q3_term_pct]
                      ,[rc3_y1_pct]
                      ,[rc4_course_name]
                      ,[rc4_exam]
                      ,[rc4_need_c]
                      ,[rc4_q1_term_pct]
                      ,[rc4_q2_term_pct]
                      ,[rc4_q3_term_pct]
                      ,[rc4_y1_pct]
                      ,[rc5_course_name]
                      ,[rc5_exam]
                      ,[rc5_need_c]
                      ,[rc5_q1_term_pct]
                      ,[rc5_q2_term_pct]
                      ,[rc5_q3_term_pct]
                      ,[rc5_y1_pct]
                      ,[rc6_course_name]
                      ,[rc6_exam]
                      ,[rc6_need_c]
                      ,[rc6_q1_term_pct]
                      ,[rc6_q2_term_pct]
                      ,[rc6_q3_term_pct]
                      ,[rc6_y1_pct]
                      ,[rc7_course_name]
                      ,[rc7_exam]
                      ,[rc7_need_c]
                      ,[rc7_q1_term_pct]
                      ,[rc7_q2_term_pct]
                      ,[rc7_q3_term_pct]
                      ,[rc7_y1_pct]
                      ,[rc8_course_name]                      
                      ,[rc8_exam]
                      ,[rc8_need_c]
                      ,[rc8_q1_term_pct]
                      ,[rc8_q2_term_pct]
                      ,[rc8_q3_term_pct]
                      ,[rc8_y1_pct])
   ) piv
 )
 
SELECT *
FROM roster
JOIN grades
  ON roster.ID = grades.studentid