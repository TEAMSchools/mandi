--created to join assessment titles and related info directly off sql server view
--LD6 2013-09-18


USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessments AS
SELECT *
FROM OPENQUERY(ILLUMINATE, '
 SELECT *
 FROM dna_assessments.assessments
')