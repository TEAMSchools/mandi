USE KIPP_NJ
GO

--need manual change for year
--this is a dirty group by cube for key school register report data

CREATE VIEW COMPLIANCE$school_register_group_report AS

WITH report AS (

SELECT academic_year
	  ,region
	  ,grade_level
	  ,ethnicity
	  ,lunchstatus
	  ,SPEDLEP
	  ,LEP_status
	  ,SUM(N_days) AS NUM_DAYS_OPEN
	  ,SUM(N_mem) AS NUM_POSSIBLE_DAYS
	  ,SUM(N_att) AS NUM_DAYS_PRESENT
	  

FROM COMPLIANCE$school_register_summary WITH(NOLOCK)
WHERE academic_year = 2015


GROUP BY CUBE

(academic_year
	  ,region
	  ,ethnicity
	  ,grade_level
	  ,lunchstatus
	  ,SPEDLEP
	  ,LEP_status)

)

SELECT *

FROM report

WHERE academic_year IS NOT NULL
  AND region IS NOT NULL