WITH responses AS (
  SELECT *
  FROM OPENROWSET(
    'MSDASQL'
   ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
   ,'select * from C:\data_robot\q12\Q12_SPR_1314_Responses.csv'
   )
 )

,locations AS (
  SELECT *
  FROM OPENROWSET(
    'MSDASQL'
   ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
   ,'select * from C:\data_robot\q12\Q12_SPR_1314_Locations.csv'
   )
 )

,combined AS (
  SELECT r.*
        ,l.survey_location
  FROM responses r
  LEFT OUTER JOIN locations l
    ON LTRIM(RTRIM(r.recipient_dummy)) = LTRIM(RTRIM(l.unique_id))  
 )

,staging AS (
  SELECT recipient_dummy      
        ,2013 AS school_year -- UPDATE
        ,'Spring' AS season_text -- UPDATE
        ,3 AS season_numeric -- UPDATE
        ,survey_location AS campus
        ,first_year
        ,question_code
        ,CASE
          WHEN response = 'Strongly Agree' THEN 5
          WHEN response = 'Agree' THEN 4
          WHEN response = 'Neutral' THEN 3
          WHEN response = 'Disagree' THEN 2
          WHEN response = 'Strongly Disagree' THEN 1
         END AS response
  FROM combined

  UNPIVOT (
    response
    FOR question_code IN (Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12)
   ) u
 )

--COMMIT TRANSACTION
--INSERT INTO SPI$staff_Q12
SELECT *
FROM staging