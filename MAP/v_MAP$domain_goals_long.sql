USE KIPP_NJ
GO

ALTER VIEW MAP$domain_goals_long AS

WITH long_data AS (
  SELECT student_number
        ,academic_year
        ,term
        ,MeasurementScale
        ,TestID
        ,testname
        ,rn      
        ,SUBSTRING(field, 5, 1) AS goal_number
        ,SUBSTRING(field, 6, 10) AS goal_field
        ,value
  FROM
      (
       SELECT student_number
             ,academic_year
             ,term
             ,measurementscale                          
             ,TestID
             ,testname
             ,rn      
             ,CONVERT(VARCHAR(64),goal1name) AS goal1name
             ,CONVERT(VARCHAR(64),goal1ritscore) AS goal1ritscore
             ,CONVERT(VARCHAR(64),goal1range) AS goal1range
             ,CONVERT(VARCHAR(64),goal1adjective) AS goal1adjective
             ,CONVERT(VARCHAR(64),goal2name) AS goal2name
             ,CONVERT(VARCHAR(64),goal2ritscore) AS goal2ritscore
             ,CONVERT(VARCHAR(64),goal2range) AS goal2range
             ,CONVERT(VARCHAR(64),goal2adjective) AS goal2adjective
             ,CONVERT(VARCHAR(64),goal3name) AS goal3name
             ,CONVERT(VARCHAR(64),goal3ritscore) AS goal3ritscore
             ,CONVERT(VARCHAR(64),goal3range) AS goal3range
             ,CONVERT(VARCHAR(64),goal3adjective) AS goal3adjective
             ,CONVERT(VARCHAR(64),goal4name) AS goal4name
             ,CONVERT(VARCHAR(64),goal4ritscore) AS goal4ritscore
             ,CONVERT(VARCHAR(64),goal4range) AS goal4range
             ,CONVERT(VARCHAR(64),goal4adjective) AS goal4adjective
             ,CONVERT(VARCHAR(64),goal5name) AS goal5name
             ,CONVERT(VARCHAR(64),goal5ritscore) AS goal5ritscore
             ,CONVERT(VARCHAR(64),goal5range) AS goal5range
             ,CONVERT(VARCHAR(64),goal5adjective) AS goal5adjective
             ,CONVERT(VARCHAR(64),goal6name) AS goal6name
             ,CONVERT(VARCHAR(64),goal6ritscore) AS goal6ritscore
             ,CONVERT(VARCHAR(64),goal6range) AS goal6range
             ,CONVERT(VARCHAR(64),goal6adjective) AS goal6adjective
             ,CONVERT(VARCHAR(64),goal7name) AS goal7name
             ,CONVERT(VARCHAR(64),goal7ritscore) AS goal7ritscore
             ,CONVERT(VARCHAR(64),goal7range) AS goal7range
             ,CONVERT(VARCHAR(64),goal7adjective) AS goal7adjective
             ,CONVERT(VARCHAR(64),goal8name) AS goal8name
             ,CONVERT(VARCHAR(64),goal8ritscore) AS goal8ritscore
             ,CONVERT(VARCHAR(64),goal8range) AS goal8range
             ,CONVERT(VARCHAR(64),goal8adjective) AS goal8adjective
       FROM KIPP_NJ..MAP$CDF#identifiers#static WITH(NOLOCK)               
      ) sub
  UNPIVOT(
    value
    FOR field IN (goal1name
                 ,goal1ritscore
                 ,goal1range
                 ,goal1adjective
                 ,goal2name
                 ,goal2ritscore
                 ,goal2range
                 ,goal2adjective
                 ,goal3name
                 ,goal3ritscore
                 ,goal3range
                 ,goal3adjective
                 ,goal4name
                 ,goal4ritscore
                 ,goal4range
                 ,goal4adjective
                 ,goal5name
                 ,goal5ritscore
                 ,goal5range
                 ,goal5adjective
                 ,goal6name
                 ,goal6ritscore
                 ,goal6range
                 ,goal6adjective
                 ,goal7name
                 ,goal7ritscore
                 ,goal7range
                 ,goal7adjective
                 ,goal8name
                 ,goal8ritscore
                 ,goal8range
                 ,goal8adjective)
   ) u
 )

SELECT student_number
      ,academic_year
      ,term
      ,MeasurementScale
      ,TestID
      ,testname
      ,rn
      ,CONVERT(INT,goal_number) AS goal_number
      ,name
      ,CONVERT(INT,ritscore) AS ritscore
      ,range
      ,adjective
FROM long_data
PIVOT(
  MAX(value)
  FOR goal_field IN ([name]
                    ,[ritscore]
                    ,[range]
                    ,[adjective])
 ) p