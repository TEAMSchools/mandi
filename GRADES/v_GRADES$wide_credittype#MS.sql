--testing pivot by credit type 09/14

USE KIPP_NJ
GO

ALTER VIEW GRADES$wide_credit_core#MS AS

WITH rost AS
  (SELECT *
   FROM KIPP_NJ..GRADES$detail_placeholder#MS
   )

   
  
SELECT *
FROM
       --course number
       (SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_course_number' AS pivot_on
	            ,pivot_ele.course_number AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit type
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credittype' AS pivot_on
	            ,pivot_ele.credittype AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --course name   
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_course_name' AS pivot_on
	            ,pivot_ele.course_name AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours T1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_T1' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_t1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours T2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_T2' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_t2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours T3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_T3' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_t3 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --credit hours Y1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_credit_hours_Y1' AS pivot_on
	            ,CAST(pivot_ele.credit_hours_y1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
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
       
       --T1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T1' AS pivot_on
	            ,CAST(pivot_ele.T1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --T2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T2' AS pivot_on
	            ,CAST(pivot_ele.T2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --T3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T3' AS pivot_on
	            ,CAST(pivot_ele.T3 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --Y1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Y1' AS pivot_on
	            ,CAST(pivot_ele.Y1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
 
       --T1 ltr
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T1_ltr' AS pivot_on
	         ,CAST(pivot_ele.T1_LETTER AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
  
       UNION ALL

       --T2 ltr
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T2_ltr' AS pivot_on
	         ,CAST(pivot_ele.T2_LETTER AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
       
       UNION ALL
       
       --T3 ltr
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T3_ltr' AS pivot_on
	         ,CAST(pivot_ele.T3_LETTER AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
       
       UNION ALL
       
       --Y1 ltr
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Y1_ltr' AS pivot_on
	         ,CAST(pivot_ele.Y1_LETTER AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
       
       UNION ALL
       
       --T1 enr sectionid
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_t1_enr_sectionid' AS pivot_on
	            ,CAST(pivot_ele.t1_enr_sectionid AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --T2 enr sectionid
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_t2_enr_sectionid' AS pivot_on
	            ,CAST(pivot_ele.t2_enr_sectionid AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --T3 enr sectionid
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_t3_enr_sectionid' AS pivot_on
	            ,CAST(pivot_ele.t3_enr_sectionid AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
/*
       UNION ALL
       
       --gpa points t1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_t1' AS pivot_on
	            ,CAST(pivot_ele.gpa_points_t1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --gpa points t2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_t2' AS pivot_on
	            ,CAST(pivot_ele.gpa_points_t2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --gpa points t3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_t3' AS pivot_on
	            ,CAST(pivot_ele.gpa_points_t3 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --gpa points y1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_gpa_points_y1' AS pivot_on
	            ,CAST(pivot_ele.gpa_points_y1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --weighted points t1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_t1' AS pivot_on
	            ,CAST(pivot_ele.weighted_points_t1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --weighted points t2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_t2' AS pivot_on
	            ,CAST(pivot_ele.weighted_points_t2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --weighted points t3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_t3' AS pivot_on
	            ,CAST(pivot_ele.weighted_points_t3 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       --weighted points y1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_weighted_points_y1' AS pivot_on
	            ,CAST(pivot_ele.weighted_points_y1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
*/        
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
       
       UNION ALL
       
        --Q1
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q1' AS pivot_on
	         ,CAST(pivot_ele.grade_1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$elements pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'Q'
       
       UNION ALL
        
        --Q2
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q1' AS pivot_on
	         ,CAST(pivot_ele.grade_2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$elements pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'Q'
       
       UNION ALL
        
        --Q3
       SELECT rost.studentid, rost.student_number, rost.schoolid, rost.lastfirst, rost.grade_level
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_Q1' AS pivot_on
	         ,CAST(pivot_ele.grade_3 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$elements pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
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
/*
     ,rc1_gpa_points_t1
     ,rc1_gpa_points_t2
     ,rc1_gpa_points_t3
     ,rc1_gpa_points_y1
     ,rc1_weighted_points_t1
     ,rc1_weighted_points_t2
     ,rc1_weighted_points_t3
     ,rc1_weighted_points_y1
*/
     ,rc1_H1
     ,rc1_H2
     ,rc1_H3
     ,rc1_A1
     ,rc1_A2
     ,rc1_A3
     ,rc1_Q1
     ,rc1_Q2
     ,rc1_Q3
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
/*
     ,rc2_gpa_points_t1
     ,rc2_gpa_points_t2
     ,rc2_gpa_points_t3
     ,rc2_gpa_points_y1
     ,rc2_weighted_points_t1
     ,rc2_weighted_points_t2
     ,rc2_weighted_points_t3
     ,rc2_weighted_points_y1
*/
     ,rc2_H1
     ,rc2_H2
     ,rc2_H3
     ,rc2_A1
     ,rc2_A2
     ,rc2_A3
     ,rc2_Q1
     ,rc2_Q2
     ,rc2_Q3
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
/*
     ,rc3_gpa_points_t1
     ,rc3_gpa_points_t2
     ,rc3_gpa_points_t3
     ,rc3_gpa_points_y1
     ,rc3_weighted_points_t1
     ,rc3_weighted_points_t2
     ,rc3_weighted_points_t3
     ,rc3_weighted_points_y1
*/
     ,rc3_H1
     ,rc3_H2
     ,rc3_H3
     ,rc3_A1
     ,rc3_A2
     ,rc3_A3
     ,rc3_Q1
     ,rc3_Q2
     ,rc3_Q3
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
/*
     ,rc4_gpa_points_t1
     ,rc4_gpa_points_t2
     ,rc4_gpa_points_t3
     ,rc4_gpa_points_y1
     ,rc4_weighted_points_t1
     ,rc4_weighted_points_t2
     ,rc4_weighted_points_t3
     ,rc4_weighted_points_y1
*/
     ,rc4_H1
     ,rc4_H2
     ,rc4_H3
     ,rc4_A1
     ,rc4_A2
     ,rc4_A3
     ,rc4_Q1
     ,rc4_Q2
     ,rc4_Q3
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
/*
     ,rc5_gpa_points_t1
     ,rc5_gpa_points_t2
     ,rc5_gpa_points_t3
     ,rc5_gpa_points_y1
     ,rc5_weighted_points_t1
     ,rc5_weighted_points_t2
     ,rc5_weighted_points_t3
     ,rc5_weighted_points_y1
*/
     ,rc5_H1
     ,rc5_H2
     ,rc5_H3
     ,rc5_A1
     ,rc5_A2
     ,rc5_A3
     ,rc5_Q1
     ,rc5_Q2
     ,rc5_Q3
/*
     ,rc6_course_number
     ,rc6_credittype
     ,rc6_course_name
     ,rc6_credit_hours_T1
     ,rc6_credit_hours_T2
     ,rc6_credit_hours_T3
     ,rc6_credit_hours_Y1
     ,rc6_teacher_last
     ,rc6_teacher_lastfirst
     ,rc6_t1
     ,rc6_t2
     ,rc6_t3
     ,rc6_y1
     ,rc6_t1_ltr
     ,rc6_t2_ltr
     ,rc6_t3_ltr
     ,rc6_y1_ltr
     ,rc6_t1_enr_sectionid
     ,rc6_t2_enr_sectionid
     ,rc6_t3_enr_sectionid
     ,rc6_gpa_points_t1
     ,rc6_gpa_points_t2
     ,rc6_gpa_points_t3
     ,rc6_gpa_points_y1
     ,rc6_weighted_points_t1
     ,rc6_weighted_points_t2
     ,rc6_weighted_points_t3
     ,rc6_weighted_points_y1
     ,rc6_H1
     ,rc6_H2
     ,rc6_H3
     ,rc6_A1
     ,rc6_A2
     ,rc6_A3
     ,rc6_Q1
     ,rc6_Q2
     ,rc6_Q3
     ,rc7_course_number
     ,rc7_credittype
     ,rc7_course_name
     ,rc7_credit_hours_T1
     ,rc7_credit_hours_T2
     ,rc7_credit_hours_T3
     ,rc7_credit_hours_Y1
     ,rc7_teacher_last
     ,rc7_teacher_lastfirst
     ,rc7_t1
     ,rc7_t2
     ,rc7_t3
     ,rc7_y1
     ,rc7_t1_ltr
     ,rc7_t2_ltr
     ,rc7_t3_ltr
     ,rc7_y1_ltr
     ,rc7_t1_enr_sectionid
     ,rc7_t2_enr_sectionid
     ,rc7_t3_enr_sectionid
     ,rc7_gpa_points_t1
     ,rc7_gpa_points_t2
     ,rc7_gpa_points_t3
     ,rc7_gpa_points_y1
     ,rc7_weighted_points_t1
     ,rc7_weighted_points_t2
     ,rc7_weighted_points_t3
     ,rc7_weighted_points_y1
     ,rc7_H1
     ,rc7_H2
     ,rc7_H3
     ,rc7_A1
     ,rc7_A2
     ,rc7_A3
     ,rc7_Q1
     ,rc7_Q2
     ,rc7_Q3
     ,rc8_course_number
     ,rc8_credittype
     ,rc8_course_name
     ,rc8_credit_hours_T1
     ,rc8_credit_hours_T2
     ,rc8_credit_hours_T3
     ,rc8_credit_hours_Y1
     ,rc8_teacher_last
     ,rc8_teacher_lastfirst
     ,rc8_t1
     ,rc8_t2
     ,rc8_t3
     ,rc8_y1
     ,rc8_t1_ltr
     ,rc8_t2_ltr
     ,rc8_t3_ltr
     ,rc8_y1_ltr
     ,rc8_t1_enr_sectionid
     ,rc8_t2_enr_sectionid
     ,rc8_t3_enr_sectionid
     ,rc8_gpa_points_t1
     ,rc8_gpa_points_t2
     ,rc8_gpa_points_t3
     ,rc8_gpa_points_y1
     ,rc8_weighted_points_t1
     ,rc8_weighted_points_t2
     ,rc8_weighted_points_t3
     ,rc8_weighted_points_y1
     ,rc8_H1
     ,rc8_H2
     ,rc8_H3
     ,rc8_A1
     ,rc8_A2
     ,rc8_A3
     ,rc8_Q1
     ,rc8_Q2
     ,rc8_Q3
     ,rc9_course_number
     ,rc9_credittype
     ,rc9_course_name
     ,rc9_credit_hours_T1
     ,rc9_credit_hours_T2
     ,rc9_credit_hours_T3
     ,rc9_credit_hours_Y1
     ,rc9_teacher_last
     ,rc9_teacher_lastfirst
     ,rc9_t1
     ,rc9_t2
     ,rc9_t3
     ,rc9_y1
     ,rc9_t1_ltr
     ,rc9_t2_ltr
     ,rc9_t3_ltr
     ,rc9_y1_ltr
     ,rc9_t1_enr_sectionid
     ,rc9_t2_enr_sectionid
     ,rc9_t3_enr_sectionid
     ,rc9_gpa_points_t1
     ,rc9_gpa_points_t2
     ,rc9_gpa_points_t3
     ,rc9_gpa_points_y1
     ,rc9_weighted_points_t1
     ,rc9_weighted_points_t2
     ,rc9_weighted_points_t3
     ,rc9_weighted_points_y1
     ,rc9_H1
     ,rc9_H2
     ,rc9_H3
     ,rc9_A1
     ,rc9_A2
     ,rc9_A3
     ,rc9_Q1
     ,rc9_Q2
     ,rc9_Q3
     ,rc10_course_number
     ,rc10_credittype
     ,rc10_course_name
     ,rc10_credit_hours_T1
     ,rc10_credit_hours_T2
     ,rc10_credit_hours_T3
     ,rc10_credit_hours_Y1
     ,rc10_teacher_last
     ,rc10_teacher_lastfirst
     ,rc10_t1
     ,rc10_t2
     ,rc10_t3
     ,rc10_y1
     ,rc10_t1_ltr
     ,rc10_t2_ltr
     ,rc10_t3_ltr
     ,rc10_y1_ltr
     ,rc10_t1_enr_sectionid
     ,rc10_t2_enr_sectionid
     ,rc10_t3_enr_sectionid
     ,rc10_gpa_points_t1
     ,rc10_gpa_points_t2
     ,rc10_gpa_points_t3
     ,rc10_gpa_points_y1
     ,rc10_weighted_points_t1
     ,rc10_weighted_points_t2
     ,rc10_weighted_points_t3
     ,rc10_weighted_points_y1
     ,rc10_H1
     ,rc10_H2
     ,rc10_H3
     ,rc10_A1
     ,rc10_A2
     ,rc10_A3
     ,rc10_Q1
     ,rc10_Q2
     ,rc10_Q3
*/
     )
) AS pwn3d
--*/