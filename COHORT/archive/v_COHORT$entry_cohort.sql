USE KIPP_NJ
GO

/*
PURPOSE:
  Single purpose view that shows one row per student indicating their entry year
  into the network, as well as their entry cohort

MAINTENANCE:
  None

CREATED BY: AM2

ORIGIN DATE: Winter 2012

UPDATE: Fall 2014 moved to KIPP_NJ (LD6)
*/

ALTER VIEW COHORT$entry_cohort AS

SELECT studentid
      ,lastfirst
      ,MIN(grade_level) AS entering_grade_level
      ,MIN(cohort) AS entering_cohort
      ,MIN(YEAR) AS entering_year
      ,SUM(CASE
           WHEN grade_level != 99 THEN 1
           ELSE 0
           END) AS years_attended
FROM COHORT$comprehensive_long#static
GROUP BY studentid, lastfirst
