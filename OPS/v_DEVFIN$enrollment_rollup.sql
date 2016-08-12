USE KIPP_NJ
GO

ALTER VIEW DEVFIN$enrollment_rollup AS

SELECT SCHOOLID
      ,metric
      ,[Sep_2015]
      ,[Oct_2015]
      ,[Nov_2015]
      ,[Dec_2015]
      ,[Jan_2015]
      ,[Feb_2015]
      ,[Mar_2015]
      ,[Apr_2015]
      ,[May_2015]
      ,[Jun_2015]
      ,[Jul_2015]
      ,[Aug_2015]
FROM
    (
     SELECT LEFT(DATENAME(MONTH,date),3) + '_' + CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) AS month
           ,SCHOOLID      
           ,'att' AS metric
           ,ROUND((SUM(CONVERT(FLOAT,attendancevalue)) / SUM(CONVERT(FLOAT,membershipvalue))) * 100,0) AS value      
     FROM DEVFIN$att_demographics_long WITH(NOLOCK)
     WHERE date >= CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-08-01'
       AND date <= CONVERT(VARCHAR,(dbo.fn_Global_Academic_Year() + 1)) + '-07-31'
     GROUP BY LEFT(DATENAME(MONTH,date),3), SCHOOLID

     UNION ALL

     SELECT month + '_' + CONVERT(VARCHAR,year) AS month
           ,SCHOOLID
           ,metric
           ,SUM(membershipvalue) AS value
     FROM
         (
          SELECT DISTINCT 
                 LEFT(DATENAME(MONTH,date),3) AS month
                ,dbo.fn_Global_Academic_Year() AS year
                ,SCHOOLID
                ,STUDENTID      
                --,lunchstatus
                ,'enrollment' AS metric
                ,membershipvalue
          FROM DEVFIN$att_demographics_long WITH(NOLOCK)
          WHERE date >= CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-08-01'
            AND date <= CONVERT(VARCHAR,(dbo.fn_Global_Academic_Year() + 1)) + '-07-31'
            AND membershipvalue = 1
         ) sub
     GROUP BY month
             ,year
             ,SCHOOLID
             ,metric
             
     UNION ALL        

     SELECT month + '_' + CONVERT(VARCHAR,year) AS month
           ,SCHOOLID
           ,metric
           ,SUM(membershipvalue) AS value
     FROM
         (
          SELECT DISTINCT 
                 LEFT(DATENAME(MONTH,date),3) AS month
                ,dbo.fn_Global_Academic_Year() AS year
                ,SCHOOLID
                ,STUDENTID      
                ,lunchstatus AS metric
                ,membershipvalue                      
          FROM DEVFIN$att_demographics_long WITH(NOLOCK)
          WHERE date >= CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-08-01'
            AND date <= CONVERT(VARCHAR,(dbo.fn_Global_Academic_Year() + 1)) + '-07-31'
            AND membershipvalue = 1
         ) sub
     GROUP BY month
             ,year
             ,SCHOOLID
             ,metric
    ) sub2
    
PIVOT(
  MAX(value)
  FOR month IN ([Sep_2015]
               ,[Oct_2015]
               ,[Nov_2015]
               ,[Dec_2015]
               ,[Jan_2015]
               ,[Feb_2015]
               ,[Mar_2015]
               ,[Apr_2015]
               ,[May_2015]
               ,[Jun_2015]
               ,[Jul_2015]
               ,[Aug_2015])
 ) piv