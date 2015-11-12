USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_tracker#Rise AS

WITH curterm AS (
  SELECT time_per_name
        ,alt_name AS term
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'
    AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND schoolid = 73252
    AND CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date
 )

,roster AS (
  SELECT co.studentid AS id
        ,co.student_number
        ,co.year
        ,co.schoolid
        ,co.lastfirst
        ,co.grade_level
        ,co.team
        ,co.advisor       
        ,co.SPEDLEP
        ,co.gender
        ,co.mother
        ,co.father       
        ,co.home_phone
        ,co.mother_cell
        ,co.mother_home
        ,co.father_cell
        ,co.father_home
        ,co.guardianemail AS contactemail
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  WHERE co.schoolid = 73252
    AND co.enroll_status = 0
    AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND co.rn = 1
 )

,cur_hex AS (
  SELECT REPLACE(time_per_name,'Round ','Q') AS hex_a
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND schoolid = 73252
    AND identifier = 'AR'
    AND CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date
 )

,fandp AS (
  SELECT STUDENTID
        ,academic_year      
        ,read_lvl
        ,GLEQ
        ,lvl_num            
        ,ROW_NUMBER() OVER(
           PARTITION BY studentid, academic_year
             ORDER BY start_date ASC) AS rn_base
        ,ROW_NUMBER() OVER(
           PARTITION BY studentid, academic_year
             ORDER BY start_date DESC) AS rn_curr
  FROM KIPP_NJ..LIT$achieved_by_round#static WITH(NOLOCK)
  WHERE read_lvl IS NOT NULL
    AND SCHOOLID = 73252
    AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
)
       
SELECT ROW_NUMBER() OVER(
           ORDER BY roster.grade_level
                   ,roster.lastfirst) AS count
      ,roster.*
       
--ATTENDANCE
      --yr
      ,att_counts.Y1_ABS_ALL AS Y1_absences_total
      ,att_counts.Y1_A AS Y1_absences_undoc
      ,ROUND(att_pct.Y1_att_pct_total,0) AS Y1_att_pct_total
      ,ROUND(att_pct.Y1_att_pct_undoc,0) AS Y1_att_pct_undoc      
      ,att_counts.Y1_T_ALL AS Y1_tardies_total
      ,att_counts.Y1_T10 AS Y1_tardies_t10
      ,ROUND(att_pct.Y1_tardy_pct_total,0) AS Y1_tardy_pct_total
      --cur   
      ,att_counts.CUR_ABS_ALL AS curterm_absences_total
      ,att_counts.CUR_A AS curterm_absences_undoc
      ,ROUND(att_pct.cur_att_pct_total,0)      AS curterm_att_pct_total
      ,ROUND(att_pct.cur_att_pct_undoc,0)      AS curterm_att_pct_undoc      
      ,att_counts.CUR_T_ALL AS curterm_tardies_total
      ,att_counts.CUR_T10 AS curterm_tardies_t10
      ,ROUND(att_pct.cur_tardy_pct_total,0)    AS curterm_tardy_pct_total

--PROMOTIONAL STATUS
      ,promo.attendance_points
      ,ROUND(promo.y1_att_pts_pct,1) AS ATT_POINTS_PCT      
      ,promo.promo_overall_rise
      ,promo.promo_grades_gpa_rise AS promo_grades_rise
      ,promo.promo_att_rise
      ,promo.promo_hw_rise
      ,promo.days_to_90

--GPA      
      ,CONVERT(FLOAT,gpa.GPA_t1_all) AS gpa_t1
      ,gpa.rank_gr_t1_all AS GPA_T1_RANK
      ,CONVERT(FLOAT,gpa.GPA_t2_all) AS gpa_t2
      ,gpa.rank_gr_t2_all AS GPA_T2_RANK
      ,CONVERT(FLOAT,gpa.GPA_t3_all) AS gpa_t3
      ,gpa.rank_gr_t3_all AS GPA_T3_RANK
      ,CONVERT(FLOAT,gpa.GPA_y1_all) AS gpa_y1       
      ,gpa.rank_gr_y1_all AS GPA_Y1_RANK      
      ,gpa.elements_all
      ,gpa.failing_all
      ,gpa.n_failing_all      
      ,gpa.n_gr AS IN_GRADE_DENOM

