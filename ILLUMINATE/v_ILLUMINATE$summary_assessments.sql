USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$summary_assessments AS

WITH test_roster AS (
  SELECT DISTINCT          
         co.SCHOOLID        
        ,co.GRADE_LEVEL
        ,res.repository_id
        ,CONVERT(DATE,repo.date_administered) AS date_administered
  FROM ILLUMINATE$summary_assessment_results_long#static res WITH(NOLOCK)    
  JOIN (
        SELECT *
        FROM OPENQUERY(ILLUMINATE,'
          SELECT repo.repository_id                
                ,repo.date_administered                
          FROM dna_repositories.repositories repo          
          WHERE deleted_at IS NULL
        ')
        ) repo
    ON res.repository_id = repo.repository_id
  JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
    ON res.student_id = co.STUDENT_NUMBER
   AND repo.date_administered >= co.ENTRYDATE
   AND repo.date_administered <= co.EXITDATE
   AND co.RN = 1
 )  

SELECT test_roster.SCHOOLID      
      ,test_roster.GRADE_LEVEL
      ,repo.repository_id
      ,repo.title
      ,repo.description
      ,repo.subject
      ,CASE
        WHEN repo.subject = 'Arabic' THEN 'WLANG'
        WHEN repo.subject = 'Arts: Music' THEN 'ART'
        WHEN repo.subject = 'Arts: Theatre' THEN 'ART'
        WHEN repo.subject = 'Arts: Visual Arts' THEN 'ART'
        WHEN repo.subject = 'Comprehension' THEN 'ENG'
        WHEN repo.subject = 'English Language Arts' THEN 'ENG'
        WHEN repo.subject = 'English' THEN 'ENG'
        WHEN repo.subject = 'Vocabulary' THEN 'ENG'
        WHEN repo.subject = 'French' THEN 'WLANG'
        WHEN repo.subject = 'Grammar' THEN 'ENG'
        WHEN repo.subject = 'Historical Arts' THEN 'SOC'
        WHEN repo.subject = 'History' THEN 'SOC'
        WHEN repo.subject = 'Humanities' THEN 'SOC'
        WHEN repo.subject = 'Mathematics' THEN 'MATH'
        WHEN repo.subject = 'Performing Arts' THEN 'ART'
        WHEN repo.subject = 'Phonics' THEN 'ENG'
        WHEN repo.subject = 'Physical Education' THEN 'PHYSED'
        WHEN repo.subject = 'Reading' THEN 'ENG'
        WHEN repo.subject = 'Science' THEN 'SCI'
        WHEN repo.subject = 'Spanish' THEN 'WLANG'
        WHEN repo.subject = 'Word Work' THEN 'ENG'
        WHEN repo.subject = 'Writing' THEN 'RHET'
        ELSE NULL
       END AS credittype
      ,repo.scope
      ,t.LASTFIRST AS created_by
      ,repo.teacher_number
      ,dt.time_per_name AS fsa_week
      ,CONVERT(DATE,repo.date_administered) AS date_administered
      ,CONVERT(DATE,repo.deleted_at) AS deleted_at
      ,dbo.fn_DateToSY(repo.date_administered) AS academic_year
      ,repo.db_virtual_table_id
FROM OPENQUERY(ILLUMINATE,'
  SELECT repo.repository_id
        ,repo.title
        ,repo.description
        ,subj.code_translation AS subject
        ,scope.code_translation AS scope        
        ,u.state_id AS teacher_number
        ,repo.date_administered
        ,repo.deleted_at
        ,repo.db_virtual_table_id
  FROM dna_repositories.repositories repo
  LEFT OUTER JOIN codes.dna_subject_areas subj
    ON repo.code_subject_area_id = subj.code_id
  LEFT OUTER JOIN codes.dna_scopes scope
    ON repo.code_scope_id = scope.code_id
  LEFT OUTER JOIN public.users u
    ON repo.user_id = u.user_id
  WHERE repo.deleted_at IS NULL
') repo
LEFT OUTER JOIN TEACHERS t WITH(NOLOCK)
  ON CONVERT(INT,repo.teacher_number) = CONVERT(INT,t.TEACHERNUMBER)
LEFT OUTER JOIN test_roster WITH(NOLOCK)
  ON repo.repository_id = test_roster.repository_id
LEFT OUTER JOIN REPORTING$dates dt WITH(NOLOCK)
  ON repo.date_administered >= dt.start_date
 AND repo.date_administered <= dt.end_date
 AND test_roster.SCHOOLID = dt.schoolid
 AND dt.school_level = 'ES'
 AND dt.identifier = 'REP'