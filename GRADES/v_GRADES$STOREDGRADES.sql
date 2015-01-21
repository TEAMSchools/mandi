USE KIPP_NJ
GO

ALTER VIEW GRADES$STOREDGRADES AS

SELECT STUDENTID
      ,SECTIONID
      ,COURSE_NUMBER
      ,COURSE_NAME
      ,TERMID
      ,KIPP_NJ.dbo.fn_TermToYear(TERMID) AS academic_year
      ,STORECODE
      ,GRADE
      ,[PERCENT] AS PCT
      ,GPA_POINTS
      ,EARNEDCRHRS
      ,GRADESCALE_NAME
      ,EXCLUDEFROMGPA
      ,EXCLUDEFROMTRANSCRIPTS
      ,EXCLUDEFROMGRADUATION
FROM OPENQUERY(PS_TEAM,'
  SELECT studentid
        ,sectionid
        ,course_number
        ,course_name
        ,termid
        ,storecode
        ,grade
        ,percent
        ,gpa_points
        ,earnedcrhrs        
        ,gradescale_name
        ,excludefromgpa
        ,excludefromtranscripts
        ,excludefromgraduation        
  FROM storedgrades
  WHERE (grade IS NOT NULL AND percent > 0)
')