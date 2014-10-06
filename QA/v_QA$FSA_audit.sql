USE KIPP_NJ
GO

ALTER VIEW QA$FSA_audit AS

WITH cur_week AS (
  SELECT DISTINCT time_per_name
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE start_date <= GETDATE()
    AND end_date >= GETDATE()
    AND identifier = 'REP'
    AND school_level = 'ES'
 )

,grades_tested AS (
  SELECT assessment_id
        ,dbo.GROUP_CONCAT(GRADE_LEVEL) AS grades_tested
  FROM
       (
        SELECT DISTINCT
               res.assessment_id
              ,CASE WHEN s.GRADE_LEVEL = 0 THEN 'K' ELSE CONVERT(VARCHAR,s.GRADE_LEVEL) END AS grade_level
        FROM STUDENTS s WITH(NOLOCK)
        JOIN ILLUMINATE$assessment_results_by_standard#static res WITH(NOLOCK)
          ON s.student_number = res.local_student_id
        WHERE s.ENROLL_STATUS = 0                  
       ) sub
  GROUP BY assessment_id
 )

,valid_assessments AS (
 SELECT a.fsa_week
       ,a.administered_at
       ,a.assessment_id
       ,REPLACE(CONVERT(VARCHAR,a.grade_level), 0, 'K') AS grade_tagged
       ,grades.grades_tested      
       ,a.schoolid
       ,sch.abbreviation AS school
       ,a.title
       ,a.subject
       ,a.scope
       ,a.standards_tested
       ,a.teachernumber
       ,a.created_by       
       ,CONVERT(VARCHAR,a.subject) + ' - '
         + 'G' + CONVERT(VARCHAR,CASE WHEN a.grade_level = 0 THEN 'K' ELSE a.grade_level END) + ' - '
         + CONVERT(VARCHAR,a.scope) + CONVERT(VARCHAR,RIGHT(a.fsa_week, 2)) + ' - '
         + CONVERT(VARCHAR,sch.ABBREVIATION) AS synth_title
       ,CASE WHEN a.scope = 'FSA' THEN
          ROW_NUMBER() OVER(
          PARTITION BY a.schoolid, a.grade_level, a.fsa_week, a.scope, a.subject, a.standards_tested, a.assessment_id
          ORDER BY a.assessment_id)
         ELSE NULL
        END AS gdocs_dupe
 FROM ILLUMINATE$assessments#static a WITH(NOLOCK)
 LEFT OUTER JOIN GDOCS$FSA_longterm_clean gdocs WITH(NOLOCK)
   ON a.schoolid = gdocs.schoolid
  AND a.grade_level = gdocs.grade_level
  AND a.fsa_week = gdocs.week_num
  AND a.subject = gdocs.subject
  AND a.standards_tested = gdocs.ccss_standard
  AND a.scope = 'FSA'
 JOIN SCHOOLS sch WITH(NOLOCK)
   ON a.schoolid = sch.SCHOOL_NUMBER
  AND sch.HIGH_GRADE = 4
 JOIN grades_tested grades
   ON a.assessment_id = grades.assessment_id
 WHERE a.academic_year = dbo.fn_Global_Academic_Year()
)

,longtermplan AS (
  SELECT gdocs.week_num AS fsa_week
        ,REPLACE(CONVERT(VARCHAR,gdocs.grade_level), 0, 'K') AS grade_tagged      
        ,gdocs.schoolid      
        ,sch.ABBREVIATION AS school
        ,gdocs.subject
        ,'FSA' AS scope
        ,COALESCE(gdocs.ccss_standard, gdocs.other_standard) AS standards_tested
        ,a.assessment_id
        ,a.title
        ,CONVERT(VARCHAR,gdocs.subject) + ' - '
         + 'G' + REPLACE(CONVERT(VARCHAR,gdocs.grade_level), 0, 'K') + ' - FSA'
         + CONVERT(VARCHAR,RIGHT(gdocs.week_num, 2)) + ' - '
         + CONVERT(VARCHAR,sch.ABBREVIATION) AS synth_title
  FROM GDOCS$FSA_longterm_clean gdocs WITH(NOLOCK)
  JOIN SCHOOLS sch WITH(NOLOCK)
    ON gdocs.schoolid = sch.SCHOOL_NUMBER
   AND sch.HIGH_GRADE = 4
  LEFT OUTER JOIN ILLUMINATE$assessments#static a WITH(NOLOCK)
    ON gdocs.schoolid = a.schoolid 
   AND gdocs.grade_level = a.grade_level
   AND gdocs.week_num = a.fsa_week
   AND gdocs.subject = a.subject
   AND COALESCE(gdocs.ccss_standard, gdocs.other_standard) = a.standards_tested
   AND a.scope = 'FSA'
  WHERE RIGHT(gdocs.week_num, 2) < (SELECT RIGHT(cur_week.time_per_name, 2) FROM cur_week)
 )

SELECT DISTINCT
       fsa_week
      ,administered_at
      ,assessment_id
      ,grade_tagged
      ,grades_tested
      ,schoolid
      ,school
      ,title
      ,subject
      ,scope
      ,NULL AS standards_tested             
      ,teachernumber
      ,created_by
      ,synth_title            
      ,'Missing scope' AS audit_result
FROM valid_assessments
WHERE scope IS NULL

UNION ALL

