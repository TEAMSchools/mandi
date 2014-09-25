USE [KIPP_NJ]
GO

ALTER VIEW NAVIANCE$students_clean AS

SELECT [hs_student_id] AS student_number
      ,[email]
      ,[mobile_phone]
      ,[program_strength]                  
      ,[counselor_name]
      ,[counselor_comments]
      ,[highest_sat]
      ,[highest_combo_sat]
      ,[recent_sat]
      ,[highest_act]
      ,[recent_act]
      ,[highest_psat]
      ,[highest_plan]
      ,[highest_ib]
      ,ROW_NUMBER() OVER(
         PARTITION BY hs_student_id
           ORDER BY studentid DESC) AS rn
FROM [dbo].[AUTOLOAD$NAVIANCE_students] WITH(NOLOCK)