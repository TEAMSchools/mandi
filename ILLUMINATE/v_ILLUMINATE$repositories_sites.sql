USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$repositories_sites AS

SELECT DISTINCT
       co.year AS academic_year
      ,co.SCHOOLID
      ,co.GRADE_LEVEL
      ,res.repository_id 
      ,repo.date_administered
FROM KIPP_NJ..ILLUMINATE$repository_data res WITH(NOLOCK)    
JOIN KIPP_NJ..ILLUMINATE$repositories#static repo WITH(NOLOCK)
  ON res.repository_id = repo.repository_id
JOIN KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
  ON res.student_id = co.STUDENT_NUMBER
 AND repo.date_administered BETWEEN co.ENTRYDATE AND co.EXITDATE
 AND co.RN = 1
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON repo.date_administered BETWEEN dt.start_date AND dt.end_date
 AND co.SCHOOLID = dt.schoolid 
 AND dt.identifier = 'REP'