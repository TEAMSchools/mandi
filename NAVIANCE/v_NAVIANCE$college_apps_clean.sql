USE [KIPP_NJ]
GO

ALTER VIEW NAVIANCE$college_apps_clean AS

SELECT [hs_student_id] AS student_number
      ,ceeb_code
      ,[act_code]
      ,[collegename]      
      ,[state]
      ,[admissions_fax]
      ,[inst_control]
      ,[level]                        
      ,[stage]      
      ,[type]
      ,[result_code]
      ,[attending]
      ,[waitlisted]
      ,[deferred]
      ,[date_transcript_requested]
      ,[initial_transcript_sent]
      ,[midyear_transcript_sent]
      ,[final_transcript_sent]
      ,comments
      ,[SPEC] AS special_prog
      ,[LEG] AS legacy
      ,[INTV] AS interviewed
      ,[VIS] AS visited
      ,[URG] AS urgent
FROM AUTOLOAD$NAVIANCE_1_college_applications WITH(NOLOCK)