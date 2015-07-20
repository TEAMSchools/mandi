USE KIPP_NJ
GO

ALTER VIEW ROSTERS$kickboard_students AS

SELECT first_name AS [First Name]
      ,last_name AS [Last Name]
      ,grade_level AS [Grade]
      ,NULL AS [Group Name (optional)] -- wait until we have rosters in
      ,HOME_PHONE AS [Phone (optional)]
      ,student_number AS [External ID (optional)]
      ,schoolid
FROM COHORT$identifiers_long#static co WITH(NOLOCK)
WHERE co.schoolid IN (133570965, 179902) -- TEAM & LSM
  AND co.year = 2015
  AND co.rn = 1
  AND co.exitdate > co.entrydate
