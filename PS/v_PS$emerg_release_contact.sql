USE KIPP_NJ
GO

ALTER VIEW PS$emerg_release_contact AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT ID AS STUDENTID      
        ,EMERG_CONTACT_1
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''EMERG_1_REL'') AS EMERG_1_REL
        ,EMERG_PHONE_1
        ,EMERG_CONTACT_2
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''EMERG_2_REL'') AS EMERG_2_REL
        ,EMERG_PHONE_2
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''EMERG_CONTACT_3'') AS EMERG_CONTACT_3
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''EMERG_3_REL'') AS EMERG_3_REL
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''EMERG_3_PHONE'') AS EMERG_3_PHONE
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''EMERG_4_NAME'') AS EMERG_4_NAME
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''EMERG_4_REL'') AS EMERG_4_REL
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''EMERG_4_PHONE'') AS EMERG_4_PHONE
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''EMERG_5_NAME'') AS EMERG_5_NAME
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''EMERG_5_REL'') AS EMERG_5_REL
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''EMERG_5_PHONE'') AS EMERG_5_PHONE
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_1_NAME'') AS RELEASE_1_NAME
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_1_PHONE'') AS RELEASE_1_PHONE
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_1_RELATION'') AS RELEASE_1_RELATION      
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_2_NAME'') AS RELEASE_2_NAME
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_2_PHONE'') AS RELEASE_2_PHONE
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_2_RELATION'') AS RELEASE_2_RELATION
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_3_NAME'') AS RELEASE_3_NAME
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_3_PHONE'') AS RELEASE_3_PHONE
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_3_RELATION'') AS RELEASE_3_RELATION
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_4_NAME'') AS RELEASE_4_NAME
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_4_PHONE'') AS RELEASE_4_PHONE
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_4_RELATION'') AS RELEASE_4_RELATION
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_5_NAME'') AS RELEASE_5_NAME
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_5_PHONE'') AS RELEASE_5_PHONE
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''RELEASE_5_RELATION'') AS RELEASE_5_RELATION
  FROM STUDENTS
  WHERE ENROLL_STATUS = 0
');