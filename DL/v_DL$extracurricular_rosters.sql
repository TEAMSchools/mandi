USE KIPP_NJ
GO

ALTER VIEW DL$extracurricular_rosters AS

SELECT ra.studentschoolid AS student_number
      ,ra.rostername
      ,r.rostertype
FROM KIPP_NJ..AUTOLOAD$DL_rosters_all r WITH(NOLOCK)
JOIN KIPP_NJ..AUTOLOAD$DL_roster_assignments ra WITH(NOLOCK)
  ON r.rosterid = ra.dlrosterid
WHERE r.rostertype IN ('Club','Athletics')