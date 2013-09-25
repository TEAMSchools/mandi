USE KIPP_NJ
GO

ALTER VIEW MAP$rutgers_ready_student_goals AS

WITH stu_roster AS
    (SELECT c.studentid
           ,c.schoolid
           ,c.grade_level
           ,c.year
     FROM KIPP_NJ..COHORT$comprehensive_long#static c
     WHERE c.year = 2013
       AND c.schoolid != 999999
       AND c.rn = 1
    )
   
   ,math_read AS
   (SELECT 'Mathematics' AS measurementscale
           ,NULL AS alt_measurementscale
    UNION
    SELECT 'Reading'
           ,NULL AS alt_measurementscale
   )

   ,sci_lang AS
   (SELECT 'Science - General Science' AS measurementscale
          ,'General Science' AS alt_measurementscale
    UNION
    SELECT 'Language'
          ,'Language Usage' AS alt_measurementscale
   )

--MATH AND READING FIRST
SELECT stu_roster.*
      ,math_read.measurementscale
      ,map_base.testritscore AS baseline_rit
      ,map_base.testpercentile AS baseline_percentile
      ,map_base.termname AS derived_from

      ,CAST(ROUND(map_base.typical_growth_fallorspring_to_spring,0) AS INT) AS keep_up_goal
      ,CAST(map_base.testritscore AS FLOAT) + CAST(map_base.typical_growth_fallorspring_to_spring AS FLOAT) AS keep_up_rit

      ,ROUND(rr_goals.RIT_target, 0) - CAST(map_base.testritscore AS FLOAT) AS rutgers_ready_goal
      ,map_base.testritscore + CAST(ROUND(CAST(rr_goals.RIT_target AS FLOAT) - CAST(map_base.testritscore AS FLOAT),0) AS FLOAT) AS rutgers_ready_rit
FROM stu_roster
JOIN math_read
  ON 1=1
 AND stu_roster.grade_level <= 11
 AND stu_roster.grade_level >= 5

--baseline (composite of Spring and Fall; pick best)
LEFT OUTER JOIN KIPP_NJ..MAP$baseline_composite map_base
  ON stu_roster.studentid = map_base.studentid 
 AND stu_roster.year = map_base.year
 AND math_read.measurementscale = map_base.measurementscale

--RR goals (generated by R script)
LEFT OUTER JOIN KIPP_NJ..MAP$rutgers_ready_goals rr_goals
  ON stu_roster.studentid = rr_goals.studentid 
 AND stu_roster.year = rr_goals.academic_year
 AND rr_goals.measurementscale = map_base.MeasurementScale

UNION ALL

--SCIENCE AND LANGUAGE NEXT
SELECT sub.*
      ,sub.baseline_rit + sub.rutgers_ready_goal AS rutgers_ready_rit
FROM
      (SELECT stu_roster.*
             ,sci_lang.measurementscale
             ,map_base.testritscore AS baseline_rit
             ,map_base.testpercentile AS baseline_percentile
             ,map_base.termname AS derived_from
             
             ,norm.r22 AS keep_up_goal
             ,map_base.testritscore + norm.r22 AS keep_up_rit

             ,CASE 
                --bottom quartile
                WHEN CAST(map_base.testpercentile AS INT) > 0   AND CAST(map_base.testpercentile AS INT) < 25 
                  THEN ROUND(CAST(norm.r22 AS FLOAT) * 2.0, 0)
                --2nd quartile
                WHEN CAST(map_base.testpercentile AS INT) >= 25 AND CAST(map_base.testpercentile AS INT) < 50 
                  THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.75, 0)
                --3rd quartile
                WHEN CAST(map_base.testpercentile AS INT) >= 50 AND CAST(map_base.testpercentile AS INT) < 75 
                  THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.5, 0)
                --top quartile
                WHEN CAST(map_base.testpercentile AS INT) >= 75 AND CAST(map_base.testpercentile AS INT) < 100
                  THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.25, 0)
              END AS rutgers_ready_goal

             
       FROM stu_roster
       JOIN sci_lang
         ON 1=1
        --AND stu_roster.grade_level <= 8
        --AND stu_roster.grade_level >= 5

       --baseline (composite of Spring and Fall; pick best)
       LEFT OUTER JOIN KIPP_NJ..MAP$baseline_composite map_base
         ON stu_roster.studentid = map_base.studentid 
        AND stu_roster.year = map_base.year
        AND sci_lang.measurementscale = map_base.measurementscale

       LEFT OUTER JOIN KIPP_NJ..MAP$growth_norms_data#2011 norm
         ON sci_lang.alt_measurementscale = norm.subject
        AND map_base.testritscore = norm.startrit
        AND stu_roster.grade_level - 1 = norm.startgrade
       ) sub

UNION ALL

--MATH AND READING FOR ES
SELECT sub.*
      ,sub.baseline_rit + sub.rutgers_ready_goal AS rutgers_ready_rit
FROM
      (SELECT stu_roster.*
             ,math_read.measurementscale
             ,map_base.testritscore AS baseline_rit
             ,map_base.testpercentile AS baseline_percentile
             ,map_base.termname AS derived_from
             
             ,norm.r22 AS keep_up_goal
             ,map_base.testritscore + norm.r22 AS keep_up_rit

             ,CASE 
                --bottom quartile
                WHEN CAST(map_base.testpercentile AS INT) > 0   AND CAST(map_base.testpercentile AS INT) < 25 
                  THEN ROUND(CAST(norm.r22 AS FLOAT) * 2.0, 0)
                --2nd quartile
                WHEN CAST(map_base.testpercentile AS INT) >= 25 AND CAST(map_base.testpercentile AS INT) < 50 
                  THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.75, 0)
                --3rd quartile
                WHEN CAST(map_base.testpercentile AS INT) >= 50 AND CAST(map_base.testpercentile AS INT) < 75 
                  THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.5, 0)
                --top quartile
                WHEN CAST(map_base.testpercentile AS INT) >= 75 AND CAST(map_base.testpercentile AS INT) < 100
                  THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.25, 0)
              END AS rutgers_ready_goal
    
       FROM stu_roster
       JOIN math_read
         ON 1=1
        AND stu_roster.grade_level <= 4

       --baseline (composite of Spring and Fall; pick best)
       LEFT OUTER JOIN KIPP_NJ..MAP$baseline_composite map_base
         ON stu_roster.studentid = map_base.studentid 
        AND stu_roster.year = map_base.year
        AND math_read.measurementscale = map_base.measurementscale

       LEFT OUTER JOIN KIPP_NJ..MAP$growth_norms_data#2011 norm
         ON math_read.alt_measurementscale = norm.subject
        AND map_base.testritscore = norm.startrit
        AND stu_roster.grade_level - 1 = norm.startgrade
       ) sub
