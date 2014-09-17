USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_tracker#TEAM AS
WITH roster AS (
  SELECT s.id
        ,s.student_number
        ,s.schoolid
        ,s.lastfirst
        ,s.grade_level
        ,s.team
        ,cs.advisor       
        ,cs.SPEDLEP
        ,s.gender
        ,s.mother
        ,s.father       
        ,s.home_phone
        ,cs.mother_cell
        ,cs.mother_home
        ,cs.father_cell
        ,cs.father_home
        ,cs.guardianemail AS contactemail
  FROM STUDENTS s WITH (NOLOCK)
  LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH (NOLOCK)
    ON s.id = cs.studentid
  WHERE s.schoolid = 133570965
    AND s.enroll_status = 0
    --AND s.id = 4686
 )

,cur_hex AS (
  SELECT CASE 
          WHEN RIGHT(time_per_name, 1) IN (1, 3, 5) THEN 'RT' + RIGHT(time_per_name, 1)
          ELSE 'RT' + CONVERT(VARCHAR,RIGHT(time_per_name, 1) - 1)
         END AS hex_a
        ,CASE 
          WHEN RIGHT(time_per_name, 1) IN (1, 3, 5) THEN 'RT' + CONVERT(VARCHAR,RIGHT(time_per_name, 1) + 1)
          ELSE 'RT' + RIGHT(time_per_name, 1)
         END AS hex_b
  FROM REPORTING$dates
  WHERE academic_year = 2014
    AND schoolid = 73252
    AND identifier = 'HEX'
    AND start_date <= GETDATE()
    AND end_date >= GETDATE()
 )
       
SELECT ROW_NUMBER() OVER(
           ORDER BY roster.grade_level
                   ,roster.lastfirst) AS Count
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
      ,promo.promo_overall_team
      ,promo.promo_grades_team
      ,promo.promo_att_team
      ,promo.promo_hw_team
      ,promo.days_to_90

