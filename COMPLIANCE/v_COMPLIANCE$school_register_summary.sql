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
       GROUP BY academic_year
               ,schoolid
      ) sub
  GROUP BY academic_year, region
 )

,att_mem AS (
  SELECT STUDENTID
        ,academic_year
        ,SCHOOLID
        ,CASE WHEN SCHOOLID LIKE '1799%' THEN 'KCNA' ELSE 'TEAM' END AS region
        ,SUM(CONVERT(INT,ATTENDANCEVALUE)) AS N_att
        ,SUM(CONVERT(INT,MEMBERSHIPVALUE)) AS N_mem
  FROM KIPP_NJ..ATT_MEM$MEMBERSHIP WITH(NOLOCK)
  GROUP BY STUDENTID
          ,academic_year
          ,SCHOOLID     
 )

SELECT sub.academic_year
      ,sub.studentid
      ,co.SID
      ,co.lastfirst
      ,sub.region
      ,sub.SCHOOLID
      ,co.grade_level
      ,co.entrydate
      ,co.exitdate
      ,co.ETHNICITY
      ,co.lunchstatus
      ,co.SPEDLEP
      ,co.LEP_STATUS
      ,CASE WHEN sub.N_mem > d.N_days THEN d.N_days ELSE sub.N_mem END AS N_mem
      ,CASE WHEN sub.N_att > d.N_days THEN d.N_days ELSE sub.N_att END AS N_att      
      ,d.N_days
FROM att_mem sub
JOIN schooldays d
  ON sub.academic_year = d.academic_year
 AND sub.region = d.region
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON sub.studentid = co.studentid
 AND sub.academic_year = co.year
 AND co.rn = 1