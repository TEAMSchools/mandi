USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessments_long AS

WITH grade_level_tags AS (
  SELECT assessment_id
        ,KIPP_NJ.dbo.GROUP_CONCAT(tag) AS grade_level_tags
  FROM
      (
       SELECT assessment_id
             ,CONVERT(VARCHAR(MAX),tag) AS tag
       FROM KIPP_NJ..ILLUMINATE$tags#static WITH(NOLOCK)
       WHERE CONVERT(VARCHAR(MAX),tag) IN ('K','1','2','3','4','5','6','7','8','9','10','11','12')
         AND assessment_id IS NOT NULL
      ) sub
  GROUP BY assessment_id
 )

SELECT sub.assessment_id      
      ,sub.title
      ,sub.scope
      ,sub.subject_area
      ,sub.credittype      
      ,sub.schoolid
      ,sub.grade_level      
      ,sub.academic_year
      ,sub.term
      ,sub.reporting_wk
      ,sub.administered_at
      ,sub.teachernumber
      ,sub.created_by
      ,sub.performance_band_set_id      
      ,sub.standard_id
      ,sub.standard_code
      ,KIPP_NJ.dbo.fn_StripCharacters(LTRIM(RTRIM(sub.standard_description)),CHAR(10)+CHAR(13)) AS standard_description
      ,sub.tags
      ,ROW_NUMBER() OVER (
          PARTITION BY sub.academic_year, sub.reporting_wk, sub.schoolid, sub.grade_level, sub.scope, sub.performance_band_set_id
              ORDER BY sub.performance_band_set_id, subject_area, standard_code ASC) AS weekly_stds_rn
      ,ROW_NUMBER() OVER (
          PARTITION BY sub.academic_year, sub.schoolid, sub.grade_level, sub.scope, sub.standard_code, sub.performance_band_set_id
              ORDER BY sub.administered_at ASC) AS std_timeline_rn
      ,CASE
        WHEN sub.schoolid = 73253 THEN
          ROW_NUMBER() OVER (
            PARTITION BY sub.academic_year, sub.schoolid, sub.subject_area, sub.standard_code
              ORDER BY sub.administered_at ASC)
        ELSE
          ROW_NUMBER() OVER (
            PARTITION BY sub.academic_year, sub.schoolid, sub.grade_level, sub.standard_code
              ORDER BY sub.administered_at ASC)
       END AS std_attempt_rn
      ,CASE
        WHEN sub.schoolid = 73253 THEN
          ROW_NUMBER() OVER (
            PARTITION BY sub.academic_year, sub.schoolid, sub.subject_area, sub.standard_code
              ORDER BY sub.administered_at DESC) 
        ELSE
          ROW_NUMBER() OVER (
            PARTITION BY sub.academic_year, sub.schoolid, sub.grade_level, sub.standard_code
              ORDER BY sub.administered_at DESC) 
       END AS std_attempt_curr
FROM
    (
     SELECT a.assessment_id                                     
           ,a.title       
           ,a.scope    
           ,a.subject_area           
           ,CASE
             WHEN a.subject_area = 'Arabic' THEN 'WLANG'
             WHEN a.subject_area = 'Arts: Music' THEN 'ART'
             WHEN a.subject_area = 'Arts: Theatre' THEN 'ART'
             WHEN a.subject_area = 'Arts: Visual Arts' THEN 'ART'
             WHEN a.subject_area = 'Comprehension' THEN 'ENG'
             WHEN a.subject_area = 'English Language Arts' THEN 'ENG'
             WHEN a.subject_area = 'English' THEN 'ENG'
             WHEN a.subject_area = 'Vocabulary' THEN 'ENG'
             WHEN a.subject_area = 'French' THEN 'WLANG'
             WHEN a.subject_area = 'Grammar' THEN 'ENG'
             WHEN a.subject_area = 'Historical Arts' THEN 'SOC'
             WHEN a.subject_area = 'History' THEN 'SOC'
             WHEN a.subject_area = 'Humanities' THEN 'SOC'
             WHEN a.subject_area = 'Mathematics' THEN 'MATH'
             WHEN a.subject_area = 'Performing Arts' THEN 'ART'
             WHEN a.subject_area = 'Phonics' THEN 'ENG'
             WHEN a.subject_area = 'Physical Education' THEN 'PHYSED'
             WHEN a.subject_area = 'Reading' THEN 'ENG'
             WHEN a.subject_area = 'Science' THEN 'SCI'
             WHEN a.subject_area = 'Spanish' THEN 'WLANG'
             WHEN a.subject_area = 'Word Work' THEN 'ENG'
             WHEN a.subject_area = 'Writing' THEN 'RHET'
             ELSE a.subject_area
            END AS credittype           
           ,a.academic_year
           ,CONVERT(DATE,a.administered_at) AS administered_at
           ,a.state_id AS teachernumber
           ,u.lastfirst AS created_by
           ,a.performance_band_set_id
           ,sch.schoolid
           ,sch.grade_level
           ,std.standard_id
           ,std.custom_code AS standard_code
           ,KIPP_NJ.dbo.ASCII_CONVERT(std.description) AS standard_description
           ,rpt_wks.time_per_name AS reporting_wk
           ,rt.alt_name AS term
           ,t.grade_level_tags AS tags
     FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
     LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessments_sites#static sch WITH(NOLOCK)
       ON a.assessment_id = sch.assessment_id
     LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd WITH(NOLOCK)
       ON a.assessment_id = astd.assessment_id
     LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
       ON astd.standard_id = std.standard_id
     LEFT OUTER JOIN grade_level_tags t
       ON a.assessment_id = t.assessment_id
     LEFT OUTER JOIN KIPP_NJ..PS$USERS#static u WITH(NOLOCK)
       ON a.state_id = u.teachernumber
     LEFT OUTER JOIN KIPP_NJ..REPORTING$dates rpt_wks WITH(NOLOCK)
       ON a.administered_at BETWEEN rpt_wks.start_date AND rpt_wks.end_date
      AND sch.schoolid = rpt_wks.schoolid
      AND rpt_wks.identifier = 'REP'
     LEFT OUTER JOIN KIPP_NJ..REPORTING$dates rt WITH(NOLOCK)
       ON a.administered_at BETWEEN rt.start_date AND rt.end_date
      AND ((a.academic_year >= 2015 AND rt.schoolid = 0) OR (a.academic_year < 2015 AND sch.schoolid = rt.schoolid)) /* district normed quarters as of 2015-2016 */
      AND rt.identifier = 'RT'
    ) sub        
