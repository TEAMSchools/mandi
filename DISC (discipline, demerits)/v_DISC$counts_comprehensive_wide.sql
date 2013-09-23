--this is a lot slower than the existing "counts", not sure if there's a reason to use this on the server
--changed to SUM logtypeid instead of subtype because some values were NULL for otherwise valid entries

USE KIPP_NJ
GO

--ALTER VIEW  AS
WITH rost AS
  (SELECT sub.*
         ,ROW_NUMBER() OVER
            (PARTITION BY base_studentid
             ORDER BY rn        
             ) AS rn_format
   FROM     
        (SELECT log.schoolid        
               ,s.id AS base_studentid
               ,s.lastfirst
               ,s.grade_level
               ,log.RT
               ,ROW_NUMBER() OVER 
                  (PARTITION BY s.id
                   ORDER BY CASE
                             WHEN log.RT = 'RT1' THEN '1'
                             WHEN log.RT = 'RT2' THEN '2'
                             WHEN log.RT = 'RT3' THEN '3'
                             WHEN log.RT = 'RT4' THEN '4'
                             WHEN log.RT = 'RT5' THEN '5'
                             WHEN log.RT = 'RT6' THEN '6'                              
                            END
                  ) AS rn
         FROM STUDENTS s
         LEFT OUTER JOIN KIPP_NJ..DISC$log log
           ON s.id = log.studentid
         WHERE log.RT IN ('RT1','RT2','RT3','RT4','RT5','RT6')
         ) sub
   )
  
