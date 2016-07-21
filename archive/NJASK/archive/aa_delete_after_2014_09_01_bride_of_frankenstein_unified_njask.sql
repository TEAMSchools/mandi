USE [KIPP_NJ]
GO

/****** Object:  View [dbo].[aa_delete_after_2014_09_01_bride_of_frankenstein_unified_njask]    Script Date: 4/15/2015 9:55:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[aa_delete_after_2014_09_01_bride_of_frankenstein_unified_njask] AS
SELECT studentid, test_schoolid, test_year, test_date, test_grade_level,
       njask_scale_score, subject
FROM aa_delete_after_2014_09_01_njask_2013
UNION 
SELECT studentid, test_schoolid, academic_year AS test_year, NULL AS test_date, test_grade_level, 
       njask_scale_score, subject
FROM KIPP_NJ..NJASK$detail

GO