--COURSE GRADES
      ,grades.rc1_course_number AS ENGLISH_course_number
      ,grades.rc1_credittype AS ENGLISH_credittype
      ,grades.rc1_course_name AS ENGLISH_course_name
      ,grades.rc1_credit_hours_T1 AS ENGLISH_credit_hours_T1
      ,grades.rc1_credit_hours_T2 AS ENGLISH_credit_hours_T2
      ,grades.rc1_credit_hours_T3 AS ENGLISH_credit_hours_T3
      ,grades.rc1_credit_hours_Y1 AS ENGLISH_credit_hours_Y1
      ,grades.rc1_teacher_last AS ENGLISH_teacher_last
      ,grades.rc1_teacher_lastfirst AS ENGLISH_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc1_t1) AS ENGLISH_t1
      ,CONVERT(FLOAT,grades.rc1_t2) AS ENGLISH_t2
      ,CONVERT(FLOAT,grades.rc1_t3) AS ENGLISH_t3
      ,CONVERT(FLOAT,grades.rc1_y1) AS ENGLISH_y1
      ,grades.rc1_t1_ltr AS ENGLISH_t1_ltr
      ,grades.rc1_t2_ltr AS ENGLISH_t2_ltr
      ,grades.rc1_t3_ltr AS ENGLISH_t3_ltr
      ,grades.rc1_y1_ltr AS ENGLISH_y1_ltr
      ,grades.rc1_t1_enr_sectionid AS ENGLISH_t1_enr_sectionid
      ,grades.rc1_t2_enr_sectionid AS ENGLISH_t2_enr_sectionid
      ,grades.rc1_t2_enr_sectionid AS ENGLISH_t3_enr_sectionid
      ,grades.rc1_gpa_points_t1 AS ENGLISH_gpa_points_t1
      ,grades.rc1_gpa_points_t2 AS ENGLISH_gpa_points_t2
      ,grades.rc1_gpa_points_t3 AS ENGLISH_gpa_points_t3
      ,grades.rc1_gpa_points_y1 AS ENGLISH_gpa_points_y1
      ,grades.rc1_weighted_points_t1 AS ENGLISH_weighted_points_t1
      ,grades.rc1_weighted_points_t2 AS ENGLISH_weighted_points_t2
      ,grades.rc1_weighted_points_t3 AS ENGLISH_weighted_points_t3
      ,grades.rc1_weighted_points_y1 AS ENGLISH_weighted_points_y1
      ,CONVERT(FLOAT,grades.rc1_H1)  AS ENGLISH_H1 
      ,CONVERT(FLOAT,grades.rc1_H2)  AS ENGLISH_H2 
      ,CONVERT(FLOAT,grades.rc1_H3)  AS ENGLISH_H3 
      ,CONVERT(FLOAT,grades.rc1_HY1) AS ENGLISH_HY1
      ,CONVERT(FLOAT,grades.rc1_Q1)  AS ENGLISH_Q1 
      ,CONVERT(FLOAT,grades.rc1_Q2)  AS ENGLISH_Q2 
      ,CONVERT(FLOAT,grades.rc1_Q3)  AS ENGLISH_Q3 
      ,CONVERT(FLOAT,grades.rc1_QY1) AS ENGLISH_QY1
      ,CONVERT(FLOAT,grades.rc1_A1) AS ENGLISH_A1
      ,CONVERT(FLOAT,grades.rc1_A2) AS ENGLISH_A2
      ,CONVERT(FLOAT,grades.rc1_A3) AS ENGLISH_A3
      
      ,grades.rc2_course_number AS RHET_course_number
      ,grades.rc2_credittype AS RHET_credittype
      ,grades.rc2_course_name AS RHET_course_name
      ,grades.rc2_credit_hours_T1 AS RHET_credit_hours_T1
      ,grades.rc2_credit_hours_T2 AS RHET_credit_hours_T2
      ,grades.rc2_credit_hours_T3 AS RHET_credit_hours_T3
      ,grades.rc2_credit_hours_Y1 AS RHET_credit_hours_Y1
      ,grades.rc2_teacher_last AS RHET_teacher_last
      ,grades.rc2_teacher_lastfirst AS RHET_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc2_t1) AS RHET_t1
      ,CONVERT(FLOAT,grades.rc2_t2) AS RHET_t2
      ,CONVERT(FLOAT,grades.rc2_t3) AS RHET_t3
      ,CONVERT(FLOAT,grades.rc2_y1) AS RHET_y1
      ,grades.rc2_t1_ltr AS RHET_t1_ltr
      ,grades.rc2_t2_ltr AS RHET_t2_ltr
      ,grades.rc2_t3_ltr AS RHET_t3_ltr
      ,grades.rc2_y1_ltr AS RHET_y1_ltr
      ,grades.rc2_t1_enr_sectionid AS RHET_t1_enr_sectionid
      ,grades.rc2_t2_enr_sectionid AS RHET_t2_enr_sectionid
      ,grades.rc2_t2_enr_sectionid AS RHET_t3_enr_sectionid
      ,grades.rc2_gpa_points_t1 AS RHET_gpa_points_t1
      ,grades.rc2_gpa_points_t2 AS RHET_gpa_points_t2
      ,grades.rc2_gpa_points_t3 AS RHET_gpa_points_t3
      ,grades.rc2_gpa_points_y1 AS RHET_gpa_points_y1
      ,grades.rc2_weighted_points_t1 AS RHET_weighted_points_t1
      ,grades.rc2_weighted_points_t2 AS RHET_weighted_points_t2
      ,grades.rc2_weighted_points_t3 AS RHET_weighted_points_t3
      ,grades.rc2_weighted_points_y1 AS RHET_weighted_points_y1
      ,CONVERT(FLOAT,grades.rc2_H1)  AS RHET_H1 
      ,CONVERT(FLOAT,grades.rc2_H2)  AS RHET_H2 
      ,CONVERT(FLOAT,grades.rc2_H3)  AS RHET_H3 
      ,CONVERT(FLOAT,grades.rc2_HY1) AS RHET_HY1
      ,CONVERT(FLOAT,grades.rc2_Q1)  AS RHET_Q1 
      ,CONVERT(FLOAT,grades.rc2_Q2)  AS RHET_Q2 
      ,CONVERT(FLOAT,grades.rc2_Q3)  AS RHET_Q3 
      ,CONVERT(FLOAT,grades.rc2_QY1) AS RHET_QY1
      ,CONVERT(FLOAT,grades.rc2_A1) AS RHET_A1
      ,CONVERT(FLOAT,grades.rc2_A2) AS RHET_A2
      ,CONVERT(FLOAT,grades.rc2_A3) AS RHET_A3
      
      ,grades.rc3_course_number AS MATH_course_number
      ,grades.rc3_credittype AS MATH_credittype
      ,grades.rc3_course_name AS MATH_course_name
      ,grades.rc3_credit_hours_T1 AS MATH_credit_hours_T1
      ,grades.rc3_credit_hours_T2 AS MATH_credit_hours_T2
      ,grades.rc3_credit_hours_T3 AS MATH_credit_hours_T3
      ,grades.rc3_credit_hours_Y1 AS MATH_credit_hours_Y1
      ,grades.rc3_teacher_last AS MATH_teacher_last
      ,grades.rc3_teacher_lastfirst AS MATH_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc3_t1) AS MATH_t1
      ,CONVERT(FLOAT,grades.rc3_t2) AS MATH_t2
      ,CONVERT(FLOAT,grades.rc3_t3) AS MATH_t3
      ,CONVERT(FLOAT,grades.rc3_y1) AS MATH_y1
      ,grades.rc3_t1_ltr AS MATH_t1_ltr
      ,grades.rc3_t2_ltr AS MATH_t2_ltr
      ,grades.rc3_t3_ltr AS MATH_t3_ltr
      ,grades.rc3_y1_ltr AS MATH_y1_ltr
      ,grades.rc3_t1_enr_sectionid AS MATH_t1_enr_sectionid
      ,grades.rc3_t2_enr_sectionid AS MATH_t2_enr_sectionid
      ,grades.rc3_t2_enr_sectionid AS MATH_t3_enr_sectionid
      ,grades.rc3_gpa_points_t1 AS MATH_gpa_points_t1
      ,grades.rc3_gpa_points_t2 AS MATH_gpa_points_t2
      ,grades.rc3_gpa_points_t3 AS MATH_gpa_points_t3
      ,grades.rc3_gpa_points_y1 AS MATH_gpa_points_y1
      ,grades.rc3_weighted_points_t1 AS MATH_weighted_points_t1
      ,grades.rc3_weighted_points_t2 AS MATH_weighted_points_t2
      ,grades.rc3_weighted_points_t3 AS MATH_weighted_points_t3
      ,grades.rc3_weighted_points_y1 AS MATH_weighted_points_y1
      ,CONVERT(FLOAT,grades.rc3_H1)  AS MATH_H1 
      ,CONVERT(FLOAT,grades.rc3_H2)  AS MATH_H2 
      ,CONVERT(FLOAT,grades.rc3_H3)  AS MATH_H3 
      ,CONVERT(FLOAT,grades.rc3_HY1) AS MATH_HY1
      ,CONVERT(FLOAT,grades.rc3_Q1)  AS MATH_Q1 
      ,CONVERT(FLOAT,grades.rc3_Q2)  AS MATH_Q2 
      ,CONVERT(FLOAT,grades.rc3_Q3)  AS MATH_Q3 
      ,CONVERT(FLOAT,grades.rc3_QY1) AS MATH_QY1
      ,CONVERT(FLOAT,grades.rc3_A1) AS MATH_A1
      ,CONVERT(FLOAT,grades.rc3_A2) AS MATH_A2
      ,CONVERT(FLOAT,grades.rc3_A3) AS MATH_A3
      
      ,grades.rc4_course_number AS SCIENCE_course_number
      ,grades.rc4_credittype AS SCIENCE_credittype
      ,grades.rc4_course_name AS SCIENCE_course_name
      ,grades.rc4_credit_hours_T1 AS SCIENCE_credit_hours_T1
      ,grades.rc4_credit_hours_T2 AS SCIENCE_credit_hours_T2
      ,grades.rc4_credit_hours_T3 AS SCIENCE_credit_hours_T3
      ,grades.rc4_credit_hours_Y1 AS SCIENCE_credit_hours_Y1
      ,grades.rc4_teacher_last AS SCIENCE_teacher_last
      ,grades.rc4_teacher_lastfirst AS SCIENCE_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc4_t1) AS SCIENCE_t1
      ,CONVERT(FLOAT,grades.rc4_t2) AS SCIENCE_t2
      ,CONVERT(FLOAT,grades.rc4_t3) AS SCIENCE_t3
      ,CONVERT(FLOAT,grades.rc4_y1) AS SCIENCE_y1
      ,grades.rc4_t1_ltr AS SCIENCE_t1_ltr
      ,grades.rc4_t2_ltr AS SCIENCE_t2_ltr
      ,grades.rc4_t3_ltr AS SCIENCE_t3_ltr
      ,grades.rc4_y1_ltr AS SCIENCE_y1_ltr
      ,grades.rc4_t1_enr_sectionid AS SCIENCE_t1_enr_sectionid
      ,grades.rc4_t2_enr_sectionid AS SCIENCE_t2_enr_sectionid
      ,grades.rc4_t2_enr_sectionid AS SCIENCE_t3_enr_sectionid
      ,grades.rc4_gpa_points_t1 AS SCIENCE_gpa_points_t1
      ,grades.rc4_gpa_points_t2 AS SCIENCE_gpa_points_t2
      ,grades.rc4_gpa_points_t3 AS SCIENCE_gpa_points_t3
      ,grades.rc4_gpa_points_y1 AS SCIENCE_gpa_points_y1
      ,grades.rc4_weighted_points_t1 AS SCIENCE_weighted_points_t1
      ,grades.rc4_weighted_points_t2 AS SCIENCE_weighted_points_t2
      ,grades.rc4_weighted_points_t3 AS SCIENCE_weighted_points_t3
      ,grades.rc4_weighted_points_y1 AS SCIENCE_weighted_points_y1
      ,CONVERT(FLOAT,grades.rc4_H1)  AS SCIENCE_H1 
      ,CONVERT(FLOAT,grades.rc4_H2)  AS SCIENCE_H2 
      ,CONVERT(FLOAT,grades.rc4_H3)  AS SCIENCE_H3 
      ,CONVERT(FLOAT,grades.rc4_HY1) AS SCIENCE_HY1
      ,CONVERT(FLOAT,grades.rc4_Q1)  AS SCIENCE_Q1 
      ,CONVERT(FLOAT,grades.rc4_Q2)  AS SCIENCE_Q2 
      ,CONVERT(FLOAT,grades.rc4_Q3)  AS SCIENCE_Q3 
      ,CONVERT(FLOAT,grades.rc4_QY1) AS SCIENCE_QY1
      ,CONVERT(FLOAT,grades.rc4_A1) AS SCIENCE_A1
      ,CONVERT(FLOAT,grades.rc4_A2) AS SCIENCE_A2
      ,CONVERT(FLOAT,grades.rc4_A3) AS SCIENCE_A3
      
      ,grades.rc5_course_number AS SOC_course_number
      ,grades.rc5_credittype AS SOC_credittype
      ,grades.rc5_course_name AS SOC_course_name
      ,grades.rc5_credit_hours_T1 AS SOC_credit_hours_T1
      ,grades.rc5_credit_hours_T2 AS SOC_credit_hours_T2
      ,grades.rc5_credit_hours_T3 AS SOC_credit_hours_T3
      ,grades.rc5_credit_hours_Y1 AS SOC_credit_hours_Y1
      ,grades.rc5_teacher_last AS SOC_teacher_last
      ,grades.rc5_teacher_lastfirst AS SOC_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc5_t1) AS SOC_t1
      ,CONVERT(FLOAT,grades.rc5_t2) AS SOC_t2
      ,CONVERT(FLOAT,grades.rc5_t3) AS SOC_t3
      ,CONVERT(FLOAT,grades.rc5_y1) AS SOC_y1
      ,grades.rc5_t1_ltr AS SOC_t1_ltr
      ,grades.rc5_t2_ltr AS SOC_t2_ltr
      ,grades.rc5_t3_ltr AS SOC_t3_ltr
      ,grades.rc5_y1_ltr AS SOC_y1_ltr
      ,grades.rc5_t1_enr_sectionid AS SOC_t1_enr_sectionid
      ,grades.rc5_t2_enr_sectionid AS SOC_t2_enr_sectionid
      ,grades.rc5_t2_enr_sectionid AS SOC_t3_enr_sectionid
      ,grades.rc5_gpa_points_t1 AS SOC_gpa_points_t1
      ,grades.rc5_gpa_points_t2 AS SOC_gpa_points_t2
      ,grades.rc5_gpa_points_t3 AS SOC_gpa_points_t3
      ,grades.rc5_gpa_points_y1 AS SOC_gpa_points_y1
      ,grades.rc5_weighted_points_t1 AS SOC_weighted_points_t1
      ,grades.rc5_weighted_points_t2 AS SOC_weighted_points_t2
      ,grades.rc5_weighted_points_t3 AS SOC_weighted_points_t3
      ,grades.rc5_weighted_points_y1 AS SOC_weighted_points_y1
      ,CONVERT(FLOAT,grades.rc5_H1)  AS SOC_H1 
      ,CONVERT(FLOAT,grades.rc5_H2)  AS SOC_H2 
      ,CONVERT(FLOAT,grades.rc5_H3)  AS SOC_H3 
      ,CONVERT(FLOAT,grades.rc5_HY1) AS SOC_HY1
      ,CONVERT(FLOAT,grades.rc5_Q1)  AS SOC_Q1 
      ,CONVERT(FLOAT,grades.rc5_Q2)  AS SOC_Q2 
      ,CONVERT(FLOAT,grades.rc5_Q3)  AS SOC_Q3 
      ,CONVERT(FLOAT,grades.rc5_QY1) AS SOC_QY1
      ,CONVERT(FLOAT,grades.rc5_A1) AS SOC_A1
      ,CONVERT(FLOAT,grades.rc5_A2) AS SOC_A2
      ,CONVERT(FLOAT,grades.rc5_A3) AS SOC_A3
      
      ,((CONVERT(FLOAT,ISNULL(grades.rc1_y1,0)) 
          + CONVERT(FLOAT,ISNULL(grades.rc2_y1,0)) 
          + CONVERT(FLOAT,ISNULL(grades.rc3_y1,0)) 
          + CONVERT(FLOAT,ISNULL(grades.rc4_y1,0)) 
          + CONVERT(FLOAT,ISNULL(grades.rc5_y1,0))) 
          / 
        CASE WHEN (CASE WHEN grades.rc1_y1 IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN grades.rc2_y1 IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN grades.rc3_y1 IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN grades.rc4_y1 IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN grades.rc5_y1 IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN NULL
             ELSE (CASE WHEN grades.rc1_y1 IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN grades.rc2_y1 IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN grades.rc3_y1 IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN grades.rc4_y1 IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN grades.rc5_y1 IS NOT NULL THEN 1 ELSE 0 END)
        END) AS Core_Avg
      ,CONVERT(FLOAT,grades.HY_all) AS HW_Avg
      ,CONVERT(FLOAT,grades.QY_all) AS HW_Q_Avg      

--Literacy tracking
--MAP$comprehensive#identifiers
--LIT$FP_test_events_long#identifiers#static

     --Lexile (from MAP)
     --update terms in JOIN
     ,lex_base.RITtoReadingScore AS BASE_LEX
     ,lex_curr.rittoreadingscore AS CUR_LEX
       --GLQ
     ,CASE
       WHEN lex_base.RITtoReadingScore  = 'BR' THEN 'Pre-K'
       WHEN lex_base.RITtoReadingScore <= 100  THEN 'K'
       WHEN lex_base.RITtoReadingScore <= 300  AND lex_base.RITtoReadingScore > 100  THEN '1st'
       WHEN lex_base.RITtoReadingScore <= 500  AND lex_base.RITtoReadingScore > 300  THEN '2nd'
       WHEN lex_base.RITtoReadingScore <= 600  AND lex_base.RITtoReadingScore > 500  THEN '3rd'
       WHEN lex_base.RITtoReadingScore <= 700  AND lex_base.RITtoReadingScore > 600  THEN '4th'
       WHEN lex_base.RITtoReadingScore <= 800  AND lex_base.RITtoReadingScore > 700  THEN '5th'
       WHEN lex_base.RITtoReadingScore <= 900  AND lex_base.RITtoReadingScore > 800  THEN '6th'
       WHEN lex_base.RITtoReadingScore <= 1000 AND lex_base.RITtoReadingScore > 900  THEN '7th'
       WHEN lex_base.RITtoReadingScore <= 1100 AND lex_base.RITtoReadingScore > 1000 THEN '8th'
       WHEN lex_base.RITtoReadingScore <= 1200 AND lex_base.RITtoReadingScore > 1100 THEN '9th'
       WHEN lex_base.RITtoReadingScore <= 1300 AND lex_base.RITtoReadingScore > 1200 THEN '10th'
       WHEN lex_base.RITtoReadingScore <= 1400 AND lex_base.RITtoReadingScore > 1300 THEN '11th'
       WHEN lex_base.RITtoReadingScore  > 1400 THEN '12th'
       ELSE NULL
      END AS BASE_LEX_GLQ_STARTING
     ,CASE
       WHEN lex_curr.RITtoReadingScore  = 'BR' THEN 'Pre-K'
       WHEN lex_curr.RITtoReadingScore <= 100  THEN 'K'
       WHEN lex_curr.RITtoReadingScore <= 300  AND lex_curr.RITtoReadingScore > 100  THEN '1st'
       WHEN lex_curr.RITtoReadingScore <= 500  AND lex_curr.RITtoReadingScore > 300  THEN '2nd'
       WHEN lex_curr.RITtoReadingScore <= 600  AND lex_curr.RITtoReadingScore > 500  THEN '3rd'
       WHEN lex_curr.RITtoReadingScore <= 700  AND lex_curr.RITtoReadingScore > 600  THEN '4th'
       WHEN lex_curr.RITtoReadingScore <= 800  AND lex_curr.RITtoReadingScore > 700  THEN '5th'
       WHEN lex_curr.RITtoReadingScore <= 900  AND lex_curr.RITtoReadingScore > 800  THEN '6th'
       WHEN lex_curr.RITtoReadingScore <= 1000 AND lex_curr.RITtoReadingScore > 900  THEN '7th'
       WHEN lex_curr.RITtoReadingScore <= 1100 AND lex_curr.RITtoReadingScore > 1000 THEN '8th'
       WHEN lex_curr.RITtoReadingScore <= 1200 AND lex_curr.RITtoReadingScore > 1100 THEN '9th'
       WHEN lex_curr.RITtoReadingScore <= 1300 AND lex_curr.RITtoReadingScore > 1200 THEN '10th'
       WHEN lex_curr.RITtoReadingScore <= 1400 AND lex_curr.RITtoReadingScore > 1300 THEN '11th'
       WHEN lex_curr.RITtoReadingScore  > 1400 THEN '12th'
       ELSE NULL
      END AS BASE_LEX_GLQ_CURRENT

     --F&P     
     ,COALESCE(fp_base.read_lvl, fp_curr.read_lvl) AS start_letter
     ,fp_curr.read_lvl AS end_letter
     --GLEQ
     ,COALESCE(fp_base.GLEQ,fp_curr.GLEQ) AS Start_GLEQ
     ,fp_curr.GLEQ AS End_GLEQ
     ,(fp_curr.GLEQ - COALESCE(fp_base.GLEQ,fp_curr.GLEQ)) AS GLEQ_Growth
     --Level #
     ,COALESCE(fp_base.lvl_num, fp_curr.lvl_num) AS [Start_#]
     ,fp_curr.lvl_num AS [End_#]
     ,(fp_curr.lvl_num - COALESCE(fp_base.lvl_num, fp_curr.lvl_num)) AS [Levels_grown]
      
--Accelerated Reader
--AR year
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, ar_yr.words),1),'.00','') AS words_read_yr
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, ar_yr.words_goal),1),'.00','') AS words_goal_yr      
     ,ar_yr.rank_words_grade_in_school AS words_rank_yr_in_grade
     ,CONVERT(FLOAT,ar_yr.mastery) AS mastery_yr
     ,NULL AS ONTRACK_WORDS_YR
     
     --AR current
     --current trimester = current HEX + previous HEX
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar_curr.words)),'.00','') AS words_read_cur_term
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, ar_curr.words_goal)),'.00','') AS words_goal_cur_term
     ,ar_curr.rank_words_grade_in_school AS words_rank_cur_term_in_grade
     --,CONVERT(FLOAT,NULL AS mastery_curr
      
      --AR progress
        --to year goal      
     ,CASE
       WHEN ar_yr.stu_status_words = 'On Track' THEN 'Yes!'
       WHEN ar_yr.stu_status_words = 'Off Track' THEN 'No'
       ELSE ar_yr.stu_status_words
      END AS stu_status_words_yr   
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,CAST(ROUND(
       CASE
        WHEN ((ar_curr.words_goal * 6) - ar_yr.words) <= 0 THEN NULL 
        ELSE (ar_curr.words_goal * 6) - ar_yr.words
       END,0) AS INT)),1),'.00','') AS words_needed_yr
      --to term goal       
     ,CASE
       WHEN ar_curr.words_goal - ar_curr.words <= 0 THEN 'Met Goal'
       WHEN ar_curr.stu_status_words IN ('On Track','Met Goal') THEN 'Yes!'
       WHEN ar_curr.stu_status_words IN ('On Track','Met Goal') THEN 'Yes!'
       WHEN ar_curr.stu_status_words IN ('Off Track','Missed Goal') THEN 'Yes!'
       WHEN ar_curr.stu_status_words IN ('Off Track','Missed Goal') THEN 'No'              
       ELSE ar_curr.stu_status_words
      END AS stu_status_words_cur_term
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,CAST(ROUND(
       CASE
        WHEN ar_curr.words_goal - ar_curr.words <= 0 THEN NULL 
        ELSE ar_curr.words_goal - ar_curr.words
       END,0) AS INT)),1),'.00','') AS words_needed_cur_term     
      
