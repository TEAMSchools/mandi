USE KIPP_NJ
GO

ALTER VIEW DEVFIN$enrollment_rollup AS

SELECT SCHOOLID
      ,metric
      ,[Sep_2013]
      ,[Oct_2013]
      ,[Nov_2013]
      ,[Dec_2013]
      ,[Jan_2013]
      ,[Feb_2013]
      ,[Mar_2013]
      ,[Apr_2013]
      ,[May_2013]
      ,[Jun_2013]
      ,[Jul_2013]
      ,[Aug_2013]
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
  FOR month IN ([Sep_2013]
               ,[Oct_2013]
               ,[Nov_2013]
               ,[Dec_2013]
               ,[Jan_2013]
               ,[Feb_2013]
               ,[Mar_2013]
               ,[Apr_2013]
               ,[May_2013]
               ,[Jun_2013]
               ,[Jul_2013]
               ,[Aug_2013])
 ) piv