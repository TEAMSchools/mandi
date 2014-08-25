USE KIPP_NJ
GO

ALTER VIEW TABLEAU$culture_dashboard#ES AS

SELECT 'KIPP NJ' AS Network
      ,CASE
        WHEN s.schoolid IN (179901) THEN 'Camden'
        ELSE 'Newark'
       END AS Region
      ,CASE
        WHEN s.schoolid IN (73254,73255,73256,73257,179901) THEN 'ES'
        WHEN s.schoolid IN (73252,133570965) THEN 'MS'
        WHEN s.schoolid IN (73253) THEN 'HS'
       END AS school_level
      ,s.schoolid
      ,dt.att_date
      ,s.student_number
      ,s.lastfirst
      ,s.grade_level
      ,s.team
      ,cs.spedlep      
            
      --
      ,dt.has_hw AS hw
      ,dt.has_uniform AS uniform
      ,dt.color_day AS color
      ,'Day' AS color_time
      ,CASE WHEN dt.color_day = 'Purple' THEN 1 ELSE 0 END AS purple      
      ,0 AS pink
      ,CASE WHEN dt.color_day = 'Green' THEN 1 ELSE 0 END AS green
      ,CASE WHEN dt.color_day = 'Yellow' THEN 1 ELSE 0 END AS yellow
      ,CASE WHEN dt.color_day = 'Orange' THEN 1 ELSE 0 END AS orange
      ,CASE WHEN dt.color_day = 'Red' THEN 1 ELSE 0 END AS red
      ,CASE WHEN dt.color_day IS NULL THEN 1 ELSE 0 END AS no_color
            
FROM STUDENTS s WITH(NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.ID = cs.STUDENTID
LEFT OUTER JOIN ES_DAILY$tracking_long#static dt WITH(NOLOCK)
  ON s.id = dt.studentid
 AND dt.att_date IS NOT NULL
 AND dt.schoolid IN (73254,73256,73257)
WHERE s.ENROLL_STATUS = 0
  AND s.GRADE_LEVEL < 5
  AND s.SCHOOLID NOT IN (73255, 179901)

UNION ALL

--THRIVE AM  
SELECT 'KIPP NJ' AS Network
      ,CASE
        WHEN s.schoolid IN (179901) THEN 'Camden'
        ELSE 'Newark'
       END AS Region
      ,'ES' AS school_level
      ,s.schoolid
      ,CONVERT(DATE,dt.att_date) AS att_date
      ,s.student_number
      ,s.lastfirst
      ,s.grade_level
      ,s.team
      ,cs.spedlep      
            
      --
      ,dt.has_hw AS hw
      ,dt.has_uniform AS uniform
      ,dt.color_am AS color
      ,'AM' AS color_time
      ,0 AS purple
      ,CASE WHEN dt.color_am = 'Pink' THEN 1 ELSE 0 END AS pink
      ,CASE WHEN dt.color_am = 'Green' THEN 1 ELSE 0 END AS green
      ,CASE WHEN dt.color_am = 'Yellow' THEN 1 ELSE 0 END AS yellow
      ,CASE WHEN dt.color_am = 'Orange' THEN 1 ELSE 0 END AS orange
      ,CASE WHEN dt.color_am = 'Red' THEN 1 ELSE 0 END AS red
      ,CASE WHEN dt.color_am IS NULL THEN 1 ELSE 0 END AS no_color
            
FROM STUDENTS s WITH(NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.ID = cs.STUDENTID
LEFT OUTER JOIN ES_DAILY$tracking_long#static dt WITH(NOLOCK)
  ON s.id = dt.studentid
 AND dt.att_date IS NOT NULL
 AND dt.schoolid IN (73255, 179901)
WHERE s.ENROLL_STATUS = 0
  AND s.SCHOOLID IN (73255, 179901)
        
UNION ALL

--THRIVE Mid
SELECT 'KIPP NJ' AS Network
      ,CASE
        WHEN s.schoolid IN (179901) THEN 'Camden'
        ELSE 'Newark'
       END AS Region
      ,'ES' AS school_level
      ,s.schoolid
      ,CONVERT(DATE,dt.att_date) AS att_date
      ,s.student_number
      ,s.lastfirst
      ,s.grade_level
      ,s.team
      ,cs.spedlep      
            
      --
      ,dt.has_hw AS hw
      ,dt.has_uniform AS uniform
      ,dt.color_mid AS color
      ,'Mid' AS color_time
      ,0 AS purple
      ,CASE WHEN dt.color_mid = 'Pink' THEN 1 ELSE 0 END AS pink
      ,CASE WHEN dt.color_mid = 'Green' THEN 1 ELSE 0 END AS green
      ,CASE WHEN dt.color_mid = 'Yellow' THEN 1 ELSE 0 END AS yellow
      ,CASE WHEN dt.color_mid = 'Orange' THEN 1 ELSE 0 END AS orange
      ,CASE WHEN dt.color_mid = 'Red' THEN 1 ELSE 0 END AS red
      ,CASE WHEN dt.color_mid IS NULL THEN 1 ELSE 0 END AS no_color

FROM STUDENTS s
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.ID = cs.STUDENTID
LEFT OUTER JOIN ES_DAILY$tracking_long#static dt WITH(NOLOCK)
  ON s.id = dt.studentid
 AND dt.att_date IS NOT NULL
 AND dt.schoolid IN (73255, 179901)
WHERE s.ENROLL_STATUS = 0
  AND s.SCHOOLID IN (73255, 179901)
        
UNION ALL

--THRIVE PM
SELECT 'KIPP NJ' AS Network
      ,CASE
        WHEN s.schoolid IN (179901) THEN 'Camden'
        ELSE 'Newark'
       END AS Region
      ,'ES' AS school_level
      ,s.schoolid
      ,CONVERT(DATE,dt.att_date) AS att_date
      ,s.student_number
      ,s.lastfirst
      ,s.grade_level
      ,s.team
      ,cs.spedlep      
            
      --
      ,dt.has_hw AS hw
      ,dt.has_uniform AS uniform
      ,dt.color_pm AS color
      ,'PM' AS color_time
      ,0 AS purple
      ,CASE WHEN dt.color_pm = 'Pink' THEN 1 ELSE 0 END AS pink
      ,CASE WHEN dt.color_pm = 'Green' THEN 1 ELSE 0 END AS green
      ,CASE WHEN dt.color_pm = 'Yellow' THEN 1 ELSE 0 END AS yellow
      ,CASE WHEN dt.color_pm = 'Orange' THEN 1 ELSE 0 END AS orange
      ,CASE WHEN dt.color_pm = 'Red' THEN 1 ELSE 0 END AS red
      ,CASE WHEN dt.color_pm IS NULL THEN 1 ELSE 0 END AS no_color
            
FROM STUDENTS s WITH(NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.ID = cs.STUDENTID
LEFT OUTER JOIN ES_DAILY$tracking_long#static dt WITH(NOLOCK)
  ON s.id = dt.studentid
 AND dt.att_date IS NOT NULL
 AND dt.schoolid IN (73255, 179901)
WHERE s.ENROLL_STATUS = 0
  AND s.SCHOOLID IN (73255, 179901)