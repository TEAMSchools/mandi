USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$TA_standards_mastery AS

-- only IA and FSA tests
WITH valid_TAs AS (
  SELECT assessment_id
        ,academic_year
        ,schoolid
        ,title
        ,grade_level
        ,scope
        ,subject        
        ,standard_id
        ,standards_tested
        ,administered_at
        ,term
  FROM ILLUMINATE$assessments#static a WITH(NOLOCK)
  WHERE schoolid IN (73254,73255,73256,73257,179901)    
    AND term IS NOT NULL
    AND scope = 'Interim Assessment'
    AND subject NOT IN ('Writing') -- summary assessment
 )

,valid_FSAs AS (
  SELECT assessment_id
        ,academic_year
        ,schoolid
        ,title
        ,grade_level
        ,scope
        ,subject        
        ,standard_id
        ,standards_tested
        ,administered_at
        ,term
  FROM ILLUMINATE$assessments#static a WITH(NOLOCK)
  WHERE schoolid IN (73254,73255,73256,73257,179901)    
    AND term IS NOT NULL
    AND scope = 'FSA'
 )

,valid_assessments AS (
  SELECT assessment_id
        ,academic_year
        ,schoolid
        ,title
        ,grade_level
        ,scope
        ,subject
        ,standard_id
        ,standards_tested
        ,administered_at
        ,term
  FROM valid_TAs WITH(NOLOCK)
  
  UNION ALL
  
  SELECT fsa.assessment_id
        ,fsa.academic_year
        ,fsa.schoolid
        ,fsa.title
        ,fsa.grade_level
        ,fsa.scope
        ,fsa.subject
        ,fsa.standard_id
        ,fsa.standards_tested
        ,fsa.administered_at
        ,fsa.term
  FROM valid_FSAs fsa WITH(NOLOCK)
  JOIN valid_TAs ta WITH(NOLOCK)
    ON fsa.academic_year = ta.academic_year
   AND fsa.schoolid = ta.schoolid
   AND fsa.grade_level = ta.grade_level
   AND fsa.standard_id = ta.standard_id
 ) 

-- the above combined, only those that students have been tested on
,scores_long AS (
  SELECT student_number        
        ,schoolid
        ,academic_year
        ,grade_level
        ,SPEDLEP
        ,assessment_id
        ,title
        ,administered_at
        ,term
        ,scope
        ,subject
        ,standard_id
        ,standards_tested            
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
             ,a.title             
             ,a.administered_at
             ,CASE 
               WHEN a.term LIKE '%Summer%' THEN 'T1'
               WHEN a.term IN ('EOY','Capstone') THEN 'T3'
               ELSE a.term
              END AS term
             ,a.scope
             ,a.subject
             ,a.standard_id
             ,a.standards_tested            
             ,CONVERT(FLOAT,percent_correct) AS pct_correct
             ,CASE WHEN res.local_student_id IS NOT NULL THEN 1 ELSE 0 END AS has_tested
       FROM COHORT$identifiers_long#static r WITH(NOLOCK)
       JOIN valid_assessments a WITH(NOLOCK)
         ON r.schoolid = a.schoolid        
        AND r.grade_level = a.grade_level
        AND r.year = a.academic_year
       JOIN ILLUMINATE$assessment_results_by_standard#static res WITH(NOLOCK)
         ON r.student_number = res.local_student_id
        AND a.assessment_id = res.assessment_id
        AND a.standard_id = res.standard_id
       WHERE r.grade_level < 5         
         AND r.enroll_status = 0         
         AND r.rn = 1
      ) sub
  WHERE has_tested = 1
 )

SELECT sub.student_number      
      ,sub.schoolid     
      ,sub.grade_level 
      ,sub.academic_year
      ,sub.term
      ,sub.subject
      ,CASE
        WHEN sub.subject = 'Comprehension' THEN 'COMP'
        WHEN sub.subject = 'Mathematics' THEN 'MATH'
        WHEN sub.subject = 'Performing Arts' THEN 'PERF'
        WHEN sub.subject = 'Humanities' THEN 'HUM'
        WHEN sub.subject = 'Phonics' THEN 'PHON'
        WHEN sub.subject = 'Science' THEN 'SCI'
        WHEN sub.subject = 'Spanish' THEN 'SPAN'
        WHEN sub.subject = 'Visual Arts' THEN 'VIZ'        
        ELSE NULL
       END AS TA_subject
      ,sub.standards_tested AS TA_standard
      ,sub.total_weighted_pct_correct
      ,obj.objective AS TA_obj
      ,CONVERT(VARCHAR(250),
        CASE 
         WHEN sub.SPEDLEP = 'SPED' AND sub.total_weighted_pct_correct >= 60 THEN 3
         WHEN sub.SPEDLEP = 'SPED' AND sub.total_weighted_pct_correct >= 30 AND sub.total_weighted_pct_correct < 60 THEN 2
         WHEN sub.SPEDLEP = 'SPED' AND sub.total_weighted_pct_correct < 30 THEN 1
         WHEN sub.total_weighted_pct_correct >= 80 THEN 3
         WHEN sub.total_weighted_pct_correct >= 60 AND sub.total_weighted_pct_correct < 80 THEN 2
         WHEN sub.total_weighted_pct_correct < 60 THEN 1
        END) AS TA_score
      ,CONVERT(VARCHAR(250),
        CASE
         WHEN sub.SPEDLEP = 'SPED' AND sub.total_weighted_pct_correct >= 60 THEN 'Meets Standard' 
         WHEN sub.SPEDLEP = 'SPED' AND sub.total_weighted_pct_correct >= 30 AND sub.total_weighted_pct_correct < 60 THEN 'Approaching Standard'
         WHEN sub.SPEDLEP = 'SPED' AND sub.total_weighted_pct_correct < 30 THEN 'Far Below Standard'
         WHEN sub.total_weighted_pct_correct >= 80 THEN 'Meets Standard'
         WHEN sub.total_weighted_pct_correct >= 60 AND sub.total_weighted_pct_correct < 80 THEN 'Approaching Standard'
         WHEN sub.total_weighted_pct_correct < 60 THEN 'Far Below Standard'
        END) AS TA_prof                            
      ,CASE
        WHEN sub.SPEDLEP = 'SPED' AND sub.total_weighted_pct_correct >= 60 THEN 1
        WHEN sub.SPEDLEP = 'SPED' AND sub.total_weighted_pct_correct < 60 THEN 0
        WHEN sub.total_weighted_pct_correct >= 80 THEN 1
        WHEN sub.total_weighted_pct_correct < 80 THEN 0
       END AS is_mastery
      ,CONVERT(FLOAT,SUM(CASE
                          WHEN sub.SPEDLEP = 'SPED' AND sub.total_weighted_pct_correct >= 60 THEN 1
                          WHEN sub.SPEDLEP = 'SPED' AND sub.total_weighted_pct_correct < 60 THEN 0
                          WHEN sub.total_weighted_pct_correct >= 80 THEN 1
                          WHEN sub.total_weighted_pct_correct < 80 THEN 0
                         END) OVER(PARTITION BY sub.student_number, sub.term, sub.subject)) AS n_mastered
      ,CONVERT(FLOAT,COUNT(sub.standards_tested) OVER(PARTITION BY sub.student_number, sub.term, sub.subject)) AS n_total
