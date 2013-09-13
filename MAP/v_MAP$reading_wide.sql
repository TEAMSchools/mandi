/*
PURPOSE:
  Simple wide view of reading scores showing fall/spring RITs for all kids
  who have taken MAP reading tests at TEAM

MAINTENANCE:
  MAINTENANCE QUARTERLY:
    Add any new termnames to the pivot, if test events have occured that aren't
    present
  
MAJOR STRUCTURAL REVISIONS OR CHANGES:
  Major simplicification on 7/12/12 - the query was looking directly @ 
  map_comprehensive and was written to look at comprehensive_with_identifiers.
  This removed a lot of cruft devoted to breaking out terms, sorting by growth
  measure, etc.
 
  This will *definitely* need to get tweaked if we intend to start reporting
  college readiness/rutgers goals (and we do!)
  
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

SELECT *
FROM OPENQUERY(KIPP_NWK,'
     SELECT *
     FROM MAP$reading_wide
')

/*
CREATE OR REPLACE VIEW map$reading_wide AS
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
      WHERE measurementscale = 'Reading'
        AND rn=1)
S PIVOT (max(testritscore)   as rit
        ,max(testpercentile) as percentile
        ,max(falltospring_goal) as falltospring_goal
         for termname in ('Fall 2013'   Fall_2013
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