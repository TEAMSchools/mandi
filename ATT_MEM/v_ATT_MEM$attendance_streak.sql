USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$attendance_streak AS

WITH valid_dates AS (
  SELECT *
        ,ROW_NUMBER() OVER(
           PARTITION BY schoolid
             ORDER BY calendardate ASC) AS day_number
  FROM
      (
       SELECT DISTINCT 
              schoolid
             ,calendardate
             ,dbo.fn_DateToSY(calendardate) AS academic_year
       FROM MEMBERSHIP WITH(NOLOCK)
       WHERE dbo.fn_DateToSY(calendardate) = (dbo.fn_Global_Academic_Year() - 1)
      ) sub
 )

SELECT academic_year
      ,studentid
      ,att_code
      ,streak_grp
      ,CONVERT(DATE,MIN(CALENDARDATE)) AS streak_start
      ,CONVERT(DATE,MAX(CALENDARDATE)) AS streak_end
      ,DATEDIFF(DAY,MIN(CALENDARDATE),MAX(CALENDARDATE)) + 1 AS streak_length
FROM
    (
     SELECT co.year AS academic_year
           ,co.STUDENTID
           ,d.CALENDARDATE
           ,ISNULL(att.ATT_CODE, 'P') AS att_code
           ,d.day_number - ROW_NUMBER() OVER(
                             PARTITION BY co.year, co.studentid, att.att_code 
                               ORDER BY d.calendardate) 
             AS streak_grp
     FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
     JOIN valid_dates d WITH(NOLOCK)
       ON co.schoolid = d.SCHOOLID
      AND co.year = d.academic_year
     LEFT OUTER JOIN ATTENDANCE att WITH(NOLOCK)
       ON co.studentid = att.studentid
      AND d.CALENDARDATE = att.ATT_DATE     
     WHERE co.year >= (dbo.fn_Global_Academic_Year() - 1)
    ) sub
GROUP BY academic_year
        ,studentid
        ,att_code
        ,streak_grp