USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$attendance_counts AS
SELECT TOP (100) PERCENT
       s.id
      ,s.lastfirst
      ,s.schoolid
      ,s.grade_level      
      --full year
      ,ISNULL(absences_undoc + absences_doc,0) AS absences_total
      ,ISNULL(absences_undoc,0) AS absences_undoc
      ,ISNULL(absences_doc,0) AS absences_doc
      ,ISNULL(tardies_reg + tardies_T10,0) AS tardies_total
      ,ISNULL(tardies_reg,0) AS tardies_reg
      ,ISNULL(tardies_T10,0) AS tardies_T10
      ,ISNULL(iss,0) AS iss
      ,ISNULL(oss,0) AS oss
      ,ISNULL(early_dismiss,0) AS early_dismiss
      --RT1
      ,ISNULL(rt1_absences_undoc + rt1_absences_doc,0) AS rt1_absences_total
      ,ISNULL(rt1_absences_undoc,0) AS rt1_absences_undoc
      ,ISNULL(rt1_absences_doc,0) AS rt1_absences_doc
      ,ISNULL(rt1_tardies_reg + rt1_tardies_T10,0) AS rt1_tardies_total
      ,ISNULL(rt1_tardies_reg,0) AS rt1_tardies_reg
      ,ISNULL(rt1_tardies_T10,0) AS rt1_tardies_T10
      ,ISNULL(rt1_iss,0) AS rt1_iss
      ,ISNULL(rt1_oss,0) AS rt1_oss
      ,ISNULL(RT1_early_dismiss,0) AS rt1_early_dismiss
      --rt2
      ,ISNULL(rt2_absences_undoc + rt2_absences_doc,0) AS rt2_absences_total
      ,ISNULL(rt2_absences_undoc,0) AS rt2_absences_undoc
      ,ISNULL(rt2_absences_doc,0) AS rt2_absences_doc
      ,ISNULL(rt2_tardies_reg + rt2_tardies_T10,0) AS rt2_tardies_total
      ,ISNULL(rt2_tardies_reg,0) AS rt2_tardies_reg
      ,ISNULL(rt2_tardies_T10,0) AS rt2_tardies_T10
      ,ISNULL(rt2_iss,0) AS rt2_iss
      ,ISNULL(rt2_oss,0) AS rt2_oss
      ,ISNULL(RT2_early_dismiss,0) AS rt2_early_dismiss
      --rt3
      ,ISNULL(rt3_absences_undoc + rt3_absences_doc,0) AS rt3_absences_total
      ,ISNULL(rt3_absences_undoc,0) AS rt3_absences_undoc
      ,ISNULL(rt3_absences_doc,0) AS rt3_absences_doc
      ,ISNULL(rt3_tardies_reg + rt3_tardies_T10,0) AS rt3_tardies_total
      ,ISNULL(rt3_tardies_reg,0) AS rt3_tardies_reg
      ,ISNULL(rt3_tardies_T10,0) AS rt3_tardies_T10
      ,ISNULL(rt3_iss,0) AS rt3_iss
      ,ISNULL(rt3_oss,0) AS rt3_oss
      ,ISNULL(RT3_early_dismiss,0) AS rt3_early_dismiss
      --rt4
      ,ISNULL(rt4_absences_undoc + rt4_absences_doc,0) AS rt4_absences_total
      ,ISNULL(rt4_absences_undoc,0) AS rt4_absences_undoc
      ,ISNULL(rt4_absences_doc,0) AS rt4_absences_doc
      ,ISNULL(rt4_tardies_reg + rt4_tardies_T10,0) AS rt4_tardies_total
      ,ISNULL(rt4_tardies_reg,0) AS rt4_tardies_reg
      ,ISNULL(rt4_tardies_T10,0) AS rt4_tardies_T10
      ,ISNULL(rt4_iss,0) AS rt4_iss
      ,ISNULL(rt4_oss,0) AS rt4_oss
      ,ISNULL(RT4_early_dismiss,0) AS rt4_early_dismiss
      --rt5
      ,ISNULL(rt5_absences_undoc + rt5_absences_doc,0) AS rt5_absences_total
      ,ISNULL(rt5_absences_undoc,0) AS rt5_absences_undoc
      ,ISNULL(rt5_absences_doc,0) AS rt5_absences_doc
      ,ISNULL(rt5_tardies_reg + rt5_tardies_T10,0) AS rt5_tardies_total
      ,ISNULL(rt5_tardies_reg,0) AS rt5_tardies_reg
      ,ISNULL(rt5_tardies_T10,0) AS rt5_tardies_T10
      ,ISNULL(rt5_iss,0) AS rt5_iss
      ,ISNULL(rt5_oss,0) AS rt5_oss
      ,ISNULL(RT5_early_dismiss,0) AS rt5_early_dismiss
      --rt6
      ,ISNULL(rt6_absences_undoc + rt6_absences_doc,0) AS rt6_absences_total
      ,ISNULL(rt6_absences_undoc,0) AS rt6_absences_undoc
      ,ISNULL(rt6_absences_doc,0) AS rt6_absences_doc
      ,ISNULL(rt6_tardies_reg + rt6_tardies_T10,0) AS rt6_tardies_total
      ,ISNULL(rt6_tardies_reg,0) AS rt6_tardies_reg
      ,ISNULL(rt6_tardies_T10,0) AS rt6_tardies_T10
      ,ISNULL(rt6_iss,0) AS rt6_iss
      ,ISNULL(rt6_oss,0) AS rt6_oss
      ,ISNULL(RT6_early_dismiss,0) AS rt6_early_dismiss
      --cur
      ,ISNULL(cur_absences_undoc + cur_absences_doc,0) AS cur_absences_total
      ,ISNULL(cur_absences_undoc,0) AS cur_absences_undoc
      ,ISNULL(cur_absences_doc,0) AS cur_absences_doc
      ,ISNULL(cur_tardies_reg + cur_tardies_T10,0) AS cur_tardies_total
      ,ISNULL(cur_tardies_reg,0) AS cur_tardies_reg
      ,ISNULL(cur_tardies_T10,0) AS cur_tardies_T10
      ,ISNULL(cur_iss,0) AS cur_iss
      ,ISNULL(cur_oss,0) AS cur_oss
      ,ISNULL(cur_early_dismiss,0) AS cur_early_dismiss
