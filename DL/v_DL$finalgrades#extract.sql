USE KIPP_NJ
GO

ALTER VIEW DL$finalgrades#extract AS

SELECT CONVERT(INT,o.student_number) AS student_number
      ,o.academic_year
      ,o.term
      ,o.course_number
      ,o.COURSE_NAME
      ,o.sectionid      
      ,sec.DCID AS sections_dcid
      ,sec.SECTION_NUMBER
      ,o.teacher_name
      ,o.credit_hours
      ,ABS(o.EXCLUDEFROMGPA - 1) AS include_grades_display
      
      /* final grades */
      ,fg.RT1_term_grade_percent_adjusted AS Q1_pct
      ,fg.RT2_term_grade_percent_adjusted AS Q2_pct
      ,fg.RT3_term_grade_percent_adjusted AS Q3_pct
      ,fg.RT4_term_grade_percent_adjusted AS Q4_pct
      ,fg.y1_grade_percent AS Y1_pct
      ,fg.y1_grade_letter AS Y1_letter

      /* category grades */
      ,cat.A_CUR AS A_term
      ,cat.C_CUR AS CW_term
      ,cat.H_CUR AS HWC_term
      ,cat.P_CUR AS CP_term
      ,cat.E_CUR AS HWQ_term

      /* other */
      ,REPLACE(CONVERT(NVARCHAR(MAX),comm.comment_value),'"','''') AS comment_value
      ,ISNULL(cc.CURRENTABSENCES,0) AS CURRENTABSENCES
      ,ISNULL(cc.CURRENTTARDIES,0) AS CURRENTTARDIES
FROM KIPP_NJ..PS$course_order_scaffold#static o WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
  ON o.sectionid = sec.ID
JOIN KIPP_NJ..GRADES$final_grades_wide#static fg WITH(NOLOCK)
  ON o.student_number = fg.student_number
 AND o.academic_year = fg.academic_year
 AND o.course_number = fg.course_number
 AND o.term = fg.term
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static cat WITH(NOLOCK)
  ON o.student_number = cat.student_number
 AND o.academic_year = cat.academic_year
 AND o.course_number = cat.COURSE_NUMBER
 AND o.reporting_term = cat.reporting_term
LEFT OUTER JOIN KIPP_NJ..PS$PGFINALGRADES_comments comm WITH(NOLOCK)
  ON o.studentid = comm.studentid
 AND o.sectionid = comm.sectionid
 AND o.term = comm.finalgradename
LEFT OUTER JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
  ON o.studentid = cc.STUDENTID
 AND o.sectionid = cc.SECTIONID
WHERE o.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND o.course_number != 'ALL'

UNION ALL

SELECT comm.student_number
      ,comm.academic_year
      ,comm.term
      ,comm.subject AS course_number
      ,comm.subject AS COURSE_NAME
      ,NULL AS sectionid
      ,NULL AS sections_dcid
      ,NULL AS section_number
      ,NULL AS teacher_name
      ,NULL AS credit_hours
      ,0 AS include_grades_display
      ,NULL AS Q1_pct
      ,NULL AS Q2_pct
      ,NULL AS Q3_pct
      ,NULL AS Q4_pct
      ,NULL AS Y1_pct
      ,NULL AS Y1_letter
      ,NULL AS A_term
      ,NULL AS CW_term
      ,NULL AS HWC_term
      ,NULL AS CP_term
      ,NULL AS HWQ_term      
      ,REPLACE(comm.comment,'"','''') AS comment_value
      ,NULL AS currentabsences
      ,NULL AS currenttardies
FROM KIPP_NJ..REPORTING$report_card_comments#ES#static comm WITH(NOLOCK)  
WHERE CONVERT(VARCHAR,comm.comment) IS NOT NULL
  AND comm.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()