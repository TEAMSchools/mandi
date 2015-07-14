USE KIPP_NJ
GO

ALTER VIEW ROSTERS$KIPPShare_Staff AS

WITH enrollments AS (
  SELECT TEACHERNUMBER
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT credittype, ', ') AS subjects_taught
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT grade_level, ', ') AS grades_taught
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  WHERE enr.academic_year = 2014
    AND enr.CREDITTYPE NOT IN ('COCUR','LOG','STUDY')
    AND grade_level != 99
  GROUP BY TEACHERNUMBER
 )
 
SELECT adp.associate_id
      ,adp.position_id
      ,ps.teachernumber
      ,COALESCE(
         LTRIM(RTRIM(CASE
                      WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) = 0 THEN SUBSTRING(adp.preferred_name, 1, LEN(adp.preferred_name))
                      WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, 1, CHARINDEX(' ',adp.preferred_name))
                      WHEN CHARINDEX(',',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, CHARINDEX(',',adp.preferred_name) + 1, LEN(adp.preferred_name))
                     END)) 
        ,adp.[first_name]) AS first_name
      ,COALESCE(
         LTRIM(RTRIM(CASE
                      WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) = 0 THEN NULL
                      WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, CHARINDEX(' ',adp.preferred_name) + 1, LEN(adp.preferred_name))
                      WHEN CHARINDEX(',',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, 1, CHARINDEX(',',adp.preferred_name) - 1)
                     END))
        ,adp.[last_name]) AS last_name
      ,location
      ,job_title
      ,dir.mail AS email_addr      
      ,enr.grades_taught
      ,enr.subjects_taught
      ,CASE
        WHEN position_status = 'Terminated' THEN 'DELETE'
        WHEN position_start_date >= '2014-08-01' THEN 'ADD'
        ELSE 'UPDATE'
       END AS staff_status      
FROM KIPP_NJ..PEOPLE$ADP_detail adp WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PEOPLE$AD_users#static dir WITH(NOLOCK)
  ON adp.position_id = dir.employeenumber
LEFT OUTER JOIN PEOPLE$ADP_PS_linking ps WITH(NOLOCK)
  ON adp.associate_id = ps.associate_id
 AND ps.is_master = 1
LEFT OUTER JOIN enrollments enr WITH(NOLOCK)
  ON ps.TEACHERNUMBER = enr.teachernumber
WHERE rn_curr = 1