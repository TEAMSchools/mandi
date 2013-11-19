/*
PURPOSE:
  Simple wide view of reading scores showing fall/spring RITs for all kids who have taken MAP reading tests at TEAM

MAINTENANCE:
  MAINTENANCE QUARTERLY:
    Add any new termnames to the pivot, if test events have occured that aren't present
  
MAJOR STRUCTURAL REVISIONS OR CHANGES:
  - Major simplicification on 7/12/12 - the query was looking directly @ map_comprehensive and was written to look at comprehensive_with_identifiers.
     This removed a lot of cruft devoted to breaking out terms, sorting by growth measure, etc.
     This will *definitely* need to get tweaked if we intend to start reporting college readiness/rutgers goals (and we do!)
  - Ported to Server via OPENQUERY, Oracle source code included below -CB
  - Rebuilt in SQL Server -CB
  
CREATED BY:
  AM2

ORIGIN DATE:
  Fall 2011
  
LAST MODIFIED:
  Fall 2013 (CB)
*/

USE KIPP_NJ
GO

ALTER VIEW MAP$reading_wide AS
SELECT s.id AS studentid
      
      -- 13-14
      ,CONVERT(FLOAT,map_s14.testritscore) AS SPRING_2014_RIT
      ,CONVERT(FLOAT,map_s14.testpercentile) AS SPRING_2014_PERCENTILE
      ,CONVERT(FLOAT,map_w13.testritscore) AS WINTER_2013_RIT
      ,CONVERT(FLOAT,map_w13.testpercentile) AS WINTER_2013_PERCENTILE
      ,CONVERT(FLOAT,map_f13.testritscore) AS FALL_2013_RIT
      ,CONVERT(FLOAT,map_f13.testpercentile) AS FALL_2013_PERCENTILE
      ,CONVERT(FLOAT,map_f13.typicalfalltospringgrowth) AS FALL_2013_FALLTOSPRING_GOAL
      
      -- 12-13
      ,CONVERT(FLOAT,map_s13.testritscore) AS SPRING_2013_RIT
      ,CONVERT(FLOAT,map_s13.testpercentile) AS SPRING_2013_PERCENTILE
      ,CONVERT(FLOAT,map_w12.testritscore) AS WINTER_2012_RIT
      ,CONVERT(FLOAT,map_w12.testpercentile) AS WINTER_2012_PERCENTILE
      ,CONVERT(FLOAT,map_f12.testritscore) AS FALL_2012_RIT
      ,CONVERT(FLOAT,map_f12.testpercentile) AS FALL_2012_PERCENTILE
      ,CONVERT(FLOAT,map_f12.typicalfalltospringgrowth) AS FALL_2012_FALLTOSPRING_GOAL
      
      -- 11-12
      ,CONVERT(FLOAT,map_s12.testritscore) AS SPRING_2012_RIT
      ,CONVERT(FLOAT,map_s12.testpercentile) AS SPRING_2012_PERCENTILE
      ,CONVERT(FLOAT,map_w11.testritscore) AS WINTER_2011_RIT
      ,CONVERT(FLOAT,map_w11.testpercentile) AS WINTER_2011_PERCENTILE
      ,CONVERT(FLOAT,map_f11.testritscore) AS FALL_2011_RIT
      ,CONVERT(FLOAT,map_f11.testpercentile) AS FALL_2011_PERCENTILE
      ,CONVERT(FLOAT,map_f11.typicalfalltospringgrowth) AS FALL_2011_FALLTOSPRING_GOAL

      -- 10-11
      ,CONVERT(FLOAT,map_s11.testritscore) AS SPRING_2011_RIT
      ,CONVERT(FLOAT,map_s11.testpercentile) AS SPRING_2011_PERCENTILE
      ,CONVERT(FLOAT,map_w10.testritscore) AS WINTER_2010_RIT
      ,CONVERT(FLOAT,map_w10.testpercentile) AS WINTER_2010_PERCENTILE
      ,CONVERT(FLOAT,map_f10.testritscore) AS FALL_2010_RIT
      ,CONVERT(FLOAT,map_f10.testpercentile) AS FALL_2010_PERCENTILE
      ,CONVERT(FLOAT,map_f10.typicalfalltospringgrowth) AS FALL_2010_FALLTOSPRING_GOAL

      -- SPR '10
      ,CONVERT(FLOAT,map_s10.testritscore) AS SPRING_2010_RIT
      ,CONVERT(FLOAT,map_s10.testpercentile) AS SPRING_2010_PERCENTILE

