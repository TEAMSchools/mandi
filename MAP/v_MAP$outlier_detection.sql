USE KIPP_NJ
GO

ALTER VIEW MAP$outlier_detection AS

WITH min_tested AS (
  SELECT c.grade_level,
         c.measurementscale,
         AVG(CAST(c.testdurationminutes AS int)) AS avg_min,
         STDEV(CAST(c.testdurationminutes AS int)) AS stdev_min
  FROM KIPP_NJ..MAP$comprehensive#identifiers c WITH(NOLOCK)
  WHERE c.fallwinterspring = 'Spring'
  GROUP BY c.grade_level,
           c.measurementscale
 )

SELECT sub.studentid
      ,sub.lastfirst
      ,sub.school
      ,sub.grade_level
      ,sub.period_string
      ,sub.year
      ,sub.end_term_string
      ,sub.measurementscale
      ,sub.start_rit
      ,sub.end_rit
      ,sub.spr_min
      ,sub.cgi
      ,sub.diff_min_z
      ,cgi + diff_min_z AS total_z
FROM
    (
     SELECT c.studentid 
           ,s.lastfirst
           ,s.school_name AS school
           ,c.grade_level
           ,c.period_string
           ,c.year
           ,c.end_term_string
           ,c.measurementscale
           ,c.start_rit
           ,c.end_rit
           ,spring_id.testdurationminutes AS spr_min
           ,CAST(ROUND(c.cgi, 2) AS float) AS cgi
           ,CAST(ROUND((spring_id.testdurationminutes - min_tested.avg_min) / min_tested.stdev_min, 2) AS float) AS diff_min_z
     FROM KIPP_NJ..MAP$growth_measures_long#static c WITH(NOLOCK)
     JOIN KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)
       ON c.studentid = s.studentid
      AND c.year = s.year
      AND s.rn = 1
     LEFT OUTER JOIN min_tested WITH(NOLOCK)
       ON c.measurementscale = min_tested.measurementscale
      AND c.end_grade_verif = min_tested.grade_level
     JOIN KIPP_NJ..MAP$comprehensive#identifiers spring_id WITH(NOLOCK)
       ON c.studentid = spring_id.ps_studentid
      AND c.measurementscale = spring_id.measurementscale
      AND c.end_rit = spring_id.testritscore
      AND c.year = spring_id.map_year_academic
      AND spring_id.fallwinterspring = 'Spring'
     WHERE c.year = KIPP_NJ.dbo.fn_Global_Academic_Year() 
       AND c.valid_observation = 1
       AND ((c.period_string = 'Spring to Spring' AND c.year_in_network > 1) 
             OR (c.period_string = 'Fall to Spring' AND c.year_in_network = 1))
    ) sub