--MAP scores
/*--UPDATE FIELDS FOR CURRENT YEAR--*/
--15-16
      --reading
      ,map_all.spr_2016_read_pctle
      ,map_all.w_2016_read_pctle
      ,map_all.f_2015_read_pctle      
      ,map_all.spr_2016_read_rit
      ,map_all.w_2016_read_rit
      ,map_all.f_2015_read_rit                  
      --math
      ,map_all.spr_2016_math_pctle
      ,map_all.w_2016_math_pctle
      ,map_all.f_2015_math_pctle      
      ,map_all.spr_2016_math_rit
      ,map_all.w_2016_math_rit
      ,map_all.f_2015_math_rit
      --lang
      ,map_all.spr_2016_lang_pctle
      ,map_all.w_2016_lang_pctle
      ,map_all.f_2015_lang_pctle
      ,map_all.spr_2016_lang_rit
      ,map_all.w_2016_lang_rit
      ,map_all.f_2015_lang_rit            
      --sci
      ,map_all.spr_2016_gen_pctle
      ,map_all.w_2016_GEN_pctle
      ,map_all.f_2015_gen_pctle
      ,map_all.spr_2016_gen_rit
      ,map_all.w_2016_GEN_RIT
      ,map_all.f_2015_gen_rit

--14-15
      --reading
      ,map_all.spr_2015_read_pctle
      ,map_all.w_2015_read_pctle
      ,map_all.f_2014_read_pctle      
      ,map_all.spr_2015_read_rit
      ,map_all.w_2015_read_rit
      ,map_all.f_2014_read_rit                  
      --math
      ,map_all.spr_2015_math_pctle
      ,map_all.w_2015_math_pctle
      ,map_all.f_2014_math_pctle      
      ,map_all.spr_2015_math_rit
      ,map_all.w_2015_math_rit
      ,map_all.f_2014_math_rit
      --lang
      ,map_all.spr_2015_lang_pctle
      ,map_all.w_2015_lang_pctle
      ,map_all.f_2014_lang_pctle
      ,map_all.spr_2015_lang_rit
      ,map_all.w_2015_lang_rit
      ,map_all.f_2014_lang_rit            
      --sci
      ,map_all.spr_2015_gen_pctle
      ,map_all.w_2015_GEN_pctle
      ,map_all.f_2014_gen_pctle
      ,map_all.spr_2015_gen_rit
      ,map_all.w_2015_GEN_RIT
      ,map_all.f_2014_gen_rit
     
 --13-14
      --reading
      ,map_all.spr_2014_read_pctle
      ,map_all.w_2014_read_pctle
      ,map_all.f_2013_read_pctle      
      ,map_all.spr_2014_read_rit
      ,map_all.w_2014_read_rit
      ,map_all.f_2013_read_rit                  
      --math
      ,map_all.spr_2014_math_pctle
      ,map_all.w_2014_math_pctle
      ,map_all.f_2013_math_pctle      
      ,map_all.spr_2014_math_rit
      ,map_all.w_2014_math_rit
      ,map_all.f_2013_math_rit
      --lang
      ,map_all.spr_2014_lang_pctle
      ,map_all.w_2014_lang_pctle
      ,map_all.f_2013_lang_pctle
      ,map_all.spr_2014_lang_rit
      ,map_all.w_2014_lang_rit
      ,map_all.f_2013_lang_rit            
      --sci
      ,map_all.spr_2014_gen_pctle
      ,map_all.w_2014_GEN_pctle
      ,map_all.f_2013_gen_pctle
      ,map_all.spr_2014_gen_rit
      ,map_all.w_2014_GEN_RIT
      ,map_all.f_2013_gen_rit

 --12-13
      --reading
      ,map_all.spr_2013_read_pctle
      ,map_all.w_2013_read_pctle
      ,map_all.f_2012_read_pctle      
      ,map_all.spr_2013_read_rit
      ,map_all.w_2013_read_rit
      ,map_all.f_2012_read_rit                  
      --math
      ,map_all.spr_2013_math_pctle
      ,map_all.w_2013_math_pctle
      ,map_all.f_2012_math_pctle      
      ,map_all.spr_2013_math_rit
      ,map_all.w_2013_math_rit
      ,map_all.f_2012_math_rit
      --lang
      ,map_all.spr_2013_lang_pctle
      ,map_all.w_2013_lang_pctle
      ,map_all.f_2012_lang_pctle
      ,map_all.spr_2013_lang_rit
      ,map_all.w_2013_lang_rit
      ,map_all.f_2012_lang_rit            
      --sci
      ,map_all.spr_2013_gen_pctle
      ,map_all.w_2013_GEN_pctle
      ,map_all.f_2012_gen_pctle
      ,map_all.spr_2013_gen_rit
      ,map_all.w_2013_GEN_RIT
      ,map_all.f_2012_gen_rit
     
