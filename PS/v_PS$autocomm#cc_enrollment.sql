USE KIPP_NJ
GO

CREATE VIEW PS$AUTOCOMM#cc_enrollment AS

SELECT s.schoolid
	  ,s.student_number
	  ,KIPP_NJ.dbo.fn_Global_Term_Id() AS termid
	  ,'ENR' AS course_number
	  ,CASE WHEN s.school_name LIKE '%Path%' THEN 'pathms' + CAST(s.grade_level AS NVARCHAR)
			ELSE LOWER(s.school_name) + CAST(s.grade_level AS NVARCHAR)
			END AS section_number
	  ,CONVERT(VARCHAR(10), CAST(s.entrydate AS DATE), 101) AS dateenrolled
	  ,CONVERT(VARCHAR(10), CAST(s.exitdate AS DATE), 101) AS dateleft

FROM COHORT$identifiers_long#static s WITH(NOLOCK)

WHERE s.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND s.school_level = 'MS'