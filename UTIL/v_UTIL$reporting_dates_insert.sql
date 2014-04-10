--BE CAREFUL ABOUT SKIPPING WEEKS (e.g. SPRING BREAK)
--ONLY DO CONSECUTIVE WEEKS IN BATCH, OTHERWISE DO ONE AT A TIME

/* --source table
   --check original and altered state before and after insert
   SELECT time_hierarchy
         ,yearid
         ,school_level
         ,identifier
         ,time_per_name
         ,start_date
         ,end_date
   FROM REPORTING$dates
   WHERE identifier = 'FSA'  
   ORDER BY start_date
*/

WITH latest_entry AS (
-- select all fields you want to INSERT INTO
-- use MAX function on the fields you want to dynamically generate
  SELECT time_hierarchy
        ,yearid
        ,school_level
        ,identifier
        ,CONVERT(INT,RIGHT(MAX(time_per_name),2)) AS week_num
        ,MAX(start_date) AS start_date
        ,MAX(end_date) AS end_date
  FROM REPORTING$dates
  WHERE identifier = 'FSA' -- type of time period you want to add  
  GROUP BY time_hierarchy -- any repeated fields go here
          ,yearid
          ,school_level
          ,identifier
 )
 
,row_gen AS (
  SELECT *
  FROM UTIL$row_generator
  WHERE n > 0 -- always
    AND n <= 7 -- number of dynamic new records to INSERT
 )

,new_rows AS (
  SELECT time_hierarchy
        ,yearid
        ,school_level
        ,identifier
        ,'Week_' + CONVERT(VARCHAR,week_num + row_gen.n) AS time_per_name
        ,DATEADD(WEEK,(row_gen.n),start_date) AS start_date
        ,DATEADD(WEEK,(row_gen.n),end_date) AS end_date
  FROM latest_entry
  JOIN row_gen
    ON 1 = 1
 )
 
--BEGIN TRANSACTION
--COMMIT TRANSACTION
--ROLLBACK TRANSACTION

INSERT INTO REPORTING$dates (time_hierarchy
                            ,yearid
                            ,school_level
                            ,identifier
                            ,time_per_name
                            ,start_date
                            ,end_date)
SELECT time_hierarchy
      ,yearid
      ,school_level
      ,identifier
      ,time_per_name
      ,start_date
      ,end_date
FROM new_rows