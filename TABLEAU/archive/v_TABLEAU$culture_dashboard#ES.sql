USE KIPP_NJ
GO

ALTER VIEW TABLEAU$culture_dashboard#ES AS

SELECT co.year
      ,co.schoolid
      ,CONVERT(DATE,dt.att_date) AS att_date
      ,co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,co.spedlep      
      ,co.gender      
      ,co.enroll_status
      --
      ,dt.term
      ,dt.week_num
      ,dt.has_hw AS hw
      ,dt.has_uniform AS uniform
      ,dt.bz_color_changed
      ,dt.color_day AS color
      ,'Day' AS color_time
      ,CASE WHEN dt.color_day = 'Purple' THEN 1 ELSE 0 END AS purple      
      ,CASE WHEN dt.color_day = 'Pink' THEN 1 ELSE 0 END AS pink
      ,CASE WHEN dt.color_day = 'Green' THEN 1 ELSE 0 END AS green
      ,CASE WHEN dt.color_day = 'Yellow' THEN 1 ELSE 0 END AS yellow
      ,CASE WHEN dt.color_day = 'Orange' THEN 1 ELSE 0 END AS orange
      ,CASE WHEN dt.color_day = 'Red' THEN 1 ELSE 0 END AS red
      ,CASE WHEN dt.color_day IS NULL THEN 1 ELSE 0 END AS no_color      
      ,supp.behavior_tier
      ,supp.plan_owner
      ,supp.admin_support
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK) 
LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_long#ES#static dt WITH(NOLOCK)
  ON co.studentid = dt.studentid
 AND co.year = dt.academic_year
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_SUPPORT_Master_List supp WITH(NOLOCK)
  ON co.student_number = supp.SN
 AND co.year = supp.academic_year
WHERE co.SCHOOLID NOT IN (73255, 179901)
  AND co.grade_level <= 4
  AND co.enroll_status = 0
  AND co.rn = 1

UNION ALL

--THRIVE/LSP AM  
SELECT co.year
      ,co.schoolid
      ,CONVERT(DATE,dt.att_date) AS att_date
      ,co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,co.spedlep      
      ,co.gender      
      ,co.enroll_status      
      --
      ,dt.term
      ,dt.week_num
      ,dt.has_hw AS hw
      ,dt.has_uniform AS uniform
      ,dt.bz_color_changed
      ,dt.color_am AS color
      ,'AM' AS color_time
      ,CASE WHEN dt.color_am = 'Purple' THEN 1 ELSE 0 END AS purple
      ,CASE WHEN dt.color_am = 'Pink' THEN 1 ELSE 0 END AS pink
      ,CASE WHEN dt.color_am = 'Green' THEN 1 ELSE 0 END AS green
      ,CASE WHEN dt.color_am = 'Yellow' THEN 1 ELSE 0 END AS yellow
      ,CASE WHEN dt.color_am = 'Orange' THEN 1 ELSE 0 END AS orange
      ,CASE WHEN dt.color_am = 'Red' THEN 1 ELSE 0 END AS red
      ,CASE WHEN dt.color_am IS NULL THEN 1 ELSE 0 END AS no_color            
      ,supp.behavior_tier
      ,supp.plan_owner
      ,supp.admin_support
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK) 
LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_long#ES#static dt WITH(NOLOCK)
  ON co.studentid = dt.studentid
 AND co.year = dt.academic_year
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_SUPPORT_Master_List supp WITH(NOLOCK)
  ON co.student_number = supp.SN
 AND co.year = supp.academic_year
WHERE co.SCHOOLID IN (73255, 179901)
  AND co.grade_level <= 4
  AND co.enroll_status = 0
  AND co.rn = 1
        
UNION ALL

--THRIVE Mid
SELECT co.year
      ,co.schoolid
      ,CONVERT(DATE,dt.att_date) AS att_date
      ,co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,co.spedlep      
      ,co.gender      
      ,co.enroll_status  
      --
      ,dt.term
      ,dt.week_num
      ,dt.has_hw AS hw
      ,dt.has_uniform AS uniform
      ,dt.bz_color_changed
      ,dt.color_mid AS color
      ,'Mid' AS color_time
      ,CASE WHEN dt.color_mid = 'Purple' THEN 1 ELSE 0 END AS purple
      ,CASE WHEN dt.color_mid = 'Pink' THEN 1 ELSE 0 END AS pink
      ,CASE WHEN dt.color_mid = 'Green' THEN 1 ELSE 0 END AS green
      ,CASE WHEN dt.color_mid = 'Yellow' THEN 1 ELSE 0 END AS yellow
      ,CASE WHEN dt.color_mid = 'Orange' THEN 1 ELSE 0 END AS orange
      ,CASE WHEN dt.color_mid = 'Red' THEN 1 ELSE 0 END AS red
      ,CASE WHEN dt.color_mid IS NULL THEN 1 ELSE 0 END AS no_color      
      ,supp.behavior_tier
      ,supp.plan_owner
      ,supp.admin_support
FROM COHORT$identifiers_long#static co WITH(NOLOCK) 
LEFT OUTER JOIN DAILY$tracking_long#ES#static dt WITH(NOLOCK)
  ON co.studentid = dt.studentid
 AND co.year = dt.academic_year 
LEFT OUTER JOIN AUTOLOAD$GDOCS_SUPPORT_Master_List supp WITH(NOLOCK)
  ON co.student_number = supp.SN
WHERE (co.SCHOOLID IN (73255) AND co.grade_level <= 2)  
  AND co.enroll_status = 0
  AND co.rn = 1  
        
UNION ALL

--THRIVE/LSP PM
SELECT co.year
      ,co.schoolid
      ,CONVERT(DATE,dt.att_date) AS att_date
      ,co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,co.spedlep      
      ,co.gender      
      ,co.enroll_status 
      --
      ,dt.term
      ,dt.week_num
      ,dt.has_hw AS hw
      ,dt.has_uniform AS uniform
      ,dt.bz_color_changed
      ,dt.color_pm AS color
      ,'PM' AS color_time
      ,CASE WHEN dt.color_pm = 'Purple' THEN 1 ELSE 0 END AS purple
      ,CASE WHEN dt.color_pm = 'Pink' THEN 1 ELSE 0 END AS pink
      ,CASE WHEN dt.color_pm = 'Green' THEN 1 ELSE 0 END AS green
      ,CASE WHEN dt.color_pm = 'Yellow' THEN 1 ELSE 0 END AS yellow
      ,CASE WHEN dt.color_pm = 'Orange' THEN 1 ELSE 0 END AS orange
      ,CASE WHEN dt.color_pm = 'Red' THEN 1 ELSE 0 END AS red
      ,CASE WHEN dt.color_pm IS NULL THEN 1 ELSE 0 END AS no_color              
      ,supp.behavior_tier
      ,supp.plan_owner
      ,supp.admin_support
FROM COHORT$identifiers_long#static co WITH(NOLOCK) 
LEFT OUTER JOIN DAILY$tracking_long#ES#static dt WITH(NOLOCK)
  ON co.studentid = dt.studentid
 AND co.year = dt.academic_year 
LEFT OUTER JOIN AUTOLOAD$GDOCS_SUPPORT_Master_List supp WITH(NOLOCK)
  ON co.student_number = supp.SN
 AND co.year = supp.academic_year
WHERE co.SCHOOLID IN (73255, 179901)
  AND co.grade_level <= 4
  AND co.enroll_status = 0
  AND co.rn = 1 