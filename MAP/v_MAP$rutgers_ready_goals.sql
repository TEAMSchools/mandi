USE KIPP_NJ
GO

CREATE VIEW MAP$rutgers_ready_student_goals AS

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

--JUST SCIENCE AND LANGUAGE FIRST
SELECT sub.*
      ,sub.baseline_rit + sub.rutgers_ready_goal AS rutgers_ready_rit
FROM
      (SELECT stu_roster.*
             ,map_base.measurementscale AS subject
             ,map_base.testritscore AS baseline_rit
             ,map_base.testpercentile AS baseline_percentile
             ,map_base.termname AS derived_from
             ,CAST(ROUND(map_base.typical_growth_fallorspring_to_spring,0) AS INT) AS keep_up_goal
             ,CASE 
                --bottom quartile
                WHEN CAST(map_base.testpercentile AS INT) > 0   AND CAST(map_base.testpercentile AS INT) < 25 
                  THEN ROUND(CAST(map_base.typical_growth_fallorspring_to_spring AS FLOAT) * 2.0, 0)
                --2nd quartile
                WHEN CAST(map_base.testpercentile AS INT) >= 25 AND CAST(map_base.testpercentile AS INT) < 50 
                  THEN ROUND(CAST(map_base.typical_growth_fallorspring_to_spring AS FLOAT) * 1.75, 0)
                --3rd quartile
                WHEN CAST(map_base.testpercentile AS INT) >= 50 AND CAST(map_base.testpercentile AS INT) < 75 
                  THEN ROUND(CAST(map_base.typical_growth_fallorspring_to_spring AS FLOAT) * 1.5, 0)
                --top quartile
                WHEN CAST(map_base.testpercentile AS INT) >= 75 AND CAST(map_base.testpercentile AS INT) < 100
                  THEN ROUND(CAST(map_base.typical_growth_fallorspring_to_spring AS FLOAT) * 1.25, 0)
              END AS rutgers_ready_goal
             ,CAST(map_base.testritscore AS FLOAT) + CAST(map_base.typical_growth_fallorspring_to_spring AS FLOAT) AS keep_up_rit

       FROM stu_roster
       LEFT OUTER JOIN KIPP_NJ..MAP$baseline_composite map_base
         ON stu_roster.studentid = map_base.studentid 
        AND stu_roster.year = map_base.year
        AND map_base.measurementscale IN ('General Science', 'Language', 'Language Usage')
       --just for testing
       WHERE map_base.testritscore IS NOT NULL


       /*
       --BRING IN RR GOALS HERE
       UNION ALL

       SELECT stu_roster.*
             ,rr_goals.measurementscale AS subject
              --go get this score
             ,map_base.testritscore AS baseline_rit
             ,map_base.testpercentile AS baseline_percentile
             ,map_base.termname AS derived_from
             ,map_base.typical_growth_fallorspring_to_spring AS keep_up_goal
             --,ROUND(rr_goals.RIT_target, 0) - CAST(map_base.testritscore AS FLOAT) AS rutgers_ready_goal
             ,CAST(rr_goals.RIT_target AS FLOAT) - CAST(map_base.testritscore AS FLOAT) AS rutgers_ready_goal
             ,NULL AS keep_up_rit
             ,NULL AS rutgers_ready_rit
       FROM stu_roster
       LEFT OUTER JOIN KIPP_NJ..MAP$baseline_composite map_base
         ON stu_roster.studentid = map_base.studentid 
        AND stu_roster.year = map_base.year
        AND map_base.measurementscale IN ('Reading', 'Mathematics')
       LEFT OUTER JOIN KIPP_NJ..MAP$rutgers_ready_goals rr_goals
         ON stu_roster.studentid = rr_goals.studentid 
        AND stu_roster.year = rr_goals.academic_year
        AND rr_goals.measurementscale = map_base.MeasurementScale
        AND rr_goals.measurementscale IN ('General Science', 'Language', 'Language Usage')
       */
       ) sub