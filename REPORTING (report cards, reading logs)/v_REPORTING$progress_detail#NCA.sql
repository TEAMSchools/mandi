USE KIPP_NJ
GO

--ALTER VIEW REPORTING$progress_detail#NCA AS
WITH roster AS
     (SELECT s.id AS JOINID
            ,s.student_number AS ID
            ,s.lastfirst AS NAME
            ,c.grade_level AS GR
            ,cs.advisor AS ADVISOR
            ,cs.SPEDLEP AS IEP
      FROM KIPP_NJ..COHORT$comprehensive_long#static c
      JOIN KIPP_NJ..STUDENTS s
        ON c.studentid = s.id
       AND s.enroll_status = 0
      LEFT OUTER JOIN KIPP_NJ..CUSTOM_STUDENTS cs
        ON cs.studentid = s.id
      WHERE year = 2013
        AND c.rn = 1        
        AND c.schoolid = 73253
     )

SELECT roster.ID
      ,roster.NAME
      ,roster.GR
      ,roster.ADVISOR
      ,roster.IEP
      ,gr.credittype AS SUBJECT
      ,gr.course_number AS COURSE_NUM
      ,gr.course_name AS COURSE_NAME
      ,t.lastfirst AS TEACHER
      ,sec.section_number AS SECTION
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
      ,cc.currentabsences AS [ABS]
      ,cc.currenttardies AS TARDY
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
FROM roster
LEFT OUTER JOIN GRADES$DETAIL#NCA gr
  ON roster.joinid = gr.studentid
LEFT OUTER JOIN SECTIONS sec
  ON gr.q1_enr_sectionid = sec.ID --update every quarter
 AND sec.termid >= dbo.fn_Global_Term_Id()
LEFT OUTER JOIN TEACHERS t
  ON t.id = sec.teacher
LEFT OUTER JOIN CC cc
  ON gr.q1_enr_sectionid = cc.sectionid --update every quarter
 AND roster.joinid = cc.studentid
 AND cc.termid >= dbo.fn_Global_Term_Id()
LEFT OUTER JOIN GRADES$elements ele_h
  ON gr.studentid = ele_h.studentid
 AND gr.course_number = ele_h.course_number
 AND ele_h.pgf_type = 'H'
LEFT OUTER JOIN GRADES$elements ele_a
  ON gr.studentid = ele_a.studentid
 AND gr.course_number = ele_a.course_number
 AND ele_a.pgf_type = 'A'
LEFT OUTER JOIN GRADES$elements ele_c
  ON gr.studentid = ele_c.studentid
 AND gr.course_number = ele_c.course_number
 AND ele_c.pgf_type = 'C'
LEFT OUTER JOIN GRADES$elements ele_p
  ON gr.studentid = ele_p.studentid
 AND gr.course_number = ele_p.course_number
 AND ele_p.pgf_type = 'P'
LEFT OUTER JOIN GPA$detail#NCA gpa
  ON roster.joinid = gpa.studentid