--NJASK scores
--NJASK$ela_wide
--NJASK$math_wide      
/*--UPDATE FIELDS FOR CURRENT YEAR--*/

--13-14      
      --Grade
      ,NULL AS njask_gr_lev_2014
      --ELA
      ,NULL AS ela_score_2014
      ,NULL AS ela_prof_2014      
      --Math
      ,NULL AS math_score_2014
      ,NULL AS math_prof_2014

--12-13
      --Grade
      ,NULL AS njask_gr_lev_2013
      --ELA
      ,NULL AS ela_score_2013
      ,NULL AS ela_prof_2013      
      --Math
      ,NULL AS math_score_2013
      ,NULL AS math_prof_2013

--11-12      
      --Grade
      ,NULL AS njask_gr_lev_2012
      --ELA
      ,NULL AS ela_score_2012
      ,NULL AS ela_prof_2012      
      --Math
      ,NULL AS math_score_2012
      ,NULL AS math_prof_2012      

--10-11
      --Grade
      ,NULL AS njask_gr_lev_2011
      --ELA
      ,NULL AS ela_score_2011
      ,NULL AS ela_prof_2011      
      --Math
      ,NULL AS math_score_2011
      ,NULL AS math_prof_2011

--DISCIPLINE
--DISC$log#static
      ,disc_recent.disc_01_date_reported
      ,disc_recent.disc_01_given_by
      ,CASE
        WHEN disc_recent.disc_01_subject IS NULL THEN disc_recent.disc_01_incident 
        ELSE disc_recent.disc_01_subject
       END AS disc_01_incident
      ,disc_recent.disc_02_date_reported
      ,disc_recent.disc_02_given_by
      ,CASE 
        WHEN disc_recent.disc_02_subject IS NULL THEN disc_recent.disc_02_incident 
        ELSE disc_recent.disc_02_subject
       END AS disc_02_incident
      ,disc_recent.disc_03_date_reported
      ,disc_recent.disc_03_given_by
      ,CASE
        WHEN disc_recent.disc_03_subject IS NULL THEN disc_recent.disc_03_incident 
        ELSE disc_recent.disc_03_subject
       END AS disc_03_incident
      ,disc_recent.disc_04_date_reported
      ,disc_recent.disc_04_given_by
      ,CASE
        WHEN disc_recent.disc_04_subject IS NULL THEN disc_recent.disc_04_incident 
        ELSE disc_recent.disc_04_subject
       END AS disc_04_incident
      ,disc_recent.disc_05_date_reported
      ,disc_recent.disc_05_given_by
      ,CASE
        WHEN disc_recent.disc_05_subject IS NULL THEN disc_recent.disc_05_incident 
        ELSE disc_recent.disc_05_subject
       END AS disc_05_incident
            
      ,CASE WHEN roster.grade_level <= 6 THEN 'Bench' ELSE 'Choices' END AS bench_choices_label
      ,CASE WHEN (disc_count.iss + disc_count.oss) > 0 THEN 'Yes' ELSE 'No' END AS ISS_OSS
      ,ISNULL(disc_count.silent_lunches,0) AS Y1_silent_lunches      
      ,ISNULL(disc_count.rt1_silent_lunches,0) AS t1_silent_lunches
      ,ISNULL(disc_count.rt2_silent_lunches,0) AS t2_silent_lunches
      ,ISNULL(disc_count.rt3_silent_lunches,0) AS t3_silent_lunches
      ,ISNULL(disc_count.detentions,0) AS Y1_detentions      
      ,ISNULL(disc_count.rt1_detentions,0) AS t1_detentions
      ,ISNULL(disc_count.rt2_detentions,0) AS t2_detentions      
      ,ISNULL(disc_count.rt3_detentions,0) AS t3_detentions
      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.bench,0) ELSE ISNULL(disc_count.choices,0) END AS Y1_bench_choices      
      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt1_bench,0) ELSE ISNULL(disc_count.rt1_choices,0) END AS T1_bench_choices
      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt2_bench,0) ELSE ISNULL(disc_count.rt2_choices,0) END AS T2_bench_choices
      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt3_bench,0) ELSE ISNULL(disc_count.rt3_choices,0) END AS T3_bench_choices

