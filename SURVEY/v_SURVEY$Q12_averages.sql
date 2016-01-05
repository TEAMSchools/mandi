USE KIPP_NJ
GO

ALTER VIEW SURVEY$Q12_averages AS

WITH curr_Q12 AS (
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
       WHERE survey_type = 'R9'
         AND competency = 'Q12'
      ) sub
 )

SELECT academic_year
      ,CASE
        WHEN responder_reporting_location = 'Bold Academy' THEN 73258        
        WHEN responder_reporting_location = 'Lanning Square Middle School' THEN 179902        
        WHEN responder_reporting_location IN ('Life Upper','Life Lower','Pathways','Life Academy') THEN 73257        
        WHEN responder_reporting_location IN ('Newark Collegiate Academy','NCA') THEN 73253        
        WHEN responder_reporting_location IN ('Revolution','Lanning Square Primary') THEN 179901
        WHEN responder_reporting_location IN ('Rise Academy','Rise') THEN 73252        
        WHEN responder_reporting_location IN ('Seek Academy','Seek') THEN 73256        
        WHEN responder_reporting_location IN ('SPARK Academy','SPARK') THEN 73254        
        WHEN responder_reporting_location IN ('TEAM Academy','TEAM') THEN 133570965        
        WHEN responder_reporting_location IN ('THRIVE Academy','THRIVE') THEN 73255        
       END AS schoolid
      ,avg_response_value
FROM
    (
     SELECT academic_year
           ,responder_reporting_location
           ,AVG(CONVERT(FLOAT,response_value)) AS avg_response_value
     FROM KIPP_NJ..PEOPLE$PM_survey_responses_long#static WITH(NOLOCK)
     WHERE survey_type = 'R9'
       AND competency = 'Q12'
       AND term IN (SELECT term FROM curr_Q12 WHERE rn = 1)
     GROUP BY academic_year
             ,responder_reporting_location

     UNION ALL

     SELECT academic_year      
           ,school
           ,AVG(CONVERT(FLOAT,response)) AS avg_response_value
     FROM KIPP_NJ..AUTOLOAD$GDOCS_SURVEY_historical_q12 WITH(NOLOCK)
     WHERE term_numeric = 3
     GROUP BY academic_year      
             ,school
    ) sub