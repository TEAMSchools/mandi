USE KIPP_NJ
GO

ALTER VIEW QA$Illuminate_zero_answered_audit AS

SELECT co.student_number
      ,co.studentid
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status      
      ,dt.alt_name AS term
      ,dt.start_date
      ,dt.end_date
      ,a.assessment_id
      ,a.title
      ,a.administered_at
      ,a.subject_area
      ,a.scope   
      ,ovr.date_taken
      ,ovr.percent_correct   
      ,ovr.answered
      ,ovr.number_of_questions
      ,att.ATT_CODE
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
  ON co.student_number = ovr.local_student_id 
 AND ovr.answered = 0
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
  ON co.studentid = att.STUDENTID
 AND ovr.date_taken = att.ATT_DATE
 AND att.ATT_CODE LIKE 'A%'
JOIN KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  ON co.year = a.academic_year
 AND a.assessment_id = ovr.assessment_id 
 --AND a.scope IN ('CMA - End-of-Module','CMA - Mid-Module', 'Common FSA', 'Exit Ticket', 'Unit Assessment')
 AND a.administered_at BETWEEN dt.start_date AND dt.end_date
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()  
  AND co.rn = 1