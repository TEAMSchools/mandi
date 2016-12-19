USE KIPP_NJ
GO

ALTER VIEW TABLEAU$incident_tracker AS

WITH dlrosters AS (
  SELECT studentschoolid
        ,rostername
  FROM KIPP_NJ..AUTOLOAD$DL_roster_assignments WITH(NOLOCK)
  WHERE dlrosterid = 43532 /* Comeback Scholars (1) */
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.year
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor
      ,co.SPEDLEP
      ,co.GENDER
      ,co.ETHNICITY
      ,r.rostername AS dl_rostername
      ,dli.incidentid AS dl_id
      ,dli.createtsdate AS dl_timestamp
      ,dli.createfirst + ' ' + dli.createlast AS referring_teacher_name
      ,dli.updatefirst + ' ' + dli.updatelast AS reviewed_by
      ,dli.status
      ,'Referral' AS dl_category
      ,ISNULL(dli.category,'Referral') AS dl_behavior
      ,dli.reporteddetails AS notes
      ,d.alt_name AS term
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN dlrosters r
  ON co.student_number = r.studentschoolid
JOIN KIPP_NJ..AUTOLOAD$DL_incidents dli WITH(NOLOCK)
  ON co.student_number = dli.studentschoolid
JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
  ON co.schoolid = d.schoolid
 AND CONVERT(DATE,dli.createtsdate) BETWEEN d.start_date AND d.end_date 
 AND d.identifier = 'RT'
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.schoolid != 999999
  AND co.rn = 1

UNION ALL

SELECT co.student_number
      ,co.lastfirst
      ,co.year
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor
      ,co.SPEDLEP
      ,co.GENDER
      ,co.ETHNICITY
      ,r.rostername AS dl_rostername
      ,dlip.incidentpenaltyid AS dl_id
      ,ISNULL(dlip.startdate, dli.closetsdate) AS dl_timestamp
      ,dli.createfirst + ' ' + dli.createlast AS referring_teacher_name
      ,dli.updatefirst + ' ' + dli.updatelast AS reviewed_by
      ,dli.status
      ,'Consequence' AS dl_category
      ,dlip.penaltyname AS dl_behavior
      ,dli.adminsummary AS notes
      ,d.alt_name AS term
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN dlrosters r
  ON co.student_number = r.studentschoolid
JOIN KIPP_NJ..AUTOLOAD$DL_incidents dli WITH(NOLOCK)
  ON co.student_number = dli.studentschoolid
JOIN KIPP_NJ..AUTOLOAD$DL_incidents_Penalties dlip WITH(NOLOCK)
  ON dli.incidentid = dlip.incidentid
JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
  ON co.schoolid = d.schoolid
 AND CONVERT(DATE,ISNULL(dlip.startdate, dli.closetsdate)) BETWEEN d.start_date AND d.end_date 
 AND d.identifier = 'RT'
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.schoolid != 999999
  AND co.rn = 1

UNION ALL

SELECT co.student_number
      ,co.lastfirst
      ,co.year
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor
      ,co.SPEDLEP
      ,co.GENDER
      ,co.ETHNICITY
      ,r.rostername AS dl_rostername      
      ,dlb.dlsaid AS dl_id
      ,dlb.dl_lastupdate AS dl_timestamp
      ,dlb.stafffirstname + ' ' + dlb.stafflastname AS referring_teacher_name
      ,NULL AS reviewed_by
      ,NULL AS status
      ,dlb.behaviorcategory AS dl_category
      ,dlb.behavior AS dl_behavior
      ,NULL AS notes
      ,d.alt_name AS term
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN dlrosters r
  ON co.student_number = r.studentschoolid
JOIN KIPP_NJ..DL$behavior dlb WITH(NOLOCK)
  ON co.student_number = dlb.studentschoolid
JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
  ON co.schoolid = d.schoolid
 AND CONVERT(DATE,dlb.dl_lastupdate) BETWEEN d.start_date AND d.end_date 
 AND d.identifier = 'RT'
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.schoolid != 999999
  AND co.rn = 1