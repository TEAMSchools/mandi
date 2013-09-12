/*
PURPOSE:
  Attendance percentages for students: all schools, all terms
  Total absences, Undoc, Doc, Total Tardies, Tardies, T10

MAINTENANCE:
  Depends on MV Attendance Counts (Oracle) being up to date
  Depends on MV Membership Counts (Oracle) being up to date

MAJOR STRUCTURAL REVISIONS OR CHANGES:
  "Ported" to Server -CB
  
TO DO:
  create attendance_counts & membership_counts AS views on Server

CREATED BY: AM2

ORIGIN DATE: Fall 2011
LAST MODIFIED: Fall 2013 (CB)
*/

CREATE VIEW ATT_MEM$att_percentages AS
SELECT att.id
      ,att.lastfirst
      ,att.schoolid
      ,att.grade_level       
--attendance percentage total
      ,CASE
        WHEN mem = 0 THEN NULL 
        ELSE ROUND(((mem - absences_total) / mem) * 100,2)
       END AS y1_att_pct_total
      ,CASE
        WHEN rt1_mem = 0 THEN NULL
        ELSE ROUND(((rt1_mem - rt1_absences_total) / rt1_mem) * 100,2)
       END AS rt1_att_pct_total
      ,CASE
        WHEN rt2_mem = 0 THEN NULL
        ELSE ROUND(((rt2_mem - rt2_absences_total) / rt2_mem) * 100,2)
       END AS rt2_att_pct_total
      ,CASE
        WHEN rt3_mem = 0 THEN NULL
        ELSE ROUND(((rt3_mem - rt3_absences_total) / rt3_mem) * 100,2)
       END AS rt3_att_pct_total
      ,CASE
        WHEN rt4_mem = 0 THEN NULL
        ELSE ROUND(((rt4_mem - rt4_absences_total) / rt4_mem) * 100,2) 
       END AS rt4_att_pct_total
      ,CASE
        WHEN rt5_mem = 0 THEN NULL
        ELSE ROUND(((rt5_mem - rt5_absences_total) / rt5_mem) * 100,2)
       END AS rt5_att_pct_total
      ,CASE
        WHEN rt6_mem = 0 THEN NULL
        ELSE ROUND(((rt6_mem - rt6_absences_total) / rt6_mem) * 100,2)
       END AS rt6_att_pct_total
      --attendance percentage, excluding documented absences (undocumented only) only
      ,CASE
        WHEN mem = 0 THEN NULL
        ELSE ROUND(((mem - absences_undoc) / mem) * 100,2)
       END AS y1_att_pct_undoc
      ,CASE
        WHEN rt1_mem = 0 THEN NULL 
        ELSE ROUND(((rt1_mem - rt1_absences_undoc) / rt1_mem) * 100,2)
       END AS rt1_att_pct_undoc
      ,CASE
        WHEN rt2_mem = 0 THEN NULL 
        ELSE ROUND(((rt2_mem - rt2_absences_undoc) / rt2_mem) * 100,2) 
       END AS rt2_att_pct_undoc
      ,CASE
        WHEN rt3_mem = 0 THEN NULL 
        ELSE ROUND(((rt3_mem - rt3_absences_undoc) / rt3_mem) * 100,2) 
       END AS rt3_att_pct_undoc 
      ,CASE
        WHEN rt4_mem = 0 THEN NULL 
        ELSE ROUND(((rt4_mem - rt4_absences_undoc) / rt4_mem) * 100,2) 
       END AS rt4_att_pct_undoc
      ,CASE
        WHEN rt5_mem = 0 THEN NULL 
        ELSE ROUND(((rt5_mem - rt5_absences_undoc) / rt5_mem) * 100,2)
       END AS rt5_att_pct_undoc
      ,CASE
        WHEN rt6_mem = 0 THEN NULL 
        ELSE ROUND(((rt6_mem - rt6_absences_undoc) / rt6_mem) * 100,2) 
       END AS rt6_att_pct_undoc   
      --tardy percentage total
      ,CASE
        WHEN mem = 0 THEN NULL 
        ELSE ROUND((tardies_total / mem) * 100,2) 
       END AS y1_tardy_pct_total
      ,CASE
        WHEN rt1_mem = 0 THEN NULL
        ELSE ROUND((rt1_tardies_total / rt1_mem) * 100,2) 
       END AS rt1_tardy_pct_total
      ,CASE
        WHEN rt2_mem = 0 THEN NULL 
        ELSE ROUND((rt2_tardies_total / rt2_mem) * 100,2) 
       END AS rt2_tardy_pct_total
      ,CASE
        WHEN rt3_mem = 0 THEN NULL 
        ELSE ROUND((rt3_tardies_total / rt3_mem) * 100,2) 
       END AS rt3_tardy_pct_total 
      ,CASE
        WHEN rt4_mem = 0 THEN NULL 
        ELSE ROUND((rt4_tardies_total / rt4_mem) * 100,2) 
       END AS rt4_tardy_pct_total
      ,CASE
        WHEN rt5_mem = 0 THEN NULL 
        ELSE ROUND((rt5_tardies_total / rt5_mem) * 100,2) 
       END AS rt5_tardy_pct_total
      ,CASE
        WHEN rt6_mem = 0 THEN NULL 
        ELSE ROUND((rt6_tardies_total / rt6_mem) * 100,2) 
       END AS rt6_tardy_pct_total   
      --tardy percentage regular only
      ,CASE
        WHEN mem = 0 THEN NULL 
        ELSE ROUND((tardies_reg / mem) * 100,2) 
       END AS y1_tardy_pct_reg
      ,CASE
        WHEN rt1_mem = 0 THEN NULL 
        ELSE ROUND((rt1_tardies_reg / rt1_mem) * 100,2) 
       END AS rt1_tardy_pct_reg
      ,CASE
        WHEN rt2_mem = 0 THEN NULL 
        ELSE ROUND((rt2_tardies_reg / rt2_mem) * 100,2) 
       END AS rt2_tardy_pct_reg
      ,CASE
        WHEN rt3_mem = 0 THEN NULL 
        ELSE ROUND((rt3_tardies_reg / rt3_mem) * 100,2) 
       END AS rt3_tardy_pct_reg 
      ,CASE
        WHEN rt4_mem = 0 THEN NULL 
        ELSE ROUND((rt4_tardies_reg / rt4_mem) * 100,2) 
       END AS rt4_tardy_pct_reg
      ,CASE
        WHEN rt5_mem = 0 THEN NULL 
        ELSE ROUND((rt5_tardies_reg / rt5_mem) * 100,2) 
       END AS rt5_tardy_pct_reg
      ,CASE
        WHEN rt6_mem = 0 THEN NULL 
        ELSE ROUND((rt6_tardies_reg / rt6_mem) * 100,2) 
       END AS rt6_tardy_pct_reg
      --tardy percentage t10 only
      ,CASE
        WHEN mem = 0 THEN NULL 
        ELSE ROUND((tardies_T10 / mem) * 100,2) 
       END AS y1_tardy_pct_T10
      ,CASE
        WHEN rt1_mem = 0 THEN NULL 
        ELSE ROUND((rt1_tardies_T10 / rt1_mem) * 100,2) 
       END AS rt1_tardy_pct_T10
      ,CASE
        WHEN rt2_mem = 0 THEN NULL 
        ELSE ROUND((rt2_tardies_T10 / rt2_mem) * 100,2) 
       END AS rt2_tardy_pct_T10
      ,CASE
        WHEN rt3_mem = 0 THEN NULL 
        ELSE ROUND((rt3_tardies_T10 / rt3_mem) * 100,2) 
       END AS rt3_tardy_pct_T10 
      ,CASE
        WHEN rt4_mem = 0 THEN NULL 
        ELSE ROUND((rt4_tardies_T10 / rt4_mem) * 100,2) 
       END AS rt4_tardy_pct_T10
      ,CASE
        WHEN rt5_mem = 0 THEN NULL 
        ELSE ROUND((rt5_tardies_T10 / rt5_mem) * 100,2) 
       END AS rt5_tardy_pct_T10
      ,CASE
        WHEN rt6_mem = 0 THEN NULL 
        ELSE ROUND((rt6_tardies_T10 / rt6_mem) * 100,2) 
       END AS rt6_tardy_pct_T10

FROM KIPP_NJ..ATT_MEM$attendance_counts att
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$membership_counts mem
             ON att.id = mem.id