--Extracurriculars
--RutgersReady..XC$activities_wide
      ,NULL AS xc_Fall_1
      ,NULL AS xc_Fall_2
      ,NULL AS xc_Winter_1
      ,NULL AS xc_Winter_2
      ,NULL AS xc_Spring_1
      ,NULL AS xc_Spring_2
      ,NULL AS xc_WinterSpring_1
      ,NULL AS xc_WinterSpring_2
      ,NULL AS xc_YearRound_1
      ,NULL AS xc_YearRound_2
      ,ISNULL(xc.activity_hash, 'None') AS activity_hash
      
FROM roster WITH (NOLOCK)

--Attendance
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts#static att_counts WITH (NOLOCK)
  ON roster.id = att_counts.studentid
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$att_percentages att_pct WITH (NOLOCK)
  ON roster.id = att_pct.studentid
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$membership_counts#static membership_counts WITH (NOLOCK)
  ON roster.id = membership_counts.studentid

--Grades & GPA
LEFT OUTER JOIN KIPP_NJ..GRADES$wide_credit_core#MS#static grades WITH (NOLOCK)
  ON roster.ID = grades.studentid
LEFT OUTER JOIN KIPP_NJ..GPA$detail#MS gpa WITH (NOLOCK)
  ON roster.id = gpa.studentid
