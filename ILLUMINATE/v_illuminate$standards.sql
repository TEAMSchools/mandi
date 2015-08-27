USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$standards AS

SELECT *      
FROM OPENQUERY(ILLUMINATE,'
  SELECT standard_id
        ,parent_standard_id
        ,category_id
        ,subject_id        
        ,state_num
        ,custom_code
        ,seq
        ,level
        ,description
  FROM standards.standards  
')