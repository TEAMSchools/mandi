USE KIPP_NJ
GO

ALTER PROCEDURE sp_DAILY$tracking_long#MERGE AS

BEGIN

  WITH dt_update AS (
    SELECT unique_id
          ,STUDENTID	
          ,SCHOOLID
          ,ATT_DATE
          ,field1
          ,field2
          ,field3
          ,field4
          ,field5
          ,field6
          ,field7
          ,field8
          ,field9
          ,field10
    FROM OPENQUERY(PS_TEAM,'
      SELECT unique_id        
            ,foreignkey AS STUDENTID	
            ,SCHOOLID
            ,user_defined_date AS ATT_DATE
            ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field1'') AS field1
            ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field2'') AS field2
            ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field3'') AS field3
            ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field4'') AS field4        
            ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field5'') AS field5        
            ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') AS field6
            ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field7'') AS field7
            ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field8'') AS field8
            ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field9'') AS field9
            ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field10'') AS field10                
      FROM virtualtablesdata2
      WHERE related_to_table = ''dailytracking''    
        AND (created_on >= TRUNC(SYSDATE - 3) OR last_modified >= TRUNC(SYSDATE - 3))
    ')  
   )

  MERGE KIPP_NJ..DAILY$tracking_long#staging AS TARGET
  USING dt_update AS SOURCE
     ON TARGET.unique_id = SOURCE.unique_id
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.field1 = SOURCE.field1
       ,TARGET.field2 = SOURCE.field2
       ,TARGET.field3 = SOURCE.field3
       ,TARGET.field4 = SOURCE.field4
       ,TARGET.field5 = SOURCE.field5
       ,TARGET.field6 = SOURCE.field6
       ,TARGET.field7 = SOURCE.field7
       ,TARGET.field8 = SOURCE.field8
       ,TARGET.field9 = SOURCE.field9
       ,TARGET.field10 = SOURCE.field10
  WHEN NOT MATCHED THEN
   INSERT
    (unique_id
    ,STUDENTID	
    ,SCHOOLID
    ,ATT_DATE
    ,field1
    ,field2
    ,field3
    ,field4
    ,field5
    ,field6
    ,field7
    ,field8
    ,field9
    ,field10)
   VALUES
    (SOURCE.unique_id
    ,SOURCE.STUDENTID	
    ,SOURCE.SCHOOLID
    ,SOURCE.ATT_DATE
    ,SOURCE.field1
    ,SOURCE.field2
    ,SOURCE.field3
    ,SOURCE.field4
    ,SOURCE.field5
    ,SOURCE.field6
    ,SOURCE.field7
    ,SOURCE.field8
    ,SOURCE.field9
    ,SOURCE.field10);

END

GO