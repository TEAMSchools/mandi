USE KIPP_NJ
GO

ALTER VIEW REPORTING$trip_tracker#Rise AS

WITH stu_cal_frame AS (
  SELECT co.studentid
        ,co.student_number
        ,co.lastfirst
        ,co.grade_level
        ,co.team
        ,co.date
        ,DATEPART(WEEK,co.date) AS week_number
        ,DATEPART(MONTH,co.date) AS month        
        ,DATEPART(WEEKDAY,co.date) AS day_of_week
  FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)
  WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND co.schoolid = 73252
    AND co.grade_level = 5
    AND co.enroll_status = 0
    AND DATEPART(WEEKDAY,co.date) = 1
    AND co.date <= CONVERT(DATE,GETDATE())
    AND co.date >= '2015-02-22'
 )

,hw_points AS (
  SELECT student_number
        ,month        
        ,ISNULL([H],0) AS [H]
        --,ISNULL([Q],0) AS [Q]
  FROM
      (
       SELECT sub.student_number
             ,sub.category
             ,sub.month             
             ,CASE
               WHEN sub.category = 'H' AND ROUND(AVG(CONVERT(FLOAT,sub.moving_average)), 1) < 70.0 THEN 5
               WHEN sub.category = 'H' AND ROUND(AVG(CONVERT(FLOAT,sub.moving_average)), 1) < 80.0 THEN 2                
               ELSE 0
              END AS hw_pts             
       FROM 
           (
            SELECT gr.student_number                  
                  ,s.month          
                  ,LEFT(gr.finalgradename, 1) AS category
                  ,gr.moving_average
                  ,gr.finalgradename
            FROM stu_cal_frame s WITH(NOLOCK)
            LEFT OUTER JOIN KIPP_NJ..GRADES$time_series#STAGING gr WITH(NOLOCK)
              ON s.student_number = gr.student_number
             AND s.date = gr.date
             AND gr.finalgradename LIKE 'H%'
             AND gr.moving_average IS NOT NULL            
           ) sub       
       GROUP BY sub.student_number
               ,sub.category               
               ,sub.month
      ) sub  
  PIVOT (
    MAX(hw_pts)
    FOR category IN ([H])
    --FOR category IN ([H],[Q])
   ) p
 )

,hw_totals AS (
  SELECT student_number
        ,SUM(H) AS H
        --,SUM(Q) AS Q
  FROM hw_points WITH(NOLOCK)
  GROUP BY student_number
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
            FROM DISC$log#static log WITH(NOLOCK)   
            WHERE log.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()         
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
      ,CONVERT(VARCHAR,s.date) AS Week_of
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
FROM stu_cal_frame s WITH(NOLOCK)
JOIN hw_points hw WITH(NOLOCK)
  ON s.student_number = hw.student_number
 AND s.month = hw.month
LEFT OUTER JOIN disc_points disc WITH(NOLOCK)
  ON s.studentid = disc.studentid
 AND s.week_number = disc.week_number
WHERE s.day_of_week = 1

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
FROM stu_cal_frame s WITH(NOLOCK)
LEFT OUTER JOIN hw_totals hw WITH(NOLOCK)
  ON s.student_number = hw.student_number
LEFT OUTER JOIN disc_points disc WITH(NOLOCK)
  ON s.studentid = disc.studentid
 AND s.week_number = disc.week_number
WHERE s.day_of_week = 1
GROUP BY s.LASTFIRST
        ,s.GRADE_LEVEL
        ,s.TEAM
        ,hw.H
        --,hw.Q