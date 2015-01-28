USE KIPP_NJ
GO

ALTER VIEW GRADES$STOREDGRADES AS

SELECT STUDENTID
      ,SCHOOLID
      ,SECTIONID
      ,COURSE_NUMBER
      ,COURSE_NAME
      ,TERMID
      ,academic_year
      ,STORECODE
      ,GRADE
      ,PCT
      ,GPA_POINTS
      ,POTENTIALCRHRS
      ,EARNEDCRHRS
      ,GRADESCALE_NAME
      ,EXCLUDEFROMGPA
      ,EXCLUDEFROMTRANSCRIPTS
      ,EXCLUDEFROMGRADUATION
FROM
    (
     SELECT STUDENTID
           ,SCHOOLID
           ,SECTIONID
           ,ISNULL(COURSE_NUMBER,'TRANSFER') AS course_number
           ,COURSE_NAME
           ,TERMID
           ,academic_year
           ,STORECODE
           ,GRADE
           ,PCT
           ,GPA_POINTS
           ,POTENTIALCRHRS
           ,EARNEDCRHRS
           ,GRADESCALE_NAME
           ,EXCLUDEFROMGPA
           ,EXCLUDEFROMTRANSCRIPTS
           ,EXCLUDEFROMGRADUATION
           ,CASE 
             WHEN course_number IS NOT NULL THEN 
              ROW_NUMBER() OVER(
                PARTITION BY academic_year, storecode, studentid, course_number
                  ORDER BY EARNEDCRHRS DESC, POTENTIALCRHRS DESC, pct DESC) 
             ELSE 1
            END AS dupe_audit
     FROM
         (
          SELECT oq.STUDENTID
                ,oq.schoolid
                ,oq.SECTIONID
                ,oq.COURSE_NUMBER
                ,oq.COURSE_NAME
                ,oq.TERMID
                ,KIPP_NJ.dbo.fn_TermToYear(oq.TERMID) AS academic_year
                ,oq.STORECODE
                ,oq.GRADE
                ,oq.[PERCENT] AS PCT
                ,oq.GPA_POINTS
                ,oq.POTENTIALCRHRS
                ,oq.EARNEDCRHRS
                ,oq.GRADESCALE_NAME
                ,oq.EXCLUDEFROMGPA
                ,oq.EXCLUDEFROMTRANSCRIPTS
                ,oq.EXCLUDEFROMGRADUATION
          FROM OPENQUERY(PS_TEAM,'
            SELECT studentid
                  ,schoolid
                  ,sectionid
                  ,course_number
                  ,course_name
                  ,termid
                  ,storecode
                  ,grade
                  ,percent
                  ,gpa_points
                  ,potentialcrhrs
                  ,earnedcrhrs  
                  ,gradescale_name
                  ,excludefromgpa
                  ,excludefromtranscripts
                  ,excludefromgraduation        
            FROM storedgrades
            WHERE (course_number IS NULL OR (course_number IS NOT NULL AND grade IS NOT NULL AND percent > 0)) -- exclude dirty data but keep transfer credits
          ') oq
          JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK) -- only records with matching student IDs returned, there's some really dirty data from 2008
            ON oq.studentid = s.id
         ) sub
    ) sub
WHERE dupe_audit = 1 -- older data has a lot of dupes, none of these records have any bearance on current students, so bank error is in their favor