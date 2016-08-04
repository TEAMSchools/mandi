USE KIPP_NJ
GO

--need manual changes for year

git ALTER VIEW COMPLIANCE$school_register_summary AS

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

,reenrollments AS (
	SELECT *
	FROM OPENQUERY(PS_TEAM,'
		SELECT studentid
				,schoolid
				,entrydate
				,exitdate
				,grade_level
				,lunchstatus
           
		FROM reenrollments
		WHERE entrydate >= ''2015-07-20'' 
			AND exitdate <= ''2016-07-01''
		')
)

--this is a dirty way to get most recent enrollment record for students who have 2+ enrollments

,lunch AS ( 
  SELECT r.*
        ,ROW_NUMBER() OVER(
	         PARTITION BY r.studentid
	           ORDER BY r.exitdate DESC) AS rownum
  FROM reenrollments r

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
      ,CASE WHEN co.ETHNICITY IS NULL THEN 'No Determination' ELSE co.ethnicity END AS ethnicity
	  ,CASE WHEN lunch.lunchstatus IS NULL THEN 'No Determination' ELSE lunch.lunchstatus END as lunchstatus
      ,co.SPEDLEP
      ,CASE WHEN co.LEP_STATUS IS NULL THEN 'No' ELSE 'Yes' END AS LEP_STATUS
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
 AND co.year = 2015
LEFT OUTER JOIN lunch
  ON co.studentid = lunch.studentid
  AND lunch.rownum = 1

