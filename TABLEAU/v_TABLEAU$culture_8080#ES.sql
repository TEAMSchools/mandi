USE KIPP_NJ
GO

ALTER VIEW TABLEAU$culture_8080#ES AS

SELECT academic_year
      ,week
      ,week_of
      ,schoolid
      ,GRADE_LEVEL
      ,TEAM
      ,studentid
      ,SUM(meets) AS n_meeting
      ,SUM(n_measures) total_measures
      ,ROUND(SUM(meets) / CASE WHEN SUM(n_measures) = 0 THEN NULL ELSE SUM(n_measures) END * 100,0) AS pct_meeting
      ,CASE WHEN ROUND(SUM(meets) / CASE WHEN SUM(n_measures) = 0 THEN NULL ELSE SUM(n_measures) END * 100,0) >= 80 THEN 1.0 ELSE 0.0 END AS is_80
FROM
    (
     SELECT dbo.fn_DateToSY(dt.att_date) AS academic_year
           ,DATEPART(WEEK,dt.att_date) AS week
           ,DATEADD(WEEK,DATEDIFF(WEEK,0,dt.att_date), 0) AS week_of
           ,s.schoolid
           ,s.GRADE_LEVEL
           ,s.TEAM
           ,s.id AS studentid
           ,ISNULL(dt.purple_pink,0) + ISNULL(dt.green,0)
             + ISNULL(dt.am_purple_pink,0) + ISNULL(dt.am_green,0)
             + ISNULL(dt.mid_purple_pink,0) + ISNULL(dt.mid_green,0)
             + ISNULL(dt.pm_purple_pink,0) + ISNULL(dt.pm_green,0) AS meets
           ,CASE WHEN dt.color_day IS NOT NULL THEN 1.0 ELSE 0.0 END
             + CASE WHEN dt.color_am IS NOT NULL THEN 1.0 ELSE 0.0 END
             + CASE WHEN dt.color_mid IS NOT NULL THEN 1.0 ELSE 0.0 END
             + CASE WHEN dt.color_pm IS NOT NULL THEN 1.0 ELSE 0.0 END
             AS n_measures      
     FROM ES_DAILY$tracking_long#static dt WITH(NOLOCK)
     JOIN STUDENTS s WITH(NOLOCK)
       ON dt.studentid = s.id
      AND s.schoolid NOT IN (133570965, 73252, 73253)
    ) sub
GROUP BY academic_year
        ,week
        ,week_of
        ,SCHOOLID
        ,GRADE_LEVEL
        ,TEAM
        ,studentid