USE KIPP_NJ
GO

ALTER VIEW PS$bus_tracker AS 

WITH dismiss_change AS (
  SELECT studentid
        ,subtype        
  FROM OPENQUERY(PS_TEAM,'
    SELECT studentid      
          ,subtype    
    FROM log
    WHERE logtypeid = 3964
      AND Discipline_IncidentDate = TRUNC(SYSDATE)
  ') oq
 )

SELECT s.STUDENT_NUMBER
      ,s.SCHOOLID
      ,s.school_name
      ,s.GRADE_LEVEL
      ,s.TEAM
      ,s.LASTFIRST
      ,bus.BUS_INFO_AM      
      ,bus.BUS_INFO_PM
      ,bus.BUS_INFO_FRIDAYS
      ,bus.BUS_INFO_BGC_CLOSED
      ,CASE 
        WHEN ch.studentid IS NOT NULL AND ch.subtype = '01' THEN 'School Event'
        WHEN ch.studentid IS NOT NULL THEN 'Parent Transport'
        WHEN DATEPART(WEEKDAY,GETDATE()) = 4 THEN BUS_INFO_FRIDAYS 
        ELSE BUS_INFO_PM 
       END AS BUS_PM_TODAY      
      ,CASE WHEN ch.studentid IS NOT NULL THEN 1 ELSE 0 END AS dismissal_flag
FROM KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$bus_info#static bus WITH(NOLOCK)
  ON s.studentid = bus.STUDENTID
LEFT OUTER JOIN dismiss_change ch WITH(NOLOCK)
  ON bus.studentid = ch.studentid
WHERE s.ENROLL_STATUS = 0
  AND s.GRADE_LEVEL < 5
  AND s.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND s.rn = 1