FROM STUDENTS s
LEFT OUTER JOIN 
     (SELECT studentid
            --Y1
            ,SUM(CASE WHEN att_code = 'A'   AND RT != 'CUR' THEN 1.0 ELSE 0.0 END) AS absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT != 'CUR' THEN 1.0
                      WHEN att_code = 'D'   AND RT != 'CUR' THEN 1.0 ELSE 0.0 END) AS absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT != 'CUR' THEN 1.0 ELSE 0.0 END) AS excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT != 'CUR' THEN 1.0 ELSE 0.0 END) AS tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT != 'CUR' THEN 1.0 ELSE 0.0 END) AS tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT != 'CUR' THEN 1.0 ELSE 0.0 END) AS ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT != 'CUR' THEN 1.0 ELSE 0.0 END) AS OSS
            ,SUM(CASE WHEN att_code = 'PLE' AND RT != 'CUR' THEN 1.0 ELSE 0.0 END) AS early_dismiss
            --RT1
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'RT1' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_OSS
            ,SUM(CASE WHEN att_code = 'PLE' AND RT = 'RT1' THEN 1.0 ELSE 0.0 END) AS RT1_early_dismiss
            --RT2
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'RT2' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_OSS
            ,SUM(CASE WHEN att_code = 'PLE' AND RT = 'RT2' THEN 1.0 ELSE 0.0 END) AS RT2_early_dismiss
            --RT3
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'RT3' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_OSS
            ,SUM(CASE WHEN att_code = 'PLE' AND RT = 'RT3' THEN 1.0 ELSE 0.0 END) AS RT3_early_dismiss
            --RT4
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'RT4' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_OSS
            ,SUM(CASE WHEN att_code = 'PLE' AND RT = 'RT4' THEN 1.0 ELSE 0.0 END) AS RT4_early_dismiss
            --RT5
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'RT5' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_OSS
            ,SUM(CASE WHEN att_code = 'PLE' AND RT = 'RT5' THEN 1.0 ELSE 0.0 END) AS RT5_early_dismiss
            --RT6
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'RT6' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_OSS
            ,SUM(CASE WHEN att_code = 'PLE' AND RT = 'RT6' THEN 1.0 ELSE 0.0 END) AS RT6_early_dismiss
             --cur
            ,SUM(CASE WHEN att_code = 'A'   AND RT = 'CUR' THEN 1.0 ELSE 0.0 END) AS cur_absences_undoc
            ,SUM(CASE WHEN att_code = 'AD'  AND RT = 'CUR' THEN 1.0
                      WHEN att_code = 'D'   AND RT = 'CUR' THEN 1.0 ELSE 0.0 END) AS cur_absences_doc
            ,SUM(CASE WHEN att_code = 'AE'  AND RT = 'CUR' THEN 1.0 ELSE 0.0 END) AS cur_excused_absences
            ,SUM(CASE WHEN att_code = 'T'   AND RT = 'CUR' THEN 1.0 ELSE 0.0 END) AS cur_tardies_reg
            ,SUM(CASE WHEN att_code = 'T10' AND RT = 'CUR' THEN 1.0 ELSE 0.0 END) AS cur_tardies_T10
            ,SUM(CASE WHEN att_code = 'S'   AND RT = 'CUR' THEN 1.0 ELSE 0.0 END) AS cur_ISS
            ,SUM(CASE WHEN att_code = 'OS'  AND RT = 'CUR' THEN 1.0 ELSE 0.0 END) AS cur_OSS
            ,SUM(CASE WHEN att_code = 'PLE' AND RT = 'CUR' THEN 1.0 ELSE 0.0 END) AS cur_early_dismiss
      FROM            
           (SELECT studentid
                  ,psad.att_date
                  ,psad.att_code                  
                  ,dates.time_per_name AS RT
            FROM ATTENDANCE psad
            JOIN REPORTING$dates dates
              ON psad.att_date >= dates.start_date
             AND psad.att_date <= dates.end_date
             AND psad.schoolid = dates.schoolid
             AND dates.identifier = 'RT'
            WHERE psad.att_code IS NOT NULL               
            
            UNION ALL
            
            SELECT psad.studentid
                  ,psad.att_date
                  ,psad.att_code                  
                  ,'CUR' AS RT            
            FROM ATTENDANCE psad
            JOIN REPORTING$dates curterm
              ON curterm.identifier = 'RT'
             AND curterm.start_date <= GETDATE()
             AND curterm.end_date >= GETDATE()
             AND psad.schoolid = curterm.schoolid
            WHERE psad.att_code IS NOT NULL                          
              AND psad.att_date >= curterm.start_date
              AND psad.att_date <= curterm.end_date
           ) sub
      GROUP BY studentid
     ) psad
  ON s.id = psad.studentid
WHERE s.entrydate >= '2013-08-01'    
--ORDER BY s.schoolid, s.grade_level, s.lastfirst
ORDER BY absences_total DESC