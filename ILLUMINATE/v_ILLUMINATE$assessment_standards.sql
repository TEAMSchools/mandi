USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessment_standards AS

SELECT *
FROM OPENQUERY(ILLUMINATE,'
  SELECT assessment_id
        ,standard_id
  FROM dna_assessments.assessment_standards  
')