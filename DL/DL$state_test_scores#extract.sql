USE KIPP_NJ
GO

ALTER VIEW DL$state_test_scores#extract AS 

SELECT co.student_number
      ,'PARCC' AS test_type      
      ,CASE WHEN parcc.subject = 'English Language Arts/Literacy' THEN 'ELA' ELSE 'Math' END AS subject
      ,parcc.subject AS test_name
      ,parcc.summativescalescore AS scale_score
      ,CASE
        WHEN parcc.summativeperformancelevel = 5 THEN 'Exceeded Expectations'
        WHEN parcc.summativeperformancelevel = 4 THEN 'Met Expectations'
        WHEN parcc.summativeperformancelevel = 3 THEN 'Approached Expectations'
        WHEN parcc.summativeperformancelevel = 2 THEN 'Partially Met Expectations'
        WHEN parcc.summativeperformancelevel = 1 THEN 'Did Not Yet Meet Expectations'
       END AS proficiency_level
      ,CASE
        WHEN parcc.summativeperformancelevel >= 4 THEN 1
        WHEN parcc.summativeperformancelevel < 4 THEN 0
        ELSE NULL
       END AS is_proficient    
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..AUTOLOAD$GDOCS_PARCC_district_summative_record_file parcc WITH(NOLOCK)
  ON parcc.statestudentidentifier = co.SID  
 AND LEFT(parcc.assessmentYear, 4) = co.year 
 AND parcc.recordtype = 1 
 AND parcc.reportedsummativescoreflag = 'Y'
 AND parcc.multiplerecordflag IS NULL
 AND parcc.reportsuppressioncode IS NULL
WHERE co.year >= 2014  
  AND co.rn = 1

UNION ALL

SELECT co.student_number      
      ,CASE
        WHEN co.schoolid = 73253 THEN 'HSPA'
        ELSE 'NJASK' 
       END AS test_type      
      ,nj.subject
      ,nj.subject AS test_name
      ,nj.scale_score
      ,nj.prof_level AS proficiency_level
      ,nj.is_prof AS is_proficient
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..AUTOLOAD$GDOCS_STATE_njask_hspa_scores nj WITH(NOLOCK)
  ON co.student_number = nj.student_number
 AND co.year = nj.academic_year 
 AND nj.void_reason IS NULL
WHERE co.rn = 1