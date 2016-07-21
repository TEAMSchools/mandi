USE KIPP_NJ
GO

ALTER VIEW AM$objectives_mastered#long AS 

WITH scaffold AS (
  SELECT c.studentid
        ,c.student_number
        ,c.grade_level
        ,c.schoolid
        ,c.school_name AS school
        ,c.year
        ,CONVERT(DATE,(CONVERT(VARCHAR,c.year) + '-07-01')) AS custom_start
        ,c.date
        ,CONVERT(VARCHAR,DATEPART(month, c.date)) + '/' + CONVERT(VARCHAR,DATEPART(day, c.date)) AS date_no_year
  FROM KIPP_NJ..COHORT$identifiers_scaffold#static c WITH (NOLOCK)
  WHERE c.schoolid IN (73252, 133570965, 73253)
    AND c.year >= 2010      
 )

SELECT CASE GROUPING(sub.studentid) WHEN 1 THEN -999 ELSE CAST(sub.studentid AS VARCHAR) END AS studentid
      ,sub.grade_level
      ,sub.schoolid
      ,sub.school
      ,sub.year
      ,sub.date
      ,sub.date_no_year
      ,SUM(mastered_dummy) AS objectives
      ,AVG(dgradelevel) AS avg_grade_level
      ,SUM(dgradelevel) AS weighted_obj_count
      ,COUNT(*) AS n
FROM
    (
     SELECT scaffold.studentid
           ,scaffold.student_number
           ,scaffold.grade_level
           ,scaffold.schoolid
           ,scaffold.school
           ,scaffold.year
           ,scaffold.custom_start
           ,scaffold.date
           ,scaffold.date_no_year
           ,am.vchdescription
           ,code.vchDescription AS state
           ,CASE WHEN timasteredtype > 0 THEN 1 ELSE 0 END AS mastered_dummy
           ,CASE
             WHEN CAST(am.dtmastereddate AS date) <=  scaffold.date AND timasteredtype > 0 THEN lib.dgradelevel
             ELSE NULL
            END AS dgradelevel
     FROM scaffold WITH(NOLOCK)
     JOIN KIPP_NJ..AM$detail#static am WITH (NOLOCK)
       ON scaffold.studentid = am.base_studentid      
      AND scaffold.custom_start <= am.dtmastereddate
      AND scaffold.date >= am.dtmastereddate
     JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_RISE].[dbo].[am_CodeMaster] code WITH (NOLOCK)
       ON am.tiobjectivestate = code.vchCode
      AND code.vchCodeCategory = 'ObjState'      
     JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_RISE].[dbo].[am_Library] lib WITH (NOLOCK)
       ON am.ilibraryid = lib.[iLibraryID]
    ) sub
GROUP BY CUBE(sub.studentid)
         --sub.studentid
        ,sub.grade_level
        ,sub.schoolid
        ,sub.school
        ,sub.year
        ,sub.date
        ,sub.date_no_year