USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_detail#NCA AS

WITH curterm AS (
  SELECT time_per_name
        ,alt_name AS term
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'
    AND academic_year = dbo.fn_Global_Academic_Year()
    AND schoolid = 73253
    AND start_date <= GETDATE()
    AND end_date >= GETDATE()
 )

,roster AS (
  SELECT c.studentid AS JOINID
        ,c.student_number AS ID
        ,c.lastfirst AS NAME
        ,c.grade_level AS GR
        ,c.advisor AS ADVISOR
        ,c.SPEDLEP AS IEP
        ,c.entry_school_name AS prev_school
        ,c.entry_grade_level AS entry_grade
  FROM KIPP_NJ..COHORT$identifiers_long#static c WITH (NOLOCK)    
  WHERE c.year = dbo.fn_Global_Academic_Year()
    AND c.rn = 1        
    AND c.schoolid = 73253
    AND c.enroll_status = 0
 )
 
,cur_section AS (
  SELECT studentid
        ,student_number
        ,course_number
        ,term
        ,sectionid
        ,teacher
  FROM GRADES$sections_by_term WITH(NOLOCK)
  WHERE term IN (SELECT term FROM curterm)
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
      ,sec.teacher
      ,cc.period AS SECT
      ,rti.tier AS RTI_Tier
      ,cc.currentabsences AS [ABS]
      ,cc.currenttardies AS TARDY
      ,Y1
      ,Y1_letter AS Y1_LTR
      ,CASE
        WHEN Y1 <  70 THEN 'Failing'
        WHEN Y1 <= 75 THEN 'Warning'
        ELSE NULL
       END AS AT_RISK
      ,Q1
      ,Q2
      ,Q3
      ,Q4
      ,E1
      ,E2
      ,CASE WHEN SUBSTRING(need_d,5,8) = '(hidden)' THEN NULL ELSE need_d END AS GET_D
      ,CASE WHEN SUBSTRING(need_c,5,8) = '(hidden)' THEN NULL ELSE need_c END AS GET_C
      ,CASE WHEN SUBSTRING(need_b,5,8) = '(hidden)' THEN NULL ELSE need_b END AS GET_B
      ,CASE WHEN SUBSTRING(need_a,5,8) = '(hidden)' THEN NULL ELSE need_a END AS GET_A      
      ,CASE
        WHEN y1 >= 70 AND y1 < 80 THEN need_c_absolute
        WHEN y1 >= 80 AND y1 < 90 THEN need_b_absolute
        WHEN y1 >= 90 THEN need_a_absolute
        ELSE NULL
       END AS MAINTAIN           
      ,ele_h.grade_1 AS H1
      ,ele_h.grade_2 AS H2
      ,ele_h.grade_3 AS H3
      ,ele_h.grade_4 AS H4
      ,ele_h.simple_avg AS HY
      ,ele_a.grade_1 AS A1
      ,ele_a.grade_2 AS A2
      ,ele_a.grade_3 AS A3
      ,ele_a.grade_4 AS A4
      ,ele_a.simple_avg AS AY
      ,ele_c.grade_1 AS C1
      ,ele_c.grade_2 AS C2
      ,ele_c.grade_3 AS C3
      ,ele_c.grade_4 AS C4
      ,ele_c.simple_avg AS CY
      ,ele_p.grade_1 AS P1
      ,ele_p.grade_2 AS P2
      ,ele_p.grade_3 AS P3
      ,ele_p.grade_4 AS P4
      ,ele_p.simple_avg AS PY
      ,gpa.GPA_Y1
      ,gpa.GPA_Q1
      ,gpa.GPA_Q2
      ,gpa.GPA_Q3
      ,gpa.GPA_Q4
      ,CASE
        WHEN y1 >= 65 AND y1 < 70 THEN 'Approaching (65-69)'
        WHEN y1 >= 60 AND y1 < 65 THEN 'Close (60-64)'
        WHEN y1 >= 55 AND y1 < 60 THEN 'Fair (55-59)'
        WHEN y1 < 55 THEN 'Fail (< 55)'
       END AS y1_label
      ,CASE
        WHEN q1 >= 65 AND q1 < 70 THEN 'Approaching (65-69)'
        WHEN q1 >= 60 AND q1 < 65 THEN 'Close (60-64)'
        WHEN q1 >= 55 AND q1 < 60 THEN 'Fair (55-59)'
        WHEN q1 < 55 THEN 'Fail (< 55)'
       END AS q1_label
      ,CASE
        WHEN q2 >= 65 AND q2 < 70 THEN 'Approaching (65-69)'
        WHEN q2 >= 60 AND q2 < 65 THEN 'Close (60-64)'
        WHEN q2 >= 55 AND q2 < 60 THEN 'Fair (55-59)'
        WHEN q2 < 55 THEN 'Fail (< 55)'
       END AS q2_label
      ,CASE
        WHEN q3 >= 65 AND q3 < 70 THEN 'Approaching (65-69)'
        WHEN q3 >= 60 AND q3 < 65 THEN 'Close (60-64)'
        WHEN q3 >= 55 AND q3 < 60 THEN 'Fair (55-59)'
        WHEN q3 < 55 THEN 'Fail (< 55)'
       END AS q3_label
      ,CASE
        WHEN q4 >= 65 AND q4 < 70 THEN 'Approaching (65-69)'
        WHEN q4 >= 60 AND q4 < 65 THEN 'Close (60-64)'
        WHEN q4 >= 55 AND q4 < 60 THEN 'Fair (55-59)'
        WHEN q4 < 55 THEN 'Fail (< 55)'
       END AS q4_label
      ,CASE
        WHEN e1 >= 65 AND e1 < 70 THEN 'Approaching (65-69)'
        WHEN e1 >= 60 AND e1 < 65 THEN 'Close (60-64)'
        WHEN e1 >= 55 AND e1 < 60 THEN 'Fair (55-59)'
        WHEN e1 < 55 THEN 'Fail (< 55)'
       END AS e1_label
      ,CASE
        WHEN e2 >= 65 AND e2 < 70 THEN 'Approaching (65-69)'
        WHEN e2 >= 60 AND e2 < 65 THEN 'Close (60-64)'
        WHEN e2 >= 55 AND e2 < 60 THEN 'Fair (55-59)'
        WHEN e2 < 55 THEN 'Fail (< 55)'
       END AS e2_label
      ,CASE
        WHEN ele_a.grade_1 >= 65 AND ele_a.grade_1 < 70 THEN 'Approaching (65-69)'
        WHEN ele_a.grade_1 >= 60 AND ele_a.grade_1 < 65 THEN 'Close (60-64)'
        WHEN ele_a.grade_1 >= 55 AND ele_a.grade_1 < 60 THEN 'Fair (55-59)'
        WHEN ele_a.grade_1 < 55 THEN 'Fail (< 55)'
       END AS a1_label
      ,CASE
        WHEN ele_a.grade_2 >= 65 AND ele_a.grade_2 < 70 THEN 'Approaching (65-69)'
        WHEN ele_a.grade_2 >= 60 AND ele_a.grade_2 < 65 THEN 'Close (60-64)'
        WHEN ele_a.grade_2 >= 55 AND ele_a.grade_2 < 60 THEN 'Fair (55-59)'
        WHEN ele_a.grade_2 < 55 THEN 'Fail (< 55)'
       END AS a2_label
      ,CASE
        WHEN ele_a.grade_3 >= 65 AND ele_a.grade_3 < 70 THEN 'Approaching (65-69)'
        WHEN ele_a.grade_3 >= 60 AND ele_a.grade_3 < 65 THEN 'Close (60-64)'
        WHEN ele_a.grade_3 >= 55 AND ele_a.grade_3 < 60 THEN 'Fair (55-59)'
        WHEN ele_a.grade_3 < 55 THEN 'Fail (< 55)'
       END AS a3_label
      ,CASE
        WHEN ele_a.grade_4 >= 65 AND ele_a.grade_4 < 70 THEN 'Approaching (65-69)'
        WHEN ele_a.grade_4 >= 60 AND ele_a.grade_4 < 65 THEN 'Close (60-64)'
        WHEN ele_a.grade_4 >= 55 AND ele_a.grade_4 < 60 THEN 'Fair (55-59)'
        WHEN ele_a.grade_4 < 55 THEN 'Fail (< 55)'
       END AS a4_label
      ,CASE
        WHEN ele_a.simple_avg >= 65 AND ele_a.simple_avg < 70 THEN 'Approaching (65-69)'
        WHEN ele_a.simple_avg >= 60 AND ele_a.simple_avg < 65 THEN 'Close (60-64)'
        WHEN ele_a.simple_avg >= 55 AND ele_a.simple_avg < 60 THEN 'Fair (55-59)'
        WHEN ele_a.simple_avg < 55 THEN 'Fail (< 55)'
       END AS ay_label      
      ,roster.entry_grade      
      ,rti.behavior_tier
FROM roster WITH (NOLOCK)
LEFT OUTER JOIN GRADES$DETAIL#NCA gr WITH (NOLOCK)
  ON roster.joinid = gr.studentid 
LEFT OUTER JOIN PS$rti_tiers#static rti WITH(NOLOCK)
  ON roster.joinid = rti.studentid
 AND gr.credittype = rti.credittype
LEFT OUTER JOIN cur_section sec
  ON roster.joinid = sec.studentid
 AND gr.course_number = sec.course_number
LEFT OUTER JOIN CC cc WITH (NOLOCK)
  ON roster.joinid = cc.studentid
 AND sec.sectionid = cc.sectionid
LEFT OUTER JOIN GRADES$elements ele_h WITH (NOLOCK)
  ON gr.studentid = ele_h.studentid
 AND gr.course_number = ele_h.course_number
 AND ele_h.pgf_type = 'H'
 AND ele_h.yearid >= LEFT(dbo.fn_Global_Term_ID(), 2)
LEFT OUTER JOIN GRADES$elements ele_a WITH (NOLOCK)
  ON gr.studentid = ele_a.studentid
 AND gr.course_number = ele_a.course_number
 AND ele_a.pgf_type = 'A'
 AND ele_a.yearid >= LEFT(dbo.fn_Global_Term_ID(), 2)
LEFT OUTER JOIN GRADES$elements ele_c WITH (NOLOCK)
  ON gr.studentid = ele_c.studentid
 AND gr.course_number = ele_c.course_number
 AND ele_c.pgf_type = 'C'
 AND ele_c.yearid >= LEFT(dbo.fn_Global_Term_ID(), 2)
LEFT OUTER JOIN GRADES$elements ele_p WITH (NOLOCK)
  ON gr.studentid = ele_p.studentid
 AND gr.course_number = ele_p.course_number
 AND ele_p.pgf_type = 'P'
 AND ele_p.yearid >= LEFT(dbo.fn_Global_Term_ID(), 2)
LEFT OUTER JOIN GPA$detail#NCA gpa WITH (NOLOCK)
  ON roster.joinid = gpa.studentid