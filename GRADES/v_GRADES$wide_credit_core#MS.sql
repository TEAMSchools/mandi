--testing pivot by credit type 09/14

USE KIPP_NJ
GO

ALTER VIEW GRADES$wide_credit_core#MS AS

WITH rost AS
     (
      SELECT s.id AS studentid
            ,s.student_number
            ,s.schoolid
            ,s.lastfirst
            ,s.grade_level      
            ,gr.course_number
            ,sub.rn_format
      FROM 
          (
           SELECT 'ENG' AS credittype
                 ,1 AS rn_format
           UNION
           SELECT 'RHET'
                 ,2
           UNION
           SELECT 'MATH'
                 ,3
           UNION
           SELECT 'SCI'
                 ,4
           UNION
           SELECT 'SOC'
                 ,5
           UNION
           SELECT 'WLANG'
                 ,8
           UNION
           SELECT 'COCUR'
                 ,6
           UNION
           SELECT 'LIB'
                 ,9
           UNION
           SELECT 'PHYSED'
                 ,7
           UNION
           SELECT 'CORE'
                 ,10
          ) sub
      JOIN STUDENTS s
        ON 1 = 1
       AND s.ENROLL_STATUS = 0
       AND s.SCHOOLID IN (73252, 133570965)
      LEFT OUTER JOIN GRADES$DETAIL#MS gr
        ON s.id = gr.studentid
       AND sub.credittype = gr.credittype
     )   
  
