USE NJ_DOE
GO

ALTER VIEW enr$bellwether AS
SELECT TOP 750000
--SELECT TOP 7500
       e.[YEAR]
      ,LEFT(e.year, 4) * 1 AS academic_year
      ,e.[COUNTY CODE] AS county_code
      ,e.[COUNTY NAME] AS county_name
      ,e.[DISTRICT CODE] AS district_code
      ,e.[DISTRICT NAME] AS district_name
      ,e.[SCHOOL CODE] AS school_code
      ,e.[SCHOOL NAME] AS school_name
      ,SUBSTRING(e.PRGCODE, PATINDEX('%[^0]%', e.PRGCODE+'.'), LEN(e.PRGCODE)) AS program_code
      ,CASE
         WHEN pc.presumptive_name = 'Pre-Kindergarten Full Day' THEN 'Preschool Full Day'
         WHEN pc.presumptive_name = 'Pre-Kindergarten Half Day' THEN 'Preschool Half Day'
         ELSE pc.presumptive_name
       END AS program_name
      ,e.[GRADE_LEVEL] AS grade_level
      ,e.[WH_M]
      ,e.[WH_F]
      ,e.[BL_M]
      ,e.[BL_F]
      ,e.[HI_M]
      ,e.[HI_F]
      ,e.[AS_M]
      ,e.[AS_F]
      ,e.[AM_M]
      ,e.[AM_F]
      ,e.[PI_M]
      ,e.[PI_F]
      ,e.[MU_M]
      ,e.[MU_F]
      ,e.[ROW_TOTAL]
      ,e.[FREE_LUNCH]
      ,e.[REDUCED_PRICE_LUNCH]
      ,e.[LEP]
      ,e.[MIGRANT]
      ,cc.City AS charter_city
      ,cc.[CITY DISTRICT CODE] AS city_district_code
FROM NJ_DOE..enr e
LEFT OUTER JOIN NJ_DOE..charter_city cc
  ON e.[DISTRICT CODE] = cc.[DISTRICT CODE]
LEFT OUTER JOIN NJ_DOE..program_codes pc
  ON SUBSTRING(e.PRGCODE, PATINDEX('%[^0]%', e.PRGCODE+'.'), LEN(e.PRGCODE)) = SUBSTRING(pc.code , PATINDEX('%[^0]%', pc.code +'.'), LEN(pc.code))
 AND LEFT(e.year, 4) * 1 = pc.academic_year
