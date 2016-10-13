USE KIPP_NJ
GO

ALTER VIEW QA$NJSMART_SID_audit AS

WITH NJSMART AS (
  SELECT stateidentificationnumber
        ,field AS NJSMART_field
        ,value AS NJSMART_value
  FROM
      (
       SELECT stateidentificationnumber             
             ,CONVERT(NVARCHAR(MAX),localidentificationnumber) AS localidentificationnumber
             ,CONVERT(NVARCHAR(MAX),firstname) AS firstname
             ,CONVERT(NVARCHAR(MAX),middlename) AS middlename
             ,CONVERT(NVARCHAR(MAX),lastname) AS lastname
             ,CONVERT(NVARCHAR(MAX),generationcodesuffix) AS generationcodesuffix
             ,CONVERT(NVARCHAR(MAX),gender) AS gender
             ,CONVERT(NVARCHAR(MAX),dateofbirth) AS dateofbirth
             ,CONVERT(NVARCHAR(MAX),cityofbirth) AS cityofbirth
             ,CONVERT(NVARCHAR(MAX),stateofbirth) AS stateofbirth
             ,CONVERT(NVARCHAR(MAX),countryofbirth) AS countryofbirth
             ,CONVERT(NVARCHAR(MAX),ethnicity) AS ethnicity
             ,CONVERT(NVARCHAR(MAX),raceamericanindian) AS raceamericanindian
             ,CONVERT(NVARCHAR(MAX),raceasian) AS raceasian
             ,CONVERT(NVARCHAR(MAX),raceblack) AS raceblack
             ,CONVERT(NVARCHAR(MAX),racepacific) AS racepacific
             ,CONVERT(NVARCHAR(MAX),racewhite) AS racewhite
             ,CONVERT(NVARCHAR(MAX),status) AS status
             ,CONVERT(NVARCHAR(MAX),RIGHT(CONCAT('0',countycoderesident),2)) AS countycoderesident
             ,CONVERT(NVARCHAR(MAX),RIGHT(CONCAT('0',districtcoderesident),4)) AS districtcoderesident
             ,CONVERT(NVARCHAR(MAX),schoolcoderesident) AS schoolcoderesident
             ,CONVERT(NVARCHAR(MAX),RIGHT(CONCAT('0',countycodeattending),2)) AS countycodeattending
             ,CONVERT(NVARCHAR(MAX),districtcodeattending) AS districtcodeattending
             ,CONVERT(NVARCHAR(MAX),schoolcodeattending) AS schoolcodeattending
             ,CONVERT(NVARCHAR(MAX),RIGHT(CONCAT('0',countycodereceiving),2)) AS countycodereceiving
             ,CONVERT(NVARCHAR(MAX),districtcodereceiving) AS districtcodereceiving
             ,CONVERT(NVARCHAR(MAX),schoolcodereceiving) AS schoolcodereceiving
             ,CONVERT(NVARCHAR(MAX),CONVERT(BIGINT,schoolexitdate)) AS schoolexitdate
             ,CONVERT(NVARCHAR(MAX),schoolexitwithdrawalcode) AS schoolexitwithdrawalcode
             ,CONVERT(NVARCHAR(MAX),yearofgraduation) AS yearofgraduation
             ,CONVERT(NVARCHAR(MAX),schoolentrydate) AS schoolentrydate
             ,CONVERT(NVARCHAR(MAX),districtentrydate) AS districtentrydate
             ,CONVERT(NVARCHAR(MAX),cumulativedaysinmembership) AS cumulativedaysinmembership
             ,CONVERT(NVARCHAR(MAX),cumulativedayspresent) AS cumulativedayspresent
             ,CONVERT(NVARCHAR(MAX),cumulativedaystowardstruancy) AS cumulativedaystowardstruancy
             ,CONVERT(NVARCHAR(MAX),enrollmenttype) AS enrollmenttype
             ,CONVERT(NVARCHAR(MAX),tuitioncode) AS tuitioncode
             ,CONVERT(NVARCHAR(MAX),freeandreducedratelunchstatus) AS freeandreducedratelunchstatus
             ,CONVERT(NVARCHAR(MAX),RIGHT(CONCAT('0',gradelevel),2)) AS gradelevel
             ,CONVERT(NVARCHAR(MAX),RIGHT(CONCAT('0',programtypecode),2)) AS programtypecode
             ,CONVERT(NVARCHAR(MAX),retained) AS retained
             ,CONVERT(NVARCHAR(MAX),RIGHT(CONCAT('0',specialeducationclassification),2)) AS specialeducationclassification
             ,CONVERT(NVARCHAR(MAX),lepprogramstartdate) AS lepprogramstartdate
             ,CONVERT(NVARCHAR(MAX),lepprogramcompletiondate) AS lepprogramcompletiondate
             ,CONVERT(NVARCHAR(MAX),nonpublic) AS nonpublic
             ,CONVERT(NVARCHAR(MAX),RIGHT(CONCAT('0',residentmunicipalcode),4)) AS residentmunicipalcode
             ,CONVERT(NVARCHAR(MAX),militaryconnectedstudentindicator) AS militaryconnectedstudentindicator
       FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_NJSMART_sid_export] WITH(NOLOCK)
      ) sub
  UNPIVOT(
    value
    FOR field IN (localidentificationnumber
                 ,firstname
                 ,middlename
                 ,lastname
                 ,generationcodesuffix
                 ,gender
                 ,dateofbirth
                 ,cityofbirth
                 ,stateofbirth
                 ,countryofbirth
                 ,ethnicity
                 ,raceamericanindian
                 ,raceasian
                 ,raceblack
                 ,racepacific
                 ,racewhite
                 ,status
                 ,countycoderesident
                 ,districtcoderesident
                 ,schoolcoderesident
                 ,countycodeattending
                 ,districtcodeattending
                 ,schoolcodeattending
                 ,countycodereceiving
                 ,districtcodereceiving
                 ,schoolcodereceiving
                 ,schoolexitdate
                 ,schoolexitwithdrawalcode
                 ,yearofgraduation
                 ,schoolentrydate
                 ,districtentrydate
                 ,cumulativedaysinmembership
                 ,cumulativedayspresent
                 ,cumulativedaystowardstruancy
                 ,enrollmenttype
                 ,tuitioncode
                 ,freeandreducedratelunchstatus
                 ,gradelevel
                 ,programtypecode
                 ,retained
                 ,specialeducationclassification
                 ,lepprogramstartdate
                 ,lepprogramcompletiondate
                 ,nonpublic
                 ,residentmunicipalcode
                 ,militaryconnectedstudentindicator)
   ) u
 )