SELECT *
FROM
       (--Detentions (total)
        SELECT s.schoolid, s.id AS base_studentid, s.lastfirst, s.grade_level
	             ,'detentions' AS pivot_on
	             ,SUM(CASE WHEN pivot_ele.logtypeid IS NOT NULL THEN 1 ELSE 0 END) AS value
        FROM KIPP_NJ..DISC$log pivot_ele
        JOIN STUDENTS s
          ON s.id = pivot_ele.studentid
        WHERE pivot_ele.logtypeid = -100000
          AND pivot_ele.subtype = 'Detention'         
        GROUP BY s.schoolid, s.id, s.lastfirst, s.grade_level
        
        UNION ALL
        
        --Silent Lunches (total)
        SELECT s.schoolid, s.id AS base_studentid, s.lastfirst, s.grade_level
	             ,'silent_lunch' AS pivot_on
	             ,SUM(CASE WHEN pivot_ele.logtypeid IS NOT NULL THEN 1 ELSE 0 END) AS value
        FROM KIPP_NJ..DISC$log pivot_ele
        JOIN STUDENTS s
          ON s.id = pivot_ele.studentid
        WHERE pivot_ele.logtypeid = -100000
          AND pivot_ele.subtype = 'Silent Lunch'         
        GROUP BY s.schoolid, s.id, s.lastfirst, s.grade_level
        
        UNION ALL
        
        --Detentions (by term)
        SELECT rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level
	             ,'rt' + CONVERT(VARCHAR,rost.rn_format) + '_detentions' AS pivot_on
	             ,SUM(CASE WHEN pivot_ele.logtypeid IS NOT NULL THEN 1 ELSE 0 END) AS value
        FROM rost
        JOIN KIPP_NJ..DISC$log pivot_ele
          ON rost.base_studentid = pivot_ele.studentid
         AND pivot_ele.logtypeid = -100000
         AND pivot_ele.subtype = 'Detention'
         AND pivot_ele.RT = 'RT' + CAST(rost.rn_format AS VARCHAR)
        GROUP BY rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level, rost.rn_format
        
        UNION ALL
        
        --Silent Lunch (by term)
        SELECT rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level
	             ,'rt' + CONVERT(VARCHAR,rost.rn_format) + '_silent_lunches' AS pivot_on
	             ,SUM(CASE WHEN pivot_ele.logtypeid IS NOT NULL THEN 1 ELSE 0 END) AS value
        FROM rost
        JOIN KIPP_NJ..DISC$log pivot_ele
          ON rost.base_studentid = pivot_ele.studentid
         AND pivot_ele.logtypeid = -100000
         AND pivot_ele.subtype = 'Silent Lunch'
         AND pivot_ele.RT = 'RT' + CONVERT(VARCHAR,rost.rn_format)
        GROUP BY rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level, rost.rn_format
        
        UNION ALL
        
        --Choices (by term)
        SELECT rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level
	             ,'rt' + CONVERT(VARCHAR,rost.rn_format) + '_choices' AS pivot_on
	             ,SUM(CASE WHEN pivot_ele.logtypeid IS NOT NULL THEN 1 ELSE 0 END) AS value
        FROM rost
        JOIN KIPP_NJ..DISC$log pivot_ele
          ON rost.base_studentid = pivot_ele.studentid
         AND pivot_ele.logtypeid = -100000
         AND pivot_ele.subtype = 'Choices'
         AND pivot_ele.RT = 'RT' + CONVERT(VARCHAR,rost.rn_format)
        GROUP BY rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level, rost.rn_format
        
        UNION ALL
        
        --Bench (by term)
        SELECT rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level
	             ,'rt' + CONVERT(VARCHAR,rost.rn_format) + '_bench' AS pivot_on
	             ,SUM(CASE WHEN pivot_ele.logtypeid IS NOT NULL THEN 1 ELSE 0 END) AS value
        FROM rost
        JOIN KIPP_NJ..DISC$log pivot_ele
          ON rost.base_studentid = pivot_ele.studentid
         AND pivot_ele.logtypeid = -100000
         AND pivot_ele.subtype = 'Bench'
         AND pivot_ele.RT = 'RT' + CONVERT(VARCHAR,rost.rn_format)
        GROUP BY rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level, rost.rn_format
        
        UNION ALL
        
        --ISS (by term)
        SELECT rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level
	             ,'rt' + CONVERT(VARCHAR,rost.rn_format) + '_ISS' AS pivot_on
	             ,SUM(CASE WHEN pivot_ele.logtypeid IS NOT NULL THEN 1 ELSE 0 END) AS value
        FROM rost
        JOIN KIPP_NJ..DISC$log pivot_ele
          ON rost.base_studentid = pivot_ele.studentid
         AND pivot_ele.logtypeid = -100000
         AND pivot_ele.subtype = 'ISS'
         AND pivot_ele.RT = 'RT' + CONVERT(VARCHAR,rost.rn_format)
        GROUP BY rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level, rost.rn_format
        
        UNION ALL
        
        --OSS (by term)
        SELECT rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level
	             ,'rt' + CONVERT(VARCHAR,rost.rn_format) + '_OSS' AS pivot_on
	             ,SUM(CASE WHEN pivot_ele.logtypeid IS NOT NULL THEN 1 ELSE 0 END) AS value
        FROM rost
        JOIN KIPP_NJ..DISC$log pivot_ele
          ON rost.base_studentid = pivot_ele.studentid
         AND pivot_ele.logtypeid = -100000
         AND pivot_ele.subtype = 'OSS'
         AND pivot_ele.RT = 'RT' + CONVERT(VARCHAR,rost.rn_format)
        GROUP BY rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level, rost.rn_format
        
        UNION ALL
        
        --Bus Warnings (by term)
        SELECT rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level
	             ,'rt' + CONVERT(VARCHAR,rost.rn_format) + '_bus_warnings' AS pivot_on
	             ,SUM(CASE WHEN pivot_ele.logtypeid IS NOT NULL THEN 1 ELSE 0 END) AS value
        FROM rost
        JOIN KIPP_NJ..DISC$log pivot_ele
          ON rost.base_studentid = pivot_ele.studentid
         AND pivot_ele.logtypeid = -100000
         AND pivot_ele.subtype = 'Bus Warning'
         AND pivot_ele.RT = 'RT' + CONVERT(VARCHAR,rost.rn_format)
        GROUP BY rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level, rost.rn_format
        
        UNION ALL
        
        --Bus Suspensions (by term)
        SELECT rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level
	             ,'rt' + CONVERT(VARCHAR,rost.rn_format) + '_bus_suspensions' AS pivot_on
	             ,SUM(CASE WHEN pivot_ele.logtypeid IS NOT NULL THEN 1 ELSE 0 END) AS value
        FROM rost
        JOIN KIPP_NJ..DISC$log pivot_ele
          ON rost.base_studentid = pivot_ele.studentid
         AND pivot_ele.logtypeid = -100000
         AND pivot_ele.subtype = 'Bus Suspension'
         AND pivot_ele.RT = 'RT' + CONVERT(VARCHAR,rost.rn_format)
        GROUP BY rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level, rost.rn_format
        
        UNION ALL
        
        --Class Removal (by term)
        SELECT rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level
	             ,'rt' + CONVERT(VARCHAR,rost.rn_format) + '_class_removal' AS pivot_on
	             ,SUM(CASE WHEN pivot_ele.logtypeid IS NOT NULL THEN 1 ELSE 0 END) AS value
        FROM rost
        JOIN KIPP_NJ..DISC$log pivot_ele
          ON rost.base_studentid = pivot_ele.studentid
         AND pivot_ele.logtypeid = -100000
         AND pivot_ele.subtype = 'Class Removal'
         AND pivot_ele.RT = 'RT' + CONVERT(VARCHAR,rost.rn_format)
        GROUP BY rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level, rost.rn_format
        
        UNION ALL
        
        --Bullying (by term)
        SELECT rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level
	             ,'rt' + CONVERT(VARCHAR,rost.rn_format) + '_bullying' AS pivot_on
	             ,SUM(CASE WHEN pivot_ele.logtypeid IS NOT NULL THEN 1 ELSE 0 END) AS value
        FROM rost
        JOIN KIPP_NJ..DISC$log pivot_ele
          ON rost.base_studentid = pivot_ele.studentid
         AND pivot_ele.logtypeid = -100000
         AND pivot_ele.subtype = 'Bullying'
         AND pivot_ele.RT = 'RT' + CONVERT(VARCHAR,rost.rn_format)
        GROUP BY rost.schoolid, rost.base_studentid, rost.lastfirst, rost.grade_level, rost.rn_format
        
        --UNION ALL
        ) sub