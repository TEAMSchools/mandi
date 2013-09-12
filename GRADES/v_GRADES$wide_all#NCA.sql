USE KIPP_NJ
GO

--Q4
--other credittypes
--E?
--other final grade types

--ALTER VIEW GRADES$wide_all#NCA AS
WITH rost AS
  (SELECT sub.*
         ,ROW_NUMBER() OVER
            (PARTITION BY studentid
             ORDER BY rn
                     ,course_number
             ) AS rn_format
   FROM     
        (SELECT studentid
               ,student_number
               ,schoolid
               ,lastfirst
               ,grade_level               
               ,course_number --used for JOIN with pivot fields
               ,ROW_NUMBER() OVER 
                  (PARTITION BY studentid
                   ORDER BY CASE
                              WHEN credittype LIKE '%ENG%'     THEN '1'
                              WHEN credittype LIKE '%RHET%'    THEN '2'
                              WHEN credittype LIKE '%MATH%'    THEN '3'
                              WHEN credittype LIKE '%SCI%'     THEN '4'
                              WHEN credittype LIKE '%SOC%'     THEN '5'
                              WHEN credittype LIKE '%WLANG%'   THEN '6'
                              WHEN credittype LIKE '%ART%'     THEN '7'
                              WHEN credittype LIKE '%PHYSED%'  THEN '8'                              
                              WHEN credittype LIKE '%LOG%'     THEN '9'
                              WHEN credittype LIKE '%STUDY%'   THEN '10'
                            END
                  ) AS rn
         FROM KIPP_NJ..GRADES$DETAIL#NCA
         WHERE credittype IN ('MATH','ENG','SCI','SOC','RHET','WLANG','ART','LOG','PHYSED','STUDY')
         )sub
   )
  
