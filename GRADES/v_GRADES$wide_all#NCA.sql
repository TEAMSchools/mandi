--fn_Global_TermId in use for current_absences and current_tardies
--no need to update the query, just the fn every year

USE KIPP_NJ
GO

ALTER VIEW GRADES$wide_all#NCA AS
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
                              --WHEN credittype LIKE '%STUDY%'   THEN NULL
                            END
                  ) AS rn
         FROM KIPP_NJ..GRADES$DETAIL#NCA
         WHERE credittype IN ('MATH','ENG','SCI','SOC','RHET','WLANG','ART','LOG','PHYSED')
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
        
        --credit hours E1
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_E1' AS pivot_on
	             ,CAST(pivot_ele.credit_hours_E1 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         
        UNION ALL
        
        --credit hours E2
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_E2' AS pivot_on
	             ,CAST(pivot_ele.credit_hours_E2 AS VARCHAR) AS value
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
        
        --E1
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_E1' AS pivot_on
	             ,CAST(pivot_ele.e1 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         
        UNION ALL
        
        --E1, all courses
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'E1_all' AS pivot_on
	             ,CAST(AVG(pivot_ele.e1) AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
        GROUP BY rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
         
        UNION ALL
        
        --E2
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_E2' AS pivot_on
	             ,CAST(pivot_ele.e2 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
        
        UNION ALL
                 
        --E2, all courses
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'E2_all' AS pivot_on
	             ,CAST(AVG(pivot_ele.e2) AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
        GROUP BY rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
         
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
        
        --Need_C
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Need_C' AS pivot_on
	             ,CAST(pivot_ele.need_c AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         
        UNION ALL
        
        --Need_B
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Need_B' AS pivot_on
	             ,CAST(pivot_ele.need_b AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         
        UNION ALL
        
        --Need_A
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Need_A' AS pivot_on
	             ,CAST(pivot_ele.need_a AS VARCHAR) AS value
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
        
        --Q4 ltr
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q4_ltr' AS pivot_on
	          ,CAST(pivot_ele.q4_letter AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
        
        UNION ALL
        
        --E1 ltr
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_E1_ltr' AS pivot_on
	          ,CAST(pivot_ele.e1_letter AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
        
        UNION ALL
        
        --E2 ltr
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_E2_ltr' AS pivot_on
	          ,CAST(pivot_ele.e2_letter AS VARCHAR) AS value
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
        
        --Q4 enr sectionid
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_q4_enr_sectionid' AS pivot_on
	             ,CAST(pivot_ele.q4_enr_sectionid AS VARCHAR) AS value
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
        
        --gpa points q4
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_q4' AS pivot_on
	             ,CAST(pivot_ele.GPA_Points_Q4 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         
        UNION ALL
        
        --gpa points e1
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_e1' AS pivot_on
	             ,CAST(pivot_ele.GPA_Points_E1 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         
        UNION ALL
        
        --gpa points e2
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_e2' AS pivot_on
	             ,CAST(pivot_ele.GPA_Points_E2 AS VARCHAR) AS value
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
        
        --weighted points q4
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_q4' AS pivot_on
	             ,CAST(pivot_ele.weighted_points_q4 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         
        UNION ALL
        
        --weighted points e1
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_e1' AS pivot_on
	             ,CAST(pivot_ele.weighted_points_E1 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         
        UNION ALL
        
        --weighted points e2
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_e2' AS pivot_on
	             ,CAST(pivot_ele.weighted_points_E2 AS VARCHAR) AS value
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
        
        --H4
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_H4' AS pivot_on
	          ,CAST(pivot_ele.grade_4 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         AND pivot_ele.pgf_type = 'H'
        
        UNION ALL
        
        --HY all courses
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'HY_all' AS pivot_on
	          ,CAST(pivot_ele.simple_avg AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND pivot_ele.course_number = 'all_courses'        
         AND pivot_ele.pgf_type = 'H'                     
        
        UNION ALL
               
        --C1
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_C1' AS pivot_on
	          ,CAST(pivot_ele.grade_1 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         AND pivot_ele.pgf_type = 'C'
        
        UNION ALL
         
         --C2
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_C2' AS pivot_on
	          ,CAST(pivot_ele.grade_2 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         AND pivot_ele.pgf_type = 'C'
        
        UNION ALL
         
         --C3
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_C3' AS pivot_on
	          ,CAST(pivot_ele.grade_3 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         AND pivot_ele.pgf_type = 'C'
        
        UNION ALL
         
         --C4
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_C4' AS pivot_on
	          ,CAST(pivot_ele.grade_4 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         AND pivot_ele.pgf_type = 'C'              
         
        UNION ALL
        
        --CY all courses
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'CY_all' AS pivot_on
	          ,CAST(pivot_ele.simple_avg AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND pivot_ele.course_number = 'all_courses'
         AND pivot_ele.pgf_type = 'C'
        
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
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_A2' AS pivot_on
	          ,CAST(pivot_ele.grade_2 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         AND pivot_ele.pgf_type = 'A'
        
        UNION ALL
         
         --A3
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_A3' AS pivot_on
	          ,CAST(pivot_ele.grade_3 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         AND pivot_ele.pgf_type = 'A'
        
        UNION ALL
         
         --A4
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_A4' AS pivot_on
	          ,CAST(pivot_ele.grade_4 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         AND pivot_ele.pgf_type = 'A'
         
        UNION ALL
        
        --AY all courses
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'AY_all' AS pivot_on
	          ,CAST(pivot_ele.simple_avg AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND pivot_ele.course_number = 'all_courses'
         AND pivot_ele.pgf_type = 'A'
        
        UNION ALL
        
        --P1
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_P1' AS pivot_on
	          ,CAST(pivot_ele.grade_1 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         AND pivot_ele.pgf_type = 'P'
        
        UNION ALL
         
         --P2
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_P2' AS pivot_on
	          ,CAST(pivot_ele.grade_2 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         AND pivot_ele.pgf_type = 'P'
        
        UNION ALL
         
         --P3
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_P3' AS pivot_on
	          ,CAST(pivot_ele.grade_3 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         AND pivot_ele.pgf_type = 'P'
        
        UNION ALL
         
         --P4
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_P4' AS pivot_on
	          ,CAST(pivot_ele.grade_4 AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         AND pivot_ele.pgf_type = 'P'
         
        UNION ALL
        
        --PY all courses
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	          ,'PY_all' AS pivot_on
	          ,CAST(pivot_ele.simple_avg AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$elements pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND pivot_ele.course_number = 'all_courses'
         AND pivot_ele.pgf_type = 'P'
        
        UNION ALL
        
        --promo_test
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	             ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_promo_test' AS pivot_on
	             ,CAST(pivot_ele.Promo_Test AS VARCHAR) AS value
        FROM rost
        JOIN KIPP_NJ..GRADES$DETAIL#NCA pivot_ele
          ON rost.studentid = pivot_ele.studentid
         AND rost.course_number = pivot_ele.course_number
         
        UNION ALL
        
        --current absences
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
              ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_current_absences' AS pivot_on
              ,CAST(pivot_ele.currentabsences AS VARCHAR) AS value      
         FROM rost
         JOIN CC pivot_ele
           ON rost.course_number = pivot_ele.course_number
          AND rost.studentid = pivot_ele.studentid
         JOIN COURSES c
           ON pivot_ele.course_number = c.course_number
        WHERE pivot_ele.termid >= dbo.fn_Global_Term_Id()

        UNION ALL
        
        --current tardies
        SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
              ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_current_tardies' AS pivot_on
              ,CAST(pivot_ele.currenttardies AS VARCHAR) AS value      
         FROM rost
         JOIN CC pivot_ele
           ON rost.course_number = pivot_ele.course_number
          AND rost.studentid = pivot_ele.studentid
         JOIN COURSES c
           ON pivot_ele.course_number = c.course_number
        WHERE pivot_ele.termid >= dbo.fn_Global_Term_Id()
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
     ,rc2_course_number
     ,rc2_credittype
     ,rc2_course_name
     ,rc2_credit_hours_Q1
     ,rc2_credit_hours_Q2
     ,rc2_credit_hours_Q3
     ,rc2_credit_hours_Q4
     ,rc2_E1_credit_hours
     ,rc2_E2_credit_hours
     ,rc2_credit_hours_Y1
     ,rc2_teacher_last
     ,rc2_teacher_lastfirst
     ,rc2_Q1
     ,rc2_Q2
     ,rc2_Q3
     ,rc2_Q4
     ,rc2_E1
     ,rc2_E2
     ,rc2_Y1
     ,rc2_Need_C
     ,rc2_Need_B
     ,rc2_Need_A
     ,rc2_Q1_ltr
     ,rc2_Q2_ltr
     ,rc2_Q3_ltr
     ,rc2_Q4_ltr
     ,rc2_E1_ltr
     ,rc2_E2_ltr
     ,rc2_Y1_ltr
     ,rc2_Q1_enr_sectionid
     ,rc2_Q2_enr_sectionid
     ,rc2_Q3_enr_sectionid
     ,rc2_Q4_enr_sectionid
     ,rc2_gpa_points_Q1
     ,rc2_gpa_points_Q2
     ,rc2_gpa_points_Q3
     ,rc2_gpa_points_Q4
     ,rc2_E1_gpa_points
     ,rc2_E2_gpa_points
     ,rc2_gpa_points_Y1
     ,rc2_weighted_points_Q1
     ,rc2_weighted_points_Q2
     ,rc2_weighted_points_Q3
     ,rc2_weighted_points_Q4
     ,rc2_weighted_points_E1
     ,rc2_weighted_points_E2
     ,rc2_weighted_points_Y1
     ,rc2_H1
     ,rc2_H2
     ,rc2_H3
     ,rc2_H4
     ,rc2_C1
     ,rc2_C2
     ,rc2_C3
     ,rc2_C4
     ,rc2_A1
     ,rc2_A2
     ,rc2_A3
     ,rc2_A4
     ,rc2_P1
     ,rc2_P2
     ,rc2_P3
     ,rc2_P4
     ,rc2_current_absences
     ,rc2_current_tardies
     ,rc2_promo_test
     ,rc3_course_number
     ,rc3_credittype
     ,rc3_course_name
     ,rc3_credit_hours_Q1
     ,rc3_credit_hours_Q2
     ,rc3_credit_hours_Q3
     ,rc3_credit_hours_Q4
     ,rc3_E1_credit_hours
     ,rc3_E2_credit_hours
     ,rc3_credit_hours_Y1
     ,rc3_teacher_last
     ,rc3_teacher_lastfirst
     ,rc3_Q1
     ,rc3_Q2
     ,rc3_Q3
     ,rc3_Q4
     ,rc3_E1
     ,rc3_E2
     ,rc3_Y1
     ,rc3_Need_C
     ,rc3_Need_B
     ,rc3_Need_A
     ,rc3_Q1_ltr
     ,rc3_Q2_ltr
     ,rc3_Q3_ltr
     ,rc3_Q4_ltr
     ,rc3_E1_ltr
     ,rc3_E2_ltr
     ,rc3_Y1_ltr
     ,rc3_Q1_enr_sectionid
     ,rc3_Q2_enr_sectionid
     ,rc3_Q3_enr_sectionid
     ,rc3_Q4_enr_sectionid
     ,rc3_gpa_points_Q1
     ,rc3_gpa_points_Q2
     ,rc3_gpa_points_Q3
     ,rc3_gpa_points_Q4
     ,rc3_E1_gpa_points
     ,rc3_E2_gpa_points
     ,rc3_gpa_points_Y1
     ,rc3_weighted_points_Q1
     ,rc3_weighted_points_Q2
     ,rc3_weighted_points_Q3
     ,rc3_weighted_points_Q4
     ,rc3_weighted_points_E1
     ,rc3_weighted_points_E2
     ,rc3_weighted_points_Y1
     ,rc3_H1
     ,rc3_H2
     ,rc3_H3
     ,rc3_H4
     ,rc3_C1
     ,rc3_C2
     ,rc3_C3
     ,rc3_C4
     ,rc3_A1
     ,rc3_A2
     ,rc3_A3
     ,rc3_A4
     ,rc3_P1
     ,rc3_P2
     ,rc3_P3
     ,rc3_P4
     ,rc3_current_absences
     ,rc3_current_tardies
     ,rc3_promo_test
     ,rc4_course_number
     ,rc4_credittype
     ,rc4_course_name
     ,rc4_credit_hours_Q1
     ,rc4_credit_hours_Q2
     ,rc4_credit_hours_Q3
     ,rc4_credit_hours_Q4
     ,rc4_E1_credit_hours
     ,rc4_E2_credit_hours
     ,rc4_credit_hours_Y1
     ,rc4_teacher_last
     ,rc4_teacher_lastfirst
     ,rc4_Q1
     ,rc4_Q2
     ,rc4_Q3
     ,rc4_Q4
     ,rc4_E1
     ,rc4_E2
     ,rc4_Y1
     ,rc4_Need_C
     ,rc4_Need_B
     ,rc4_Need_A
     ,rc4_Q1_ltr
     ,rc4_Q2_ltr
     ,rc4_Q3_ltr
     ,rc4_Q4_ltr
     ,rc4_E1_ltr
     ,rc4_E2_ltr
     ,rc4_Y1_ltr
     ,rc4_Q1_enr_sectionid
     ,rc4_Q2_enr_sectionid
     ,rc4_Q3_enr_sectionid
     ,rc4_Q4_enr_sectionid
     ,rc4_gpa_points_Q1
     ,rc4_gpa_points_Q2
     ,rc4_gpa_points_Q3
     ,rc4_gpa_points_Q4
     ,rc4_E1_gpa_points
     ,rc4_E2_gpa_points
     ,rc4_gpa_points_Y1
     ,rc4_weighted_points_Q1
     ,rc4_weighted_points_Q2
     ,rc4_weighted_points_Q3
     ,rc4_weighted_points_Q4
     ,rc4_weighted_points_E1
     ,rc4_weighted_points_E2
     ,rc4_weighted_points_Y1
     ,rc4_H1
     ,rc4_H2
     ,rc4_H3
     ,rc4_H4
     ,rc4_C1
     ,rc4_C2
     ,rc4_C3
     ,rc4_C4
     ,rc4_A1
     ,rc4_A2
     ,rc4_A3
     ,rc4_A4
     ,rc4_P1
     ,rc4_P2
     ,rc4_P3
     ,rc4_P4
     ,rc4_current_absences
     ,rc4_current_tardies
     ,rc4_promo_test
     ,rc5_course_number
     ,rc5_credittype
     ,rc5_course_name
     ,rc5_credit_hours_Q1
     ,rc5_credit_hours_Q2
     ,rc5_credit_hours_Q3
     ,rc5_credit_hours_Q4
     ,rc5_E1_credit_hours
     ,rc5_E2_credit_hours
     ,rc5_credit_hours_Y1
     ,rc5_teacher_last
     ,rc5_teacher_lastfirst
     ,rc5_Q1
     ,rc5_Q2
     ,rc5_Q3
     ,rc5_Q4
     ,rc5_E1
     ,rc5_E2
     ,rc5_Y1
     ,rc5_Need_C
     ,rc5_Need_B
     ,rc5_Need_A
     ,rc5_Q1_ltr
     ,rc5_Q2_ltr
     ,rc5_Q3_ltr
     ,rc5_Q4_ltr
     ,rc5_E1_ltr
     ,rc5_E2_ltr
     ,rc5_Y1_ltr
     ,rc5_Q1_enr_sectionid
     ,rc5_Q2_enr_sectionid
     ,rc5_Q3_enr_sectionid
     ,rc5_Q4_enr_sectionid
     ,rc5_gpa_points_Q1
     ,rc5_gpa_points_Q2
     ,rc5_gpa_points_Q3
     ,rc5_gpa_points_Q4
     ,rc5_E1_gpa_points
     ,rc5_E2_gpa_points
     ,rc5_gpa_points_Y1
     ,rc5_weighted_points_Q1
     ,rc5_weighted_points_Q2
     ,rc5_weighted_points_Q3
     ,rc5_weighted_points_Q4
     ,rc5_weighted_points_E1
     ,rc5_weighted_points_E2
     ,rc5_weighted_points_Y1
     ,rc5_H1
     ,rc5_H2
     ,rc5_H3
     ,rc5_H4
     ,rc5_C1
     ,rc5_C2
     ,rc5_C3
     ,rc5_C4
     ,rc5_A1
     ,rc5_A2
     ,rc5_A3
     ,rc5_A4
     ,rc5_P1
     ,rc5_P2
     ,rc5_P3
     ,rc5_P4
     ,rc5_current_absences
     ,rc5_current_tardies
     ,rc5_promo_test
     ,rc6_course_number
     ,rc6_credittype
     ,rc6_course_name
     ,rc6_credit_hours_Q1
     ,rc6_credit_hours_Q2
     ,rc6_credit_hours_Q3
     ,rc6_credit_hours_Q4
     ,rc6_E1_credit_hours
     ,rc6_E2_credit_hours
     ,rc6_credit_hours_Y1
     ,rc6_teacher_last
     ,rc6_teacher_lastfirst
     ,rc6_Q1
     ,rc6_Q2
     ,rc6_Q3
     ,rc6_Q4
     ,rc6_E1
     ,rc6_E2
     ,rc6_Y1
     ,rc6_Need_C
     ,rc6_Need_B
     ,rc6_Need_A
     ,rc6_Q1_ltr
     ,rc6_Q2_ltr
     ,rc6_Q3_ltr
     ,rc6_Q4_ltr
     ,rc6_E1_ltr
     ,rc6_E2_ltr
     ,rc6_Y1_ltr
     ,rc6_Q1_enr_sectionid
     ,rc6_Q2_enr_sectionid
     ,rc6_Q3_enr_sectionid
     ,rc6_Q4_enr_sectionid
     ,rc6_gpa_points_Q1
     ,rc6_gpa_points_Q2
     ,rc6_gpa_points_Q3
     ,rc6_gpa_points_Q4
     ,rc6_E1_gpa_points
     ,rc6_E2_gpa_points
     ,rc6_gpa_points_Y1
     ,rc6_weighted_points_Q1
     ,rc6_weighted_points_Q2
     ,rc6_weighted_points_Q3
     ,rc6_weighted_points_Q4
     ,rc6_weighted_points_E1
     ,rc6_weighted_points_E2
     ,rc6_weighted_points_Y1
     ,rc6_H1
     ,rc6_H2
     ,rc6_H3
     ,rc6_H4
     ,rc6_C1
     ,rc6_C2
     ,rc6_C3
     ,rc6_C4
     ,rc6_A1
     ,rc6_A2
     ,rc6_A3
     ,rc6_A4
     ,rc6_P1
     ,rc6_P2
     ,rc6_P3
     ,rc6_P4
     ,rc6_current_absences
     ,rc6_current_tardies
     ,rc6_promo_test
     ,rc7_course_number
     ,rc7_credittype
     ,rc7_course_name
     ,rc7_credit_hours_Q1
     ,rc7_credit_hours_Q2
     ,rc7_credit_hours_Q3
     ,rc7_credit_hours_Q4
     ,rc7_E1_credit_hours
     ,rc7_E2_credit_hours
     ,rc7_credit_hours_Y1
     ,rc7_teacher_last
     ,rc7_teacher_lastfirst
     ,rc7_Q1
     ,rc7_Q2
     ,rc7_Q3
     ,rc7_Q4
     ,rc7_E1
     ,rc7_E2
     ,rc7_Y1
     ,rc7_Need_C
     ,rc7_Need_B
     ,rc7_Need_A
     ,rc7_Q1_ltr
     ,rc7_Q2_ltr
     ,rc7_Q3_ltr
     ,rc7_Q4_ltr
     ,rc7_E1_ltr
     ,rc7_E2_ltr
     ,rc7_Y1_ltr
     ,rc7_Q1_enr_sectionid
     ,rc7_Q2_enr_sectionid
     ,rc7_Q3_enr_sectionid
     ,rc7_Q4_enr_sectionid
     ,rc7_gpa_points_Q1
     ,rc7_gpa_points_Q2
     ,rc7_gpa_points_Q3
     ,rc7_gpa_points_Q4
     ,rc7_E1_gpa_points
     ,rc7_E2_gpa_points
     ,rc7_gpa_points_Y1
     ,rc7_weighted_points_Q1
     ,rc7_weighted_points_Q2
     ,rc7_weighted_points_Q3
     ,rc7_weighted_points_Q4
     ,rc7_weighted_points_E1
     ,rc7_weighted_points_E2
     ,rc7_weighted_points_Y1
     ,rc7_H1
     ,rc7_H2
     ,rc7_H3
     ,rc7_H4
     ,rc7_C1
     ,rc7_C2
     ,rc7_C3
     ,rc7_C4
     ,rc7_A1
     ,rc7_A2
     ,rc7_A3
     ,rc7_A4
     ,rc7_P1
     ,rc7_P2
     ,rc7_P3
     ,rc7_P4
     ,rc7_current_absences
     ,rc7_current_tardies
     ,rc7_promo_test
     ,rc8_course_number
     ,rc8_credittype
     ,rc8_course_name
     ,rc8_credit_hours_Q1
     ,rc8_credit_hours_Q2
     ,rc8_credit_hours_Q3
     ,rc8_credit_hours_Q4
     ,rc8_E1_credit_hours
     ,rc8_E2_credit_hours
     ,rc8_credit_hours_Y1
     ,rc8_teacher_last
     ,rc8_teacher_lastfirst
     ,rc8_Q1
     ,rc8_Q2
     ,rc8_Q3
     ,rc8_Q4
     ,rc8_E1
     ,rc8_E2
     ,rc8_Y1
     ,rc8_Need_C
     ,rc8_Need_B
     ,rc8_Need_A
     ,rc8_Q1_ltr
     ,rc8_Q2_ltr
     ,rc8_Q3_ltr
     ,rc8_Q4_ltr
     ,rc8_E1_ltr
     ,rc8_E2_ltr
     ,rc8_Y1_ltr
     ,rc8_Q1_enr_sectionid
     ,rc8_Q2_enr_sectionid
     ,rc8_Q3_enr_sectionid
     ,rc8_Q4_enr_sectionid
     ,rc8_gpa_points_Q1
     ,rc8_gpa_points_Q2
     ,rc8_gpa_points_Q3
     ,rc8_gpa_points_Q4
     ,rc8_E1_gpa_points
     ,rc8_E2_gpa_points
     ,rc8_gpa_points_Y1
     ,rc8_weighted_points_Q1
     ,rc8_weighted_points_Q2
     ,rc8_weighted_points_Q3
     ,rc8_weighted_points_Q4
     ,rc8_weighted_points_E1
     ,rc8_weighted_points_E2
     ,rc8_weighted_points_Y1
     ,rc8_H1
     ,rc8_H2
     ,rc8_H3
     ,rc8_H4
     ,rc8_C1
     ,rc8_C2
     ,rc8_C3
     ,rc8_C4
     ,rc8_A1
     ,rc8_A2
     ,rc8_A3
     ,rc8_A4
     ,rc8_P1
     ,rc8_P2
     ,rc8_P3
     ,rc8_P4
     ,rc8_current_absences
     ,rc8_current_tardies
     ,rc8_promo_test
     ,rc9_course_number
     ,rc9_credittype
     ,rc9_course_name
     ,rc9_credit_hours_Q1
     ,rc9_credit_hours_Q2
     ,rc9_credit_hours_Q3
     ,rc9_credit_hours_Q4
     ,rc9_E1_credit_hours
     ,rc9_E2_credit_hours
     ,rc9_credit_hours_Y1
     ,rc9_teacher_last
     ,rc9_teacher_lastfirst
     ,rc9_Q1
     ,rc9_Q2
     ,rc9_Q3
     ,rc9_Q4
     ,rc9_E1
     ,rc9_E2
     ,rc9_Y1
     ,rc9_Need_C
     ,rc9_Need_B
     ,rc9_Need_A
     ,rc9_Q1_ltr
     ,rc9_Q2_ltr
     ,rc9_Q3_ltr
     ,rc9_Q4_ltr
     ,rc9_E1_ltr
     ,rc9_E2_ltr
     ,rc9_Y1_ltr
     ,rc9_Q1_enr_sectionid
     ,rc9_Q2_enr_sectionid
     ,rc9_Q3_enr_sectionid
     ,rc9_Q4_enr_sectionid
     ,rc9_gpa_points_Q1
     ,rc9_gpa_points_Q2
     ,rc9_gpa_points_Q3
     ,rc9_gpa_points_Q4
     ,rc9_E1_gpa_points
     ,rc9_E2_gpa_points
     ,rc9_gpa_points_Y1
     ,rc9_weighted_points_Q1
     ,rc9_weighted_points_Q2
     ,rc9_weighted_points_Q3
     ,rc9_weighted_points_Q4
     ,rc9_weighted_points_E1
     ,rc9_weighted_points_E2
     ,rc9_weighted_points_Y1
     ,rc9_H1
     ,rc9_H2
     ,rc9_H3
     ,rc9_H4
     ,rc9_C1
     ,rc9_C2
     ,rc9_C3
     ,rc9_C4
     ,rc9_A1
     ,rc9_A2
     ,rc9_A3
     ,rc9_A4
     ,rc9_P1
     ,rc9_P2
     ,rc9_P3
     ,rc9_P4
     ,rc9_current_absences
     ,rc9_current_tardies
     ,rc9_promo_test
     ,rc10_course_number
     ,rc10_credittype
     ,rc10_course_name
     ,rc10_credit_hours_Q1
     ,rc10_credit_hours_Q2
     ,rc10_credit_hours_Q3
     ,rc10_credit_hours_Q4
     ,rc10_E1_credit_hours
     ,rc10_E2_credit_hours
     ,rc10_credit_hours_Y1
     ,rc10_teacher_last
     ,rc10_teacher_lastfirst
     ,rc10_Q1
     ,rc10_Q2
     ,rc10_Q3
     ,rc10_Q4
     ,rc10_E1
     ,rc10_E2
     ,rc10_Y1
     ,rc10_Need_C
     ,rc10_Need_B
     ,rc10_Need_A
     ,rc10_Q1_ltr
     ,rc10_Q2_ltr
     ,rc10_Q3_ltr
     ,rc10_Q4_ltr
     ,rc10_E1_ltr
     ,rc10_E2_ltr
     ,rc10_Y1_ltr
     ,rc10_Q1_enr_sectionid
     ,rc10_Q2_enr_sectionid
     ,rc10_Q3_enr_sectionid
     ,rc10_Q4_enr_sectionid
     ,rc10_gpa_points_Q1
     ,rc10_gpa_points_Q2
     ,rc10_gpa_points_Q3
     ,rc10_gpa_points_Q4
     ,rc10_E1_gpa_points
     ,rc10_E2_gpa_points
     ,rc10_gpa_points_Y1
     ,rc10_weighted_points_Q1
     ,rc10_weighted_points_Q2
     ,rc10_weighted_points_Q3
     ,rc10_weighted_points_Q4
     ,rc10_weighted_points_E1
     ,rc10_weighted_points_E2
     ,rc10_weighted_points_Y1
     ,rc10_H1
     ,rc10_H2
     ,rc10_H3
     ,rc10_H4
     ,rc10_C1
     ,rc10_C2
     ,rc10_C3
     ,rc10_C4
     ,rc10_A1
     ,rc10_A2
     ,rc10_A3
     ,rc10_A4
     ,rc10_P1
     ,rc10_P2
     ,rc10_P3
     ,rc10_P4
     ,rc10_current_absences
     ,rc10_current_tardies
     ,rc10_promo_test
     ,HY_all
     ,AY_all
     ,CY_all
     ,PY_all
     ,E1_all
     ,E2_all
     )
) AS pwn3d
--*/