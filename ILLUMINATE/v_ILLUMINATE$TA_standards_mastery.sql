USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$TA_standards_mastery AS

-- only IA and FSA tests
WITH valid_TAs AS (
  SELECT assessment_id
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
    AND academic_year = dbo.fn_Global_Academic_Year()
    AND term IS NOT NULL
    AND scope = 'Interim Assessment'
    AND subject NOT IN ('Writing') -- summary assessment
 )

,valid_FSAs AS (
  SELECT assessment_id
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
    AND academic_year = dbo.fn_Global_Academic_Year()
    AND term IS NOT NULL
    AND scope = 'FSA'
    AND subject IN (SELECT subject FROM valid_TAs WITH(NOLOCK)) -- only TA subjects factor into mastery
    AND standard_id IN (SELECT standard_id FROM valid_TAs WITH(NOLOCK)) -- only TA standards factor into mastery
 )

,valid_assessments AS (
  SELECT *
  FROM valid_TAs WITH(NOLOCK)
  UNION ALL
  SELECT *
  FROM valid_FSAs WITH(NOLOCK)
 ) 

-- scores long
,standard_scores AS (
  SELECT local_student_id AS student_number
        ,assessment_id
        ,standard_id        
        ,CONVERT(FLOAT,percent_correct) AS pct_correct
  FROM ILLUMINATE$assessment_results_by_standard#static WITH(NOLOCK)
  WHERE standard_id IN (SELECT standard_id FROM valid_assessments WITH(NOLOCK))
 )

-- ES students
,roster AS (
  SELECT schoolid
        ,student_number        
        ,grade_level
        ,spedlep
  FROM COHORT$identifiers_long#static WITH(NOLOCK)
  WHERE year = dbo.fn_Global_Academic_Year()  
    AND grade_level < 5
    AND enroll_status = 0
    AND rn = 1
 )

-- the above combined, only those that students have been tested on
,scores_long AS (
  SELECT student_number        
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
       SELECT r.student_number             
             ,r.grade_level
             ,r.SPEDLEP
             ,a.assessment_id
             ,a.title
             ,a.administered_at
             ,a.term
             ,a.scope
             ,a.subject
             ,a.standard_id
             ,a.standards_tested            
             ,res.pct_correct
             ,CASE WHEN res.student_number IS NOT NULL THEN 1 ELSE 0 END AS has_tested
       FROM roster r WITH(NOLOCK)
       JOIN valid_assessments a WITH(NOLOCK)
         ON r.schoolid = a.schoolid
        AND r.grade_level = a.grade_level
       LEFT OUTER JOIN standard_scores res WITH(NOLOCK)
         ON r.student_number = res.student_number
        AND a.assessment_id = res.assessment_id
        AND a.standard_id = res.standard_id
      ) sub
  WHERE has_tested = 1
 )

SELECT sub.student_number      
      ,sub.term
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
             ,grade_level
             ,SPEDLEP
             ,term
             ,subject
             ,standards_tested
    ) sub
LEFT OUTER JOIN GDOCS$TA_standards_clean obj WITH(NOLOCK)
  ON sub.grade_level = obj.grade_level
 AND sub.term = obj.term
 AND sub.standards_tested = obj.ccss_standard
 AND obj.dupe_audit = 1