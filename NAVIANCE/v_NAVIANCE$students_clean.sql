USE [KIPP_NJ]
GO

ALTER VIEW NAVIANCE$students_clean AS

SELECT *
      ,ROW_NUMBER() OVER(
         PARTITION BY hs_student_id
           ORDER BY studentid DESC) AS rn
FROM KIPP_NJ..AUTOLOAD$NAVIANCE_0_students WITH(NOLOCK)