FROM
    (
     SELECT student_number
           ,schoolid
           ,academic_year
           ,grade_level
           ,SPEDLEP
           ,term
           ,subject
           ,standards_tested      
           ,SUM(weighted_pct_points) AS total_weighted_points
           ,SUM(weighted_points_poss) AS total_weighted_points_poss
           ,ROUND(SUM(weighted_pct_points) / SUM(weighted_points_poss) * 100,0) AS total_weighted_pct_correct
     FROM 
         (
          SELECT student_number
                ,schoolid                
                ,academic_year
                ,grade_level
                ,SPEDLEP
                ,term        
                ,subject
                ,standards_tested
                ,rn_cur
                -- weighted points earned
                ,CASE
                  -- Gr 1+ math/comp, IA, weighted 60%
                  WHEN grade_level >= 1          
                   AND scope = 'Interim Assessment' 
                   AND subject IN ('Mathematics','Comprehension')          
                    THEN (pct_correct * 0.6)
                  -- Gr 1+ math/comp, FSA, weighted 20%
                  WHEN grade_level >= 1 
                   AND scope = 'FSA' 
                   AND subject IN ('Mathematics','Comprehension')          
                   AND rn_cur <= 2
                    THEN (pct_correct * 0.2)
                  -- K-1 phonics, all tests, no weighting
                  WHEN grade_level IN (0,1) 
                   AND subject = 'Phonics' 
                    THEN pct_correct
                  -- K math, no FSAs, no weighting
                  WHEN grade_level = 0 
                   AND scope = 'Interim Assessment'
                   AND subject = 'Mathematics'
                    THEN pct_correct
                  -- K comp, all tests, no weighting
                  WHEN grade_level = 0          
                   AND subject = 'Comprehension'
                    THEN pct_correct        
                  -- All grades specials, all tests, no weighting
                  WHEN subject NOT IN ('Writing','Comprehension','Mathematics','Phonics')
                   THEN pct_correct
                  ELSE NULL
                 END AS weighted_pct_points
                -- weighted points possible (depending on IA/FSA)
                ,CASE
                  -- Gr 1+ math/comp, IA, weighted 60%
                  WHEN grade_level >= 1          
                   AND scope = 'Interim Assessment' 
                   AND subject IN ('Mathematics','Comprehension')          
                    THEN 60
                  -- Gr 1+ math/comp, FSA, weighted 20%
                  WHEN grade_level >= 1 
                   AND scope = 'FSA' 
                   AND subject IN ('Mathematics','Comprehension')          
                   AND rn_cur <= 2
                    THEN 20
                  -- K-1 phonics, all tests, no weighting
                  WHEN grade_level IN (0,1) 
                   AND subject = 'Phonics' 
                    THEN 100
                  -- K math, no FSAs, no weighting
                  WHEN grade_level = 0 
                   AND scope = 'Interim Assessment'
                   AND subject = 'Mathematics'
                    THEN 100
                  -- K comp, all tests, no weighting
                  WHEN grade_level = 0          
                   AND subject = 'Comprehension'
                    THEN 100        
                  -- All grades specials, all tests, no weighting
                  WHEN subject NOT IN ('Writing','Comprehension','Mathematics','Phonics')
                   THEN 100
                  ELSE NULL
                 END AS weighted_points_poss
          FROM scores_long WITH(NOLOCK)
         ) sub
     GROUP BY student_number
             ,schoolid
             ,academic_year
             ,grade_level
             ,SPEDLEP
             ,term
             ,subject
             ,standards_tested
    ) sub
LEFT OUTER JOIN GDOCS$TA_standards_clean obj WITH(NOLOCK)
  ON sub.schoolid = obj.schoolid
 AND sub.grade_level = obj.grade_level 
 AND sub.term = obj.term
 AND sub.standards_tested = obj.ccss_standard
 AND obj.dupe_audit = 1