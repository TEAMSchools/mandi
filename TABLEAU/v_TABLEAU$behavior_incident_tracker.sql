USE KIPP_NJ
GO

ALTER VIEW TABLEAU$behavior_incident_tracker AS

SELECT co.student_number
      ,co.lastfirst
      ,co.year
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor
      ,co.SPEDLEP
            
      ,dli.category
      ,CONVERT(DATE,dli.createtsdate) AS incident_createdate
      ,CONVERT(DATE,dli.issuetsdate) AS incident_issuedate

      ,dli.createby
      ,LTRIM(RTRIM(CONCAT(dli.createlast, ', ', dli.createfirst))) AS create_lastfirst
      ,dli.infraction
      ,dli.isreferral      
      ,dli.location      
      ,dli.returnperiod     
      ,dli.status      

      ,dlip.penaltyname
      ,CONVERT(DATE,dlip.startdate) AS penalty_startdate
      ,CONVERT(DATE,dlip.enddate) AS penalty_enddate
      ,dlip.numdays
      ,dlip.numperiods
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..AUTOLOAD$DL_incidents dli WITH(NOLOCK)
  ON co.student_number = dli.studentschoolid
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$DL_incidents_Penalties dlip WITH(NOLOCK)
  ON dli.incidentid = dlip.incidentid
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.schoolid != 999999
  AND co.rn = 1

--UNION ALL

--SELECT co.student_number
--      ,co.lastfirst
--      ,co.year
--      ,co.reporting_schoolid
--      ,co.grade_level
--      ,co.team
--      ,co.advisor
--      ,co.SPEDLEP
            
--      ,dli.category
--      ,CONVERT(DATE,dli.createtsdate) AS incident_createdate
--      ,CONVERT(DATE,dli.issuetsdate) AS incident_issuedate

--      ,dli.createby
--      ,LTRIM(RTRIM(CONCAT(dli.createlast, ', ', dli.createfirst))) AS create_lastfirst
--      ,dli.infraction
--      ,dli.isreferral      
--      ,dli.location      
--      ,dli.returnperiod     
--      ,dli.status      

--      ,dlia.actionname
--      ,NULL AS penalty_startdate
--      ,NULL AS penalty_enddate
--      ,NULL AS numdays
--      ,NULL AS numperiods
--FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
--JOIN KIPP_NJ..AUTOLOAD$DL_incidents dli WITH(NOLOCK)
--  ON co.student_number = dli.studentschoolid
--LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$DL_incidents_Actions dlia WITH(NOLOCK)
--  ON dli.incidentid = dlia.sourceid
--WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
--  AND co.schoolid != 999999
--  AND co.rn = 1