FROM STUDENTS s WITH (NOLOCK)
LEFT OUTER JOIN MAP$comprehensive#identifiers map_s14 WITH (NOLOCK)
  ON s.student_number = map_s14.studentid
 AND map_s14.map_year_academic = 2013
 AND map_s14.fallwinterspring_numeric = 3
 AND map_s14.measurementscale = 'Reading'
 AND map_s14.rn=1
LEFT OUTER JOIN MAP$comprehensive#identifiers map_w13 WITH (NOLOCK)
  ON s.student_number = map_w13.studentid
 AND map_w13.map_year_academic = 2013
 AND map_w13.fallwinterspring_numeric = 2
 AND map_w13.measurementscale = 'Reading'
 AND map_w13.rn=1
LEFT OUTER JOIN MAP$comprehensive#identifiers map_f13 WITH (NOLOCK)
  ON s.student_number = map_f13.studentid
 AND map_f13.map_year_academic = 2013
 AND map_f13.fallwinterspring_numeric = 1
 AND map_f13.measurementscale = 'Reading'
 AND map_f13.rn=1
LEFT OUTER JOIN MAP$comprehensive#identifiers map_s13 WITH (NOLOCK)
  ON s.student_number = map_s13.studentid
 AND map_s13.map_year_academic = 2012
 AND map_s13.fallwinterspring_numeric = 3
 AND map_s13.measurementscale = 'Reading'
 AND map_s13.rn=1
LEFT OUTER JOIN MAP$comprehensive#identifiers map_w12 WITH (NOLOCK)
  ON s.student_number = map_w12.studentid
 AND map_w12.map_year_academic = 2012
 AND map_w12.fallwinterspring_numeric = 2
 AND map_w12.measurementscale = 'Reading'
 AND map_w12.rn=1
LEFT OUTER JOIN MAP$comprehensive#identifiers map_f12 WITH (NOLOCK)
  ON s.student_number = map_f12.studentid
 AND map_f12.map_year_academic = 2012
 AND map_f12.fallwinterspring_numeric = 1
 AND map_f12.measurementscale = 'Reading'
 AND map_f12.rn=1
LEFT OUTER JOIN MAP$comprehensive#identifiers map_s12 WITH (NOLOCK)
  ON s.student_number = map_s12.studentid
 AND map_s12.map_year_academic = 2011
 AND map_s12.fallwinterspring_numeric = 3
 AND map_s12.measurementscale = 'Reading'
 AND map_s12.rn=1
LEFT OUTER JOIN MAP$comprehensive#identifiers map_w11 WITH (NOLOCK)
  ON s.student_number = map_w11.studentid
 AND map_w11.map_year_academic = 2011
 AND map_w11.fallwinterspring_numeric = 2
 AND map_w11.measurementscale = 'Reading'
 AND map_w11.rn=1
LEFT OUTER JOIN MAP$comprehensive#identifiers map_f11 WITH (NOLOCK)
  ON s.student_number = map_f11.studentid
 AND map_f11.map_year_academic = 2011
 AND map_f11.fallwinterspring_numeric = 1
 AND map_f11.measurementscale = 'Reading'
 AND map_f11.rn=1
LEFT OUTER JOIN MAP$comprehensive#identifiers map_s11 WITH (NOLOCK)
  ON s.student_number = map_s11.studentid
 AND map_s11.map_year_academic = 2010
 AND map_s11.fallwinterspring_numeric = 3
 AND map_s11.measurementscale = 'Reading'
 AND map_s11.rn=1
LEFT OUTER JOIN MAP$comprehensive#identifiers map_w10 WITH (NOLOCK)
  ON s.student_number = map_w10.studentid
 AND map_w10.map_year_academic = 2010
 AND map_w10.fallwinterspring_numeric = 2
 AND map_w10.measurementscale = 'Reading'
 AND map_w10.rn=1
LEFT OUTER JOIN MAP$comprehensive#identifiers map_f10 WITH (NOLOCK)
  ON s.student_number = map_f10.studentid
 AND map_f10.map_year_academic = 2010
 AND map_f10.fallwinterspring_numeric = 1
 AND map_f10.measurementscale = 'Reading'
 AND map_f10.rn=1
LEFT OUTER JOIN MAP$comprehensive#identifiers map_s10 WITH (NOLOCK)
  ON s.student_number = map_s10.studentid
 AND map_s10.map_year_academic = 2009
 AND map_s10.fallwinterspring_numeric = 3
 AND map_s10.measurementscale = 'Reading'
 AND map_s10.rn=1
WHERE s.enroll_status = 0