LEFT OUTER JOIN KIPP_NJ..REPORTING$promo_status#MS promo WITH (NOLOCK)
  ON roster.id = promo.studentid
  
--LITERACY
  --F&P
LEFT OUTER JOIN fandp fp_base WITH (NOLOCK)
  ON roster.id = fp_base.studentid
 AND roster.year = fp_base.academic_year
 AND fp_base.rn_base = 1 
LEFT OUTER JOIN fandp fp_curr WITH (NOLOCK)
  ON roster.id = fp_curr.studentid 
 AND roster.year = fp_curr.academic_year
 AND fp_curr.rn_curr = 1 
  --LEXILE
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static lex_base WITH (NOLOCK)
  ON roster.student_number = lex_base.student_number
 AND roster.year = lex_base.academic_year
 AND lex_base.MeasurementScale = 'Reading'
 AND lex_base.rn_base = 1 
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static lex_curr WITH (NOLOCK)
  ON roster.student_number = lex_curr.student_number
 AND roster.year = lex_curr.academic_year
 AND lex_curr.MeasurementScale = 'Reading'
 AND lex_curr.rn_curr = 1
   
--ED TECH
  --ACCELERATED READER
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON roster.id = ar_yr.studentid 
 AND roster.year = ar_yr.academic_year
 AND ar_yr.time_period_name = 'Year' 
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_curr WITH (NOLOCK)
  ON roster.id = ar_curr.studentid 
 AND roster.year = ar_curr.academic_year 
 AND ar_curr.time_period_name = (SELECT hex_a FROM cur_hex)

--MAP
LEFT OUTER JOIN KIPP_NJ..MAP$wide_all#static map_all WITH (NOLOCK)
  ON roster.id = map_all.studentid
  
--Discipline
LEFT OUTER JOIN KIPP_NJ..DISC$recent_incidents_wide disc_recent WITH (NOLOCK)
  ON roster.id = disc_recent.studentid
 AND disc_recent.log_type = 'Discipline'
LEFT OUTER JOIN KIPP_NJ..DISC$counts_wide disc_count WITH (NOLOCK)
  ON roster.id = disc_count.studentid
  
--XC
LEFT OUTER JOIN KIPP_NJ..XC$activities_wide xc WITH(NOLOCK)
  ON roster.STUDENT_NUMBER = xc.student_number
 AND roster.year = xc.academic_year