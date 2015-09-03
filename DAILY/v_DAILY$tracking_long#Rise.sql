USE KIPP_NJ
GO

ALTER VIEW DAILY$tracking_long#Rise AS

SELECT studentid
      ,schoolid
      ,att_date
      ,field AS class
      ,CASE WHEN GRADE_LEVEL = 7 AND value = 'S' THEN '$' ELSE value END AS ccr
      ,CASE
        -- 8th codes
        WHEN GRADE_LEVEL = 8 AND value = 'S' THEN 1
        WHEN value = 'E' THEN 3
        WHEN value = 'G' THEN 2        
        WHEN value = 'N' THEN 0
        WHEN value = 'U' THEN -3        
        -- 7th codes
        WHEN GRADE_LEVEL = 7 AND value = 'S' THEN 5
        WHEN value = 'SL' THEN 0
        WHEN value = 'D' THEN -3
        WHEN value = 'C' THEN -11
        ELSE NULL
       END AS ccr_score
      ,CASE WHEN value = 'E' THEN 1 ELSE 0 END AS E
      ,CASE WHEN value = 'G' THEN 1 ELSE 0 END AS G
      ,CASE WHEN value = 'S' THEN 1 ELSE 0 END AS S
      ,CASE WHEN value = 'N' THEN 1 ELSE 0 END AS N
      ,CASE WHEN value = 'U' THEN 1 ELSE 0 END AS U      
FROM
    (
     SELECT daily.studentid
           ,daily.schoolid
           ,s.GRADE_LEVEL
           ,CONVERT(DATE,daily.att_date) AS att_date
           ,LTRIM(RTRIM(daily.adv_behavior)) AS adv_behavior
           ,LTRIM(RTRIM(daily.adv_logistic)) AS adv_logistic
           ,LTRIM(RTRIM(daily.math)) AS math
           ,LTRIM(RTRIM(daily.science)) AS science
           ,LTRIM(RTRIM(daily.reading)) AS reading
           ,LTRIM(RTRIM(daily.writing)) AS writing
           ,LTRIM(RTRIM(daily.history)) AS history
           ,LTRIM(RTRIM(daily.elec)) AS elec
           ,LTRIM(RTRIM(daily.other)) AS other
     FROM 
         (
          SELECT KIPP_NJ.dbo.fn_DateToSY(att_date) AS academic_year
                ,CONVERT(DATE,att_date) AS att_date
                ,studentid
                ,schoolid
                ,field1 AS adv_behavior
                ,field2 AS adv_logistic
                ,field3 AS math
                ,field4 AS science
                ,field5 AS reading
                ,field6 AS writing
                ,field7 AS history
                ,field8 AS elec
                ,field9 AS other
                ,field10
                ,ROW_NUMBER() OVER(
                   PARTITION BY studentid, att_date
                     ORDER BY unique_id ASC) AS dupe_audit
          FROM KIPP_NJ..DAILY$tracking_long#staging WITH(NOLOCK)
          WHERE schoolid = 73252            
         ) daily
     JOIN KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)
       ON daily.studentid = s.studentid
      AND daily.academic_year = s.year
      AND s.rn = 1
     WHERE daily.dupe_audit = 1
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