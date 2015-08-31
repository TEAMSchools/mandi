USE KIPP_NJ
GO

ALTER VIEW TABLEAU$assessment_mastery#ES AS

WITH valid_TAs AS (
  SELECT a.assessment_id
        ,a.academic_year
        ,a.schoolid
        ,a.title
        ,a.grade_level
        ,a.scope
        ,a.subject        
        ,a.standard_id
        ,a.standards_tested
        ,a.administered_at
        ,a.term        
  FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)  
  WHERE a.schoolid IN (73254,73255,73256,73257,179901)    
    AND a.term IS NOT NULL
    AND a.scope = 'Interim Assessment'
    AND a.subject NOT IN ('Writing') -- summary assessment
    AND a.standards_tested NOT IN ('CCSS.LA.2.L.2.4.a'
                                  ,'CCSS.LA.2.L.2.4.c'
                                  ,'CCSS.LA.2.L.2.4.d'
                                  ,'CCSS.LA.2.L.2.5.b'
                                  ,'CCSS.LA.3.L.3.5'
                                  ,'CCSS.LA.3.L.3.5.a'
                                  ,'CCSS.LA.3.L.3.6'
                                  ,'CCSS.LA.4.L.4.4'
                                  ,'CCSS.LA.4.L.4.4.a'
                                  ,'CCSS.LA.4.L.4.4.b'
                                  ,'CCSS.LA.4.L.4.5.a'
                                  ,'CCSS.LA.1.RF.1.3.g')
 )
 
-- the above combined, only those that students have been tested on
,scores_long AS (
  SELECT student_number        
        ,schoolid
        ,academic_year
        ,grade_level
        ,SPEDLEP        
        ,term        
        ,subject
        ,standard_id        
        ,pct_correct
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, scope, standard_id, term
             ORDER BY administered_at DESC) AS rn_cur
  FROM
      (
       SELECT r.year AS academic_year
             ,r.student_number             
             ,r.schoolid
             ,r.grade_level
             ,r.SPEDLEP
             ,a.assessment_id             
             ,a.administered_at
             ,CASE 
               WHEN a.term LIKE '%Summer%' THEN 'T1'
               WHEN a.term IN ('EOY','Capstone') THEN 'T3'
               ELSE a.term
              END AS term
             ,a.scope
             ,a.subject
             ,a.standard_id             
             ,CONVERT(FLOAT,percent_correct) AS pct_correct
             ,CASE WHEN res.local_student_id IS NOT NULL THEN 1 ELSE 0 END AS has_tested
       FROM KIPP_NJ..COHORT$identifiers_long#static r WITH(NOLOCK)       
       JOIN KIPP_NJ..ILLUMINATE$assessment_results_by_standard#static res WITH(NOLOCK)
         ON r.student_number = res.local_student_id        
       JOIN valid_TAs a WITH(NOLOCK)
         ON a.assessment_id = res.assessment_id
        AND a.standard_id = res.standard_id
        AND r.schoolid = a.schoolid        
        AND r.year = a.academic_year        
       WHERE r.grade_level < 5         
         AND r.enroll_status = 0         
         AND r.rn = 1
      ) sub
  WHERE has_tested = 1    
 )

,TA_raw AS (
  SELECT student_number      
        ,schoolid     
        ,grade_level 
        ,academic_year
        ,term
        ,subject
        ,CASE
          WHEN subject = 'Comprehension' THEN 'COMP'
          WHEN subject = 'Mathematics' THEN 'MATH'
          WHEN subject = 'Performing Arts' THEN 'PERF'
          WHEN subject = 'Humanities' THEN 'HUM'
          WHEN subject = 'Phonics' THEN 'PHON'
          WHEN subject = 'Science' THEN 'SCI'
          WHEN subject = 'Spanish' THEN 'SPAN'
          WHEN subject = 'Visual Arts' THEN 'VIZ'        
          ELSE NULL
         END AS TA_subject
        ,standard_id
        --,standards_tested AS TA_standard
        ,pct_correct                             
        ,CASE
          WHEN SPEDLEP = 'SPED' AND pct_correct >= 60 THEN 1
          WHEN SPEDLEP = 'SPED' AND pct_correct < 60 THEN 0
          WHEN pct_correct >= 80 THEN 1
          WHEN pct_correct < 80 THEN 0
         END AS is_mastery      
  FROM scores_long
 )

SELECT m.student_number
      ,co.school_name
      ,co.lastfirst
      ,co.grade_level
      ,co.TEAM
      ,co.SPEDLEP
      ,m.academic_year
      ,m.term
      ,m.TA_subject
      ,AVG(CONVERT(FLOAT,m.is_mastery)) * 100 AS weighted_pct_stds_mastered
      ,AVG(m.total_weighted_pct_correct) AS weighted_pct_correct
      ,CASE WHEN ROUND(AVG(CONVERT(FLOAT,m.is_mastery)) * 100,0) >= 80 THEN 1 ELSE 0 END AS is_8080_weighted
      ,AVG(CONVERT(FLOAT,ta.is_mastery)) * 100 AS raw_pct_stds_mastered
      ,AVG(ta.pct_correct) AS raw_pct_correct
      ,CASE WHEN ROUND(AVG(CONVERT(FLOAT,ta.is_mastery)) * 100,0) >= 80 THEN 1 ELSE 0 END AS is_8080_raw
FROM ILLUMINATE$TA_standards_mastery m WITH(NOLOCK)
JOIN TA_raw ta WITH(NOLOCK)
  ON m.student_number = ta.student_number
 AND m.academic_year = ta.academic_year
 AND m.term = ta.term 
 AND m.standard_id = ta.standard_id
JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
  ON m.student_number = co.student_number
 AND co.year = m.academic_year
 AND co.rn = 1
GROUP BY m.student_number
        ,co.school_name
        ,co.lastfirst
        ,co.grade_level
        ,co.TEAM
        ,co.SPEDLEP
        ,m.academic_year
        ,m.term
        ,m.TA_subject
