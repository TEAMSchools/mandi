USE KIPP_NJ
GO

ALTER VIEW GRADES$STOREDGRADES AS

SELECT STUDENTID
      ,SECTIONID
      ,COURSE_NUMBER
      ,COURSE_NAME
      ,TERMID
      ,academic_year
      ,STORECODE
      ,GRADE
      ,PCT
      ,GPA_POINTS
      ,EARNEDCRHRS
      ,GRADESCALE_NAME
      ,EXCLUDEFROMGPA
      ,EXCLUDEFROMTRANSCRIPTS
      ,EXCLUDEFROMGRADUATION
FROM
    (
     SELECT STUDENTID
           ,SECTIONID
           ,COURSE_NUMBER
           ,COURSE_NAME
           ,TERMID
           ,academic_year
           ,STORECODE
           ,GRADE
           ,PCT
           ,GPA_POINTS
           ,EARNEDCRHRS
           ,GRADESCALE_NAME
           ,EXCLUDEFROMGPA
           ,EXCLUDEFROMTRANSCRIPTS
           ,EXCLUDEFROMGRADUATION
           ,ROW_NUMBER() OVER(
              PARTITION BY academic_year, storecode, studentid, course_name
                ORDER BY pct DESC) AS dupe_audit
     FROM
         (
          SELECT oq.STUDENTID
                ,oq.SECTIONID
                ,oq.COURSE_NUMBER
                ,oq.COURSE_NAME
                ,oq.TERMID
                ,KIPP_NJ.dbo.fn_TermToYear(oq.TERMID) AS academic_year
                ,oq.STORECODE
                ,oq.GRADE
                ,oq.[PERCENT] AS PCT
                ,oq.GPA_POINTS
                ,oq.EARNEDCRHRS
                ,oq.GRADESCALE_NAME
                ,oq.EXCLUDEFROMGPA
                ,oq.EXCLUDEFROMTRANSCRIPTS
                ,oq.EXCLUDEFROMGRADUATION
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
          ') oq
          JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK) -- only records with matching student IDs returned, there's some really dirty data from 2008
            ON oq.studentid = s.id
         ) sub
    ) sub
WHERE dupe_audit = 1 -- older data has a lot of dupes, none of these records have any bearance on current students, so bank error is in their favor