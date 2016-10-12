USE KIPP_NJ
GO

ALTER VIEW PS$STUDENTS_custom AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT s.ID AS STUDENTID
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''SPECIAL_EDUCATION'') AS SPECIAL_EDUCATION        
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''504_STATUS'') AS STATUS_504
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Middle_Name_Custom'') AS MIDDLE_NAME_CUSTOM        
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''NJ_CityOfBirth'') AS NJ_CityOfBirth
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''NJ_StateOfBirth'') AS NJ_StateOfBirth
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''NJ_CountryOfBirth'') AS NJ_CountryOfBirth
        
        ,c.SPEDLEP
        ,c.LEP_STATUS        
        
        ,u.NEWARK_ENROLLMENT_NUMBER
        ,u.INFOSNAP_ID
        ,u.TRANSFER_KIPP_CODE
        ,u.CR_PREVSCHOOLNAME
        ,u.ADVISOR
        ,u.ADVISOR_EMAIL
        ,u.ADVISOR_CELL                
        ,u.DEFAULT_STUDENT_WEB_ID
        ,u.DEFAULT_STUDENT_WEB_PASSWORD
        ,u.DEFAULT_FAMILY_WEB_ID
        ,u.DEFAULT_FAMILY_WEB_PASSWORD                
        ,u.LUNCH_BALANCE
        ,u.INFOSNAP_OPT_IN
        ,u.FATHER_REGISTERED_TO_VOTE
        ,u.MOTHER_REGISTERED_TO_VOTE
  FROM STUDENTS s
  LEFT OUTER JOIN STUDENTCOREFIELDS c
    ON s.DCID = c.STUDENTSDCID
  LEFT OUTER JOIN U_STUDENTSUSERFIELDS u
    ON s.DCID = u.STUDENTSDCID  
')
