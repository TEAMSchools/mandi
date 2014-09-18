USE SPI
GO

ALTER VIEW SPI$staff_Q12_avgs AS

SELECT school_year
      ,season_text 
      ,season_numeric 
      ,campus 
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
GROUP BY school_year
        ,season_text 
        ,season_numeric 
        ,campus 
        ,question_code