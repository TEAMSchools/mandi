USE KIPP_NJ
GO

ALTER VIEW PS$bus_tracker AS 

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT student_number
        ,schoolid
        ,school_name
        ,grade_level
        ,team
        ,lastfirst
        ,bus_info_am
        ,bus_info_pm
        ,bus_info_fridays
        ,bus_info_bgc_closed
        ,CASE 
          WHEN TO_CHAR(SYSDATE,''D'') = 4 THEN BUS_INFO_FRIDAYS 
          WHEN log_studentid IS NULL THEN BUS_INFO_PM 
          WHEN log_studentid IS NOT NULL AND subtype = ''01'' THEN ''School Event''
          WHEN log_studentid IS NOT NULL THEN ''Parent Transport''
         END AS BUS_PM_TODAY      
       ,CASE WHEN log_studentid IS NOT NULL THEN 1 ELSE 0 END AS dismissal_flag
  FROM
      (
       SELECT s.STUDENT_NUMBER
             ,s.SCHOOLID
             ,sch.abbreviation AS school_name
             ,s.GRADE_LEVEL
             ,s.TEAM
             ,s.LASTFIRST
             ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',s.ID,''BUS_INFO_AM'') AS BUS_INFO_AM
             ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',s.ID,''BUS_INFO_PM'') AS BUS_INFO_PM        
             ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',s.ID,''BUS_INFO_FRIDAYS'') AS BUS_INFO_FRIDAYS
             ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',s.ID,''BUS_INFO_BGC_CLOSED'') AS BUS_INFO_BGC_CLOSED                     
             ,log.studentid AS log_studentid
             ,log.subtype
       FROM STUDENTS s
       JOIN SCHOOLS sch
         ON s.schoolid = sch.school_number
       LEFT OUTER JOIN log
         ON s.id = log.studentid
        AND log.logtypeid = 3964
        AND log.Discipline_IncidentDate = TRUNC(SYSDATE)
       WHERE s.enroll_status = 0
         AND s.GRADE_LEVEL < 5         
      ) sub
')