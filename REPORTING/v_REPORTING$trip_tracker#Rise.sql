USE KIPP_NJ
GO

ALTER VIEW REPORTING$trip_tracker#Rise AS

WITH stu_cal_frame AS (
  SELECT id AS studentid
        ,lastfirst
        ,grade_level
        ,team
        ,cal.*
  FROM STUDENTS s WITH(NOLOCK)
  JOIN (
        SELECT (CONVERT(INT,week)) AS week_number
              ,CONVERT(DATE,weekday_sun) AS week_of
              ,DATEPART(MONTH,weekday_sun) AS month
        FROM UTIL$reporting_weeks_days WITH(NOLOCK)
        WHERE year = dbo.fn_Global_Academic_Year()
          AND weekday_sun >= CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-11-23')
          AND weekday_sun <= GETDATE()
       ) cal
    ON 1 = 1
  WHERE s.enroll_status = 0
    AND s.schoolid = 73252
    AND s.grade_level = 5
 )

,hw_points AS (
  SELECT studentid
        ,month        
        ,ISNULL([H],0) AS [H]
        --,ISNULL([Q],0) AS [Q]
  FROM
      (
       SELECT oq.studentid
             ,LEFT(oq.rt_name,1) AS category
             --,CONVERT(VARCHAR,oq.week_of,1) AS week_of
             ,CONVERT(VARCHAR,DATEPART(MONTH, date_value)) AS month
             --,ROUND(AVG(CONVERT(FLOAT,oq.synthetic_percent)),1) AS hw_avg
             ,CASE
               WHEN oq.rt_name LIKE 'H%' AND ROUND(AVG(CONVERT(FLOAT,oq.synthetic_percent)),1) < 70.0 THEN 5
               WHEN oq.rt_name LIKE 'H%' AND ROUND(AVG(CONVERT(FLOAT,oq.synthetic_percent)),1) < 80.0 THEN 2 
               --WHEN oq.rt_name LIKE 'H%' AND ROUND(AVG(CONVERT(FLOAT,oq.synthetic_percent)),1) < 90.0 THEN 2
               --WHEN oq.rt_name LIKE 'Q%' AND ROUND(AVG(CONVERT(FLOAT,oq.synthetic_percent)),1) < 70.0 THEN 10
               --WHEN oq.rt_name LIKE 'Q%' AND ROUND(AVG(CONVERT(FLOAT,oq.synthetic_percent)),1) < 80.0 THEN 2                
               ELSE 0
              END AS hw_pts             
       FROM OPENQUERY(KIPP_NWK,'
         SELECT gr.studentid
               ,gr.date_value               
               ,gr.synthetic_percent
               ,gr.rt_name
         FROM students@PS_TEAM s
         JOIN grades$time_series_detail gr
           ON s.id = gr.studentid
          AND gr.rt_name LIKE ''H%''
          AND gr.date_value >= TO_DATE(''2014-08-01'', ''YYYY-MM-DD'')
          AND gr.synthetic_percent IS NOT NULL
         WHERE s.enroll_status = 0
           AND s.grade_level = 5
       ') oq       
       GROUP BY oq.studentid
               ,oq.rt_name               
               ,DATEPART(MONTH, date_value)
      ) sub
  
  PIVOT (
    MAX(hw_pts)
    FOR category IN ([H])
    --FOR category IN ([H],[Q])
   ) p
)

,hw_totals AS (
  SELECT studentid
        ,SUM(H) AS H
        --,SUM(Q) AS Q
  FROM hw_points
  GROUP BY studentid
 )

,disc_points AS ( 
  SELECT studentid
        ,week_number
        ,[Bench]
        ,[SL]
        ,[Detention]
        ,[HW Detention]
        ,[Paycheck]
  FROM      
      (
       SELECT studentid
             ,week_number
             ,subtype
             ,SUM(disc_points) AS disc_points
       FROM
           (
            SELECT log.studentid
                  ,DATEPART(WEEK,log.entry_date) AS week_number
                  ,CASE
                    WHEN log.subtype = 'Silent Lunch' THEN 'SL'
                    WHEN log.subtype = 'Bench / Choices' THEN 'Bench'
                    --WHEN log.subtype = 'Detention' AND log.discipline_details = 'Homework' THEN 'HW Detention'
                    ELSE log.subtype
                   END AS subtype
                  ,log.discipline_details
                  ,CASE
                    WHEN log.subtype = 'Bench / Choices' THEN 8
                    WHEN log.subtype = 'Silent Lunch' THEN 2
                    WHEN log.subtype = 'Detention' THEN 4
                    --WHEN log.subtype = 'Detention' AND log.discipline_details != 'Homework' THEN 4 
                    --WHEN log.subtype = 'Detention' AND log.discipline_details = 'Homework' THEN 8
                    WHEN log.subtype = 'Paycheck' AND log.discipline_details = 'Paycheck Below $90' THEN 2
                    WHEN log.subtype = 'Paycheck' AND log.discipline_details IN ('Paycheck Below $80','Paycheck Below $70') THEN 5
                    ELSE 0
                   END AS disc_points        
            FROM STUDENTS s WITH(NOLOCK)
            JOIN DISC$log#static log WITH(NOLOCK)
              ON s.ID = log.studentid
             AND log.entry_date >= CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-08-01')
            WHERE s.ENROLL_STATUS = 0
              AND s.SCHOOLID = 73252
              AND s.GRADE_LEVEL = 5  
           ) sub
       GROUP BY studentid, week_number, subtype
      ) sub

  PIVOT (
    MAX(disc_points)
    FOR subtype IN ([Bench]
                   ,[SL]
                   ,[Detention]
                   ,[HW Detention]
                   ,[Paycheck])
   ) p
)

SELECT s.LASTFIRST AS Name
      ,s.GRADE_LEVEL AS Gr
      ,s.team
      ,ROW_NUMBER() OVER(
          PARTITION BY s.studentid
              ORDER BY s.week_number) AS Week_Number
      ,CONVERT(VARCHAR,s.week_of) AS Week_of
      ,hw.H
      --,hw.Q
      ,ISNULL(disc.Bench,0) AS Bench
      ,ISNULL(disc.SL,0) AS Silent_Lunch
      ,ISNULL(disc.Detention,0) AS Detention
      --,ISNULL(disc.[HW Detention],0) AS HW_Detention
      ,ISNULL(disc.Paycheck,0) AS Paycheck
      ,ISNULL(hw.H,0)
        --+ ISNULL(hw.Q,0)
        + ISNULL(disc.Bench,0)
        + ISNULL(disc.SL,0)
        + ISNULL(disc.Detention,0)
        --+ ISNULL(disc.[HW Detention],0)
        + ISNULL(disc.Paycheck,0)
        AS TOTAL
FROM stu_cal_frame s
JOIN hw_points hw
  ON s.studentid = hw.studentid
 AND s.month = hw.month
LEFT OUTER JOIN disc_points disc
  ON s.studentid = disc.studentid
 AND s.week_number = disc.week_number

UNION ALL

SELECT s.LASTFIRST AS Name
      ,s.GRADE_LEVEL AS Gr
      ,s.team
      ,0 AS Week_Number
      ,'Total' AS Week_of
      ,hw.H AS H
      --,hw.Q AS Q
      ,SUM(ISNULL(disc.Bench,0)) AS Bench
      ,SUM(ISNULL(disc.SL,0)) AS Silent_Lunch
      ,SUM(ISNULL(disc.Detention,0)) AS Detention
      --,SUM(ISNULL(disc.[HW Detention],0)) AS HW_Detention
      ,SUM(ISNULL(disc.Paycheck,0)) AS Paycheck
      ,SUM(ISNULL(disc.Bench,0)
            + ISNULL(disc.SL,0)
            + ISNULL(disc.Detention,0)
            --+ ISNULL(disc.[HW Detention],0)
            + ISNULL(disc.Paycheck,0))
         + ISNULL(hw.H,0)
         --+ ISNULL(hw.Q,0)
         AS TOTAL
FROM stu_cal_frame s
LEFT OUTER JOIN hw_totals hw
  ON s.studentid = hw.studentid
LEFT OUTER JOIN disc_points disc
  ON s.studentid = disc.studentid
 AND s.week_number = disc.week_number
GROUP BY s.LASTFIRST
        ,s.GRADE_LEVEL
        ,s.TEAM
        ,hw.H
        --,hw.Q