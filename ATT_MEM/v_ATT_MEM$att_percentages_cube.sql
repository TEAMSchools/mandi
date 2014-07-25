USE [KIPP_NJ]
GO

ALTER VIEW ATT_MEM$att_percentages_cube AS
SELECT TOP (100) PERCENT *
FROM
     (SELECT CASE
             WHEN schoolid IS NULL THEN 'Region'
             WHEN schoolid = 73252 THEN 'Rise'
             WHEN schoolid = 73253 THEN 'NCA'
             WHEN schoolid = 73254 THEN 'SPARK'
             WHEN schoolid = 73255 THEN 'THRIVE'
             WHEN schoolid = 73256 THEN 'Seek'
             WHEN schoolid = 133570965 THEN 'TEAM Academy'
            END AS School
           ,CASE
             WHEN grade_level IS NULL THEN 'All'
             ELSE CAST(grade_level AS VARCHAR)
            END AS Grade
           ,att_avg_yr AS [Attendance Average %]
           ,tardy_avg_yr AS [Tardy Average %]
     FROM
         (SELECT att.schoolid
                ,s.grade_level      
                ,ROUND(AVG(y1_att_pct_total),1) AS att_avg_yr      
                ,ROUND(AVG(y1_tardy_pct_total),1) AS tardy_avg_yr
          FROM KIPP_NJ..ATT_MEM$att_percentages att
          JOIN STUDENTS s
            ON s.id = att.id
          WHERE att.schoolid != 999999
            AND s.EXITDATE >= GETDATE()
          GROUP BY CUBE (att.schoolid, s.grade_level)    
          ) sub
     ) sub2
ORDER BY school


