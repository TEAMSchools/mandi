USE KIPP_NJ
GO

ALTER VIEW NAVIANCE$ccp_goals_tasks_long AS

SELECT *
      ,ROW_NUMBER() OVER(
         PARTITION BY student_id
           ORDER BY CONVERT(DATE,date) DESC) AS rn_recent
FROM KIPP_NJ..AUTOLOAD$GDOCS_KTC_ccp_goals_tasks WITH(NOLOCK)