USE KIPP_NJ
GO

ALTER VIEW DISC$tardy_demerits AS 

SELECT att.schoolid
      ,att.studentid
      ,t.LASTFIRST AS entry_author                
      ,CONVERT(DATE,att_date) AS entry_date      
      ,3223 AS logtypeid
      ,06 AS subtypeid      
      ,'Demerits' AS logtype
      ,'Tardy' AS subtype
      ,'Late to Class' AS subject      
      ,'Late to Class' AS discipline_details      
FROM KIPP_NJ..ATT_MEM$PS_ATTENDANCE_MEETING att WITH(NOLOCK)
JOIN KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
  ON att.sectionid = sec.ID
 AND att.schoolid = sec.SCHOOLID
JOIN KIPP_NJ..PS$SCHOOLSTAFF#static ss WITH(NOLOCK)
  ON sec.TEACHER = ss.ID
JOIN KIPP_NJ..PS$USERS#static t WITH(NOLOCK)
  ON ss.USERS_DCID = t.DCID
WHERE att.att_code IN ('T','T10')
  AND att.schoolid = 73253    

UNION ALL

SELECT att.schoolid
      ,att.studentid
      ,t.LASTFIRST AS entry_author        
      ,CONVERT(DATE,att_date) AS entry_date      
      ,3223 AS logtypeid
      ,06 AS subtypeid      
      ,'Demerits' AS logtype
      ,'Tardy' AS subtype
      ,'Late to School' AS subject      
      ,'Late to School' AS discipline_details      
FROM KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
  ON att.STUDENTID = cc.STUDENTID
 AND att.SCHOOLID = cc.SCHOOLID
 AND att.ATT_DATE >= cc.DATEENROLLED
 AND att.ATT_DATE <= cc.DATELEFT
 AND cc.COURSE_NUMBER = 'HR' 
JOIN KIPP_NJ..PS$SCHOOLSTAFF#static ss WITH(NOLOCK)
  ON cc.TEACHERID = ss.ID
JOIN KIPP_NJ..PS$USERS#static t WITH(NOLOCK)
  ON ss.USERS_DCID = t.DCID
WHERE att.att_code IN ('T','T10')
  AND att.schoolid = 73253    