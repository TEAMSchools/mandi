USE KIPP_NJ
GO

ALTER VIEW TABLEAU$PARCC_dashboard AS

WITH external_prof AS (
  SELECT academic_year        
        ,testcode
        ,grade_level
        ,[NJ]
        ,[NPS]
        ,[CPS]
        ,[PARCC]        
  FROM
      (
       SELECT academic_year
             ,testcode
             ,grade_level
             ,entity
             ,pct_proficient
       FROM KIPP_NJ..AUTOLOAD$GDOCS_PARCC_external_proficiency_rates WITH(NOLOCK)
       WHERE NOT (grade_level IS NOT NULL AND testcode IN ('ALG01','ALG02','GEO01'))
      ) sub
  PIVOT(
    MAX(pct_proficient)
    FOR entity IN ([NJ]
                  ,[NPS]
                  ,[PARCC]
                  ,[CPS])
   ) p
 ) 

SELECT co.student_number
      ,co.lastfirst
      ,co.year AS academic_year
      ,co.schoolid           
      ,co.grade_level            
      ,co.school_level     
      ,CASE WHEN co.schoolid LIKE '1799%' THEN 'Camden' ELSE 'Newark' END AS region      
      ,co.enroll_status
      
      ,'PARCC' AS test_type
      ,parcc.testcode
      ,parcc.subject      
      ,parcc.summativescalescore      
      ,parcc.summativeperformancelevel
      ,parcc.summativereadingscalescore            
      ,parcc.summativewritingscalescore                        

      ,parcc.pbatotaltestitems      
      ,parcc.pbatotaltestitemsattempted
      ,parcc.eoytotaltestitems                  
      ,parcc.eoytotaltestitemsattempted

      ,CASE WHEN co.enroll_status != 2 AND parcc.localstudentidentifier IS NULL THEN 1 ELSE 0 END AS is_optout
      ,CASE
        WHEN parcc.summativeperformancelevel >= 4 THEN 1
        WHEN parcc.summativeperformancelevel < 4 THEN 0
        ELSE NULL
       END AS is_prof

      ,ext.NJ AS pct_prof_NJ
      ,ext.NPS AS pct_prof_NPS
      ,ext.CPS AS pct_prof_CPS
      ,ext.PARCC AS pct_prof_PARCC

      /* potentially useful */
      --,parcc.pbaunit1totalnumberofitems
      --,parcc.pbaunit1numberofattempteditems
      --,parcc.pbaunit2totalnumberofitems
      --,parcc.pbaunit2numberofattempteditems
      --,parcc.pbaunit3totalnumberofitems
      --,parcc.pbaunit3numberofattempteditems
      --,parcc.eoyunit1totalnumberofitems
      --,parcc.eoyunit1numberofattempteditems
      --,parcc.eoyunit2totalnumberofitems
      --,parcc.eoyunit2numberofattempteditems
      --,parcc.eoyunit3totalnumberofitems
      --,parcc.eoyunit3numberofattempteditems            
      --,parcc.subclaim1category
      --,parcc.subclaim2category
      --,parcc.subclaim3category
      --,parcc.subclaim4category
      --,parcc.subclaim5category
      --,parcc.eoynottestedreason      
      --,parcc.pbanottestedreason            
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..AUTOLOAD$GDOCS_PARCC_district_summative_record_file parcc WITH(NOLOCK)
  ON parcc.statestudentidentifier = co.SID  
 AND LEFT(parcc.assessmentYear, 4) = co.year 
 AND parcc.recordtype = 1 
 AND parcc.reportedsummativescoreflag = 'Y'
 AND parcc.multiplerecordflag IS NULL
 AND parcc.reportsuppressioncode IS NULL
LEFT OUTER JOIN external_prof ext WITH(NOLOCK)
  ON co.year = ext.academic_year
 AND parcc.testcode = ext.testcode 
WHERE co.year >= 2014  
  AND co.rn = 1

UNION ALL

