USE [KIPP_NJ]
GO

/****** Object:  StoredProcedure [dbo].[sp_ENROLL$one_newark_stats]    Script Date: 8/26/2015 4:29:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_ENROLL$one_newark_stats]
AS

--1) declare variables
DECLARE
  @num_enrolled        INT
 ,@num_unenrolled      INT
 ,@n                   INT
--2) set values

 SET @num_enrolled = (SELECT COUNT(*)
                     FROM [OneNewarkEnrolls].[dbo].[Contact] c
                     WHERE c.CanAllowPortalSelfReg = 1
                     )

 SET @num_unenrolled = (SELECT COUNT(*)
                        FROM [OneNewarkEnrolls].[dbo].[Contact] c
                        WHERE c.CanAllowPortalSelfReg = 0
                        )

 SET @n = (SELECT COUNT(*)
           FROM [OneNewarkEnrolls].[dbo].[Contact] c
           )

--create a temp table with these values
  --drop if exists
		IF OBJECT_ID(N'tempdb..#ENROLL$temp_stats') IS NOT NULL
		BEGIN
						DROP TABLE [#ENROLL$temp_stats]
		END

  CREATE TABLE #ENROLL$temp_stats (
    num_enrolled int
   ,num_unenrolled int
   ,n int
  )

  INSERT INTO #ENROLL$temp_stats SELECT @num_enrolled, @num_unenrolled, @n;
--3) merge into stat table


  MERGE KIPP_NJ..ENROLL$one_newark_stats AS target
  USING #ENROLL$temp_stats AS source
  ON target.date = CAST(GETDATE() AS date)

  WHEN MATCHED THEN
    UPDATE SET 
      target.num_enrolled = source.num_enrolled
     ,target.num_unenrolled = source.num_unenrolled
     ,target.total_n = source.n

  WHEN NOT MATCHED BY target THEN
  INSERT (date
         ,num_enrolled
         ,num_unenrolled
         ,total_n) 
  VALUES (CAST(GETDATE() AS date)
         ,source.num_enrolled
         ,source.num_unenrolled
         ,source.n);

GO


