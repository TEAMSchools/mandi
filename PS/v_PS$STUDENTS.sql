USE KIPP_NJ
GO

ALTER VIEW PS$STUDENTS AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT DCID
        ,ID
        ,STUDENT_NUMBER
        ,STATE_STUDENTNUMBER
        ,LASTFIRST
        ,FIRST_NAME
        ,MIDDLE_NAME
        ,LAST_NAME        
        ,ENROLL_STATUS
        ,SCHOOLID
        ,GRADE_LEVEL                
        ,TEAM        
        ,DOB        
        ,ENTRYDATE
        ,EXITDATE
        ,ENTRYCODE
        ,EXITCODE        
        ,STREET
        ,CITY
        ,STATE
        ,ZIP                
        ,GEOCODE 
        ,GENDER
        ,LUNCHSTATUS
        ,ETHNICITY                                                
        ,WEB_ID                
        ,ALLOWWEBACCESS                        
        ,STUDENT_WEB_ID        
        ,STUDENT_ALLOWWEBACCESS                                                
        ,LDAPENABLED
        ,NEXT_SCHOOL                                  
        ,SCHED_NEXTYEARGRADE                
        ,ENROLLMENT_SCHOOLID                
        ,FTEID                
        ,PERSON_ID        
        ,DISTRICTENTRYDATE
        ,DISTRICTENTRYGRADELEVEL
        ,SCHOOLENTRYDATE
        ,SCHOOLENTRYGRADELEVEL        
        ,GRADUATED_SCHOOLID                
  FROM STUDENTS  
')