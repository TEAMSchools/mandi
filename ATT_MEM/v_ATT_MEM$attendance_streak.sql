USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$attendance_streak AS

WITH valid_dates AS (
  SELECT schoolid
        ,calendardate
        ,academic_year
        ,ROW_NUMBER() OVER(
           PARTITION BY schoolid
             ORDER BY calendardate ASC) AS day_number
  FROM
      (
       SELECT DISTINCT 
              schoolid
             ,CONVERT(DATE,calendardate) AS calendardate
             ,academic_year
       FROM KIPP_NJ..ATT_MEM$MEMBERSHIP WITH(NOLOCK)       
      ) sub
 )

SELECT academic_year
      ,schoolid
      ,studentid
      ,att_code
      ,streak_id
      ,CONVERT(DATE,MIN(CALENDARDATE)) AS streak_start
      ,CONVERT(DATE,MAX(CALENDARDATE)) AS streak_end
      ,DATEDIFF(DAY,MIN(CALENDARDATE),MAX(CALENDARDATE)) + 1 AS streak_length
      ,COUNT(CALENDARDATE) AS streak_length_membership
FROM
    (
     SELECT co.year AS academic_year
           ,co.STUDENTID
           ,co.schoolid
           ,d.CALENDARDATE
           ,ISNULL(att.ATT_CODE, 'P') AS att_code
           ,d.day_number - ROW_NUMBER() OVER(
                             PARTITION BY co.year, co.studentid, att.att_code 
                               ORDER BY d.calendardate) 
             AS streak_id
     FROM COHORT$identifiers_long#static co WITH(NOLOCK)
     JOIN valid_dates d WITH(NOLOCK)
       ON co.schoolid = d.SCHOOLID
      AND co.year = d.academic_year
     LEFT OUTER JOIN ATT_MEM$ATTENDANCE att WITH(NOLOCK)
       ON co.studentid = att.studentid
      AND d.CALENDARDATE = att.ATT_DATE          
    ) sub
GROUP BY academic_year
        ,studentid
        ,schoolid
        ,att_code
        ,streak_id