,POWERSCHOOL AS ( 
  SELECT stateidentificationnumber
        ,field AS PS_field
        ,value AS PS_value
  FROM
      (
       SELECT stateidentificationnumber
             ,CONVERT(NVARCHAR(MAX),localidentificationnumber) AS localidentificationnumber
             ,CONVERT(NVARCHAR(MAX),firstname) AS firstname
             ,CONVERT(NVARCHAR(MAX),middlename) AS middlename
             ,CONVERT(NVARCHAR(MAX),lastname) AS lastname
             ,CONVERT(NVARCHAR(MAX),generationcodesuffix) AS generationcodesuffix
             ,CONVERT(NVARCHAR(MAX),gender) AS gender
             ,CONVERT(NVARCHAR(MAX),dateofbirth) AS dateofbirth
             ,CONVERT(NVARCHAR(MAX),cityofbirth) AS cityofbirth
             ,CONVERT(NVARCHAR(MAX),stateofbirth) AS stateofbirth
             ,CONVERT(NVARCHAR(MAX),countryofbirth) AS countryofbirth
             ,CONVERT(NVARCHAR(MAX),ethnicity) AS ethnicity
             ,CONVERT(NVARCHAR(MAX),raceamericanindian) AS raceamericanindian
             ,CONVERT(NVARCHAR(MAX),raceasian) AS raceasian
             ,CONVERT(NVARCHAR(MAX),raceblack) AS raceblack
             ,CONVERT(NVARCHAR(MAX),racepacific) AS racepacific
             ,CONVERT(NVARCHAR(MAX),racewhite) AS racewhite
             ,CONVERT(NVARCHAR(MAX),status) AS status
             ,CONVERT(NVARCHAR(MAX),countycoderesident) AS countycoderesident
             ,CONVERT(NVARCHAR(MAX),districtcoderesident) AS districtcoderesident
             ,CONVERT(NVARCHAR(MAX),schoolcoderesident) AS schoolcoderesident
             ,CONVERT(NVARCHAR(MAX),countycodeattending) AS countycodeattending
             ,CONVERT(NVARCHAR(MAX),districtcodeattending) AS districtcodeattending
             ,CONVERT(NVARCHAR(MAX),schoolcodeattending) AS schoolcodeattending
             ,CONVERT(NVARCHAR(MAX),countycodereceiving) AS countycodereceiving
             ,CONVERT(NVARCHAR(MAX),districtcodereceiving) AS districtcodereceiving
             ,CONVERT(NVARCHAR(MAX),schoolcodereceiving) AS schoolcodereceiving
             ,CONVERT(NVARCHAR(MAX),schoolexitdate) AS schoolexitdate
             ,CONVERT(NVARCHAR(MAX),schoolexitwithdrawalcode) AS schoolexitwithdrawalcode
             ,CONVERT(NVARCHAR(MAX),yearofgraduation) AS yearofgraduation
             ,CONVERT(NVARCHAR(MAX),schoolentrydate) AS schoolentrydate
             ,CONVERT(NVARCHAR(MAX),districtentrydate) AS districtentrydate
             ,CONVERT(NVARCHAR(MAX),cumulativedaysinmembership) AS cumulativedaysinmembership
             ,CONVERT(NVARCHAR(MAX),cumulativedayspresent) AS cumulativedayspresent
             ,CONVERT(NVARCHAR(MAX),cumulativedaystowardstruancy) AS cumulativedaystowardstruancy
             ,CONVERT(NVARCHAR(MAX),enrollmenttype) AS enrollmenttype
             ,CONVERT(NVARCHAR(MAX),tuitioncode) AS tuitioncode
             ,CONVERT(NVARCHAR(MAX),freeandreducedratelunchstatus) AS freeandreducedratelunchstatus
             ,CONVERT(NVARCHAR(MAX),gradelevel) AS gradelevel
             ,CONVERT(NVARCHAR(MAX),programtypecode) AS programtypecode
             ,CONVERT(NVARCHAR(MAX),retained) AS retained
             ,CONVERT(NVARCHAR(MAX),specialeducationclassification) AS specialeducationclassification
             ,CONVERT(NVARCHAR(MAX),lepprogramstartdate) AS lepprogramstartdate
             ,CONVERT(NVARCHAR(MAX),lepprogramcompletiondate) AS lepprogramcompletiondate
             ,CONVERT(NVARCHAR(MAX),nonpublic) AS nonpublic
             ,CONVERT(NVARCHAR(MAX),residentmunicipalcode) AS residentmunicipalcode
             ,CONVERT(NVARCHAR(MAX),militaryconnectedstudentindicator) AS militaryconnectedstudentindicator
       FROM KIPP_NJ..COMPLIANCE$SID_roster_submission WITH(NOLOCK)
      ) sub
  UNPIVOT(
    value
    FOR field IN (localidentificationnumber
                 ,firstname
                 ,middlename
                 ,lastname
                 ,generationcodesuffix
                 ,gender
                 ,dateofbirth
                 ,cityofbirth
                 ,stateofbirth
                 ,countryofbirth
                 ,ethnicity
                 ,raceamericanindian
                 ,raceasian
                 ,raceblack
                 ,racepacific
                 ,racewhite
                 ,status
                 ,countycoderesident
                 ,districtcoderesident
                 ,schoolcoderesident
                 ,countycodeattending
                 ,districtcodeattending
                 ,schoolcodeattending
                 ,countycodereceiving
                 ,districtcodereceiving
                 ,schoolcodereceiving
                 ,schoolexitdate
                 ,schoolexitwithdrawalcode
                 ,yearofgraduation
                 ,schoolentrydate
                 ,districtentrydate
                 ,cumulativedaysinmembership
                 ,cumulativedayspresent
                 ,cumulativedaystowardstruancy
                 ,enrollmenttype
                 ,tuitioncode
                 ,freeandreducedratelunchstatus
                 ,gradelevel
                 ,programtypecode
                 ,retained
                 ,specialeducationclassification
                 ,lepprogramstartdate
                 ,lepprogramcompletiondate
                 ,nonpublic
                 ,residentmunicipalcode
                 ,militaryconnectedstudentindicator)
   ) u
 )

SELECT n.stateidentificationnumber
      ,n.NJSMART_field AS field
      ,n.NJSMART_value
      ,p.PS_value
FROM NJSMART n
LEFT OUTER JOIN POWERSCHOOL p
  ON n.stateidentificationnumber = p.StateIdentificationNumber
 AND n.NJSMART_field = p.PS_field
WHERE n.NJSMART_value != p.PS_value
  AND p.PS_value IS NOT NULL