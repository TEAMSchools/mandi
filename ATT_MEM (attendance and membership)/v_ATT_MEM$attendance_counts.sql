USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$attendance_counts AS
SELECT TOP (100) PERCENT
       s.id
      ,s.lastfirst
      ,s.schoolid
      ,s.grade_level      
      --full year
      ,absences_undoc + absences_doc AS absences_total
      ,absences_undoc
      ,absences_doc
      ,tardies_reg + tardies_T10 AS tardies_total
      ,tardies_reg
      ,tardies_T10
      ,iss
      ,oss
      --RT1
      ,rt1_absences_undoc + rt1_absences_doc AS rt1_absences_total
      ,rt1_absences_undoc
      ,rt1_absences_doc
      ,rt1_tardies_reg + rt1_tardies_T10 AS rt1_tardies_total
      ,rt1_tardies_reg
      ,rt1_tardies_T10
      ,rt1_iss
      ,rt1_oss
      --rt2
      ,rt2_absences_undoc + rt2_absences_doc AS rt2_absences_total
      ,rt2_absences_undoc
      ,rt2_absences_doc
      ,rt2_tardies_reg + rt2_tardies_T10 AS rt2_tardies_total
      ,rt2_tardies_reg
      ,rt2_tardies_T10
      ,rt2_iss
      ,rt2_oss
      --rt3
      ,rt3_absences_undoc + rt3_absences_doc AS rt3_absences_total
      ,rt3_absences_undoc
      ,rt3_absences_doc
      ,rt3_tardies_reg + rt3_tardies_T10 AS rt3_tardies_total
      ,rt3_tardies_reg
      ,rt3_tardies_T10
      ,rt3_iss
      ,rt3_oss
      --rt4
      ,rt4_absences_undoc + rt4_absences_doc AS rt4_absences_total
      ,rt4_absences_undoc
      ,rt4_absences_doc
      ,rt4_tardies_reg + rt4_tardies_T10 AS rt4_tardies_total
      ,rt4_tardies_reg
      ,rt4_tardies_T10
      ,rt4_iss
      ,rt4_oss
      --rt5
      ,rt5_absences_undoc + rt5_absences_doc AS rt5_absences_total
      ,rt5_absences_undoc
      ,rt5_absences_doc
      ,rt5_tardies_reg + rt5_tardies_T10 AS rt5_tardies_total
      ,rt5_tardies_reg
      ,rt5_tardies_T10
      ,rt5_iss
      ,rt5_oss
      --rt6
      ,rt6_absences_undoc + rt6_absences_doc AS rt6_absences_total
      ,rt6_absences_undoc
      ,rt6_absences_doc
      ,rt6_tardies_reg + rt6_tardies_T10 AS rt6_tardies_total
      ,rt6_tardies_reg
      ,rt6_tardies_T10
      ,rt6_iss
      ,rt6_oss
FROM STUDENTS s
LEFT OUTER JOIN 
     (SELECT studentid
            --Y1
            ,SUM(CASE WHEN att_code = 'A'   THEN 1.0 ELSE 0.0 END) AS absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  THEN 1.0
                      WHEN att_code = 'D'   THEN 1.0 ELSE 0.0 END) AS absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  THEN 1.0 ELSE 0.0 END) AS excused_absences
            ,SUM(CASE WHEN att_code = 'T'   THEN 1.0 ELSE 0.0 END) AS tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' THEN 1.0 ELSE 0.0 END) AS tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   THEN 1.0 ELSE 0.0 END) AS ISS
            ,SUM(CASE WHEN att_code = 'OS'  THEN 1.0 ELSE 0.0 END) AS OSS
            --RT1
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'RT1' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_OSS
            --RT2
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'RT2' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_OSS
            --RT3
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'RT3' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_OSS
            --RT4
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'RT4' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_OSS
            --RT5
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'RT5' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_OSS
            --RT6
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'RT6' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_OSS
      FROM            
           (SELECT studentid
                  ,psad.att_date
                  ,psad.att_code
                  --ADD TERMS TO REPORTING$dates TABLE AND TURN THIS INTO A SQL SERVER JOIN TO THE OPENQUERY
                  ,CASE
                    --Middle Schools (Rise & TEAM)
                    WHEN psad.schoolid IN (73252,133570965) AND psad.att_date >= '2013-08-05' AND psad.att_date <= '2013-11-22' THEN 'RT1'
                    WHEN psad.schoolid IN (73252,133570965) AND psad.att_date >= '2013-11-25' AND psad.att_date <= '2014-03-07' THEN 'RT2'
                    WHEN psad.schoolid IN (73252,133570965) AND psad.att_date >= '2014-03-10' AND psad.att_date <= '2014-06-20' THEN 'RT3'
                    --NCA
                    WHEN psad.schoolid = 73253 AND psad.att_date >= '2013-09-03' AND psad.att_date <= '2013-11-08' THEN 'RT1'
                    WHEN psad.schoolid = 73253 AND psad.att_date >= '2013-11-12' AND psad.att_date <= '2014-01-27' THEN 'RT2'
                    WHEN psad.schoolid = 73253 AND psad.att_date >= '2014-02-03' AND psad.att_date <= '2014-04-04' THEN 'RT3'
                    WHEN psad.schoolid = 73253 AND psad.att_date >= '2014-04-21' AND psad.att_date <= '2014-06-20' THEN 'RT4'
                    --Elementary Schools (SPARK, THRIVE, Seek)
                    WHEN psad.schoolid IN (73254,73255,73256) AND psad.att_date >= '2013-08-19' AND psad.att_date <= '2013-08-30' THEN 'RT1'
                    WHEN psad.schoolid IN (73254,73255,73256) AND psad.att_date >= '2013-09-04' AND psad.att_date <= '2013-11-22' THEN 'RT2'
                    WHEN psad.schoolid IN (73254,73255,73256) AND psad.att_date >= '2013-11-25' AND psad.att_date <= '2014-02-14' THEN 'RT3'
                    WHEN psad.schoolid IN (73254,73255,73256) AND psad.att_date >= '2014-02-25' AND psad.att_date <= '2014-05-16' THEN 'RT4'
                    WHEN psad.schoolid IN (73254,73255,73256) AND psad.att_date >= '2014-05-19' AND psad.att_date <= '2014-06-13' THEN 'RT5'
                    ELSE NULL
                   END AS RT
            FROM ATTENDANCE psad
            WHERE psad.att_code IS NOT NULL
           ) sub
      GROUP BY studentid
     ) psad
  ON s.id = psad.studentid
WHERE s.entrydate >= '2013-08-01'
--AND s.enroll_status = 0
ORDER BY s.schoolid, s.grade_level, s.lastfirst