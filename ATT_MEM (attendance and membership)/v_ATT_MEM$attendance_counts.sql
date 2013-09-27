USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$attendance_counts AS
SELECT TOP (100) PERCENT
       s.id
      ,s.lastfirst
      ,s.schoolid
      ,s.grade_level      
      --full year
      ,CONVERT(INT,ISNULL(absences_undoc,0)) + CONVERT(INT,ISNULL(absences_doc,0)) AS absences_total
      ,CONVERT(INT,ISNULL(absences_undoc,0)) AS absences_undoc
      ,CONVERT(INT,ISNULL(absences_doc,0)) AS absences_doc
      ,CONVERT(INT,ISNULL(tardies_reg,0)) + CONVERT(INT,ISNULL(tardies_T10,0)) AS tardies_total
      ,CONVERT(INT,ISNULL(tardies_reg,0)) AS tardies_reg
      ,CONVERT(INT,ISNULL(tardies_T10,0)) AS tardies_T10
      ,CONVERT(INT,ISNULL(iss,0)) AS iss
      ,CONVERT(INT,ISNULL(oss,0)) AS oss
      --RT1
      ,CONVERT(INT,ISNULL(rt1_absences_undoc,0)) + CONVERT(INT,ISNULL(rt1_absences_doc,0)) AS rt1_absences_total
      ,CONVERT(INT,ISNULL(rt1_absences_undoc,0)) AS rt1_absences_undoc
      ,CONVERT(INT,ISNULL(rt1_absences_doc,0)) AS rt1_absences_doc
      ,CONVERT(INT,ISNULL(rt1_tardies_reg,0)) + CONVERT(INT,ISNULL(rt1_tardies_T10,0)) AS rt1_tardies_total
      ,CONVERT(INT,ISNULL(rt1_tardies_reg,0)) AS rt1_tardies_reg
      ,CONVERT(INT,ISNULL(rt1_tardies_T10,0)) AS rt1_tardies_T10
      ,CONVERT(INT,ISNULL(rt1_iss,0)) AS rt1_iss
      ,CONVERT(INT,ISNULL(rt1_oss,0)) AS rt1_oss
      --rt2
      ,CONVERT(INT,ISNULL(rt2_absences_undoc,0)) + CONVERT(INT,ISNULL(rt2_absences_doc,0)) AS rt2_absences_total
      ,CONVERT(INT,ISNULL(rt2_absences_undoc,0)) AS rt2_absences_undoc
      ,CONVERT(INT,ISNULL(rt2_absences_doc,0)) AS rt2_absences_doc
      ,CONVERT(INT,ISNULL(rt2_tardies_reg,0)) + CONVERT(INT,ISNULL(rt2_tardies_T10,0)) AS rt2_tardies_total
      ,CONVERT(INT,ISNULL(rt2_tardies_reg,0)) AS rt2_tardies_reg
      ,CONVERT(INT,ISNULL(rt2_tardies_T10,0)) AS rt2_tardies_T10
      ,CONVERT(INT,ISNULL(rt2_iss,0)) AS rt2_iss
      ,CONVERT(INT,ISNULL(rt2_oss,0)) AS rt2_oss
      --rt3
      ,CONVERT(INT,ISNULL(rt3_absences_undoc,0)) + CONVERT(INT,ISNULL(rt3_absences_doc,0)) AS rt3_absences_total
      ,CONVERT(INT,ISNULL(rt3_absences_undoc,0)) AS rt3_absences_undoc
      ,CONVERT(INT,ISNULL(rt3_absences_doc,0)) AS rt3_absences_doc
      ,CONVERT(INT,ISNULL(rt3_tardies_reg,0)) + CONVERT(INT,ISNULL(rt3_tardies_T10,0)) AS rt3_tardies_total
      ,CONVERT(INT,ISNULL(rt3_tardies_reg,0)) AS rt3_tardies_reg
      ,CONVERT(INT,ISNULL(rt3_tardies_T10,0)) AS rt3_tardies_T10
      ,CONVERT(INT,ISNULL(rt3_iss,0)) AS rt3_iss
      ,CONVERT(INT,ISNULL(rt3_oss,0)) AS rt3_oss
      --rt4
      ,CONVERT(INT,ISNULL(rt4_absences_undoc,0)) + CONVERT(INT,ISNULL(rt4_absences_doc,0)) AS rt4_absences_total
      ,CONVERT(INT,ISNULL(rt4_absences_undoc,0)) AS rt4_absences_undoc
      ,CONVERT(INT,ISNULL(rt4_absences_doc,0)) AS rt4_absences_doc
      ,CONVERT(INT,ISNULL(rt4_tardies_reg,0)) + CONVERT(INT,ISNULL(rt4_tardies_T10,0)) AS rt4_tardies_total
      ,CONVERT(INT,ISNULL(rt4_tardies_reg,0)) AS rt4_tardies_reg
      ,CONVERT(INT,ISNULL(rt4_tardies_T10,0)) AS rt4_tardies_T10
      ,CONVERT(INT,ISNULL(rt4_iss,0)) AS rt4_iss
      ,CONVERT(INT,ISNULL(rt4_oss,0)) AS rt4_oss
      --rt5
      ,CONVERT(INT,ISNULL(rt5_absences_undoc,0)) + CONVERT(INT,ISNULL(rt5_absences_doc,0)) AS rt5_absences_total
      ,CONVERT(INT,ISNULL(rt5_absences_undoc,0)) AS rt5_absences_undoc
      ,CONVERT(INT,ISNULL(rt5_absences_doc,0)) AS rt5_absences_doc
      ,CONVERT(INT,ISNULL(rt5_tardies_reg,0)) + CONVERT(INT,ISNULL(rt5_tardies_T10,0)) AS rt5_tardies_total
      ,CONVERT(INT,ISNULL(rt5_tardies_reg,0)) AS rt5_tardies_reg
      ,CONVERT(INT,ISNULL(rt5_tardies_T10,0)) AS rt5_tardies_T10
      ,CONVERT(INT,ISNULL(rt5_iss,0)) AS rt5_iss
      ,CONVERT(INT,ISNULL(rt5_oss,0)) AS rt5_oss
      --rt6
      ,CONVERT(INT,ISNULL(rt6_absences_undoc,0)) + CONVERT(INT,ISNULL(rt6_absences_doc,0)) AS rt6_absences_total
      ,CONVERT(INT,ISNULL(rt6_absences_undoc,0)) AS rt6_absences_undoc
      ,CONVERT(INT,ISNULL(rt6_absences_doc,0)) AS rt6_absences_doc
      ,CONVERT(INT,ISNULL(rt6_tardies_reg,0)) + CONVERT(INT,ISNULL(rt6_tardies_T10,0)) AS rt6_tardies_total
      ,CONVERT(INT,ISNULL(rt6_tardies_reg,0)) AS rt6_tardies_reg
      ,CONVERT(INT,ISNULL(rt6_tardies_T10,0)) AS rt6_tardies_T10
      ,CONVERT(INT,ISNULL(rt6_iss,0)) AS rt6_iss
      ,CONVERT(INT,ISNULL(rt6_oss,0)) AS rt6_oss
