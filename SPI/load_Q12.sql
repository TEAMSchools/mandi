WITH responses AS (
  SELECT [rollup] AS campus
        ,[Q12 Survey_1] AS Q1
        ,[Q12 Survey_2] AS Q2
        ,[Q12 Survey_3] AS Q3
        ,[Q12 Survey_4] AS Q4
        ,[Q12 Survey_5] AS Q5
        ,[Q12 Survey_6] AS Q6
        ,[Q12 Survey_7] AS Q7
        ,[Q12 Survey_8] AS Q8
        ,[Q12 Survey_9] AS Q9
        ,[Q12 Survey_10] AS Q10
        ,[Q12 Survey_11] AS Q11
        ,[Q12 Survey_12] AS Q12
  FROM OPENROWSET(
    'MSDASQL'
   ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
   ,'select * from C:\data_robot\q12\Q12_MOY_1415_Responses.csv'
   )
  WHERE [rollup] != '*'
 )

--,locations AS (
--  SELECT *
--  FROM OPENROWSET(
--    'MSDASQL'
--   ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
--   ,'select * from C:\data_robot\q12\Q12_SPR_1314_Locations.csv'
--   )
-- )

--,combined AS (
--  SELECT r.*
--        ,l.survey_location
--  FROM responses r
--  LEFT OUTER JOIN locations l
--    ON LTRIM(RTRIM(r.recipient_dummy)) = LTRIM(RTRIM(l.unique_id))  
-- )

,staging AS (
  SELECT recipient_dummy
        ,school_year
        ,season_text
        ,season_numeric
        ,campus
        ,first_year
        ,question_code
        ,response
  FROM
      (
       SELECT ROW_NUMBER() OVER(                
                ORDER BY campus) AS recipient_dummy      
             ,2014 AS school_year -- UPDATE
             ,'Winter' AS season_text -- UPDATE
             ,2 AS season_numeric -- UPDATE
             ,campus
             ,NULL AS first_year
             ,Q1
             ,Q2
             ,Q3
             ,Q4
             ,Q5
             ,Q6
             ,Q7
             ,Q8
             ,Q9
             ,Q10
             ,Q11
             ,Q12             
       FROM responses       
      ) sub
  UNPIVOT (
    response
    FOR question_code IN (Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12)
   ) u
 )


--INSERT INTO SPI..SPI$staff_Q12
SELECT *
FROM staging

/*
BEGIN TRANSACTION
ROLLBACK TRANSACTION
COMMIT TRANSACTION
*/