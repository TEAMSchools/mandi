USE KIPP_NJ
GO

ALTER VIEW TABLEAU$progress_detail AS

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

SELECT roster.student_number
      ,roster.lastfirst
      ,roster.school_name
      ,roster.grade_level
      ,roster.ADVISOR
      ,roster.SPEDLEP
      ,roster.entry_school_name
      ,roster.entry_grade_level
      ,rti.behavior_tier
      ,gr.credittype
      ,gr.course_number
      ,gr.course_name
      ,sec.teacher
      ,cc.period
      ,rti.tier AS RTI_tier
      ,cc.currentabsences AS absences
      ,cc.currenttardies AS tardies
      ,Y1
      ,y1_letter      
      ,Q1
      ,Q2
      ,Q3
      ,Q4
      ,E1
      ,E2
      ,CASE WHEN need_d LIKE '%(hidden)%' THEN NULL ELSE need_d END AS GET_D
      ,CASE WHEN need_c LIKE '%(hidden)%' THEN NULL ELSE need_c END AS GET_C
      ,CASE WHEN need_b LIKE '%(hidden)%' THEN NULL ELSE need_b END AS GET_B
      ,CASE WHEN need_a LIKE '%(hidden)%' THEN NULL ELSE need_a END AS GET_A      
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
FROM KIPP_NJ..COHORT$identifiers_long#static roster WITH(NOLOCK)
LEFT OUTER JOIN GRADES$DETAIL#NCA gr WITH(NOLOCK)
  ON roster.studentid = gr.studentid 
LEFT OUTER JOIN PS$rti_tiers#static rti WITH(NOLOCK)
  ON roster.studentid = rti.studentid
 AND gr.credittype = rti.credittype
LEFT OUTER JOIN cur_section sec
  ON roster.studentid = sec.studentid
 AND gr.course_number = sec.course_number
LEFT OUTER JOIN PS$CC#static cc WITH(NOLOCK)
  ON roster.studentid = cc.studentid
 AND sec.sectionid = cc.sectionid
LEFT OUTER JOIN GRADES$elements ele_h WITH(NOLOCK)
  ON gr.studentid = ele_h.studentid
 AND gr.course_number = ele_h.course_number
 AND ele_h.pgf_type = 'H'
 AND ele_h.yearid >= LEFT(dbo.fn_Global_Term_ID(), 2)
LEFT OUTER JOIN GRADES$elements ele_a WITH(NOLOCK)
  ON gr.studentid = ele_a.studentid
 AND gr.course_number = ele_a.course_number
 AND ele_a.pgf_type = 'A'
 AND ele_a.yearid >= LEFT(dbo.fn_Global_Term_ID(), 2)
LEFT OUTER JOIN GRADES$elements ele_c WITH(NOLOCK)
  ON gr.studentid = ele_c.studentid
 AND gr.course_number = ele_c.course_number
 AND ele_c.pgf_type = 'C'
 AND ele_c.yearid >= LEFT(dbo.fn_Global_Term_ID(), 2)
LEFT OUTER JOIN GRADES$elements ele_p WITH(NOLOCK)
  ON gr.studentid = ele_p.studentid
 AND gr.course_number = ele_p.course_number
 AND ele_p.pgf_type = 'P'
 AND ele_p.yearid >= LEFT(dbo.fn_Global_Term_ID(), 2)
LEFT OUTER JOIN GPA$detail#NCA gpa WITH(NOLOCK)
  ON roster.studentid = gpa.studentid
WHERE roster.year = dbo.fn_Global_Academic_Year()
  AND roster.rn = 1        
  AND roster.schoolid = 73253
  AND roster.enroll_status = 0