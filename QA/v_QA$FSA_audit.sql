USE KIPP_NJ
GO

ALTER VIEW QA$FSA_audit AS

SELECT a.assessment_id
      ,s.schoolid
      ,a.title      
      ,a.scope
      ,a.subject_area
      ,a.teachernumber
      ,a.created_by
      ,a.standard_code
      ,a.standard_description
      ,rt.alt_name AS term
      ,d.time_per_name
      ,FORMAT(d.start_date,'M/dd') AS start_date
      ,FORMAT(d.end_date,'M/dd') AS end_date
      ,ovr.local_student_id
FROM KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON ovr.local_student_id = s.STUDENT_NUMBER
JOIN KIPP_NJ..ILLUMINATE$assessments_long#static a WITH(NOLOCK)
  ON s.schoolid = a.schoolid             
 AND ovr.assessment_id = a.assessment_id
JOIN KIPP_NJ..REPORTING$dates rt WITH(NOLOCK)
  ON s.schoolid = rt.schoolid
 AND ((a.scope NOT LIKE 'CMA%' AND ovr.date_taken BETWEEN rt.start_date AND rt.end_date) OR (a.scope LIKE 'CMA%' AND a.administered_at BETWEEN rt.start_date AND rt.end_date))
 AND rt.identifier = 'RT'
JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
  ON s.schoolid = d.schoolid
 AND ((a.scope LIKE 'CMA%' AND a.administered_at BETWEEN d.start_date AND d.end_date) 
         OR (a.scope NOT LIKE 'CMA%' AND ovr.date_taken BETWEEN DATEADD(DAY, (3 - DATEPART(DW,d.start_date)), d.start_date)
                                                            AND DATEADD(DAY, 7, (DATEADD(DAY,(2 - DATEPART(DW,d.start_date)), d.start_date)))))
 AND d.identifier = 'REP'
WHERE ovr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND s.SCHOOLID != 73258

UNION ALL

SELECT a.assessment_id
      ,s.schoolid
      ,a.title      
      ,a.scope
      ,a.subject_area
      ,a.teachernumber
      ,a.created_by
      ,a.standard_code
      ,a.standard_description
      ,rt.alt_name AS term
      ,d.time_per_name
      ,FORMAT(d.start_date,'M/dd') AS start_date
      ,FORMAT(d.end_date,'M/dd') AS end_date
      ,ovr.local_student_id
FROM KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON ovr.local_student_id = s.STUDENT_NUMBER
JOIN KIPP_NJ..REPORTING$dates rt WITH(NOLOCK)
  ON s.schoolid = rt.schoolid
 AND ovr.date_taken BETWEEN rt.start_date AND rt.end_date
 AND rt.identifier = 'RT'
JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
  ON s.schoolid = d.schoolid
 AND ovr.date_taken BETWEEN d.start_date AND d.end_date
 AND d.identifier = 'REP'
JOIN KIPP_NJ..ILLUMINATE$assessments_long#static a WITH(NOLOCK)
  ON s.schoolid = a.schoolid             
 AND ovr.assessment_id = a.assessment_id
WHERE ovr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND s.SCHOOLID = 73258