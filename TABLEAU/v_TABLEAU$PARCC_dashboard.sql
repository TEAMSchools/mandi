USE KIPP_NJ
GO

ALTER VIEW TABLEAU$PARCC_dashboard AS

WITH external_prof AS (
  SELECT academic_year        
        ,testcode
        ,grade_level
        ,[NJ]
        ,[NPS]
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
                  ,[PARCC])
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