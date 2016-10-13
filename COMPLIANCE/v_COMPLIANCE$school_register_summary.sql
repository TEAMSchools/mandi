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
      ,CASE WHEN co.schoolid LIKE '1799%' THEN 'KCNA' ELSE 'TEAM' END AS region      
      ,co.grade_level
      ,co.entrydate
      ,co.exitdate
      ,co.sped_code
      ,CASE
        /* EasyIEP data entry is extremely fucked up */
        WHEN co.year >= 2015 AND co.SID IN ('2935932793','2834021035','7465249910','7441242928','1505686831','2286460623','1844319947','9431566446','9622939214','7070945280',
                                            '8601749816','3997184815','1134359003','3218068691','2774078349','6823700895','5290877659','8117808635','4802612574','7997579648',
                                            '3373470235','4257180533','9509085255') THEN 'LLD Mild-to-Moderate'
        WHEN co.year >= 2015 AND co.SID IN ('7492522716','5465997966','3713085357','1194087026','1334559506','4478909595') THEN 'Autism'
        WHEN co.year >= 2015 AND co.SID IN ('1169223856','1240010558','2930172527','3583607990','6367109429','7287679809','4829668227','7229318281') THEN 'Cognitive-Mild'
        WHEN co.year >= 2015 AND co.SID IN ('2926827662','4549382509','4355868898','7583098257','6918087445','2209413438','7565129726','4767836482','4313714647','3726579821','1420437737','1617765966','4821629468','1648342943') THEN 'LLD Mild to Moderate'
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
JOIN schooldays d
  ON sub.academic_year = d.academic_year
 AND CASE WHEN co.schoolid LIKE '1799%' THEN 'KCNA' ELSE 'TEAM' END = d.region