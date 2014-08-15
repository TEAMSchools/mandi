USE KIPP_NJ
GO

ALTER VIEW PS$bus_tracker AS 

WITH dismiss_change AS (
  SELECT studentid
        ,entry_date      
  FROM OPENQUERY(PS_TEAM,'
    SELECT studentid
          ,entry_date
    FROM log
    WHERE logtypeid = 3964
      AND ENTRY_DATE = TRUNC(SYSDATE)
  ') oq
 )

SELECT s.STUDENT_NUMBER
      ,s.SCHOOLID
      ,sch.ABBREVIATION AS school_name
      ,s.GRADE_LEVEL
      ,s.TEAM
      ,s.LASTFIRST
      ,bus.BUS_INFO_AM      
      ,bus.BUS_INFO_PM
      ,bus.BUS_INFO_FRIDAYS
      ,bus.BUS_INFO_BGC_CLOSED
      ,CASE 
        WHEN ch.studentid IS NOT NULL THEN 'Parent Pickup'
        WHEN DATEPART(WEEKDAY,GETDATE()) = 6 THEN BUS_INFO_FRIDAYS 
        ELSE BUS_INFO_PM 
       END AS BUS_PM_TODAY      
      ,CASE WHEN ch.studentid IS NOT NULL THEN 1 ELSE 0 END AS dismissal_flag
FROM STUDENTS s WITH(NOLOCK)
JOIN SCHOOLS sch WITH(NOLOCK)
  ON s.SCHOOLID = sch.SCHOOL_NUMBER
LEFT OUTER JOIN PS$bus_info#static bus WITH(NOLOCK)
  ON s.id = bus.STUDENTID
LEFT OUTER JOIN dismiss_change ch WITH(NOLOCK)
  ON bus.studentid = ch.studentid
WHERE s.ENROLL_STATUS = 0
  AND s.GRADE_LEVEL < 5