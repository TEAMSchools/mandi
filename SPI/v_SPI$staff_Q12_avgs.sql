USE SPI
GO

ALTER VIEW SPI$staff_Q12_avgs AS

SELECT SCHOOL_YEAR
      ,SEASON_TEXT
      ,SEASON_NUMERIC
      ,CAMPUS
      ,QUESTION_CODE
      ,q_avg
      ,pct_5s
      ,pct_4s
      ,pct_3s
      ,pct_2s
      ,pct_1s
      ,season_code      
      ,ROUND(AVG(q_avg) OVER(PARTITION BY campus, season_code),2) AS overall_avg
      ,campus + '_' + CONVERT(VARCHAR,rn) AS hash
FROM
    (
     SELECT *           
           ,ROW_NUMBER() OVER(
              PARTITION BY campus, question_code
                ORDER BY school_year DESC, season_numeric DESC) AS rn
     FROM
         (
          SELECT school_year
                ,season_text 
                ,season_numeric 
                ,CASE
                  WHEN campus LIKE 'Life%' THEN 'Life'
                  WHEN campus = 'Revolution' THEN 'Rev'
                  ELSE campus
                 END AS campus
                ,question_code 
                ,ROUND(AVG(CONVERT(FLOAT,response)),2) AS q_avg 
                ,CONVERT(FLOAT,ROUND(AVG(CASE
                                          WHEN response IS NULL THEN NULL
                                          WHEN response = 5 THEN 1.0
                                          WHEN response != 5 THEN 0.0
                                         END ) * 100,0)) AS pct_5s 
                ,CONVERT(FLOAT,ROUND(AVG(CASE
                                          WHEN response IS NULL THEN NULL
                                          WHEN response = 4 THEN 1.0
                                          WHEN response != 4 THEN 0.0
                                         END ) * 100,0)) AS pct_4s 
                ,CONVERT(FLOAT,ROUND(AVG(CASE
                                          WHEN response IS NULL THEN NULL
                                          WHEN response = 3 THEN 1.0
                                          WHEN response != 3 THEN 0.0
                                         END ) * 100,0)) AS pct_3s 
                ,CONVERT(FLOAT,ROUND(AVG(CASE
                                          WHEN response IS NULL THEN NULL
                                          WHEN response = 2 THEN 1.0
                                          WHEN response != 2 THEN 0.0
                                         END ) * 100,0)) AS pct_2s 
                ,CONVERT(FLOAT,ROUND(AVG(CASE
                                          WHEN response IS NULL THEN NULL
                                          WHEN response = 1 THEN 1.0
                                          WHEN response != 1 THEN 0.0
                                         END ) * 100,0)) AS pct_1s
                ,season_text + ' ' + CONVERT(VARCHAR,school_year) AS season_code
          FROM SPI..SPI$staff_Q12 WITH(NOLOCK)
          WHERE campus IS NOT NULL
            AND CAMPUS != 'Room 9'
          GROUP BY school_year
                  ,season_text 
                  ,season_numeric 
                  ,CASE
                    WHEN campus LIKE 'Life%' THEN 'Life'
                    WHEN campus = 'Revolution' THEN 'Rev'
                    ELSE campus
                   END
                  ,question_code
         ) sub
    ) sub