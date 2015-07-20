USE KIPP_NJ
GO

ALTER VIEW ROSTERS$kickboard_staff AS

SELECT COALESCE(
         LTRIM(RTRIM(CASE
                      WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) = 0 THEN NULL
                      WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, CHARINDEX(' ',adp.preferred_name) + 1, LEN(adp.preferred_name))
                      WHEN CHARINDEX(',',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, 1, CHARINDEX(',',adp.preferred_name) - 1)
                     END))
        ,adp.[last_name]) AS [Last Name]
      ,COALESCE(
         LTRIM(RTRIM(CASE
                      WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) = 0 THEN SUBSTRING(adp.preferred_name, 1, LEN(adp.preferred_name))
                      WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, 1, CHARINDEX(' ',adp.preferred_name))
                      WHEN CHARINDEX(',',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, CHARINDEX(',',adp.preferred_name) + 1, LEN(adp.preferred_name))
                     END)) 
        ,adp.[first_name]) AS [First Name]            
      ,'Teacher' AS [Role ID]
      ,NULL AS [Courses (required if using Academics)]
      ,COALESCE(dir.mail, LOWER(LEFT(adp.first_name,1) + KIPP_NJ.dbo.REMOVESPECIALCHARS(adp.last_name)) + '@kippnj.org') AS [Email]
      ,adp.associate_id AS [External ID (optional)]
      ,location
FROM KIPP_NJ..PEOPLE$ADP_detail adp WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PEOPLE$AD_users#static dir WITH(NOLOCK)
  ON adp.position_id = dir.employeenumber
WHERE adp.position_status = 'Active'
  AND (adp.location_code IN (1,16) OR adp.associate_id = '6SKN03G3K')
  AND rn_curr = 1