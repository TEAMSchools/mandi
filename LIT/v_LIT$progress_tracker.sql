USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[LIT$progress_tracker] AS

SELECT
 --STUDENT IDENTIFIERS
       s.schoolid
      ,s.grade_level
      ,scores.studentid
      ,scores.student_number
      ,scores.lastfirst
      ,s.FIRST_NAME + ' ' + s.LAST_NAME AS full_name       
      ,scores.academic_year
      ,scores.schoolid AS test_schoolid
      ,scores.grade_level AS test_grade_level      
      ,s.team
      ,cs.advisor
      ,cs.SPEDLEP
      ,NULL AS read_teacher      
            
--TEST IDENTIFIERS      
      ,scores.testid
      ,CASE WHEN LTRIM(RTRIM(scores.test_round)) IN ('Diagnostic','BOY') THEN 'DR' ELSE LTRIM(RTRIM(scores.test_round)) END AS test_round
      ,scores.test_date      
      ,scores.color
      ,scores.genre
      ,scores.status
      ,scores.read_lvl
      ,scores.GLEQ
      ,scores.lvl_num
      ,scores.instruct_lvl
      ,scores.indep_lvl
      ,scores.fp_wpmrate
      ,scores.fp_keylever
      
-- GROWTH MEASURES      
      ,growth.t1_growth_GLEQ AS DRT1_GLEQ
      ,growth.t1_growth_lvl AS DRT1_lvl
      ,growth.t1t2_growth_GLEQ AS T1T2_GLEQ
      ,growth.t1t2_growth_lvl AS T1T2_lvl
      ,growth.t2t3_growth_GLEQ AS T2T3_GLEQ
      ,growth.t2t3_growth_lvl AS T2T3_lvl
      ,growth.t3EOY_growth_GLEQ AS T3EOY_GLEQ
      ,growth.t3EOY_growth_lvl AS T3EOY_lvl
      ,growth.yr_growth_GLEQ AS YTD_GLEQ
      ,growth.yr_growth_lvl AS YTD_lvl
            
--MAP LEXILE
--scores from MAP reading test taken within a 16-week range of the FP/STEP test
      ,map.testritscore AS map_reading_rit
      ,map.testpercentile AS map_reading_pct
      ,map.rittoreadingscore AS lexile
      ,map.rittoreadingmax AS lexile_max
      ,map.rittoreadingmin AS lexile_min      
            
--REPORTING HASHES
      ,CASE
        WHEN status = 'Achieved' 
          THEN CONVERT(VARCHAR,scores.student_number) + '_'
                + CONVERT(VARCHAR,test_round) + '_' 
                + CONVERT(VARCHAR,status) + '_' 
                + CONVERT(VARCHAR, academic_year) + '_'
                + CONVERT(VARCHAR,achv_curr_round)
        WHEN status = 'Did Not Achieve' 
          THEN CONVERT(VARCHAR,scores.student_number) + '_'
                + CONVERT(VARCHAR,test_round) + '_' 
                + CONVERT(VARCHAR,status) + '_' 
                + CONVERT(VARCHAR, academic_year) + '_'
                + CONVERT(VARCHAR,dna_round)
        ELSE NULL
       END AS reporting_hash
      ,dna.dna_reason AS reasons_for_DNA       
FROM LIT$test_events#identifiers scores WITH(NOLOCK)      
LEFT OUTER JOIN LIT$dna_reasons dna WITH(NOLOCK)
  ON scores.unique_id = dna.unique_id
LEFT OUTER JOIN LIT$growth_measures_wide#static growth WITH(NOLOCK)
  ON scores.studentid = growth.STUDENTID
 AND scores.academic_year = growth.year
JOIN STUDENTS s WITH(NOLOCK)
  ON scores.studentid = s.id
 AND s.GRADE_LEVEL < 5
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH (NOLOCK)
  ON scores.studentid = cs.studentid
LEFT OUTER JOIN MAP$comprehensive#identifiers map WITH (NOLOCK)
  ON scores.studentid = map.ps_studentid 
 AND scores.academic_year = map.map_year_academic
 AND map.measurementscale = 'Reading'
 AND CASE 
      WHEN scores.test_round IN ('DR','T1') THEN 'Fall'
      WHEN scores.test_round = 'T2' THEN 'Winter'
      WHEN scores.test_round IN ('T3', 'EOY') THEN 'Spring'
     END = map.fallwinterspring
 AND map.rn = 1
WHERE scores.academic_year >= 2013