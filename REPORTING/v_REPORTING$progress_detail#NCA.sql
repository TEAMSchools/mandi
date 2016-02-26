USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_detail#NCA AS

WITH curterm AS (
  SELECT time_per_name
        ,alt_name AS term
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'    
    AND schoolid = 73253
    AND (CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date)
 )

,roster AS (
  SELECT c.studentid AS JOINID
        ,c.student_number AS ID
        ,c.year
        ,c.lastfirst AS NAME
        ,c.grade_level AS GR
        ,c.advisor AS ADVISOR
        ,c.SPEDLEP AS IEP
        ,c.entry_school_name AS prev_school
        ,c.entry_grade_level AS entry_grade
  FROM KIPP_NJ..COHORT$identifiers_long#static c WITH (NOLOCK)    
  WHERE c.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND c.rn = 1        
    AND c.schoolid = 73253
    AND c.enroll_status = 0
 )
 
SELECT roster.ID
      ,roster.NAME
      ,roster.GR
      ,roster.ADVISOR
      ,roster.IEP
      ,roster.prev_school

      ,gr.credittype AS SUBJECT
      ,gr.course_number AS COURSE_NUM
      ,gr.course_name AS COURSE_NAME
      ,gr.teacher_name AS teacher
      
      ,cc.period AS SECT
      ,rti.tier AS RTI_Tier
      ,cc.currentabsences AS [ABS]
      ,cc.currenttardies AS TARDY
      
      ,gr.y1_grade_percent AS Y1
      ,gr.y1_grade_letter AS Y1_LTR
      ,CASE
        WHEN gr.y1_grade_percent <  70 THEN 'Failing'
        WHEN gr.y1_grade_percent <= 75 THEN 'Warning'
        ELSE 'Passing'
       END AS AT_RISK
      
      ,gr.RT1_term_grade_percent AS Q1
      ,gr.RT2_term_grade_percent AS Q2
      ,gr.RT3_term_grade_percent AS Q3
      ,gr.RT4_term_grade_percent AS Q4
      ,gr.e1_grade_percent AS E1
      ,gr.e1_grade_percent AS E2

      ,CASE WHEN gr.y1_grade_percent >= 65 THEN NULL ELSE gr.need_65 END AS GET_D
      ,CASE WHEN gr.y1_grade_percent >= 70 THEN NULL ELSE gr.need_70 END AS GET_C
      ,CASE WHEN gr.y1_grade_percent >= 80 THEN NULL ELSE gr.need_80 END AS GET_B
      ,CASE WHEN gr.y1_grade_percent >= 90 THEN NULL ELSE gr.need_90 END AS GET_A      
      ,CASE
        WHEN gr.y1_grade_percent BETWEEN 70 AND 79 THEN need_70
        WHEN gr.y1_grade_percent BETWEEN 80 AND 89 THEN need_80
        WHEN gr.y1_grade_percent >= 90 THEN need_90
        ELSE NULL
       END AS MAINTAIN           
      
      ,cat.H_RT1 AS H1
      ,cat.H_RT2 AS H2
      ,cat.H_RT3 AS H3
      ,cat.H_RT4 AS H4
      ,cat.H_Y1 AS HY
      ,cat.A_RT1 AS A1
      ,cat.A_RT2 AS A2
      ,cat.A_RT3 AS A3
      ,cat.A_RT4 AS A4
      ,cat.A_Y1 AS AY
      ,cat.C_RT1 AS C1
      ,cat.C_RT2 AS C2
      ,cat.C_RT3 AS C3
      ,cat.C_RT4 AS C4
      ,cat.C_Y1 AS CY
      ,cat.P_RT1 AS P1
      ,cat.P_RT2 AS P2
      ,cat.P_RT3 AS P3
      ,cat.P_RT4 AS P4
      ,cat.P_Y1 AS PY
      
      ,CONVERT(MONEY,gpa.GPA_Y1_CUR) AS GPA_Y1
      ,CONVERT(MONEY,gpa.GPA_term_RT1) AS GPA_Q1
      ,CONVERT(MONEY,gpa.GPA_term_RT2) AS GPA_Q2
      ,CONVERT(MONEY,gpa.GPA_term_RT3) AS GPA_Q3
      ,CONVERT(MONEY,gpa.GPA_term_RT4) AS GPA_Q4
      
      ,CASE
        WHEN gr.y1_grade_percent BETWEEN 65 AND 69 THEN 'Approaching (65-69)'
        WHEN gr.y1_grade_percent BETWEEN 60 AND 64 THEN 'Close (60-64)'
        WHEN gr.y1_grade_percent BETWEEN 55 AND 59 THEN 'Fair (55-59)'
        WHEN gr.y1_grade_percent < 55 THEN 'Fail (< 55)'
       END AS y1_label
      ,CASE
        WHEN gr.RT1_term_grade_percent BETWEEN 65 AND 69 THEN 'Approaching (65-69)'
        WHEN gr.RT1_term_grade_percent BETWEEN 60 AND 64 THEN 'Close (60-64)'
        WHEN gr.RT1_term_grade_percent BETWEEN 55 AND 59 THEN 'Fair (55-59)'
        WHEN gr.RT1_term_grade_percent < 55 THEN 'Fail (< 55)'
       END AS q1_label
      ,CASE
        WHEN gr.RT2_term_grade_percent BETWEEN 65 AND 69 THEN 'Approaching (65-69)'
        WHEN gr.RT2_term_grade_percent BETWEEN 60 AND 64 THEN 'Close (60-64)'
        WHEN gr.RT2_term_grade_percent BETWEEN 55 AND 59 THEN 'Fair (55-59)'
        WHEN gr.RT2_term_grade_percent < 55 THEN 'Fail (< 55)'
       END AS q2_label
      ,CASE
        WHEN gr.RT3_term_grade_percent BETWEEN 65 AND 69 THEN 'Approaching (65-69)'
        WHEN gr.RT3_term_grade_percent BETWEEN 60 AND 64 THEN 'Close (60-64)'
        WHEN gr.RT3_term_grade_percent BETWEEN 55 AND 59 THEN 'Fair (55-59)'
        WHEN gr.RT3_term_grade_percent < 55 THEN 'Fail (< 55)'
       END AS q3_label
      ,CASE
        WHEN gr.RT4_term_grade_percent BETWEEN 65 AND 69 THEN 'Approaching (65-69)'
        WHEN gr.RT4_term_grade_percent BETWEEN 60 AND 64 THEN 'Close (60-64)'
        WHEN gr.RT4_term_grade_percent BETWEEN 55 AND 59 THEN 'Fair (55-59)'
        WHEN gr.RT4_term_grade_percent < 55 THEN 'Fail (< 55)'
       END AS q4_label
      ,CASE
        WHEN gr.E1_grade_percent BETWEEN 65 AND 69 THEN 'Approaching (65-69)'
        WHEN gr.E1_grade_percent BETWEEN 60 AND 64 THEN 'Close (60-64)'
        WHEN gr.E1_grade_percent BETWEEN 55 AND 59 THEN 'Fair (55-59)'
        WHEN gr.E1_grade_percent < 55 THEN 'Fail (< 55)'
       END AS e1_label
      ,CASE
        WHEN gr.E2_grade_percent BETWEEN 65 AND 69 THEN 'Approaching (65-69)'
        WHEN gr.E2_grade_percent BETWEEN 60 AND 64 THEN 'Close (60-64)'
        WHEN gr.E2_grade_percent BETWEEN 55 AND 59 THEN 'Fair (55-59)'
        WHEN gr.E2_grade_percent < 55 THEN 'Fail (< 55)'
       END AS e2_label
      
      ,CASE
        WHEN cat.A_RT1 BETWEEN 65 AND 69 THEN 'Approaching (65-69)'
        WHEN cat.A_RT1 BETWEEN 60 AND 64 THEN 'Close (60-64)'
        WHEN cat.A_RT1 BETWEEN 55 AND 59 THEN 'Fair (55-59)'
        WHEN cat.A_RT1 < 55 THEN 'Fail (< 55)'
       END AS a1_label
      ,CASE
        WHEN cat.A_RT2 BETWEEN 65 AND 69 THEN 'Approaching (65-69)'
        WHEN cat.A_RT2 BETWEEN 60 AND 64 THEN 'Close (60-64)'
        WHEN cat.A_RT2 BETWEEN 55 AND 59 THEN 'Fair (55-59)'
        WHEN cat.A_RT2 < 55 THEN 'Fail (< 55)'
       END AS a2_label
      ,CASE
        WHEN cat.A_RT3 BETWEEN 65 AND 69 THEN 'Approaching (65-69)'
        WHEN cat.A_RT3 BETWEEN 60 AND 64 THEN 'Close (60-64)'
        WHEN cat.A_RT3 BETWEEN 55 AND 59 THEN 'Fair (55-59)'
        WHEN cat.A_RT3 < 55 THEN 'Fail (< 55)'
       END AS a3_label
      ,CASE
        WHEN cat.A_RT4 BETWEEN 65 AND 69 THEN 'Approaching (65-69)'
        WHEN cat.A_RT4 BETWEEN 60 AND 64 THEN 'Close (60-64)'
        WHEN cat.A_RT4 BETWEEN 55 AND 59 THEN 'Fair (55-59)'
        WHEN cat.A_RT4 < 55 THEN 'Fail (< 55)'
       END AS a4_label
      ,CASE
        WHEN cat.A_Y1 BETWEEN 65 AND 69 THEN 'Approaching (65-69)'
        WHEN cat.A_Y1 BETWEEN 60 AND 64 THEN 'Close (60-64)'
        WHEN cat.A_Y1 BETWEEN 55 AND 59 THEN 'Fair (55-59)'
        WHEN cat.A_Y1 < 55 THEN 'Fail (< 55)'
       END AS ay_label      
      
      ,roster.entry_grade      
      ,rti.behavior_tier
FROM roster WITH(NOLOCK)
CROSS JOIN curterm
LEFT OUTER JOIN KIPP_NJ..GRADES$final_grades_wide#static gr WITH(NOLOCK)
  ON roster.ID = gr.student_number
 AND gr.is_curterm = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static cat WITH(NOLOCK)
  ON roster.ID = cat.student_number
 AND curterm.time_per_name = cat.reporting_term
 AND gr.course_number = cat.COURSE_NUMBER
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_detail_wide#static gpa WITH (NOLOCK)
  ON roster.id = gpa.student_number
 AND roster.year = gpa.academic_year
 AND curterm.term = gpa.term
LEFT OUTER JOIN KIPP_NJ..PS$CC#static cc WITH (NOLOCK)
  ON roster.joinid = cc.studentid
 AND gr.sectionid = cc.sectionid
LEFT OUTER JOIN KIPP_NJ..PS$rti_tiers#static rti WITH(NOLOCK)
  ON roster.joinid = rti.studentid
 AND gr.credittype = rti.credittype