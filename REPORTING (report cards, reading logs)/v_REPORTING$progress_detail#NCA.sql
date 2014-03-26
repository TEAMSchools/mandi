--Y1 Tracker

USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_detail#NCA AS
WITH roster AS
     (
      SELECT s.id AS JOINID
            ,s.student_number AS ID
            ,s.lastfirst AS NAME
            ,c.grade_level AS GR
            ,cs.advisor AS ADVISOR
            ,cs.SPEDLEP AS IEP
      FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH (NOLOCK)
      JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
        ON c.studentid = s.id
       AND s.enroll_status = 0
      LEFT OUTER JOIN KIPP_NJ..CUSTOM_STUDENTS cs WITH (NOLOCK)
        ON cs.studentid = s.id
      WHERE year = 2013
        AND c.rn = 1        
        AND c.schoolid = 73253
     )

,entry_grade AS (
  SELECT STUDENTID
        ,LASTFIRST
        ,GRADE_LEVEL      
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  WHERE YEAR_IN_NETWORK = 1
    AND RN = 1
 )

,prev_school AS (
  SELECT STUDENTID
        ,LASTFIRST
        ,MAX(grade_level) AS grade_level
        ,CASE 
          WHEN SCHOOLID IS NULL THEN 'New to TEAM Schools'
          WHEN SCHOOLID = 73252 THEN 'Rise'
          WHEN SCHOOLID = 133570965 THEN 'TEAM Academy'
         END AS prev_school
  FROM
  (
   SELECT s.ID AS studentid
         ,s.LASTFIRST
         ,co.GRADE_LEVEL
         ,co.SCHOOLID
   FROM STUDENTS s WITH(NOLOCK)
   LEFT OUTER JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
     ON s.ID = co.STUDENTID
    AND co.SCHOOLID != 73253
   WHERE s.SCHOOLID = 73253
     AND s.ENROLL_STATUS = 0
  ) sub
  GROUP BY STUDENTID, LASTFIRST, SCHOOLID
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
      ,sec.section_number AS SECT
      ,cc.currentabsences AS [ABS]
      ,cc.currenttardies AS TARDY,Y1
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
      ,prev_school.prev_school
      ,entry_grade.GRADE_LEVEL AS entry_grade
FROM roster WITH (NOLOCK)
LEFT OUTER JOIN GRADES$DETAIL#NCA gr WITH (NOLOCK)
  ON roster.joinid = gr.studentid
LEFT OUTER JOIN SECTIONS sec WITH (NOLOCK)
  ON gr.q3_enr_sectionid = sec.ID --update every quarter
 AND sec.termid >= dbo.fn_Global_Term_Id()
LEFT OUTER JOIN TEACHERS t WITH (NOLOCK)
  ON t.id = sec.teacher
LEFT OUTER JOIN CC cc WITH (NOLOCK)
  ON gr.q3_enr_sectionid = cc.sectionid --update every quarter
 AND roster.joinid = cc.studentid
 AND cc.termid >= dbo.fn_Global_Term_Id()
LEFT OUTER JOIN GRADES$elements ele_h WITH (NOLOCK)
  ON gr.studentid = ele_h.studentid
 AND gr.course_number = ele_h.course_number
 AND ele_h.pgf_type = 'H'
LEFT OUTER JOIN GRADES$elements ele_a WITH (NOLOCK)
  ON gr.studentid = ele_a.studentid
 AND gr.course_number = ele_a.course_number
 AND ele_a.pgf_type = 'A'
LEFT OUTER JOIN GRADES$elements ele_c WITH (NOLOCK)
  ON gr.studentid = ele_c.studentid
 AND gr.course_number = ele_c.course_number
 AND ele_c.pgf_type = 'C'
LEFT OUTER JOIN GRADES$elements ele_p WITH (NOLOCK)
  ON gr.studentid = ele_p.studentid
 AND gr.course_number = ele_p.course_number
 AND ele_p.pgf_type = 'P'
LEFT OUTER JOIN GPA$detail#NCA gpa WITH (NOLOCK)
  ON roster.joinid = gpa.studentid
LEFT OUTER JOIN prev_school
  ON roster.JOINID = prev_school.studentid
LEFT OUTER JOIN entry_grade
  ON roster.JOINID = entry_grade.STUDENTID  