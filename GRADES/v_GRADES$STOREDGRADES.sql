USE KIPP_NJ
GO

ALTER VIEW GRADES$STOREDGRADES AS

SELECT *
FROM
    (
     SELECT *
           ,CASE 
             WHEN COURSE_NUMBER = 'TRANSFER' THEN 1
             ELSE ROW_NUMBER() OVER(
                   PARTITION BY ACADEMIC_YEAR, STUDENTID, STORECODE, COURSE_NUMBER
                    ORDER BY EARNEDCRHRS DESC, POTENTIALCRHRS DESC, [PERCENT] DESC) 
            END AS dupe_audit
     FROM
         (
          SELECT *
                ,KIPP_NJ.dbo.fn_TermToYear(TERMID) AS academic_year
          FROM OPENQUERY(PS_TEAM,'
            SELECT DCID
                  ,STUDENTID
                  ,SECTIONID
                  ,TERMID
                  ,STORECODE
                  ,DATESTORED
                  ,GRADE
                  ,PERCENT
                  ,ABSENCES
                  ,TARDIES
                  ,BEHAVIOR
                  ,POTENTIALCRHRS
                  ,EARNEDCRHRS
                  ,COURSE_NAME
                  ,NVL(COURSE_NUMBER,''TRANSFER'') AS COURSE_NUMBER
                  ,CREDIT_TYPE
                  ,GRADE_LEVEL
                  ,SCHOOLID
                  ,COURSE_EQUIV
                  ,SCHOOLNAME
                  ,GRADESCALE_NAME
                  ,TEACHER_NAME
                  ,EXCLUDEFROMGPA
                  ,GPA_POINTS
                  ,GPA_ADDEDVALUE                  
                  ,EXCLUDEFROMCLASSRANK
                  ,EXCLUDEFROMHONORROLL                  
                  ,ISEARNEDCRHRSFROMGB
                  ,ISPOTENTIALCRHRSFROMGB
                  ,TERMBINSNAME                  
                  ,REPLACED_GRADE
                  ,EXCLUDEFROMTRANSCRIPTS
                  ,REPLACED_DCID
                  ,EXCLUDEFROMGRADUATION
                  ,EXCLUDEFROMGRADESUPPRESSION
                  ,REPLACED_EQUIVALENT_COURSE
                  ,GRADEREPLACEMENTPOLICY_ID
            FROM STOREDGRADES sg            
          ') oq          
         ) sub
    ) sub
WHERE dupe_audit = 1