SELECT DISTINCT
       fsa_week
      ,administered_at
      ,assessment_id
      ,grade_tagged
      ,grades_tested
      ,schoolid
      ,school
      ,title
      ,subject
      ,scope
      ,NULL AS standards_tested             
      ,teachernumber
      ,created_by
      ,synth_title            
      ,'Missing subject' AS audit_result
FROM valid_assessments
WHERE subject IS NULL

UNION ALL
      
SELECT DISTINCT
       fsa_week
      ,administered_at
      ,assessment_id
      ,grade_tagged
      ,grades_tested
      ,schoolid
      ,school
      ,title
      ,subject
      ,scope
      ,NULL AS standards_tested             
      ,teachernumber
      ,created_by
      ,synth_title            
      ,'Missing grade level' AS audit_result
FROM valid_assessments
WHERE grade_tagged IS NULL

UNION ALL
      
     
SELECT DISTINCT
       fsa_week
      ,administered_at
      ,assessment_id
      ,grade_tagged
      ,grades_tested
      ,schoolid
      ,school
      ,title
      ,subject
      ,scope
      ,NULL AS standards_tested             
      ,teachernumber
      ,created_by
      ,synth_title            
      ,'Missing standards' AS audit_result
FROM valid_assessments
WHERE standards_tested IS NULL

UNION ALL
     
SELECT DISTINCT
       fsa_week
      ,administered_at
      ,assessment_id
      ,grade_tagged
      ,grades_tested
      ,schoolid
      ,school
      ,title
      ,subject
      ,scope
      ,NULL AS standards_tested             
      ,teachernumber
      ,created_by
      ,synth_title                        
      ,'Missing date' AS audit_result
FROM valid_assessments
WHERE administered_at IS NULL

UNION ALL

SELECT DISTINCT
       fsa_week
      ,administered_at
      ,assessment_id
      ,grade_tagged
      ,grades_tested
      ,schoolid
      ,school
      ,title
      ,subject
      ,scope
      ,NULL AS standards_tested             
      ,teachernumber
      ,created_by
      ,synth_title            
      ,'Scope/Title mismatch' AS audit_result
FROM valid_assessments
WHERE (title LIKE '%FSA%' AND scope != 'FSA') -- title contains FSA but not tagged
   OR (title NOT LIKE '%FSA%' AND scope = 'FSA') -- tag is FSA but not in the title
   OR (scope = 'FSA' AND (subject LIKE '%Vocab%' OR title LIKE '%Vocab%')) -- vocab test tagged as FSA         
         
UNION ALL
     
SELECT DISTINCT
       fsa_week
      ,administered_at
      ,assessment_id
      ,grade_tagged
      ,grades_tested
      ,schoolid
      ,school
      ,title
      ,subject
      ,scope
      ,NULL AS standards_tested             
      ,teachernumber
      ,created_by
      ,synth_title            
      ,'Tagged grade doesn''t match tested grade' AS audit_result
FROM valid_assessments
WHERE (scope != 'Intervention' AND CHARINDEX(grade_tagged, grades_tested) = 0)         

UNION ALL
     
SELECT DISTINCT
       fsa_week
      ,administered_at
      ,assessment_id
      ,grade_tagged
      ,grades_tested
      ,schoolid
      ,school
      ,title
      ,subject
      ,scope
      ,NULL AS standards_tested             
      ,teachernumber
      ,created_by
      ,synth_title            
      ,'Incorrect FSA date, according to title' AS audit_result      
FROM valid_assessments
WHERE scope = 'FSA' 
  AND (CHARINDEX(RIGHT(fsa_week,2), title) = 0 AND title LIKE '%FSA[0-9][0-9]%') -- 2-digit FSA week in title, doesn't match date
   OR (CHARINDEX(RIGHT(fsa_week,1), title) = 0 AND title LIKE '%FSA[0-9]%') -- 1-digit FSA week in title, doesn't match date
        
UNION ALL
     
SELECT DISTINCT
       fsa_week
      ,administered_at
      ,assessment_id
      ,grade_tagged
      ,grades_tested
      ,schoolid
      ,school
      ,title
      ,subject
      ,scope
      ,NULL AS standards_tested             
      ,teachernumber
      ,created_by
      ,synth_title            
      ,'Invalid date (Weekend/Out of Scope)' AS audit_result
FROM valid_assessments
WHERE scope = 'FSA'
  AND (DATEPART(DW,administered_at) IN (1,7) OR (administered_at IS NOT NULL AND fsa_week IS NULL))

UNION ALL

SELECT DISTINCT
       fsa_week
      ,administered_at
      ,assessment_id
      ,grade_tagged
      ,grades_tested
      ,schoolid
      ,school
      ,title
      ,subject
      ,scope
      ,standards_tested             
      ,teachernumber
      ,created_by
      ,synth_title            
      ,'Dupe on LTP' AS audit_result
FROM valid_assessments
WHERE gdocs_dupe > 1      

UNION ALL

SELECT DISTINCT
       fsa_week
      ,NULL AS administered_at
      ,assessment_id
      ,grade_tagged
      ,NULL AS grades_tested
      ,schoolid
      ,school
      ,title
      ,subject
      ,scope
      ,standards_tested             
      ,NULL AS teachernumber
      ,NULL AS created_by
      ,synth_title            
      ,'On LTP but no match in Illuminate' AS audit_result
FROM longtermplan
WHERE assessment_id IS NULL