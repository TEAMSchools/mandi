USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$behavior_reporting_long#Seek AS
SELECT rn
      ,att_date
      ,student_number
      ,studentid
      ,lastfirst
      ,grade_level
      ,team
      ,hw
      ,color_day
      ,CAST(student_number AS VARCHAR(20)) + '_' + CAST(att_date AS VARCHAR(20)) AS hash
FROM ES_DAILY$daily_tracking_long#static WITH (NOLOCK)
WHERE SCHOOLID = 73256 --Seek only
  AND att_date >= '04-Sep-13'
  AND att_date <= '22-Nov-13'