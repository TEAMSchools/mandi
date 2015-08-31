USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$repository_fields AS

SELECT *
FROM OPENQUERY(ILLUMINATE,'
  SELECT repository_id        
        ,field_id
        ,name        
        ,label                     
        ,seq                  
  FROM dna_repositories.fields
  WHERE deleted_at IS NULL
')