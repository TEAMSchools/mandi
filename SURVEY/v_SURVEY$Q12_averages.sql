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
      ,schoolid
      ,AVG(CONVERT(FLOAT,response_value)) AS avg_response_value
FROM
    (
     SELECT academic_year
           ,CASE
             WHEN responder_reporting_location = 'TEAM Academy' THEN 133570965
             WHEN responder_reporting_location = 'Rise Academy' THEN 73252                  
             WHEN responder_reporting_location = 'Newark Collegiate Academy' THEN 73253                  
             WHEN responder_reporting_location = 'SPARK Academy' THEN 73254
             WHEN responder_reporting_location = 'THRIVE Academy' THEN 73255
             WHEN responder_reporting_location = 'Seek Academy' THEN 73256
             WHEN responder_reporting_location = 'Life Academy' THEN 73257
             WHEN responder_reporting_location = 'Pathways' THEN 732574573
             WHEN responder_reporting_location = 'Bold Academy' THEN 73258    
             WHEN responder_reporting_location = 'Lanning Square Primary' THEN 179901
             WHEN responder_reporting_location = 'Whittier Elementary' THEN 1799015075
             WHEN responder_reporting_location = 'Lanning Square MS' THEN 179902
             WHEN responder_reporting_location = 'Whittier Middle' THEN 179903                  
             WHEN responder_reporting_location = 'Room 9 (Newark)' THEN 0                  
             WHEN responder_reporting_location = 'KIPP NJ' THEN 0
             WHEN responder_reporting_location = 'KCNA' THEN 0
             WHEN responder_reporting_location = '18th Avenue Campus' THEN 0
             ELSE 0
            END AS schoolid
           ,response_value
     FROM KIPP_NJ..PEOPLE$PM_survey_responses_long#static WITH(NOLOCK)
     WHERE survey_type = 'R9'
       AND competency = 'Q12'
       AND term IN (SELECT term FROM curr_Q12 WHERE rn = 1)
    ) sub
GROUP BY academic_year
        ,schoolid

UNION ALL

SELECT academic_year      
      ,CASE                          
        WHEN school IN ('Life Upper','Life Lower') THEN 73257        
        WHEN school = 'NCA' THEN 73253        
        WHEN school = 'Revolution' THEN 179901
        WHEN school = 'Rise' THEN 73252        
        WHEN school = 'Seek Academy' THEN 73256        
        WHEN school = 'SPARK' THEN 73254        
        WHEN school = 'TEAM' THEN 133570965        
        WHEN school = 'THRIVE' THEN 73255        
        WHEN school = 'Room 9' THEN 0
        ELSE 0
       END AS schoolid
      ,AVG(CONVERT(FLOAT,response)) AS avg_response_value
FROM KIPP_NJ..AUTOLOAD$GDOCS_SURVEY_historical_q12 WITH(NOLOCK)
WHERE term_numeric = 3
GROUP BY academic_year      
        ,CASE                          
          WHEN school IN ('Life Upper','Life Lower') THEN 73257        
          WHEN school = 'NCA' THEN 73253        
          WHEN school = 'Revolution' THEN 179901
          WHEN school = 'Rise' THEN 73252        
          WHEN school = 'Seek Academy' THEN 73256        
          WHEN school = 'SPARK' THEN 73254        
          WHEN school = 'TEAM' THEN 133570965        
          WHEN school = 'THRIVE' THEN 73255        
          WHEN school = 'Room 9' THEN 0
          ELSE 0
         END