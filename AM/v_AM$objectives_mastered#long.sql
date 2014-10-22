USE KIPP_NJ
GO

ALTER VIEW AM$objectives_mastered#long AS 
WITH scaffold AS
    (SELECT c.studentid
           ,s.student_number
           ,c.grade_level
           ,c.schoolid
           ,sch.abbreviation AS school
           ,c.year
           ,CONVERT(datetime, CAST('07/01/' + CONVERT(VARCHAR,c.year) AS DATE), 101) AS custom_start
           ,CAST(c.entrydate AS date) AS entrydate
           ,CAST(c.exitdate AS date) AS exitdate
           ,CAST(rd.date AS DATE) AS date
           ,CAST(DATEPART(month, rd.date) AS VARCHAR) + '/' + CAST(DATEPART(day, rd.date) AS VARCHAR) AS date_no_year
     FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH (NOLOCK)
     JOIN KIPP_NJ..SCHOOLS sch WITH (NOLOCK)
       ON c.schoolid = sch.school_number
     JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
       ON c.studentid = s.id
     JOIN KIPP_NJ..UTIL$reporting_days#static rd WITH (NOLOCK)
       ON rd.date >= c.entrydate
      AND rd.date <  c.exitdate
      AND rd.date <= CAST(GETDATE() AS date)           
     WHERE c.schoolid IN (73252, 133570965, 73253)
       AND c.year >= 2010
       AND c.rn = 1
       --testing
       --AND s.last_name = 'Williams'
       --AND c.studentid IN (4754, 4687, 5848, 5843)
       --AND c.year IN (2013, 2012)
       --AND c.schoolid = 73252
       --AND c.grade_level = 6
     )

SELECT CASE GROUPING(sub.studentid)
         WHEN 1 THEN -999
         ELSE CAST(sub.studentid AS VARCHAR)
       END AS studentid
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
      (SELECT scaffold.*
             ,am.vchdescription
             ,code.vchDescription AS state
             ,CASE
                WHEN timasteredtype > 0 THEN 1
                ELSE 0
              END AS mastered_dummy
             ,CASE
                 WHEN CAST(am.dtmastereddate AS date) <=  scaffold.date 
                  AND timasteredtype > 0 THEN lib.dgradelevel
                 ELSE NULL
              END AS dgradelevel
       FROM scaffold WITH(NOLOCK)
       JOIN KIPP_NJ..AM$detail#static am WITH (NOLOCK)
         ON scaffold.studentid = am.base_studentid
        AND CAST(am.dtmastereddate AS date) >= scaffold.custom_start
        AND CAST(am.dtmastereddate AS date) <= scaffold.date

       JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_RISE].[dbo].[am_CodeMaster] code WITH (NOLOCK)
         ON code.vchCodeCategory = 'ObjState'
        AND am.tiobjectivestate = code.vchCode
       JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_RISE].[dbo].[am_Library] lib WITH (NOLOCK)
         ON am.ilibraryid = lib.[iLibraryID]
       ) sub
GROUP BY 
        CUBE(sub.studentid)
         --sub.studentid
        ,sub.grade_level
        ,sub.schoolid
        ,sub.school
        ,sub.year
        ,sub.date
        ,sub.date_no_year