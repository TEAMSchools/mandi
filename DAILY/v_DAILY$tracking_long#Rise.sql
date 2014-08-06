USE KIPP_NJ
GO

ALTER VIEW DAILY$tracking_long#Rise AS

SELECT studentid
      ,schoolid
      ,att_date
      ,field AS class
      ,value AS ccr
      ,CASE WHEN value = 'E' THEN 1 ELSE 0 END AS E
      ,CASE WHEN value = 'G' THEN 1 ELSE 0 END AS G
      ,CASE WHEN value = 'S' THEN 1 ELSE 0 END AS S
      ,CASE WHEN value = 'N' THEN 1 ELSE 0 END AS N
      ,CASE WHEN value = 'U' THEN 1 ELSE 0 END AS U      
FROM
    (
     SELECT daily.studentid
           ,daily.schoolid
           ,CONVERT(DATE,daily.att_date) AS att_date
           ,daily.adv_behavior
           ,daily.adv_logistic
           ,daily.math
           ,daily.science
           ,daily.reading
           ,daily.writing
           ,daily.history
           ,daily.elec
           ,daily.other
     FROM OPENQUERY(PS_BUCA,'
       SELECT user_defined_date AS att_date
             ,foreignkey AS studentid
             ,schoolid
             ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field1'') AS adv_behavior
             ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field2'') AS adv_logistic
             ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field3'') AS math
             ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field4'') AS science
             ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field5'') AS reading
             ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') AS writing
             ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field7'') AS history
             ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field8'') AS elec
             ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field9'') AS other
             /*,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field10'') field10*/        
       FROM virtualtablesdata2
       WHERE related_to_table = ''dailytracking''
         AND schoolid = 73252
     ') daily
    ) sub
UNPIVOT (
  value
  FOR field IN (adv_behavior
               ,adv_logistic
               ,math
               ,science
               ,reading
               ,writing
               ,history
               ,elec
               ,other)
 ) u