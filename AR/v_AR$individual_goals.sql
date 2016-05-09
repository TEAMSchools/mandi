USE KIPP_NJ
GO

ALTER VIEW AR$individual_goals AS 

SELECT sn AS student_number
      ,REPLACE(cycle,'Q','RT') AS term
      ,CONVERT(FLOAT,adjusted_goal) AS adjusted_goal
      ,ROW_NUMBER() OVER(
         PARTITION BY sn, cycle
           ORDER BY adjusted_goal DESC) AS rn        
FROM
    (
     SELECT CONVERT(INT,sn) AS sn
           ,CONVERT(VARCHAR,cycle) AS cycle
           ,CONVERT(FLOAT,REPLACE(adjusted_goal,',','')) AS adjusted_goal
     FROM KIPP_NJ..AUTOLOAD$GDOCS_AR_NCA WITH(NOLOCK)
     WHERE sn IS NOT NULL  
       AND adjusted_goal IS NOT NULL
     UNION ALL
     SELECT CONVERT(INT,sn) AS sn
           ,CONVERT(VARCHAR,cycle) AS cycle
           ,CONVERT(FLOAT,REPLACE(adjusted_goal,',','')) AS adjusted_goal
     FROM KIPP_NJ..AUTOLOAD$GDOCS_AR_rise WITH(NOLOCK)
     WHERE sn IS NOT NULL  
       AND adjusted_goal IS NOT NULL
     UNION ALL
     SELECT CONVERT(INT,sn) AS sn
           ,CONVERT(VARCHAR,cycle) AS cycle
           ,CONVERT(FLOAT,REPLACE(adjusted_goal,',','')) AS adjusted_goal
     FROM KIPP_NJ..AUTOLOAD$GDOCS_AR_team WITH(NOLOCK)
     WHERE sn IS NOT NULL  
       AND adjusted_goal IS NOT NULL
     UNION ALL
     SELECT CONVERT(INT,sn) AS sn
           ,CONVERT(VARCHAR,cycle) AS cycle
           ,CONVERT(FLOAT,REPLACE(adjusted_goal,',','')) AS adjusted_goal
     FROM KIPP_NJ..AUTOLOAD$GDOCS_AR_bold WITH(NOLOCK)
     WHERE sn IS NOT NULL  
       AND adjusted_goal IS NOT NULL
     UNION ALL
     SELECT CONVERT(INT,sn) AS sn
           ,CONVERT(VARCHAR,cycle) AS cycle
           ,CONVERT(FLOAT,REPLACE(adjusted_goal,',','')) AS adjusted_goal
     FROM KIPP_NJ..AUTOLOAD$GDOCS_AR_lsm WITH(NOLOCK)
     WHERE sn IS NOT NULL    
       AND adjusted_goal IS NOT NULL
    ) sub