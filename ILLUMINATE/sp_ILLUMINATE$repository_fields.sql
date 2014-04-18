SELECT *
      ,ROW_NUMBER() OVER(
          PARTITION BY repository_id, dupe_check
              ORDER BY updated_at DESC) AS rn
FROM
    (
     SELECT *
           ,CASE WHEN CHARINDEX('_', RIGHT(name, 2)) > 0 THEN LEFT(name, (LEN(name) - 2)) ELSE name END AS dupe_check
     FROM OPENQUERY(ILLUMINATE,'
       SELECT repository_id        
             ,field_id
             ,name        
             ,label
             ,type
             ,seq
             ,calculation        
             ,expression_id                
             ,created_at
             ,updated_at           
             ,deleted_at     
       FROM dna_repositories.fields
     ')
    ) sub