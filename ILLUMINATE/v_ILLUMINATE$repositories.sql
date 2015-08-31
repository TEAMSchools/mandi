USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$repositories AS

SELECT repo.repository_id
      ,KIPP_NJ.dbo.fn_DateToSY(repo.date_administered) AS academic_year
      ,CONVERT(DATE,repo.date_administered) AS date_administered      
      ,repo.title      
      ,repo.subject_area      
      ,repo.scope
      ,repo.state_id AS teachernumber
      ,t.LASTFIRST AS created_by      
      ,CASE
        WHEN repo.subject_area = 'Arabic' THEN 'WLANG'
        WHEN repo.subject_area = 'Arts: Music' THEN 'ART'
        WHEN repo.subject_area = 'Arts: Theatre' THEN 'ART'
        WHEN repo.subject_area = 'Arts: Visual Arts' THEN 'ART'
        WHEN repo.subject_area = 'Comprehension' THEN 'ENG'
        WHEN repo.subject_area = 'English Language Arts' THEN 'ENG'
        WHEN repo.subject_area = 'English' THEN 'ENG'
        WHEN repo.subject_area = 'Vocabulary' THEN 'ENG'
        WHEN repo.subject_area = 'French' THEN 'WLANG'
        WHEN repo.subject_area = 'Grammar' THEN 'ENG'
        WHEN repo.subject_area = 'Historical Arts' THEN 'SOC'
        WHEN repo.subject_area = 'History' THEN 'SOC'
        WHEN repo.subject_area = 'Humanities' THEN 'SOC'
        WHEN repo.subject_area = 'Mathematics' THEN 'MATH'
        WHEN repo.subject_area = 'Performing Arts' THEN 'ART'
        WHEN repo.subject_area = 'Phonics' THEN 'ENG'
        WHEN repo.subject_area = 'Physical Education' THEN 'PHYSED'
        WHEN repo.subject_area = 'Reading' THEN 'ENG'
        WHEN repo.subject_area = 'Science' THEN 'SCI'
        WHEN repo.subject_area = 'Spanish' THEN 'WLANG'
        WHEN repo.subject_area = 'Word Work' THEN 'ENG'
        WHEN repo.subject_area = 'Writing' THEN 'RHET'
        ELSE NULL
       END AS credittype      
FROM OPENQUERY(ILLUMINATE,'
  SELECT repo.repository_id
        ,repo.title        
        ,repo.date_administered
        ,subj.code_translation AS subject_area
        ,scope.code_translation AS scope
        ,u.state_id           
  FROM dna_repositories.repositories repo
  LEFT OUTER JOIN codes.dna_subject_areas subj
    ON repo.code_subject_area_id = subj.code_id
  LEFT OUTER JOIN codes.dna_scopes scope
    ON repo.code_scope_id = scope.code_id
  LEFT OUTER JOIN public.users u
    ON repo.user_id = u.user_id
  WHERE repo.deleted_at IS NULL
') repo
LEFT OUTER JOIN KIPP_NJ..PS$USERS#static t WITH(NOLOCK)
  ON repo.state_id = t.TEACHERNUMBER