/* TEMP FIX UNTIL OFFICIAL SCORES */
SELECT co.student_number
      ,co.lastfirst
      ,co.year AS academic_year
      ,co.schoolid           
      ,co.grade_level            
      ,co.school_level     
      ,CASE WHEN co.schoolid LIKE '1799%' THEN 'Camden' ELSE 'Newark' END AS region      
      ,co.enroll_status
      
      ,'PARCC' AS test_type
      ,CASE
        WHEN test_name = 'Algebra I' THEN 'ALG01'
        WHEN test_name = 'Algebra II' THEN 'ALG02'
        WHEN test_name = 'Geometry' THEN 'GEO01'
        WHEN test_name = 'Grade 10 ELA/Literacy' THEN 'ELA10'
        WHEN test_name = 'Grade 11 ELA/Literacy' THEN 'ELA11'
        WHEN test_name = 'Grade 3 ELA/Literacy' THEN 'ELA03'
        WHEN test_name = 'Grade 3 Mathematics' THEN 'MAT03'
        WHEN test_name = 'Grade 4 ELA/Literacy' THEN 'ELA04'
        WHEN test_name = 'Grade 4 Mathematics' THEN 'MAT04'
        WHEN test_name = 'Grade 5 ELA/Literacy' THEN 'ELA05'
        WHEN test_name = 'Grade 5 Mathematics' THEN 'MAT05'
        WHEN test_name = 'Grade 6 ELA/Literacy' THEN 'ELA06'
        WHEN test_name = 'Grade 6 Mathematics' THEN 'MAT06'
        WHEN test_name = 'Grade 7 ELA/Literacy' THEN 'ELA07'
        WHEN test_name = 'Grade 7 Mathematics' THEN 'MAT07'
        WHEN test_name = 'Grade 8 ELA/Literacy' THEN 'ELA08'
        WHEN test_name = 'Grade 8 Mathematics' THEN 'MAT08'
        WHEN test_name = 'Grade 9 ELA/Literacy' THEN 'ELA09'
       END AS testcode
      ,CASE 
        WHEN parcc.test_name LIKE '%ELA%' THEN 'ELA'
        ELSE 'Math'
       END AS subject      
      ,parcc.scale_score AS summativescalescore      
      ,CASE
        WHEN parcc.performance_level = 'Exceeded Expectations' THEN 5
        WHEN parcc.performance_level = 'Met Expectations' THEN 4
        WHEN parcc.performance_level = 'Approached Expectations' THEN 3
        WHEN parcc.performance_level = 'Partially Met Expectations' THEN 2
        WHEN parcc.performance_level = 'Did Not Yet Meet Expectations' THEN 1
       END AS summativeperformancelevel
      ,NULL AS summativereadingscalescore            
      ,NULL AS summativewritingscalescore                        

      ,NULL AS pbatotaltestitems      
      ,NULL AS pbatotaltestitemsattempted
      ,NULL AS eoytotaltestitems                  
      ,NULL AS eoytotaltestitemsattempted

      ,NULL AS is_optout
      ,CASE                
        WHEN parcc.performance_level IN ('Met Expectations','Exceeded Expectations') THEN 1.0 
        WHEN parcc.performance_level NOT IN ('Met Expectations','Exceeded Expectations') THEN 0.0 
       END AS is_prof

      ,ext.NJ AS pct_prof_NJ
      ,ext.NPS AS pct_prof_NPS
      ,ext.CPS AS pct_prof_CPS
      ,ext.PARCC AS pct_prof_PARCC
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..AUTOLOAD$GDOCS_PARCC_preliminary_data parcc WITH(NOLOCK)
  ON co.student_number = parcc.local_student_identifier
 AND co.year = parcc.academic_year 
LEFT OUTER JOIN external_prof ext WITH(NOLOCK)
  ON co.year = ext.academic_year
 AND CASE
      WHEN test_name = 'Algebra I' THEN 'ALG01'
      WHEN test_name = 'Algebra II' THEN 'ALG02'
      WHEN test_name = 'Geometry' THEN 'GEO01'
      WHEN test_name = 'Grade 10 ELA/Literacy' THEN 'ELA10'
      WHEN test_name = 'Grade 11 ELA/Literacy' THEN 'ELA11'
      WHEN test_name = 'Grade 3 ELA/Literacy' THEN 'ELA03'
      WHEN test_name = 'Grade 3 Mathematics' THEN 'MAT03'
      WHEN test_name = 'Grade 4 ELA/Literacy' THEN 'ELA04'
      WHEN test_name = 'Grade 4 Mathematics' THEN 'MAT04'
      WHEN test_name = 'Grade 5 ELA/Literacy' THEN 'ELA05'
      WHEN test_name = 'Grade 5 Mathematics' THEN 'MAT05'
      WHEN test_name = 'Grade 6 ELA/Literacy' THEN 'ELA06'
      WHEN test_name = 'Grade 6 Mathematics' THEN 'MAT06'
      WHEN test_name = 'Grade 7 ELA/Literacy' THEN 'ELA07'
      WHEN test_name = 'Grade 7 Mathematics' THEN 'MAT07'
      WHEN test_name = 'Grade 8 ELA/Literacy' THEN 'ELA08'
      WHEN test_name = 'Grade 8 Mathematics' THEN 'MAT08'
      WHEN test_name = 'Grade 9 ELA/Literacy' THEN 'ELA09'
     END = ext.testcode 
WHERE co.year = 2015
  AND co.rn = 1
/* TEMP FIX UNTIL OFFICIAL SCORES */

UNION ALL

SELECT co.student_number
      ,co.lastfirst
      ,co.year AS academic_year
      ,co.schoolid           
      ,co.grade_level            
      ,co.school_level     
      ,CASE WHEN co.schoolid LIKE '1799%' THEN 'Camden' ELSE 'Newark' END AS region      
      ,co.enroll_status
      
      ,CASE
        WHEN co.schoolid = 73253 THEN 'HSPA'
        ELSE 'NJASK' 
       END AS test_type
      ,CONCAT(nj.subject, ' ', co.grade_level)  AS testcode
      ,nj.subject      
      ,nj.scale_score AS summativescalescore      
      ,CASE
        WHEN nj.prof_level IN ('Below Proficient','Partially Proficient') THEN 1
        WHEN nj.prof_level = 'Proficient' THEN 4
        WHEN nj.prof_level = 'Advanced Proficient' THEN 5
       END AS summativeperformancelevel      
      ,NULL AS summativereadingscalescore            
      ,NULL AS summativewritingscalescore                        

      ,NULL AS pbatotaltestitems      
      ,NULL AS pbatotaltestitemsattempted
      ,NULL AS eoytotaltestitems                  
      ,NULL AS eoytotaltestitemsattempted

      ,NULL AS is_optout
      ,nj.is_prof

      ,ext.NJ AS pct_prof_NJ
      ,ext.NPS AS pct_prof_NPS
      ,ext.CPS AS pct_prof_CPS
      ,ext.PARCC AS pct_prof_PARCC
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..AUTOLOAD$GDOCS_STATE_njask_hspa_scores nj WITH(NOLOCK)
  ON co.student_number = nj.student_number
 AND co.year = nj.academic_year 
 AND nj.void_reason IS NULL
LEFT OUTER JOIN external_prof ext
  ON co.year = ext.academic_year
 AND co.grade_level = ext.grade_level
 AND nj.subject = ext.testcode
WHERE co.rn = 1