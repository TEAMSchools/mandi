USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$school_register_summary AS

WITH schooldays AS (
  SELECT academic_year
        ,region
        ,MIN(n_days) AS N_days
  FROM
      (
       SELECT academic_year
             ,schoolid
             ,CASE WHEN schoolid LIKE '1799%' THEN 'KCNA' ELSE 'TEAM' END AS region
             ,SUM(membershipvalue) AS N_days
       FROM KIPP_NJ..PS$calendar_day WITH(NOLOCK)
       WHERE CONVERT(DATE,date_value) <= CONVERT(DATE,GETDATE())
         AND schoolid != 12345 /* exclude summer school */
       GROUP BY academic_year
               ,schoolid
      ) sub
  GROUP BY academic_year, region
 )

,att_mem AS (
  SELECT STUDENTID
        ,academic_year        
        ,SUM(CONVERT(INT,ATTENDANCEVALUE)) AS N_att
        ,SUM(CONVERT(INT,MEMBERSHIPVALUE)) AS N_mem
  FROM KIPP_NJ..ATT_MEM$MEMBERSHIP WITH(NOLOCK)
  WHERE MEMBERSHIPVALUE = 1
  GROUP BY STUDENTID
          ,academic_year          
 )

SELECT sub.academic_year      
      ,co.student_number
      ,co.SID
      ,co.lastfirst
      ,co.schoolid
      ,co.reporting_schoolid
      ,CASE WHEN co.schoolid LIKE '1799%' THEN 'KCNA' ELSE 'TEAM' END AS region      
      ,co.grade_level
      ,co.entrydate
      ,co.exitdate
      ,co.sped_code
      ,CASE
        WHEN cs.programtypecode IS NOT NULL THEN CONVERT(VARCHAR,cs.programtypecode)
        WHEN co.grade_level = 0 THEN 'K'
        ELSE CONVERT(VARCHAR,co.grade_level)
       END AS report_grade_level      
      ,co.ethnicity
      ,ISNULL(co.ETHNICITY,'B') AS race_status
	     ,co.lunchstatus
      ,CASE
        WHEN co.lunchstatus IN ('F','R') THEN 'Low Income'
        WHEN co.lunchstatus = 'P' THEN 'Not Low Income'
        WHEN co.lunchstatus IS NULL THEN 'Not Low Income'
       END AS low_income_status
      ,co.spedlep AS sped
      ,CASE
        WHEN co.SPEDLEP LIKE '%SPED%' THEN 'IEP'
        ELSE 'Not IEP'
       END AS IEP_status
      ,co.lep_status AS lep
      ,CASE 
        WHEN co.LEP_STATUS = 1 THEN 'LEP' 
        WHEN co.LEP_STATUS IS NULL THEN 'Not LEP'        
       END AS LEP_status
      ,d.N_days AS N_days_open
      ,CASE WHEN sub.N_mem > d.N_days THEN d.N_days ELSE sub.N_mem END AS N_days_possible
      ,CASE WHEN sub.N_att > d.N_days THEN d.N_days ELSE sub.N_att END AS N_days_present 
FROM att_mem sub
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON sub.studentid = co.studentid
 AND sub.academic_year = co.year
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_custom#static cs
  ON co.studentid = cs.studentid
JOIN schooldays d
  ON sub.academic_year = d.academic_year
 AND CASE WHEN co.schoolid LIKE '1799%' THEN 'KCNA' ELSE 'TEAM' END = d.region