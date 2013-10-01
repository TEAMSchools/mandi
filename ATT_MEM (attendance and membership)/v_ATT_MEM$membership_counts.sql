USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$membership_counts AS
SELECT s.id
      ,s.lastfirst
      ,s.schoolid
      ,s.grade_level
      ,SUM(CONVERT(FLOAT,membershipvalue)) AS mem
      ,SUM(CONVERT(FLOAT,CASE WHEN RT = 'RT1' THEN membershipvalue ELSE 0 END)) AS RT1_mem
      ,SUM(CONVERT(FLOAT,CASE WHEN RT = 'RT2' THEN membershipvalue ELSE 0 END)) AS RT2_mem
      ,SUM(CONVERT(FLOAT,CASE WHEN RT = 'RT3' THEN membershipvalue ELSE 0 END)) AS RT3_mem
      ,SUM(CONVERT(FLOAT,CASE WHEN RT = 'RT4' THEN membershipvalue ELSE 0 END)) AS RT4_mem
      ,SUM(CONVERT(FLOAT,CASE WHEN RT = 'RT5' THEN membershipvalue ELSE 0 END)) AS RT5_mem
      ,SUM(CONVERT(FLOAT,CASE WHEN RT = 'RT6' THEN membershipvalue ELSE 0 END)) AS RT6_mem
FROM STUDENTS s
LEFT OUTER JOIN
     (SELECT studentid
            ,calendardate
            ,membershipvalue
            ,CASE
              --Middle Schools (Rise & TEAM)
              WHEN schoolid IN (73252,133570965) AND calendardate >= '2013-08-05' AND calendardate <= '2013-11-22' THEN 'RT1'
              WHEN schoolid IN (73252,133570965) AND calendardate >= '2013-11-25' AND calendardate <= '2014-03-07' THEN 'RT2'
              WHEN schoolid IN (73252,133570965) AND calendardate >= '2014-03-10' AND calendardate <= '2014-06-20' THEN 'RT3'
              --NCA
              WHEN schoolid = 73253 AND calendardate >= '2013-09-03' AND calendardate <= '2013-11-08' THEN 'RT1'
              WHEN schoolid = 73253 AND calendardate >= '2013-11-12' AND calendardate <= '2014-01-27' THEN 'RT2'
              WHEN schoolid = 73253 AND calendardate >= '2014-02-03' AND calendardate <= '2014-04-04' THEN 'RT3'
              WHEN schoolid = 73253 AND calendardate >= '2014-04-21' AND calendardate <= '2014-06-20' THEN 'RT4'
              --Elementary Schools (SPARK, THRIVE, Seek)
              WHEN schoolid IN (73254,73255,73256) AND calendardate >= '2013-08-19' AND calendardate <= '2013-08-30' THEN 'RT1'
              WHEN schoolid IN (73254,73255,73256) AND calendardate >= '2013-09-04' AND calendardate <= '2013-11-22' THEN 'RT2'
              WHEN schoolid IN (73254,73255,73256) AND calendardate >= '2013-11-25' AND calendardate <= '2014-02-14' THEN 'RT3'
              WHEN schoolid IN (73254,73255,73256) AND calendardate >= '2014-02-25' AND calendardate <= '2014-05-16' THEN 'RT4'
              WHEN schoolid IN (73254,73255,73256) AND calendardate >= '2014-05-19' AND calendardate <= '2014-06-13' THEN 'RT5'
              ELSE NULL
             END AS RT     
      FROM MEMBERSHIP            
     ) ctod
  ON s.id = ctod.studentid
WHERE s.entrydate >= '2013-08-01'
GROUP BY s.id,s.lastfirst,s.schoolid,s.grade_level
--*/