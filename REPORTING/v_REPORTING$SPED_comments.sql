USE KIPP_NJ
GO

ALTER VIEW REPORTING$SPED_comments AS

SELECT CONVERT(INT,student_id) AS student_number
      ,CASE
        WHEN [field_subject] = 'Math' THEN 'Mathematics'
        WHEN [field_subject] = 'ELA' THEN 'Comprehension'
        ELSE [field_subject] 
       END AS subject
      ,[field_comment] AS comment      
      ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[field_date])) AS academic_year
      ,CONVERT(DATE,[field_date]) AS date      
      ,ROW_NUMBER() OVER(
          PARTITION BY student_id, field_subject
              ORDER BY CONVERT(DATE,[field_date]) DESC) AS rn
FROM (
      SELECT d.student_id
            ,d.repository_row_id
            ,d.field
            ,d.value            
      FROM KIPP_NJ..ILLUMINATE$repository_data d WITH(NOLOCK)      
      WHERE d.repository_id = 58
     ) sub
PIVOT(
  MAX(value)
  FOR field IN ([field_subject]
               ,[field_comment]
               ,[field_date])
 ) p