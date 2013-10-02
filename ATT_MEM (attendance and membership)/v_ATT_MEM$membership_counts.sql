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
            ,dates.time_per_name AS RT     
      FROM MEMBERSHIP mem
      JOIN REPORTING$dates dates
        ON mem.calendardate >= dates.start_date
       AND mem.calendardate <= dates.end_date
       AND mem.schoolid = dates.schoolid
     ) ctod
  ON s.id = ctod.studentid
WHERE s.entrydate >= '2013-08-01'
GROUP BY s.id,s.lastfirst,s.schoolid,s.grade_level
--*/