--GPA
      /*
      ,CONVERT(FLOAT,gpa.gpa_t1) AS gpa_t1
      ,gpa.GPA_T1_Rank_G AS GPA_T1_RANK
      ,CONVERT(FLOAT,gpa.gpa_t2) AS gpa_t2
      ,gpa.GPA_T2_Rank_G AS GPA_T2_RANK
      ,CONVERT(FLOAT,gpa.GPA_t3) AS gpa_t3
      ,gpa.GPA_T3_Rank_G AS GPA_T3_RANK
      ,CONVERT(FLOAT,gpa.gpa_y1) AS gpa_y1       
      ,gpa.GPA_Y1_Rank_G AS GPA_Y1_RANK      
      */      
      ,gpa.GPA_t1_all
      ,gpa.GPA_T2_all
      ,gpa.GPA_T3_all
      ,gpa.GPA_Y1_all
      ,gpa.elements_all
      ,gpa.failing_all
      ,gpa.n_failing_all      
      --,gpa.Y1_Dem AS IN_GRADE_DENOM

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
      
      ,CASE
        WHEN roster.grade_level != 7 THEN
         ((CONVERT(FLOAT,grades.rc1_y1) 
           + CONVERT(FLOAT,grades.rc2_y1) 
           + CONVERT(FLOAT,grades.rc3_y1) 
           + CONVERT(FLOAT,grades.rc4_y1) 
           + CONVERT(FLOAT,grades.rc5_y1)) / 5)
        WHEN roster.grade_level = 7 THEN
        ((CONVERT(FLOAT,grades.rc1_y1) 
           --+ CONVERT(FLOAT,grades.rc2_y1) 
           + CONVERT(FLOAT,grades.rc3_y1) 
           + CONVERT(FLOAT,grades.rc4_y1) 
           + CONVERT(FLOAT,grades.rc5_y1)) / 4)
        WHEN grades.rc5_course_number IS NULL THEN
        ((CONVERT(FLOAT,grades.rc1_y1) 
           + CONVERT(FLOAT,grades.rc2_y1) 
           + CONVERT(FLOAT,grades.rc3_y1) 
           + CONVERT(FLOAT,grades.rc4_y1)) / 4)
        WHEN grades.rc4_course_number IS NULL THEN
        ((CONVERT(FLOAT,grades.rc1_y1) 
           + CONVERT(FLOAT,grades.rc2_y1) 
           + CONVERT(FLOAT,grades.rc3_y1) 
           --+ CONVERT(FLOAT,grades.rc4_y1) 
           + CONVERT(FLOAT,grades.rc5_y1)) / 4)
       END AS Core_Avg
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
       WHEN lex_base.RITtoReadingScore  = 'BR' THEN NULL
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
       WHEN lex_curr.RITtoReadingScore  = 'BR' THEN NULL
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
     ,CASE
       WHEN fp_base.read_lvl IS NOT NULL THEN fp_base.read_lvl
       ELSE fp_curr.read_lvl
      END AS start_letter
     ,fp_curr.read_lvl AS end_letter
       --GLQ
     ,CASE
       WHEN fp_base.GLEQ IS NOT NULL THEN ROUND(fp_base.GLEQ,1)
       ELSE ROUND(fp_curr.GLEQ,1)
      END AS Start_GLEQ
     ,ROUND(fp_curr.GLEQ,1) AS End_GLEQ
     ,ROUND((fp_curr.GLEQ - CASE WHEN fp_base.GLEQ IS NOT NULL THEN fp_base.GLEQ ELSE fp_curr.GLEQ END),1) AS GLEQ_Growth
       --Level #
     ,CASE
       WHEN fp_base.lvl_num IS NOT NULL THEN fp_base.lvl_num
       ELSE fp_curr.lvl_num
      END AS [Start_#]
     ,fp_curr.lvl_num AS [End_#]
     ,(fp_curr.lvl_num - CASE WHEN fp_base.lvl_num IS NOT NULL THEN fp_base.lvl_num ELSE fp_curr.lvl_num END) AS [Levels_grown]
      
--Accelerated Reader
--update terms in JOIN
--AR year
     ,replace(convert(varchar,convert(Money, ar_yr.words),1),'.00','') AS words_read_yr
     ,replace(convert(varchar,convert(Money, ar_curr.words_goal * 6),1),'.00','') AS words_goal_yr      
     ,ar_yr.rank_words_grade_in_school AS words_rank_yr_in_grade
     ,ar_yr.mastery AS mastery_yr
     ,NULL AS ONTRACK_WORDS_YR
     
     --AR current
     ,replace(convert(varchar,convert(Money, ar_curr.words),1),'.00','') AS words_read_cur_term
     ,replace(convert(varchar,convert(Money, ar_curr.words_goal),1),'.00','') AS words_goal_cur_term
     ,ar_curr.rank_words_grade_in_school AS words_rank_cur_term_in_grade
     ,ar_curr.mastery AS mastery_curr
      
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
       WHEN ar_curr.stu_status_words = 'On Track' THEN 'Yes!'
       WHEN ar_curr.stu_status_words = 'Off Track' THEN 'No'
       ELSE ar_curr.stu_status_words
      END AS stu_status_words_cur_term      
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,CAST(ROUND(
       CASE
        WHEN (ar_curr.words_goal - ar_curr.words) <= 0 THEN NULL 
        ELSE ar_curr.words_goal - ar_curr.words
       END,0) AS INT)),1),'.00','') AS words_needed_cur_term     
      
--MAP scores
--MAP$wide_all
     
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
     
 --11-12
      --reading
      ,map_all.spr_2012_read_pctle
      --,map_all.w_2012_read_pctle
      ,map_all.f_2011_read_pctle      
      ,map_all.spr_2012_read_rit
      --,map_all.w_2012_read_rit
      ,map_all.f_2011_read_rit                  
      --math
      ,map_all.spr_2012_math_pctle
      --,map_all.w_2012_math_pctle
      ,map_all.f_2011_math_pctle      
      ,map_all.spr_2012_math_rit
      --,map_all.w_2012_math_rit
      ,map_all.f_2011_math_rit
      --lang
      ,map_all.spr_2012_lang_pctle
      --,map_all.w_2012_lang_pctle
      ,map_all.f_2011_lang_pctle
      ,map_all.spr_2012_lang_rit
      --,map_all.w_2012_lang_rit
      ,map_all.f_2011_lang_rit            
      --sci
      ,map_all.spr_2012_gen_pctle
      --,map_all.w_2012_GEN_pctle
      ,map_all.f_2011_gen_pctle
      ,map_all.spr_2012_gen_rit
      --,map_all.w_2012_GEN_RIT
      ,map_all.f_2011_gen_rit
     
