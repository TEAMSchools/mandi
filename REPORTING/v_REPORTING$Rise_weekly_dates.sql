USE KIPP_NJ
GO

ALTER VIEW REPORTING$Rise_weekly_dates AS

SELECT date
      ,day_of_week      
FROM
    (
     SELECT date
           ,day_of_week
           ,date_order
           ,MAX(date_order) OVER() AS max_date_order
     FROM
         (
          SELECT *
                ,ROW_NUMBER() OVER(
                   ORDER BY date ASC) AS date_order
                ,ROW_NUMBER() OVER(
                   PARTITION BY day_of_week
                     ORDER BY date DESC) AS rn
          FROM
              (
               SELECT DISTINCT
                      date_value AS date
                     ,DATENAME(WEEKDAY,date_value) AS day_of_week                        
               FROM KIPP_NJ..PS$CALENDAR_DAY WITH(NOLOCK)
               WHERE SCHOOLID = 73252                 
                 AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()     
                 AND DATEPART(WEEKDAY,date_value) NOT IN (1,7)                
                 AND date_value < CASE 
                                     WHEN DATEPART(WEEKDAY,date_value) >= 5 THEN DATEADD(DAY, 4 - DATEPART(WEEKDAY,GETDATE()), CONVERT(DATE,GETDATE()))
                                     ELSE DATEADD(DAY, 5 - DATEPART(WEEKDAY,GETDATE()), CONVERT(DATE,GETDATE()))
                                    END
              ) sub
         ) sub
     WHERE rn = 1
    ) sub
WHERE max_date_order - date_order < 5 /* if there's a day off during the week, this will prevent earlier dates from filling in the gaps */