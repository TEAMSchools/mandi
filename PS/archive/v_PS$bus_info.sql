USE KIPP_NJ
GO

ALTER VIEW PS$bus_info AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT ID AS STUDENTID      
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''BUS_INFO_AM'') AS BUS_INFO_AM
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''BUS_INFO_PM'') AS BUS_INFO_PM        
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''BUS_INFO_FRIDAYS'') AS BUS_INFO_FRIDAYS
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''BUS_INFO_BGC_CLOSED'') AS BUS_INFO_BGC_CLOSED
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''BUS_NOTES'') AS BUS_NOTES        
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''GEOCODE'') AS GEOCODE        
  FROM STUDENTS
  WHERE GRADE_LEVEL <= 4
    AND SCHOOLID != 73252
    AND ENROLL_STATUS = 0    
')