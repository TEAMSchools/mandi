USE KIPP_NJ
GO

ALTER VIEW SURVEY$manager_survey_averages AS

WITH curr_manager_survey AS (
  SELECT academic_year
        ,term        
        ,ROW_NUMBER() OVER(
           PARTITION BY academic_year
             ORDER BY term DESC) AS rn
  FROM
      (
       SELECT DISTINCT
              academic_year
             ,term       
       FROM KIPP_NJ..PEOPLE$PM_survey_responses_long#static WITH(NOLOCK)
       WHERE survey_type = 'Manager'
         AND is_open_ended = 0
      ) sub
 )

SELECT academic_year
      ,schoolid      
      ,(AVG(CONVERT(FLOAT,is_topbox)) * 100) AS pct_topbox
FROM
    (
     SELECT academic_year
           --,term
           ,subject_name
           --,question_code
           ,CASE WHEN response_value IN (3,4) THEN 1.0 ELSE 0.0 END AS is_topbox
           ,CASE
             WHEN subject_reporting_location = 'Bold Academy' THEN 73258
             WHEN subject_reporting_location = 'Lanning Square Middle School' THEN 179902
             WHEN subject_reporting_location = 'Lanning Square Primary' THEN 179901
             WHEN subject_reporting_location = 'Life Academy' THEN 73257
             WHEN subject_reporting_location = 'Newark Collegiate Academy' THEN 73253
             WHEN subject_reporting_location = 'Rise Academy' THEN 73252
             WHEN subject_reporting_location = 'Seek Academy' THEN 73256
             WHEN subject_reporting_location = 'SPARK Academy' THEN 73254
             WHEN subject_reporting_location = 'TEAM Academy' THEN 133570965
             WHEN subject_reporting_location = 'THRIVE Academy' THEN 73255
            END AS schoolid
     FROM KIPP_NJ..PEOPLE$PM_survey_responses_long#static WITH(NOLOCK)
     WHERE survey_type = 'Manager'
       AND is_open_ended = 0
       AND term IN (SELECT term FROM curr_manager_survey WHERE rn = 1)
    ) sub
GROUP BY academic_year
        ,schoolid