USE KIPP_NJ
GO

ALTER VIEW DL$mod_standards#extract AS

SELECT student_number
      ,academic_year
      ,term
      ,subject_area
      ,standard_description
      ,ROUND(AVG(percent_correct),0) AS percent_correct
      ,CASE
        WHEN ROUND(AVG(percent_correct),0) >= 85 THEN 'Exceeded Expectations'
        WHEN ROUND(AVG(percent_correct),0) >= 70 THEN 'Met Expectations'
        WHEN ROUND(AVG(percent_correct),0) >= 50 THEN 'Approached Expectations'
        WHEN ROUND(AVG(percent_correct),0) >= 35 THEN 'Partially Met Expectations'
        WHEN ROUND(AVG(percent_correct),0) < 35 THEN 'Did Not Yet Meet Expectations'
       END AS standard_proficiency
FROM
    (
     SELECT res.local_student_id AS student_number
           ,a.academic_year
           ,CASE WHEN dt.alt_name = 'Summer School' THEN 'Q1' ELSE dt.alt_name END AS term
           ,CASE
             WHEN a.subject_area IN ('Text Study','Mathematics') THEN 'Specials'
             ELSE a.subject_area
            END AS subject_area
           ,CASE
             WHEN a.subject_area NOT IN ('Text Study','Mathematics') THEN CONCAT(a.subject_area, ' - ', REPLACE(CONVERT(VARCHAR(MAX),std.description),'"',''''))
             ELSE REPLACE(CONVERT(VARCHAR(MAX),std.description),'"','''')
            END AS standard_description
           ,CONVERT(FLOAT,res.percent_correct) AS percent_correct
     FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
     JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd WITH(NOLOCK)
       ON a.assessment_id = astd.assessment_id
     JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
       ON astd.standard_id = std.standard_id
      AND std.custom_code NOT LIKE 'TES.W.%'
     JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard res WITH(NOLOCK)
       ON a.assessment_id = res.assessment_id
      AND std.standard_id = res.standard_id
      AND res.answered > 0
     JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       ON res.local_student_id = co.student_number
      AND a.academic_year = co.year
      AND (co.grade_level <= 4 AND co.schoolid != 73252) /* ES only */
      AND co.rn = 1
     JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
       ON co.schoolid = dt.schoolid
      AND a.academic_year = dt.academic_year
      AND a.administered_at BETWEEN dt.start_date AND dt.end_date
      AND dt.identifier = 'RT'
     WHERE a.scope IN ('CMA - End-of-Module','Unit Assessment')
       AND a.subject_area != 'Writing'
       AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    ) sub
GROUP BY student_number
        ,academic_year
        ,term
        ,subject_area
        ,standard_description