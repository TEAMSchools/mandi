USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$distinct_assessments AS

SELECT DISTINCT
       assessment_id
      ,standard_id
      ,title
      ,scope
      ,subject
      ,credittype
      ,term
      ,academic_year
      ,administered_at
      ,standards_tested        
      ,standard_descr
FROM ILLUMINATE$assessments#static WITH(NOLOCK)  