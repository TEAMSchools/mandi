USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$membership_counts AS
--/*
SELECT *
FROM OPENQUERY(KIPP_NWK,'
SELECT id
,lastfirst
,schoolid
,grade_level
,CAST(mem AS FLOAT) AS mem
,CAST(rt1_mem AS FLOAT) AS rt1_mem
,CAST(rt2_mem AS FLOAT) AS rt2_mem
,CAST(rt3_mem AS FLOAT) AS rt3_mem
,CAST(rt4_mem AS FLOAT) AS rt4_mem
,CAST(rt5_mem AS FLOAT) AS rt5_mem
,CAST(rt6_mem AS FLOAT) AS rt6_mem
FROM membership_counts
')
--*/
/*
SELECT s.id
      ,s.lastfirst
      ,s.schoolid
      ,s.grade_level
      ,SUM(CONVERT(INT,membershipvalue)) AS mem
      ,SUM(CONVERT(INT,CASE WHEN RT = 'RT1' THEN membershipvalue ELSE 0 END)) AS RT1_mem
      ,SUM(CONVERT(INT,CASE WHEN RT = 'RT2' THEN membershipvalue ELSE 0 END)) AS RT2_mem
      ,SUM(CONVERT(INT,CASE WHEN RT = 'RT3' THEN membershipvalue ELSE 0 END)) AS RT3_mem
      ,SUM(CONVERT(INT,CASE WHEN RT = 'RT4' THEN membershipvalue ELSE 0 END)) AS RT4_mem
      ,SUM(CONVERT(INT,CASE WHEN RT = 'RT5' THEN membershipvalue ELSE 0 END)) AS RT5_mem
      ,SUM(CONVERT(INT,CASE WHEN RT = 'RT6' THEN membershipvalue ELSE 0 END)) AS RT6_mem
FROM STUDENTS s
LEFT OUTER JOIN OPENQUERY(PS_TEAM,'
     SELECT studentid
           ,calendardate
           ,membershipvalue
           ,CASE
             --Middle Schools (Rise & TEAM)
             WHEN schoolid IN (73252,133570965) AND calendardate >= TO_DATE(''2013-08-05'',''YYYY-MM-DD'') AND calendardate <= TO_DATE(''2013-11-22'',''YYYY-MM-DD'') THEN ''RT1''
             WHEN schoolid IN (73252,133570965) AND calendardate >= TO_DATE(''2013-11-25'',''YYYY-MM-DD'') AND calendardate <= TO_DATE(''2014-03-07'',''YYYY-MM-DD'') THEN ''RT2''
             WHEN schoolid IN (73252,133570965) AND calendardate >= TO_DATE(''2014-03-10'',''YYYY-MM-DD'') AND calendardate <= TO_DATE(''2014-06-20'',''YYYY-MM-DD'') THEN ''RT3''
             --NCA
             WHEN schoolid = 73253 AND calendardate >= TO_DATE(''2013-09-03'',''YYYY-MM-DD'') AND calendardate <= TO_DATE(''2013-11-08'',''YYYY-MM-DD'') THEN ''RT1''
             WHEN schoolid = 73253 AND calendardate >= TO_DATE(''2013-11-12'',''YYYY-MM-DD'') AND calendardate <= TO_DATE(''2014-01-27'',''YYYY-MM-DD'') THEN ''RT2''
             WHEN schoolid = 73253 AND calendardate >= TO_DATE(''2014-02-03'',''YYYY-MM-DD'') AND calendardate <= TO_DATE(''2014-04-04'',''YYYY-MM-DD'') THEN ''RT3''
             WHEN schoolid = 73253 AND calendardate >= TO_DATE(''2013-04-21'',''YYYY-MM-DD'') AND calendardate <= TO_DATE(''2014-06-20'',''YYYY-MM-DD'') THEN ''RT4''
             --Elementary Schools (SPARK, THRIVE, Seek)
             WHEN schoolid IN (73254,73255,73256) AND calendardate >= TO_DATE(''2013-08-19'',''YYYY-MM-DD'') AND calendardate <= TO_DATE(''2013-08-30'',''YYYY-MM-DD'') THEN ''RT1''
             WHEN schoolid IN (73254,73255,73256) AND calendardate >= TO_DATE(''2013-09-04'',''YYYY-MM-DD'') AND calendardate <= TO_DATE(''2013-11-22'',''YYYY-MM-DD'') THEN ''RT2''
             WHEN schoolid IN (73254,73255,73256) AND calendardate >= TO_DATE(''2013-11-25'',''YYYY-MM-DD'') AND calendardate <= TO_DATE(''2014-02-14'',''YYYY-MM-DD'') THEN ''RT3''
             WHEN schoolid IN (73254,73255,73256) AND calendardate >= TO_DATE(''2014-02-25'',''YYYY-MM-DD'') AND calendardate <= TO_DATE(''2014-05-16'',''YYYY-MM-DD'') THEN ''RT4''
             WHEN schoolid IN (73254,73255,73256) AND calendardate >= TO_DATE(''2014-05-19'',''YYYY-MM-DD'') AND calendardate <= TO_DATE(''2014-06-13'',''YYYY-MM-DD'') THEN ''RT5''
             ELSE NULL
            END AS RT     
     FROM pssis_adaadm_daily_ctod
     WHERE calendardate >= TO_DATE(''2013-08-01'',''YYYY-MM-DD'')
       AND calendardate <= TO_DATE(''2014-06-30'',''YYYY-MM-DD'')
     --GROUP BY calendardate,membershipvalue
     ') ctod
   ON s.id = ctod.studentid
WHERE s.entrydate >= '2013-08-01'
GROUP BY s.id,s.lastfirst,s.schoolid,s.grade_level
ORDER BY schoolid, grade_level, lastfirst
--*/