SELECT *
FROM
       --course number
       (SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_course_number' AS pivot_on
	            ,pivot_ele.course_number AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit type
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credittype' AS pivot_on
	            ,pivot_ele.credittype AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --course name   
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_course_name' AS pivot_on
	            ,pivot_ele.course_name AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours T1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_T1' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_t1 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours T2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_T2' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_t2 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours T3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_T3' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_t3 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours Y1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_Y1' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_y1 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --teacher last
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_teacher_last' AS pivot_on
	            ,tch.last_name AS value
       FROM rost WITH (NOLOCK)
       LEFT OUTER JOIN KIPP_NJ..PS$teacher_by_last_enrollment tch WITH (NOLOCK)
         ON rost.studentid = tch.studentid
        AND rost.course_number = tch.course_number
        AND tch.rn = 1
        
       UNION ALL
       
       --teacher lastfirst
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_teacher_lastfirst' AS pivot_on
	            ,tch.lastfirst AS value
       FROM rost WITH (NOLOCK)
       LEFT OUTER JOIN KIPP_NJ..PS$teacher_by_last_enrollment tch WITH (NOLOCK)
         ON rost.studentid = tch.studentid
        AND rost.course_number = tch.course_number
        AND tch.rn = 1
        
       UNION ALL
       
       --T1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T1' AS pivot_on
	            ,CAST(pivot_ele.T1 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --T2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T2' AS pivot_on
	            ,CAST(pivot_ele.T2 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --T3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T3' AS pivot_on
	            ,CAST(pivot_ele.T3 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --Y1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Y1' AS pivot_on
	            ,CAST(pivot_ele.Y1 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
 
       --T1 ltr
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T1_ltr' AS pivot_on
	         ,CAST(pivot_ele.T1_LETTER AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
  
       UNION ALL

       --T2 ltr
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T2_ltr' AS pivot_on
	         ,CAST(pivot_ele.T2_LETTER AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
       
       UNION ALL
       
       --T3 ltr
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T3_ltr' AS pivot_on
	         ,CAST(pivot_ele.T3_LETTER AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
       
       UNION ALL
       
       --Y1 ltr
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Y1_ltr' AS pivot_on
	         ,CAST(pivot_ele.Y1_LETTER AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
       
       UNION ALL
       
       --T1 enr sectionid
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_t1_enr_sectionid' AS pivot_on
	            ,CAST(pivot_ele.t1_enr_sectionid AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --T2 enr sectionid
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_t2_enr_sectionid' AS pivot_on
	            ,CAST(pivot_ele.t2_enr_sectionid AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --T3 enr sectionid
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_t3_enr_sectionid' AS pivot_on
	            ,CAST(pivot_ele.t3_enr_sectionid AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
--/*
       UNION ALL
       
       --gpa points t1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_t1' AS pivot_on
	            ,CAST(pivot_ele.gpa_points_t1 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --gpa points t2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_t2' AS pivot_on
	            ,CAST(pivot_ele.gpa_points_t2 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --gpa points t3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_t3' AS pivot_on
	            ,CAST(pivot_ele.gpa_points_t3 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --gpa points y1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_y1' AS pivot_on
	            ,CAST(pivot_ele.gpa_points_y1 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --weighted points t1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_t1' AS pivot_on
	            ,CAST(pivot_ele.weighted_points_t1 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --weighted points t2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_t2' AS pivot_on
	            ,CAST(pivot_ele.weighted_points_t2 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --weighted points t3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_t3' AS pivot_on
	            ,CAST(pivot_ele.weighted_points_t3 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --weighted points y1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_y1' AS pivot_on
	            ,CAST(pivot_ele.weighted_points_y1 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
--*/        
       UNION ALL
       
       --H1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_H1' AS pivot_on
	         ,CAST(pivot_ele.grade_1 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'H'
       
       UNION ALL
       
       --H2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_H2' AS pivot_on
	         ,CAST(pivot_ele.grade_2 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'H'
       
       UNION ALL
       
        --H3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_H3' AS pivot_on
	         ,CAST(pivot_ele.grade_3 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'H'
       
       UNION ALL
       
       --HY1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_HY1' AS pivot_on
	         ,CAST(pivot_ele.simple_avg AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'H'
       
       UNION ALL
       
       --HY all courses
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'HY_all' AS pivot_on
	         ,CAST(pivot_ele.simple_avg AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND pivot_ele.course_number = 'all_courses'        
        AND pivot_ele.pgf_type = 'H'                     
       
       UNION ALL
              
       --A1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_A1' AS pivot_on
	         ,CAST(pivot_ele.grade_1 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'A'
       
       UNION ALL
        
        --A2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_A2' AS pivot_on
	         ,CAST(pivot_ele.grade_2 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'A'
       
       UNION ALL
        
        --A3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_A3' AS pivot_on
	         ,CAST(pivot_ele.grade_3 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'A'                     
       
       UNION ALL
       
        --Q1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q1' AS pivot_on
	         ,CAST(pivot_ele.grade_1 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'Q'
       
       UNION ALL
        
        --Q2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q2' AS pivot_on
	         ,CAST(pivot_ele.grade_2 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'Q'
       
       UNION ALL
        
        --Q3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q3' AS pivot_on
	         ,CAST(pivot_ele.grade_3 AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'Q'              
       
       UNION ALL 
       
         --QY1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_QY1' AS pivot_on
	         ,CAST(pivot_ele.simple_avg AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'Q'              
        
       UNION ALL
       
       --QY all courses
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'QY_all' AS pivot_on
	         ,CAST(pivot_ele.simple_avg AS VARCHAR) AS value
       FROM rost WITH (NOLOCK)
       JOIN KIPP_NJ..GRADES$elements pivot_ele WITH (NOLOCK)
         ON rost.studentid = pivot_ele.studentid
        AND pivot_ele.course_number = 'all_courses'        
        AND pivot_ele.pgf_type = 'Q'
       )sub
--/*
PIVOT (
  MAX(value) 
  FOR pivot_on 
  IN (rc1_course_number
     ,rc1_credittype
     ,rc1_course_name
     ,rc1_credit_hours_T1
     ,rc1_credit_hours_T2
     ,rc1_credit_hours_T3
     ,rc1_credit_hours_Y1
     ,rc1_teacher_last
     ,rc1_teacher_lastfirst
     ,rc1_t1
     ,rc1_t2
     ,rc1_t3
     ,rc1_y1
     ,rc1_t1_ltr
     ,rc1_t2_ltr
     ,rc1_t3_ltr
     ,rc1_y1_ltr
     ,rc1_t1_enr_sectionid
     ,rc1_t2_enr_sectionid
     ,rc1_t3_enr_sectionid
     ,rc1_gpa_points_t1
     ,rc1_gpa_points_t2
     ,rc1_gpa_points_t3
     ,rc1_gpa_points_y1
     ,rc1_weighted_points_t1
     ,rc1_weighted_points_t2
     ,rc1_weighted_points_t3
     ,rc1_weighted_points_y1
     ,rc1_H1
     ,rc1_H2
     ,rc1_H3
     ,rc1_HY1
     ,rc1_A1
     ,rc1_A2
     ,rc1_A3
     ,rc1_Q1
     ,rc1_Q2
     ,rc1_Q3
     ,rc1_QY1
     ,rc2_course_number
     ,rc2_credittype
     ,rc2_course_name
     ,rc2_credit_hours_T1
     ,rc2_credit_hours_T2
     ,rc2_credit_hours_T3
     ,rc2_credit_hours_Y1
     ,rc2_teacher_last
     ,rc2_teacher_lastfirst
     ,rc2_t1
     ,rc2_t2
     ,rc2_t3
     ,rc2_y1
     ,rc2_t1_ltr
     ,rc2_t2_ltr
     ,rc2_t3_ltr
     ,rc2_y1_ltr
     ,rc2_t1_enr_sectionid
     ,rc2_t2_enr_sectionid
     ,rc2_t3_enr_sectionid
     ,rc2_gpa_points_t1
     ,rc2_gpa_points_t2
     ,rc2_gpa_points_t3
     ,rc2_gpa_points_y1
     ,rc2_weighted_points_t1
     ,rc2_weighted_points_t2
     ,rc2_weighted_points_t3
     ,rc2_weighted_points_y1
     ,rc2_H1
     ,rc2_H2
     ,rc2_H3
     ,rc2_HY1
     ,rc2_A1
     ,rc2_A2
     ,rc2_A3
     ,rc2_Q1
     ,rc2_Q2
     ,rc2_Q3
     ,rc2_QY1
     ,rc3_course_number
     ,rc3_credittype
     ,rc3_course_name
     ,rc3_credit_hours_T1
     ,rc3_credit_hours_T2
     ,rc3_credit_hours_T3
     ,rc3_credit_hours_Y1
     ,rc3_teacher_last
     ,rc3_teacher_lastfirst
     ,rc3_t1
     ,rc3_t2
     ,rc3_t3
     ,rc3_y1
     ,rc3_t1_ltr
     ,rc3_t2_ltr
     ,rc3_t3_ltr
     ,rc3_y1_ltr
     ,rc3_t1_enr_sectionid
     ,rc3_t2_enr_sectionid
     ,rc3_t3_enr_sectionid
     ,rc3_gpa_points_t1
     ,rc3_gpa_points_t2
     ,rc3_gpa_points_t3
     ,rc3_gpa_points_y1
     ,rc3_weighted_points_t1
     ,rc3_weighted_points_t2
     ,rc3_weighted_points_t3
     ,rc3_weighted_points_y1
     ,rc3_H1
     ,rc3_H2
     ,rc3_H3
     ,rc3_HY1
     ,rc3_A1
     ,rc3_A2
     ,rc3_A3
     ,rc3_Q1
     ,rc3_Q2
     ,rc3_Q3
     ,rc3_QY1
     ,rc4_course_number
     ,rc4_credittype
     ,rc4_course_name
     ,rc4_credit_hours_T1
     ,rc4_credit_hours_T2
     ,rc4_credit_hours_T3
     ,rc4_credit_hours_Y1
     ,rc4_teacher_last
     ,rc4_teacher_lastfirst
     ,rc4_t1
     ,rc4_t2
     ,rc4_t3
     ,rc4_y1
     ,rc4_t1_ltr
     ,rc4_t2_ltr
     ,rc4_t3_ltr
     ,rc4_y1_ltr
     ,rc4_t1_enr_sectionid
     ,rc4_t2_enr_sectionid
     ,rc4_t3_enr_sectionid
     ,rc4_gpa_points_t1
     ,rc4_gpa_points_t2
     ,rc4_gpa_points_t3
     ,rc4_gpa_points_y1
     ,rc4_weighted_points_t1
     ,rc4_weighted_points_t2
     ,rc4_weighted_points_t3
     ,rc4_weighted_points_y1
     ,rc4_H1
     ,rc4_H2
     ,rc4_H3
     ,rc4_HY1
     ,rc4_A1
     ,rc4_A2
     ,rc4_A3
     ,rc4_Q1
     ,rc4_Q2
     ,rc4_Q3
     ,rc4_QY1
     ,rc5_course_number
     ,rc5_credittype
     ,rc5_course_name
     ,rc5_credit_hours_T1
     ,rc5_credit_hours_T2
     ,rc5_credit_hours_T3
     ,rc5_credit_hours_Y1
     ,rc5_teacher_last
     ,rc5_teacher_lastfirst
     ,rc5_t1
     ,rc5_t2
     ,rc5_t3
     ,rc5_y1
     ,rc5_t1_ltr
     ,rc5_t2_ltr
     ,rc5_t3_ltr
     ,rc5_y1_ltr
     ,rc5_t1_enr_sectionid
     ,rc5_t2_enr_sectionid
     ,rc5_t3_enr_sectionid
     ,rc5_gpa_points_t1
     ,rc5_gpa_points_t2
     ,rc5_gpa_points_t3
     ,rc5_gpa_points_y1
     ,rc5_weighted_points_t1
     ,rc5_weighted_points_t2
     ,rc5_weighted_points_t3
     ,rc5_weighted_points_y1
     ,rc5_H1
     ,rc5_H2
     ,rc5_H3
     ,rc5_HY1
     ,rc5_A1
     ,rc5_A2
     ,rc5_A3
     ,rc5_Q1
     ,rc5_Q2
     ,rc5_Q3
     ,rc5_QY1
     ,HY_all
     ,QY_all
     )
) AS pwn3d
--*/
