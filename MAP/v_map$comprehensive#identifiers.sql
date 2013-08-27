USE KIPP_NJ
GO

CREATE VIEW MAP$comprehensive#identifiers AS
SELECT cohort.schoolid
      ,cohort.grade_level
      ,cohort.cohort
      ,cohort.year_in_network AS stu_year_in_network
      ,cohort.abbreviation AS year_abbreviation
      ,norms_2008.percentile AS percentile_2008_norms
      ,norms_2011.percentile AS percentile_2011_norms
      ,sq_2.*
      /*
      ,CASE
         --MATH ACT model
         WHEN sq_2.measurementscale = 'Mathematics'
           THEN round(-28.193 --intercept
             + (0.307 * CAST(sq_2.testritscore AS FLOAT)) 
             + ( (-4.256 * cohort.grade_level) + (0.183 * (cohort.grade_level * cohort.grade_level))  ) 
             + CASE
                 WHEN sq_2.fallwinterspring = 'Fall' THEN 0
                 
                 WHEN sq_2.fallwinterspring = 'Winter' THEN -1.173  --half of Spring
                 WHEN sq_2.fallwinterspring = 'Spring' THEN -2.346 
                 ELSE NULL
               END
                  ,0)
         --READING ACT model
         WHEN sq_2.measurementscale = 'Reading'
           THEN round(-52.748 --intercept
             + (0.417 * sq_2.testritscore)
             + ( (-3.433 * cohort.grade_level) + (0.132 * (cohort.grade_level * cohort.grade_level))  )
             + CASE
                 WHEN sq_2.fallwinterspring = 'Fall' THEN 0
                 WHEN sq_2.fallwinterspring = 'Winter' THEN -0.829  --half of Spring
                 WHEN sq_2.fallwinterspring = 'Spring' THEN -1.655
                 ELSE NULL
               END
                  ,0)
         ELSE NULL
       END AS proj_ACT_subj_score
      */
      FROM
            (SELECT CASE
                      WHEN teststartdate >= '01-AUG-14' AND teststartdate <= '01-JUL-15'
                        THEN 2014
                      WHEN teststartdate >= '01-AUG-13' AND teststartdate <= '01-JUL-14'
                        THEN 2013
                      WHEN teststartdate >= '01-AUG-12' AND teststartdate <= '01-JUL-13'
                        THEN 2012
                      WHEN teststartdate >= '01-AUG-11' AND teststartdate <= '01-JUL-12'
                        THEN 2011
                      WHEN teststartdate >= '01-AUG-10' AND teststartdate <= '01-JUL-11'
                        THEN 2010
                      WHEN teststartdate >= '01-AUG-09' AND teststartdate <= '01-JUL-10'
                        THEN 2009
                      WHEN teststartdate >= '01-AUG-08' AND teststartdate <= '01-JUL-09'
                        THEN 2008
                    END map_year_academic
                   ,CASE
                      WHEN fallwinterspring = 'Fall'   THEN 1 
                      WHEN fallwinterspring = 'Winter' THEN 2
                      WHEN fallwinterspring = 'Spring' THEN 3
                      ELSE NULL
                    END fallwinterspring_numeric
                   ,sq_1.*
                   ,ROW_NUMBER() OVER 
                      (PARTITION BY studentid, termname, measurementscale
                       ORDER BY map_year DESC
                                   -- replace with CASE
                                 ,CASE
                                    WHEN fallwinterspring = 'Fall'   THEN 1 
                                    WHEN fallwinterspring = 'Winter' THEN 2
                                    WHEN fallwinterspring = 'Spring' THEN 3
                                    ELSE NULL
                                  END ASC
                                 ,growthmeasureyn DESC
                                 ,teststandarderror ASC) AS rn
             FROM
                   (SELECT sq_0.ps_studentid
                          ,sq_0.lastfirst
                          ,SUBSTRING(termname, 1, CHARINDEX(' ', termname)) AS fallwinterspring 
                          ,CASE
                             WHEN SUBSTRING(termname, 1, CHARINDEX(' ', termname)) = 'Fall'
                               THEN SUBSTRING(SUBSTRING(termname, CHARINDEX(' ', termname)+1, 100), 1, 4)
                             WHEN SUBSTRING(termname, 1, CHARINDEX(' ', termname)) IN ('Winter', 'Spring')
                               THEN SUBSTRING(SUBSTRING(termname, CHARINDEX(' ', termname)+1, 100), 6, 4)
                           END AS map_year
                          ,map.* 
                    FROM
                         (SELECT s.id AS ps_studentid
                                ,s.student_number
                                ,s.lastfirst
                          FROM KIPP_NJ..STUDENTS s
                          ) sq_0
                    JOIN NWEA..map$cdf map 
                      ON CAST(sq_0.student_number AS NVARCHAR) = map.studentid
                    ) sq_1
              ) sq_2
      LEFT OUTER JOIN COHORT$comprehensive_long cohort 
        ON  CAST(cohort.studentid AS NVARCHAR) = sq_2.ps_studentid 
        AND sq_2.map_year_academic = cohort.year
        AND cohort.rn = 1
      LEFT OUTER JOIN MAP$norm_table#2008 norms_2008 
        ON  cohort.grade_level = norms_2008.grade 
        AND sq_2.measurementscale = norms_2008.measurementscale 
        AND sq_2.testritscore = norms_2008.rit 
        AND sq_2.fallwinterspring = norms_2008.fallwinterspring
      LEFT OUTER JOIN MAP$norm_table#2011 norms_2011 
        ON  cohort.grade_level = norms_2011.grade 
        AND sq_2.measurementscale = norms_2011.measurementscale 
        AND sq_2.testritscore = norms_2011.rit 
        AND sq_2.fallwinterspring = norms_2011.fallwinterspring