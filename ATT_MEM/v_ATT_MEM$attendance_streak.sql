USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$attendance_streak AS

WITH valid_dates AS (
  SELECT schoolid
        ,CONVERT(DATE,date_value) AS date_value
        ,academic_year
        ,ROW_NUMBER() OVER(
      PARTITION BY schoolid, academic_year
        ORDER BY CONVERT(DATE,date_value) ASC) AS day_number
  FROM KIPP_NJ..PS$CALENDAR_DAY WITH(NOLOCK)
  WHERE membershipvalue = 1
    AND insession = 1
 )

SELECT academic_year
      ,studentid
      ,schoolid
      ,grade_level      
      ,att_code
      ,streak_id
      ,CONVERT(DATE,MIN(date_value)) AS streak_start
      ,CONVERT(DATE,MAX(date_value)) AS streak_end
      ,DATEDIFF(DAY,MIN(date_value),MAX(date_value)) + 1 AS streak_length
      ,COUNT(date_value) AS streak_length_membership
FROM
    (
     SELECT co.year AS academic_year
           ,co.STUDENTID
           ,co.schoolid
           ,co.grade_level
           ,d.date_value
           ,ISNULL(att.ATT_CODE, 'P') AS att_code
           ,d.day_number
           ,CONCAT(co.STUDENTID, '_'
                  ,co.year, '_'
                  ,ISNULL(att.ATT_CODE, 'P')
                  ,d.day_number - ROW_NUMBER() OVER(PARTITION BY co.year, co.studentid, att.att_code ORDER BY d.date_value)
                  ) AS streak_id
     FROM COHORT$identifiers_long#static co WITH(NOLOCK)
     JOIN valid_dates d WITH(NOLOCK)
       ON co.schoolid = d.SCHOOLID
      AND co.year = d.academic_year
     LEFT OUTER JOIN ATT_MEM$ATTENDANCE att WITH(NOLOCK)
       ON co.studentid = att.studentid
      AND d.date_value = att.ATT_DATE          
    ) sub
GROUP BY academic_year
        ,studentid
        ,schoolid
        ,att_code
        ,streak_id
        ,grade_level