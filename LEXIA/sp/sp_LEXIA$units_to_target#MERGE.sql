USE KIPP_NJ
GO

ALTER PROCEDURE sp_LEXIA$units_to_target#MERGE AS

BEGIN

  WITH lexia_update AS (
    SELECT DISTINCT 
           CONVERT(VARCHAR(64),username) AS username
          ,CONVERT(INT,units_to_target) AS units_to_target
          ,CONVERT(INT,week_time) AS week_time          
          ,CONVERT(DATE,GETDATE()) AS datestamp
    FROM KIPP_NJ..AUTOLOAD$LEXIA_detail WITH(NOLOCK)
   )
  
  MERGE KIPP_NJ..LEXIA$units_to_target AS TARGET
    USING lexia_update AS SOURCE
       ON TARGET.username = SOURCE.username
      AND TARGET.datestamp = SOURCE.datestamp
    WHEN MATCHED THEN
     UPDATE
      SET TARGET.units_to_target = SOURCE.units_to_target
         ,TARGET.week_time = SOURCE.week_time
    WHEN NOT MATCHED BY TARGET THEN
     INSERT
      (username
      ,units_to_target
      ,datestamp
      ,week_time)
     VALUES
      (SOURCE.username
      ,SOURCE.units_to_target
      ,SOURCE.datestamp
      ,SOURCE.week_time);

END
GO