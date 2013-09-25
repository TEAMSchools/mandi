/*
PURPOSE:
  Simple wide view of math scores showing fall/spring RITs for all kids who have taken MAP math tests at TEAM

MAINTENANCE:
  MAINTENANCE QUARTERLY:
    Activate new termnames in the pivot if test events have occured that aren't present
  MAINTENANCE YEARLY:
    Add new termnames for year, comment out/kill anything beyond past 4 years
  
MAJOR STRUCTURAL REVISIONS OR CHANGES:
  Major simplicification on 7/12/12 - the query was looking directly @ map_comprehensive and was written to look at comprehensive_with_identifiers.
    This removed a lot of cruft devoted to breaking out terms, sorting by growth measure, etc.
    This will *definitely* need to get tweaked if we intend to start reporting college readiness/rutgers goals (and we do!)
  "Ported" to Server via OPENQUERY, Oracle source code included below -CB

CREATED BY:
  AM2

ORIGIN DATE:
  Fall 2011
  
LAST MODIFIED:
  Fall 2013 (CB)
*/

USE KIPP_NJ
GO

ALTER VIEW MAP$math_wide AS
SELECT *
FROM OPENQUERY(KIPP_NWK,'
       SELECT STUDENTID
             --,CAST(SPRING_2014_RIT AS INT)               AS SPRING_2014_RIT
             --,CAST(SPRING_2014_PERCENTILE AS INT)        AS SPRING_2014_PERCENTILE
             --,CAST(SPRING_2014_FALLTOSPRING_GOAL AS INT) AS SPRING_2014_FALLTOSPRING_GOAL
             --,CAST(WINTER_2013_RIT AS INT)               AS WINTER_2013_RIT
             --,CAST(WINTER_2013_PERCENTILE AS INT)        AS WINTER_2013_PERCENTILE
             --,CAST(WINTER_2013_FALLTOSPRING_GOAL AS INT) AS WINTER_2013_FALLTOSPRING_GOAL
             ,CAST(FALL_2013_RIT AS INT)                 AS FALL_2013_RIT
             ,CAST(FALL_2013_PERCENTILE AS INT)          AS FALL_2013_PERCENTILE
             ,CAST(FALL_2013_FALLTOSPRING_GOAL AS INT)   AS FALL_2013_FALLTOSPRING_GOAL
             ,CAST(SPRING_2013_RIT AS INT)               AS SPRING_2013_RIT
             ,CAST(SPRING_2013_PERCENTILE AS INT)        AS SPRING_2013_PERCENTILE
             ,CAST(SPRING_2013_FALLTOSPRING_GOAL AS INT) AS SPRING_2013_FALLTOSPRING_GOAL
             ,CAST(WINTER_2012_RIT AS INT)               AS WINTER_2012_RIT
             ,CAST(WINTER_2012_PERCENTILE AS INT)        AS WINTER_2012_PERCENTILE
             ,CAST(WINTER_2012_FALLTOSPRING_GOAL AS INT) AS WINTER_2012_FALLTOSPRING_GOAL
             ,CAST(FALL_2012_RIT AS INT)                 AS FALL_2012_RIT
             ,CAST(FALL_2012_PERCENTILE AS INT)          AS FALL_2012_PERCENTILE
             ,CAST(FALL_2012_FALLTOSPRING_GOAL AS INT)   AS FALL_2012_FALLTOSPRING_GOAL
             ,CAST(SPRING_2012_RIT AS INT)               AS SPRING_2012_RIT
             ,CAST(SPRING_2012_PERCENTILE AS INT)        AS SPRING_2012_PERCENTILE
             ,CAST(SPRING_2012_FALLTOSPRING_GOAL AS INT) AS SPRING_2012_FALLTOSPRING_GOAL
             ,CAST(WINTER_2011_RIT AS INT)               AS WINTER_2011_RIT
             ,CAST(WINTER_2011_PERCENTILE AS INT)        AS WINTER_2011_PERCENTILE
             ,CAST(WINTER_2011_FALLTOSPRING_GOAL AS INT) AS WINTER_2011_FALLTOSPRING_GOAL
             ,CAST(FALL_2011_RIT AS INT)                 AS FALL_2011_RIT
             ,CAST(FALL_2011_PERCENTILE AS INT)          AS FALL_2011_PERCENTILE
             ,CAST(FALL_2011_FALLTOSPRING_GOAL AS INT)   AS FALL_2011_FALLTOSPRING_GOAL
             ,CAST(SPRING_2011_RIT AS INT)               AS SPRING_2011_RIT
             ,CAST(SPRING_2011_PERCENTILE AS INT)        AS SPRING_2011_PERCENTILE
             ,CAST(SPRING_2011_FALLTOSPRING_GOAL AS INT) AS SPRING_2011_FALLTOSPRING_GOAL
             ,CAST(WINTER_2010_RIT AS INT)               AS WINTER_2010_RIT
             ,CAST(WINTER_2010_PERCENTILE AS INT)        AS WINTER_2010_PERCENTILE
             ,CAST(WINTER_2010_FALLTOSPRING_GOAL AS INT) AS WINTER_2010_FALLTOSPRING_GOAL
             ,CAST(FALL_2010_RIT AS INT)                 AS FALL_2010_RIT
             ,CAST(FALL_2010_PERCENTILE AS INT)          AS FALL_2010_PERCENTILE
             ,CAST(FALL_2010_FALLTOSPRING_GOAL AS INT)   AS FALL_2010_FALLTOSPRING_GOAL
             ,CAST(SPRING_2010_RIT AS INT)               AS SPRING_2010_RIT
             ,CAST(SPRING_2010_PERCENTILE AS INT)        AS SPRING_2010_PERCENTILE
             --,CAST(SPRING_2010_FALLTOSPRING_GOAL AS INT) AS SPRING_2010_FALLTOSPRING_GOAL
             --,CAST(WINTER_2009_RIT AS INT)               AS WINTER_2009_RIT
             --,CAST(WINTER_2009_PERCENTILE AS INT)        AS WINTER_2009_PERCENTILE
             --,CAST(WINTER_2009_FALLTOSPRING_GOAL AS INT) AS WINTER_2009_FALLTOSPRING_GOAL
             --,CAST(FALL_2009_RIT AS INT)                 AS FALL_2009_RIT
             --,CAST(FALL_2009_PERCENTILE AS INT)          AS FALL_2009_PERCENTILE
             --,CAST(FALL_2009_FALLTOSPRING_GOAL AS INT)   AS FALL_2009_FALLTOSPRING_GOAL
             --,CAST(SPRING_2009_RIT AS INT)               AS SPRING_2009_RIT
             --,CAST(SPRING_2009_PERCENTILE AS INT)        AS SPRING_2009_PERCENTILE
             --,CAST(SPRING_2009_FALLTOSPRING_GOAL AS INT) AS SPRING_2009_FALLTOSPRING_GOAL
             --,CAST(WINTER_2008_RIT AS INT)               AS WINTER_2008_RIT
             --,CAST(WINTER_2008_PERCENTILE AS INT)        AS WINTER_2008_PERCENTILE
             --,CAST(WINTER_2008_FALLTOSPRING_GOAL AS INT) AS WINTER_2008_FALLTOSPRING_GOAL
             --,CAST(FALL_2008_RIT AS INT)                 AS FALL_2008_RIT
             --,CAST(FALL_2008_PERCENTILE AS INT)          AS FALL_2008_PERCENTILE
             --,CAST(FALL_2008_FALLTOSPRING_GOAL AS INT)   AS FALL_2008_FALLTOSPRING_GOAL
       FROM MAP$math_wide
       ')

/*
SELECT *
FROM 
     (SELECT studentid
            ,termname
            ,testritscore
            ,testpercentile
            ,CASE
              WHEN fallwinterspring = 'Fall' THEN typicalfalltospringgrowth 
              ELSE NULL
             END as falltospring_goal
      FROM map$comprehensive_identifiers
      WHERE measurementscale = 'Mathematics'
        AND rn=1
     )
     
S PIVOT(
  MAX(testritscore) AS rit
 ,MAX(testpercentile) AS percentile
 ,MAX(falltospring_goal) AS falltospring_goal
  FOR termname IN ('Fall 2013'   Fall_2013
                  ,'Spring 2013' Spring_2013
                  ,'Winter 2012' Winter_2012
                  ,'Fall 2012'   Fall_2012
                  ,'Spring 2012' Spring_2012
                  ,'Winter 2011' Winter_2011
                  ,'Fall 2011'   Fall_2011
                  ,'Spring 2011' Spring_2011
                  ,'Winter 2010' Winter_2010
                  ,'Fall 2010'   Fall_2010
                  ,'Spring 2010' Spring_2010
                  ,'Winter 2009' Winter_2009
                  ,'Fall 2009'   Fall_2009
                  ,'Spring 2009' Spring_2009
                  ,'Winter 2008' Winter_2008
                  ,'Fall 2008'   Fall_2008
                  )
       )
*/