USE KIPP_NJ
GO

ALTER VIEW QA$FSA_audit AS

SELECT DISTINCT
       a.assessment_id
      ,sch.schoolid
      ,a.title      
      ,a.scope
      ,a.subject_area
      ,a.teachernumber
      ,a.created_by
      ,a.standard_code
      ,a.standard_description
      ,d.time_per_name
      ,FORMAT(d.start_date,'M/dd') AS start_date
      ,FORMAT(d.end_date,'M/dd') AS end_date
FROM KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
JOIN KIPP_NJ..ILLUMINATE$assessments_sites#static sch WITH(NOLOCK)
  ON ovr.assessment_id = sch.assessment_id 
JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
  ON sch.schoolid = d.schoolid
 AND ((sch.schoolid != 73258 AND ovr.date_taken BETWEEN DATEADD(DAY, (3 - DATEPART(DW,d.start_date)), d.start_date) /* Tuesday start */
                                                   AND DATEADD(DAY, 7, (DATEADD(DAY,(2 - DATEPART(DW,d.start_date)), d.start_date)))) /* Monday end */
   OR (sch.schoolid = 73258 AND ovr.date_taken BETWEEN DATEADD(DAY, 1, d.start_date) AND DATEADD(DAY, 1, d.end_date))) /* Tues - Mon for BOLD */
 AND d.identifier = 'REP'
JOIN KIPP_NJ..ILLUMINATE$assessments_long#static a WITH(NOLOCK)
  ON sch.schoolid = a.schoolid             
 AND ovr.assessment_id = a.assessment_id
WHERE ovr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()