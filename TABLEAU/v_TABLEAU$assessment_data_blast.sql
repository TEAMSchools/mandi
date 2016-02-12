USE KIPP_NJ
GO

ALTER VIEW TABLEAU$assessment_data_blast AS

SELECT co.schoolid
      ,co.year AS academic_year
      ,co.grade_level
      ,co.team      
      ,co.student_number
      ,co.lastfirst
      ,co.spedlep  
      ,co.enroll_status    
      ,co.gender
      ,co.retained_yr_flag
      ,co.retained_ever_flag

      ,a.assessment_id
      ,a.title
      ,a.scope            
      ,a.subject_area AS subject      
      ,a.administered_at
      ,CASE 
        WHEN a.tags IS NULL THEN 0
        WHEN CHARINDEX(REPLACE(co.grade_level, 0, 'K'), a.tags) = 0 THEN 1 
        ELSE 0 
       END AS is_replacement      
      
      ,ovr.date_taken
      ,ovr.percent_correct AS overall_pct_correct            

      ,std.custom_code AS standards_tested      
      ,std.description AS standard_descr      

      ,ROUND(CONVERT(FLOAT,res.percent_correct),1) AS std_percent_correct
      ,CONVERT(FLOAT,res.mastered) AS std_is_mastered
            
      ,enr.teacher_name      
      ,enr.period
      ,enr.section_number
      
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, a.assessment_id
           ORDER BY co.student_number) AS overall_rn      
FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH (NOLOCK)
JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
  ON a.assessment_id = ovr.assessment_id  
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd WITH(NOLOCK)
  ON a.assessment_id = astd.assessment_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
  ON astd.standard_id = std.standard_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard res WITH (NOLOCK)
  ON ovr.local_student_id = res.local_student_id
 AND a.assessment_id = res.assessment_id
 AND astd.standard_id = res.standard_id  
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH (NOLOCK) 
  ON ovr.local_student_id = co.student_number
 AND a.academic_year = co.year 
 --AND a.schoolid = co.schoolid
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.studentid = enr.studentid
 AND co.year = enr.academic_year
 AND enr.COURSE_NUMBER = 'HR'
 AND enr.drop_flags = 0
WHERE a.academic_year >= KIPP_NJ.dbo.fn_Global_Academic_Year()    
  AND a.scope IN ('CMA - End-of-Module','CMA - Mid-Module')
  AND a.subject_area IN ('Text Study','Mathematics')