--NJASK scores
--NJASK$ela_wide
--NJASK$math_wide      
/*--UPDATE FIELDS FOR CURRENT YEAR--*/

--13-14      
      --Grade
      ,njask_math.gr_lev_2014 AS njask_gr_lev_2014
      --ELA
      ,njask_ela.score_2014 AS ela_score_2014
      ,njask_ela.prof_2014 AS ela_prof_2014      
      --Math
      ,njask_math.score_2014 AS math_score_2014
      ,njask_math.prof_2014 AS math_prof_2014

--12-13
      --Grade
      ,njask_math.gr_lev_2013 AS njask_gr_lev_2013
      --ELA
      ,njask_ela.score_2013 AS ela_score_2013
      ,njask_ela.prof_2013 AS ela_prof_2013      
      --Math
      ,njask_math.score_2013 AS math_score_2013
      ,njask_math.prof_2013 AS math_prof_2013

--11-12      
      --Grade
      ,njask_math.gr_lev_2012 AS njask_gr_lev_2012
      --ELA
      ,njask_ela.score_2012 AS ela_score_2012
      ,njask_ela.prof_2012 AS ela_prof_2012      
      --Math
      ,njask_math.score_2012 AS math_score_2012
      ,njask_math.prof_2012 AS math_prof_2012      

--10-11
      --Grade
      ,njask_math.gr_lev_2011 AS njask_gr_lev_2011
      --ELA
      ,njask_ela.score_2011 AS ela_score_2011
      ,njask_ela.prof_2011 AS ela_prof_2011      
      --Math
      ,njask_math.score_2011 AS math_score_2011
      ,njask_math.prof_2011 AS math_prof_2011
      
      
--DISCIPLINE
      ,disc_recent.disc_01_date_reported
      ,disc_recent.disc_01_given_by
      ,disc_recent.DISC_01_subtype
      ,CASE
        WHEN disc_recent.disc_01_subject IS NULL THEN disc_recent.disc_01_incident 
        ELSE disc_recent.disc_01_subject
       END AS disc_01_incident
      ,disc_recent.disc_02_date_reported
      ,disc_recent.disc_02_given_by
      ,disc_recent.DISC_02_subtype
      ,CASE 
        WHEN disc_recent.disc_02_subject IS NULL THEN disc_recent.disc_02_incident 
        ELSE disc_recent.disc_02_subject
       END AS disc_02_incident
      ,disc_recent.disc_03_date_reported
      ,disc_recent.disc_03_given_by
      ,disc_recent.DISC_03_subtype
      ,CASE
        WHEN disc_recent.disc_03_subject IS NULL THEN disc_recent.disc_03_incident 
        ELSE disc_recent.disc_03_subject
       END AS disc_03_incident
      ,disc_recent.disc_04_date_reported
      ,disc_recent.disc_04_given_by
      ,disc_recent.DISC_04_subtype
      ,CASE
        WHEN disc_recent.disc_04_subject IS NULL THEN disc_recent.disc_04_incident 
        ELSE disc_recent.disc_04_subject
       END AS disc_04_incident
      ,disc_recent.disc_05_date_reported
      ,disc_recent.disc_05_given_by
      ,disc_recent.DISC_05_subtype
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
      ,ISNULL(disc_count.ISS,0) AS Y1_iss
      ,ISNULL(disc_count.rt1_iss,0) AS t1_iss
      ,ISNULL(disc_count.rt2_iss,0) AS t2_iss      
      ,ISNULL(disc_count.rt3_iss,0) AS t3_iss      
      ,ISNULL(disc_count.oss,0) AS Y1_oss
      ,ISNULL(disc_count.rt1_oss,0) AS t1_oss
      ,ISNULL(disc_count.rt2_oss,0) AS t2_oss      
      ,ISNULL(disc_count.rt3_oss,0) AS t3_oss      
      ,ISNULL(disc_count.bench,0) AS Y1_bench
      ,ISNULL(disc_count.rt1_bench,0) AS t1_bench
      ,ISNULL(disc_count.rt2_bench,0) AS t2_bench      
      ,ISNULL(disc_count.rt3_bench,0) AS t3_bench  
      --,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.bench,0) ELSE ISNULL(disc_count.choices,0) END AS Y1_bench_choices      
      --,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt1_bench,0) ELSE ISNULL(disc_count.rt1_choices,0) END AS T1_bench_choices
      --,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt2_bench,0) ELSE ISNULL(disc_count.rt1_choices,0) END AS T2_bench_choices
      --,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt3_bench,0) ELSE ISNULL(disc_count.rt1_choices,0) END AS T3_bench_choices
      
