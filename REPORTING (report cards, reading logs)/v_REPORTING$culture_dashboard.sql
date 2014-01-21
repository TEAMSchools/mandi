USE KIPP_NJ
GO

ALTER VIEW REPORTING$culture_dashboard AS

SELECT *
FROM
     (
      SELECT 'KIPP NJ' AS Network
            ,CASE
              WHEN s.schoolid IN (73252,73253,73254,73255,73256,133570965) THEN 'Newark'
              ELSE NULL 
             END AS Region
            ,CASE
              WHEN s.schoolid IN (73254,73255,73256) THEN 'ES'
              WHEN s.schoolid IN (73252,133570965) THEN 'MS'
              WHEN s.schoolid IN (73253) THEN 'HS'
             END AS school_level
            ,s.schoolid
            ,CASE
              WHEN s.schoolid IN (73254,73255,73256) THEN CONVERT(DATE,dt.att_date)
              WHEN s.schoolid IN (73252,73253,133570965) THEN CONVERT(DATE,disc.entry_date)
             END AS att_date
            ,s.student_number
            ,s.lastfirst
            ,s.grade_level
            ,s.team
            ,dt.spedlep      
            
            --
            ,CASE
              WHEN dt.hw = 'Yes' THEN 1
              WHEN dt.hw = 'No' THEN 0 
              ELSE NULL
             END AS hw
            ,dt.color_day AS color
            ,'Day' AS color_time
            ,CASE WHEN dt.color_day = 'Purple' THEN 1 ELSE 0 END AS purple      
            ,0 AS pink
            ,CASE WHEN dt.color_day = 'Green' THEN 1 ELSE 0 END AS green
            ,CASE WHEN dt.color_day = 'Yellow' THEN 1 ELSE 0 END AS yellow
            ,CASE WHEN dt.color_day = 'Orange' THEN 1 ELSE 0 END AS orange
            ,CASE WHEN dt.color_day = 'Red' THEN 1 ELSE 0 END AS red
            ,CASE WHEN dt.color_day IS NULL THEN 1 ELSE 0 END AS no_color
            
            --
            ,CASE WHEN disc.subtype = 'Detention' THEN 1 ELSE 0 END AS detentions
            ,CASE 
              WHEN disc.subtype = 'Silent Lunch' THEN 1
              WHEN disc.subtype = 'Silent Lunch (5 Day)' THEN 5
              ELSE 0
             END AS silent_lunches
            ,CASE WHEN disc.subtype = 'Choices' THEN 1 ELSE 0 END AS choices
            ,CASE WHEN disc.subtype = 'Bench' THEN 1 ELSE 0 END AS benches
            ,CASE WHEN disc.subtype = 'ISS' THEN 1 ELSE 0 END AS ISS
            ,CASE WHEN disc.subtype = 'OSS' THEN 1 ELSE 0 END AS OSS
            ,CASE WHEN disc.subtype = 'Bus Warning' THEN 1 ELSE 0 END AS bus_warnings
            ,CASE WHEN disc.subtype = 'Bus Suspension' THEN 1 ELSE 0 END AS bus_suspensions
            ,CASE WHEN disc.subtype = 'Class Removal' THEN 1 ELSE 0 END AS class_removals
            ,CASE WHEN disc.subtype = 'Bullying' THEN 1 ELSE 0 END AS bullying
            
            --
            ,CASE WHEN disc.logtypeid = 3023 THEN 1 ELSE 0 END AS merits
            ,CASE WHEN disc.logtypeid = 3223 THEN 1 ELSE 0 END AS demerits
            
      FROM STUDENTS s
      LEFT OUTER JOIN ES_DAILY$daily_tracking_long#static dt
        ON s.id = dt.studentid
       AND dt.schoolid IN (73254,73256)
      LEFT OUTER JOIN DISC$log#static disc
        ON s.id = disc.studentid
       AND disc.schoolid IN (73252,73253,133570965)
      WHERE s.ENROLL_STATUS = 0
        AND s.SCHOOLID != 73255

      UNION ALL

      --THRIVE AM  
      SELECT 'KIPP NJ' AS Network
            ,CASE
              WHEN s.schoolid IN (73252,73253,73254,73255,73256,133570965) THEN 'Newark'
              ELSE NULL 
             END AS Region
            ,'ES' AS school_level
            ,s.schoolid
            ,CONVERT(DATE,dt.att_date) AS att_date
            ,s.student_number
            ,s.lastfirst
            ,s.grade_level
            ,s.team
            ,dt.spedlep      
            
            --
            ,CASE
              WHEN dt.hw = 'Yes' THEN 1
              WHEN dt.hw = 'No' THEN 0 
              ELSE NULL
             END AS hw
            ,dt.thrive_am AS color
            ,'AM' AS color_time
            ,0 AS purple
            ,CASE WHEN dt.thrive_am = 'Pink' THEN 1 ELSE 0 END AS pink
            ,CASE WHEN dt.thrive_am = 'Green' THEN 1 ELSE 0 END AS green
            ,CASE WHEN dt.thrive_am = 'Yellow' THEN 1 ELSE 0 END AS yellow
            ,CASE WHEN dt.thrive_am = 'Orange' THEN 1 ELSE 0 END AS orange
            ,CASE WHEN dt.thrive_am = 'Red' THEN 1 ELSE 0 END AS red
            ,CASE WHEN dt.thrive_am IS NULL THEN 1 ELSE 0 END AS no_color
            
            --
            ,0 AS detentions
            ,0 AS silent_lunches
            ,0 AS choices
            ,0 AS benches
            ,0 AS ISS
            ,0 AS OSS
            ,0 AS bus_warnings
            ,0 AS bus_suspensions
            ,0 AS class_removals
            ,0 AS bullying
            
            --
            ,0 AS merits
            ,0 AS demerits
            
      FROM STUDENTS s
      LEFT OUTER JOIN ES_DAILY$daily_tracking_long#static dt
        ON s.id = dt.studentid
       AND dt.schoolid = 73255
      WHERE s.ENROLL_STATUS = 0
        AND s.SCHOOLID = 73255
        
      UNION ALL

      --THRIVE Mid
      SELECT 'KIPP NJ' AS Network
            ,CASE
              WHEN s.schoolid IN (73252,73253,73254,73255,73256,133570965) THEN 'Newark'
              ELSE NULL 
             END AS Region
            ,'ES' AS school_level
            ,s.schoolid
            ,CONVERT(DATE,dt.att_date) AS att_date
            ,s.student_number
            ,s.lastfirst
            ,s.grade_level
            ,s.team
            ,dt.spedlep      
            
            --
            ,CASE
              WHEN dt.hw = 'Yes' THEN 1
              WHEN dt.hw = 'No' THEN 0 
              ELSE NULL
             END AS hw
            ,dt.thrive_mid AS color
            ,'Mid' AS color_time
            ,0 AS purple
            ,CASE WHEN dt.thrive_mid = 'Pink' THEN 1 ELSE 0 END AS pink
            ,CASE WHEN dt.thrive_mid = 'Green' THEN 1 ELSE 0 END AS green
            ,CASE WHEN dt.thrive_mid = 'Yellow' THEN 1 ELSE 0 END AS yellow
            ,CASE WHEN dt.thrive_mid = 'Orange' THEN 1 ELSE 0 END AS orange
            ,CASE WHEN dt.thrive_mid = 'Red' THEN 1 ELSE 0 END AS red
            ,CASE WHEN dt.thrive_mid IS NULL THEN 1 ELSE 0 END AS no_color
            
            --
            ,0 AS detentions
            ,0 AS silent_lunches
            ,0 AS choices
            ,0 AS benches
            ,0 AS ISS
            ,0 AS OSS
            ,0 AS bus_warnings
            ,0 AS bus_suspensions
            ,0 AS class_removals
            ,0 AS bullying
            
            --
            ,0 AS merits
            ,0 AS demerits
            
      FROM STUDENTS s
      LEFT OUTER JOIN ES_DAILY$daily_tracking_long#static dt
        ON s.id = dt.studentid
       AND dt.schoolid = 73255
      WHERE s.ENROLL_STATUS = 0
        AND s.SCHOOLID = 73255
        
      UNION ALL

      --THRIVE PM
      SELECT 'KIPP NJ' AS Network
            ,CASE
              WHEN s.schoolid IN (73252,73253,73254,73255,73256,133570965) THEN 'Newark'
              ELSE NULL 
             END AS Region
            ,'ES' AS school_level
            ,s.schoolid
            ,CONVERT(DATE,dt.att_date) AS att_date
            ,s.student_number
            ,s.lastfirst
            ,s.grade_level
            ,s.team
            ,dt.spedlep      
            
            --
            ,CASE
              WHEN dt.hw = 'Yes' THEN 1
              WHEN dt.hw = 'No' THEN 0 
              ELSE NULL
             END AS hw
            ,dt.thrive_pm AS color
            ,'PM' AS color_time
            ,0 AS purple
            ,CASE WHEN dt.thrive_pm = 'Pink' THEN 1 ELSE 0 END AS pink
            ,CASE WHEN dt.thrive_pm = 'Green' THEN 1 ELSE 0 END AS green
            ,CASE WHEN dt.thrive_pm = 'Yellow' THEN 1 ELSE 0 END AS yellow
            ,CASE WHEN dt.thrive_pm = 'Orange' THEN 1 ELSE 0 END AS orange
            ,CASE WHEN dt.thrive_pm = 'Red' THEN 1 ELSE 0 END AS red
            ,CASE WHEN dt.thrive_pm IS NULL THEN 1 ELSE 0 END AS no_color
            
            --
            ,0 AS detentions
            ,0 AS silent_lunches
            ,0 AS choices
            ,0 AS benches
            ,0 AS ISS
            ,0 AS OSS
            ,0 AS bus_warnings
            ,0 AS bus_suspensions
            ,0 AS class_removals
            ,0 AS bullying
            
            --
            ,0 AS merits
            ,0 AS demerits
            
      FROM STUDENTS s
      LEFT OUTER JOIN ES_DAILY$daily_tracking_long#static dt
        ON s.id = dt.studentid
       AND dt.schoolid = 73255
      WHERE s.ENROLL_STATUS = 0
        AND s.SCHOOLID = 73255  
     ) sub
     
WHERE att_date IS NOT NULL