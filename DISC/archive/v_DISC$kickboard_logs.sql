USE KIPP_NJ
GO

ALTER VIEW DISC$kickboard_logs AS 

SELECT co.schoolid
      ,co.studentid
      --,bhv.external_id AS student_number
      ,CONCAT(bhv.staff_last_name, ', ', bhv.staff_first_name) AS entry_author
      ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,bhv.date)) AS academic_year
      ,CONVERT(DATE,bhv.date) AS entry_date      
      ,bhv.category AS logtype
      ,bhv.behavior AS subtype
      ,bhv.comments AS subject      
      ,bhv.dollar_points AS point_value
      ,bhv.daily_activity_group_name AS period
FROM KIPP_NJ..AUTOLOAD$KICKBOARD_behavior bhv WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON bhv.external_id = co.student_number
 AND co.year = KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,bhv.date))
 AND co.rn = 1