FROM STUDENTS s
LEFT OUTER JOIN OPENQUERY(PS_TEAM,'
SELECT studentid
--Y1
,SUM(CASE WHEN att_code = ''A'' THEN 1 ELSE 0 END) AS absences_undoc
,SUM(CASE WHEN att_code = ''AD'' THEN 1
WHEN att_code = ''D'' THEN 1 ELSE 0 END) AS absences_doc
,SUM(CASE WHEN att_code = ''AE'' THEN 1 ELSE 0 END) AS excused_absences
,SUM(CASE WHEN att_code = ''T'' THEN 1 ELSE 0 END) AS tardies_reg
,SUM(CASE WHEN att_code = ''T10'' THEN 1 ELSE 0 END) AS tardies_T10
,SUM(CASE WHEN att_code = ''S'' THEN 1 ELSE 0 END) AS ISS
,SUM(CASE WHEN att_code = ''OS'' THEN 1 ELSE 0 END) AS OSS
--RT1
,SUM(CASE WHEN att_code = ''A'' AND RT = ''RT1'' THEN 1 ELSE 0 END) AS RT1_absences_undoc
,SUM(CASE WHEN att_code = ''AD'' AND RT = ''RT1'' THEN 1
WHEN att_code = ''D'' AND RT = ''RT1'' THEN 1 ELSE 0 END) AS RT1_absences_doc
,SUM(CASE WHEN att_code = ''AE'' AND RT = ''RT1'' THEN 1 ELSE 0 END) AS RT1_excused_absences
,SUM(CASE WHEN att_code = ''T'' AND RT = ''RT1'' THEN 1 ELSE 0 END) AS RT1_tardies_reg
,SUM(CASE WHEN att_code = ''T10'' AND RT = ''RT1'' THEN 1 ELSE 0 END) AS RT1_tardies_T10
,SUM(CASE WHEN att_code = ''S'' AND RT = ''RT1'' THEN 1 ELSE 0 END) AS RT1_ISS
,SUM(CASE WHEN att_code = ''OS'' AND RT = ''RT1'' THEN 1 ELSE 0 END) AS RT1_OSS
--RT2
,SUM(CASE WHEN att_code = ''A'' AND RT = ''RT2'' THEN 1 ELSE 0 END) AS RT2_absences_undoc
,SUM(CASE WHEN att_code = ''AD'' AND RT = ''RT2'' THEN 1
WHEN att_code = ''D'' AND RT = ''RT2'' THEN 1 ELSE 0 END) AS RT2_absences_doc
,SUM(CASE WHEN att_code = ''AE'' AND RT = ''RT2'' THEN 1 ELSE 0 END) AS RT2_excused_absences
,SUM(CASE WHEN att_code = ''T'' AND RT = ''RT2'' THEN 1 ELSE 0 END) AS RT2_tardies_reg
,SUM(CASE WHEN att_code = ''T10'' AND RT = ''RT2'' THEN 1 ELSE 0 END) AS RT2_tardies_T10
,SUM(CASE WHEN att_code = ''S'' AND RT = ''RT2'' THEN 1 ELSE 0 END) AS RT2_ISS
,SUM(CASE WHEN att_code = ''OS'' AND RT = ''RT2'' THEN 1 ELSE 0 END) AS RT2_OSS
--RT3
,SUM(CASE WHEN att_code = ''A'' AND RT = ''RT3'' THEN 1 ELSE 0 END) AS RT3_absences_undoc
,SUM(CASE WHEN att_code = ''AD'' AND RT = ''RT3'' THEN 1
WHEN att_code = ''D'' AND RT = ''RT3'' THEN 1 ELSE 0 END) AS RT3_absences_doc
,SUM(CASE WHEN att_code = ''AE'' AND RT = ''RT3'' THEN 1 ELSE 0 END) AS RT3_excused_absences
,SUM(CASE WHEN att_code = ''T'' AND RT = ''RT3'' THEN 1 ELSE 0 END) AS RT3_tardies_reg
,SUM(CASE WHEN att_code = ''T10'' AND RT = ''RT3'' THEN 1 ELSE 0 END) AS RT3_tardies_T10
,SUM(CASE WHEN att_code = ''S'' AND RT = ''RT3'' THEN 1 ELSE 0 END) AS RT3_ISS
,SUM(CASE WHEN att_code = ''OS'' AND RT = ''RT3'' THEN 1 ELSE 0 END) AS RT3_OSS
--RT4
,SUM(CASE WHEN att_code = ''A'' AND RT = ''RT4'' THEN 1 ELSE 0 END) AS RT4_absences_undoc
,SUM(CASE WHEN att_code = ''AD'' AND RT = ''RT4'' THEN 1
WHEN att_code = ''D'' AND RT = ''RT4'' THEN 1 ELSE 0 END) AS RT4_absences_doc
,SUM(CASE WHEN att_code = ''AE'' AND RT = ''RT4'' THEN 1 ELSE 0 END) AS RT4_excused_absences
,SUM(CASE WHEN att_code = ''T'' AND RT = ''RT4'' THEN 1 ELSE 0 END) AS RT4_tardies_reg
,SUM(CASE WHEN att_code = ''T10'' AND RT = ''RT4'' THEN 1 ELSE 0 END) AS RT4_tardies_T10
,SUM(CASE WHEN att_code = ''S'' AND RT = ''RT4'' THEN 1 ELSE 0 END) AS RT4_ISS
,SUM(CASE WHEN att_code = ''OS'' AND RT = ''RT4'' THEN 1 ELSE 0 END) AS RT4_OSS
--RT5
,SUM(CASE WHEN att_code = ''A'' AND RT = ''RT5'' THEN 1 ELSE 0 END) AS RT5_absences_undoc
,SUM(CASE WHEN att_code = ''AD'' AND RT = ''RT5'' THEN 1
WHEN att_code = ''D'' AND RT = ''RT5'' THEN 1 ELSE 0 END) AS RT5_absences_doc
,SUM(CASE WHEN att_code = ''AE'' AND RT = ''RT5'' THEN 1 ELSE 0 END) AS RT5_excused_absences
,SUM(CASE WHEN att_code = ''T'' AND RT = ''RT5'' THEN 1 ELSE 0 END) AS RT5_tardies_reg
,SUM(CASE WHEN att_code = ''T10'' AND RT = ''RT5'' THEN 1 ELSE 0 END) AS RT5_tardies_T10
,SUM(CASE WHEN att_code = ''S'' AND RT = ''RT5'' THEN 1 ELSE 0 END) AS RT5_ISS
,SUM(CASE WHEN att_code = ''OS'' AND RT = ''RT5'' THEN 1 ELSE 0 END) AS RT5_OSS
--RT6
,SUM(CASE WHEN att_code = ''A'' AND RT = ''RT6'' THEN 1 ELSE 0 END) AS RT6_absences_undoc
,SUM(CASE WHEN att_code = ''AD'' AND RT = ''RT6'' THEN 1
WHEN att_code = ''D'' AND RT = ''RT6'' THEN 1 ELSE 0 END) AS RT6_absences_doc
,SUM(CASE WHEN att_code = ''AE'' AND RT = ''RT6'' THEN 1 ELSE 0 END) AS RT6_excused_absences
,SUM(CASE WHEN att_code = ''T'' AND RT = ''RT6'' THEN 1 ELSE 0 END) AS RT6_tardies_reg
,SUM(CASE WHEN att_code = ''T10'' AND RT = ''RT6'' THEN 1 ELSE 0 END) AS RT6_tardies_T10
,SUM(CASE WHEN att_code = ''S'' AND RT = ''RT6'' THEN 1 ELSE 0 END) AS RT6_ISS
,SUM(CASE WHEN att_code = ''OS'' AND RT = ''RT6'' THEN 1 ELSE 0 END) AS RT6_OSS
FROM
--ADD TERMS TO REPORTING$dates TABLE AND TURN THIS INTO A SQL SERVER JOIN TO THE OPENQUERY
(SELECT studentid
,psad.att_date
,psad.att_code
,CASE
--Middle Schools (Rise & TEAM)
WHEN psad.schoolid IN (73252,133570965) AND psad.att_date >= TO_DATE(''2013-08-05'',''YYYY-MM-DD'') AND psad.att_date <= TO_DATE(''2013-11-22'',''YYYY-MM-DD'') THEN ''RT1''
WHEN psad.schoolid IN (73252,133570965) AND psad.att_date >= TO_DATE(''2013-11-25'',''YYYY-MM-DD'') AND psad.att_date <= TO_DATE(''2014-03-07'',''YYYY-MM-DD'') THEN ''RT2''
WHEN psad.schoolid IN (73252,133570965) AND psad.att_date >= TO_DATE(''2014-03-10'',''YYYY-MM-DD'') AND psad.att_date <= TO_DATE(''2014-06-20'',''YYYY-MM-DD'') THEN ''RT3''
--NCA
WHEN psad.schoolid = 73253 AND psad.att_date >= TO_DATE(''2013-09-03'',''YYYY-MM-DD'') AND psad.att_date <= TO_DATE(''2013-11-08'',''YYYY-MM-DD'') THEN ''RT1''
WHEN psad.schoolid = 73253 AND psad.att_date >= TO_DATE(''2013-11-12'',''YYYY-MM-DD'') AND psad.att_date <= TO_DATE(''2014-01-27'',''YYYY-MM-DD'') THEN ''RT2''
WHEN psad.schoolid = 73253 AND psad.att_date >= TO_DATE(''2014-02-03'',''YYYY-MM-DD'') AND psad.att_date <= TO_DATE(''2014-04-04'',''YYYY-MM-DD'') THEN ''RT3''
WHEN psad.schoolid = 73253 AND psad.att_date >= TO_DATE(''2013-04-21'',''YYYY-MM-DD'') AND psad.att_date <= TO_DATE(''2014-06-20'',''YYYY-MM-DD'') THEN ''RT4''
--Elementary Schools (SPARK, THRIVE, Seek)
WHEN psad.schoolid IN (73254,73255,73256) AND psad.att_date >= TO_DATE(''2013-08-19'',''YYYY-MM-DD'') AND psad.att_date <= TO_DATE(''2013-08-30'',''YYYY-MM-DD'') THEN ''RT1''
WHEN psad.schoolid IN (73254,73255,73256) AND psad.att_date >= TO_DATE(''2013-09-04'',''YYYY-MM-DD'') AND psad.att_date <= TO_DATE(''2013-11-22'',''YYYY-MM-DD'') THEN ''RT2''
WHEN psad.schoolid IN (73254,73255,73256) AND psad.att_date >= TO_DATE(''2013-11-25'',''YYYY-MM-DD'') AND psad.att_date <= TO_DATE(''2014-02-14'',''YYYY-MM-DD'') THEN ''RT3''
WHEN psad.schoolid IN (73254,73255,73256) AND psad.att_date >= TO_DATE(''2014-02-25'',''YYYY-MM-DD'') AND psad.att_date <= TO_DATE(''2014-05-16'',''YYYY-MM-DD'') THEN ''RT4''
WHEN psad.schoolid IN (73254,73255,73256) AND psad.att_date >= TO_DATE(''2014-05-19'',''YYYY-MM-DD'') AND psad.att_date <= TO_DATE(''2014-06-13'',''YYYY-MM-DD'') THEN ''RT5''
ELSE NULL
END AS RT
FROM PS_ATTENDANCE_DAILY psad
WHERE psad.att_date >= TO_DATE(''2013-08-01'',''YYYY-MM-DD'')
AND psad.att_date <= TO_DATE(''2014-06-30'',''YYYY-MM-DD'')
AND psad.att_code IS NOT NULL
) sub
GROUP BY studentid
') psad
ON s.id = psad.studentid
WHERE s.entrydate >= '2013-08-01'
ORDER BY s.schoolid, s.grade_level, s.lastfirst