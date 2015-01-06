USE KIPP_NJ
GO

ALTER VIEW PS$RTI_tiers AS 

SELECT studentid      
      ,RTI_TIER_BHV AS behavior_tier
      ,SUBSTRING(RTI_TIER_BHV,CHARINDEX(' ',RTI_TIER_BHV) + 1,1) AS behavior_tier_numeric
      ,CASE WHEN field = 'RTI_TIER_WL' THEN 'WLANG' ELSE REVERSE(LEFT(REVERSE(field), CHARINDEX('_', REVERSE(field)) - 1)) END AS credittype
      ,tier
      ,SUBSTRING(tier,CHARINDEX(' ',tier) + 1,1) AS tier_numeric
FROM OPENQUERY(PS_TEAM,'
  SELECT s.id AS studentid
        ,x.RTI_TIER_ENG
        ,x.RTI_TIER_MATH
        ,x.RTI_TIER_RHET
        ,x.RTI_TIER_SCI
        ,x.RTI_TIER_SOC
        ,x.RTI_TIER_WL
        ,x.RTI_TIER_BHV
  FROM U_DEF_EXT_STUDENTS x
  JOIN STUDENTS s
    ON x.studentsdcid = s.dcid
   AND s.schoolid = 73253
')
UNPIVOT(
  tier
  FOR field IN (RTI_TIER_ENG
               ,RTI_TIER_MATH
               ,RTI_TIER_RHET
               ,RTI_TIER_SCI
               ,RTI_TIER_SOC
               ,RTI_TIER_WL)
 ) u