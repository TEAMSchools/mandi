USE KIPP_NJ
GO

ALTER VIEW PS$CUSTOM_STUDENTS AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT ID AS STUDENTID                
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''SID'') AS SID
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''ADVISOR'') AS ADVISOR
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''ADVISOR_EMAIL'') AS ADVISOR_EMAIL
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''ADVISOR_CELL'') AS ADVISOR_CELL
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''SPEDLEP'') AS SPEDLEP              
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''SPECIAL_EDUCATION'') AS SPEDLEP_CODE
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''504_STATUS'') AS STATUS_504
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''LEP_STATUS'') AS LEP_STATUS
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''LUNCH_BALANCE'') AS LUNCH_BALANCE
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''DIYNICKNAME'') AS DIY_NICKNAME        
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''DEFAULT_STUDENT_WEB_ID'') AS DEFAULT_STUDENT_WEB_ID
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''DEFAULT_STUDENT_WEB_PASSWORD'') AS DEFAULT_STUDENT_WEB_PASSWORD
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''DEFAULT_FAMILY_WEB_ID'') AS DEFAULT_FAMILY_WEB_ID
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''DEFAULT_FAMILY_WEB_PASSWORD'') AS DEFAULT_FAMILY_WEB_PASSWORD        
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''NEWARK_ENROLLMENT_NUMBER'') AS NEWARK_ENROLLMENT_NUMBER
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Transfer_KIPP_Code'') AS Transfer_KIPP_Code
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''CR_PrevSchoolName'') AS CR_PrevSchoolName
  FROM STUDENTS
')