SELECT *
FROM
       --course number
       (SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_course_number' AS pivot_on
	            ,pivot_ele.course_number AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit type
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credittype' AS pivot_on
	            ,pivot_ele.credittype AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --course name   
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_course_name' AS pivot_on
	            ,pivot_ele.course_name AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours Q1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_Q1' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_q1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours Q2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_Q2' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_q2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours Q3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_Q3' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_q3 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours Q4
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_Q4' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_q4 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours Y1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_Y1' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_y1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --teacher last
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_teacher_last' AS pivot_on
	            ,tch.last_name AS value
       FROM rost
       LEFT OUTER JOIN KIPP_NJ..PS$teacher_by_last_enrollment tch
         ON rost.studentid = tch.studentid
        AND rost.course_number = tch.course_number
        
       UNION ALL
       
       --teacher lastfirst
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_teacher_lastfirst' AS pivot_on
	            ,tch.lastfirst AS value
       FROM rost
       LEFT OUTER JOIN KIPP_NJ..PS$teacher_by_last_enrollment tch
         ON rost.studentid = tch.studentid
        AND rost.course_number = tch.course_number
        
       UNION ALL
       
       --Q1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q1' AS pivot_on
	            ,CAST(pivot_ele.Q1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --Q2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q2' AS pivot_on
	            ,CAST(pivot_ele.Q2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --Q3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q3' AS pivot_on
	            ,CAST(pivot_ele.Q3 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --Q4
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q4' AS pivot_on
	            ,CAST(pivot_ele.Q4 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --Y1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Y1' AS pivot_on
	            ,CAST(pivot_ele.Y1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
 
       --Q1 ltr
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q1_ltr' AS pivot_on
	         ,CAST(pivot_ele.Q1_LETTER AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
  
       UNION ALL

       --Q2 ltr
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q2_ltr' AS pivot_on
	         ,CAST(pivot_ele.Q2_LETTER AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
       
       UNION ALL
       
       --Q3 ltr
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q3_ltr' AS pivot_on
	         ,CAST(pivot_ele.Q3_LETTER AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
       
       UNION ALL
       
       --Y1 ltr
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Y1_ltr' AS pivot_on
	         ,CAST(pivot_ele.Y1_LETTER AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
       
       UNION ALL
       
       --Q1 enr sectionid
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_q1_enr_sectionid' AS pivot_on
	            ,CAST(pivot_ele.q1_enr_sectionid AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --Q2 enr sectionid
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_q2_enr_sectionid' AS pivot_on
	            ,CAST(pivot_ele.q2_enr_sectionid AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --Q3 enr sectionid
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_q3_enr_sectionid' AS pivot_on
	            ,CAST(pivot_ele.q3_enr_sectionid AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --gpa points q1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_q1' AS pivot_on
	            ,CAST(pivot_ele.gpa_points_q1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --gpa points q2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_q2' AS pivot_on
	            ,CAST(pivot_ele.gpa_points_q2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --gpa points q3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_q3' AS pivot_on
	            ,CAST(pivot_ele.gpa_points_q3 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --gpa points y1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_y1' AS pivot_on
	            ,CAST(pivot_ele.gpa_points_y1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --weighted points q1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_q1' AS pivot_on
	            ,CAST(pivot_ele.weighted_points_q1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --weighted points q2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_q2' AS pivot_on
	            ,CAST(pivot_ele.weighted_points_q2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --weighted points q3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_q3' AS pivot_on
	            ,CAST(pivot_ele.weighted_points_q3 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --weighted points y1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_y1' AS pivot_on
	            ,CAST(pivot_ele.weighted_points_y1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --H1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_H1' AS pivot_on
	         ,CAST(pivot_ele.grade_1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$elements pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'H'
       
       UNION ALL
       
       --H2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_H2' AS pivot_on
	         ,CAST(pivot_ele.grade_2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$elements pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'H'
       
       UNION ALL
       
        --H3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_H3' AS pivot_on
	         ,CAST(pivot_ele.grade_3 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$elements pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'H'
       
       UNION ALL
              
       --A1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_A1' AS pivot_on
	         ,CAST(pivot_ele.grade_1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$elements pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'A'
       
       UNION ALL
        
        --A2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_A1' AS pivot_on
	         ,CAST(pivot_ele.grade_2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$elements pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'A'
       
       UNION ALL
        
        --A3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_A1' AS pivot_on
	         ,CAST(pivot_ele.grade_3 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$elements pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'A'              
       )sub
       
--/*
PIVOT (
  MAX(value) 
  FOR pivot_on 
  IN (rc1_course_number
     ,rc1_credittype
     ,rc1_course_name
     ,rc1_credit_hours_Q1
     ,rc1_credit_hours_Q2
     ,rc1_credit_hours_Q3
     ,rc1_credit_hours_Q4
     ,rc1_E1_credit_hours
     ,rc1_E2_credit_hours
     ,rc1_credit_hours_Y1
     ,rc1_teacher_last
     ,rc1_teacher_lastfirst
     ,rc1_Q1
     ,rc1_Q2
     ,rc1_Q3
     ,rc1_Q4
     ,rc1_E1
     ,rc1_E2
     ,rc1_Y1
     ,rc1_Need_C
     ,rc1_Need_B
     ,rc1_Need_A
     ,rc1_Q1_ltr
     ,rc1_Q2_ltr
     ,rc1_Q3_ltr
     ,rc1_Q4_ltr
     ,rc1_E1_ltr
     ,rc1_E2_ltr
     ,rc1_Y1_ltr
     ,rc1_Q1_enr_sectionid
     ,rc1_Q2_enr_sectionid
     ,rc1_Q3_enr_sectionid
     ,rc1_Q4_enr_sectionid
     ,rc1_gpa_points_Q1
     ,rc1_gpa_points_Q2
     ,rc1_gpa_points_Q3
     ,rc1_gpa_points_Q4
     ,rc1_E1_gpa_points
     ,rc1_E2_gpa_points
     ,rc1_gpa_points_Y1
     ,rc1_weighted_points_Q1
     ,rc1_weighted_points_Q2
     ,rc1_weighted_points_Q3
     ,rc1_weighted_points_Q4
     ,rc1_weighted_points_E1
     ,rc1_weighted_points_E2
     ,rc1_weighted_points_Y1
     ,rc1_H1
     ,rc1_H2
     ,rc1_H3
     ,rc1_H4
     ,rc1_C1
     ,rc1_C2
     ,rc1_C3
     ,rc1_C4
     ,rc1_A1
     ,rc1_A2
     ,rc1_A3
     ,rc1_A4
     ,rc1_P1
     ,rc1_P2
     ,rc1_P3
     ,rc1_P4
     ,rc1_current_absences
     ,rc1_current_tardies
     ,rc1_promo_test
     )
) AS pwn3d
--*/