FROM roster WITH (NOLOCK)

--Attendance
LEFT OUTER JOIN ATT_MEM$attendance_counts att_counts WITH (NOLOCK)
  ON roster.id = att_counts.studentid
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct WITH (NOLOCK)
  ON roster.id = att_pct.studentid
LEFT OUTER JOIN ATT_MEM$membership_counts membership_counts WITH (NOLOCK)
  ON roster.id = membership_counts.studentid

--Grades & GPA
LEFT OUTER JOIN GRADES$wide_credit_core#MS grades WITH (NOLOCK)
  ON roster.ID = grades.studentid
LEFT OUTER JOIN GPA$detail#MS gpa WITH (NOLOCK)
  ON roster.id = gpa.studentid
LEFT OUTER JOIN REPORTING$promo_status#MS promo WITH (NOLOCK)
  ON roster.id = promo.studentid
  
--LITERACY -- upadate parameters for current term
  --F&P
LEFT OUTER JOIN LIT$test_events#identifiers fp_base WITH (NOLOCK)
  ON roster.student_number = fp_base.STUDENT_NUMBER
 AND fp_base.academic_year = dbo.fn_Global_Academic_Year()
 AND fp_base.achv_base_yr = 1
LEFT OUTER JOIN LIT$test_events#identifiers fp_curr WITH (NOLOCK)
  ON roster.student_number = fp_curr.STUDENT_NUMBER
 --AND fp_curr.year = dbo.fn_Global_Academic_Year()
 AND fp_curr.achv_curr_all = 1
  --LEXILE
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_base WITH (NOLOCK)
  ON roster.student_number = lex_base.StudentID
 AND lex_base.MeasurementScale = 'Reading'
 AND lex_base.rn_base = 1
 AND lex_base.map_year_academic = dbo.fn_Global_Academic_Year()
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_curr WITH (NOLOCK)
  ON roster.student_number = lex_curr.StudentID
 AND lex_curr.MeasurementScale = 'Reading'
 AND lex_curr.rn_curr = 1
 AND lex_curr.map_year_academic = dbo.fn_Global_Academic_Year()
  
--ED TECH
  --ACCELERATED READER
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON roster.id = ar_yr.studentid 
 AND ar_yr.time_period_name = 'Year'
 AND ar_yr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr WITH (NOLOCK)
  ON roster.id = ar_curr.studentid 
 AND ar_curr.time_period_name = (SELECT hex_a FROM cur_hex)
 AND ar_curr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr2 WITH (NOLOCK)
  ON roster.id = ar_curr2.studentid 
 AND ar_curr2.time_period_name = (SELECT hex_b FROM cur_hex)
 AND ar_curr2.yearid = dbo.fn_Global_Term_Id()

--MAP
LEFT OUTER JOIN MAP$wide_all map_all WITH (NOLOCK)
  ON roster.id = map_all.studentid
  
--NJASK
LEFT OUTER JOIN NJASK$ELA_WIDE njask_ela WITH (NOLOCK)
  ON roster.id = njask_ela.studentid
 AND njask_ela.schoolid = 133570965
 AND njask_ela.rn = 1
LEFT OUTER JOIN NJASK$MATH_WIDE njask_math WITH (NOLOCK)
  ON roster.id = njask_math.studentid
 AND njask_math.schoolid = 133570965

--Discipline
LEFT OUTER JOIN DISC$recent_incidents_wide disc_recent WITH (NOLOCK)
  ON roster.id = disc_recent.studentid
LEFT OUTER JOIN DISC$counts_wide disc_count WITH (NOLOCK)
  ON roster.id = disc_count.studentid