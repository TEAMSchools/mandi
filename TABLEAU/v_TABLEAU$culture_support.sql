USE KIPP_NJ
GO

ALTER VIEW TABLEAU$culture_support AS

SELECT r.SN AS student_number
      ,co.school_name
      ,co.grade_level
      ,co.team
      ,co.SPEDLEP
      ,r.[Behavior Tier] AS behavior_tier
      ,r.[Plan Owner] AS plan_owner
      ,REPLACE(r.[Admin Support],'’','''') AS admin_support
      ,supp.Week AS week_num
      ,supp.Status AS week_status
FROM [AUTOLOAD$GDOCS_SUPPORT_Master_List] r WITH(NOLOCK)
JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
  ON r.SN = co.student_number
 AND co.year = dbo.fn_Global_Academic_Year()
 AND co.rn = 1
LEFT OUTER JOIN [AUTOLOAD$GDOCS_SUPPORT_Data_Entry] supp WITH(NOLOCK)
  ON r.SN = supp.SN
WHERE r.[Behavior Tier ] IS NOT NULL