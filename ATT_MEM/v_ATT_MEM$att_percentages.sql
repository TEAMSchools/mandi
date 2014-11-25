/*
PURPOSE:
  Attendance percentages for students: all schools, all terms
  Total absences, Undoc, Doc, Total Tardies, Tardies, T10

MAINTENANCE:
 ATT_MEM$attendance_counts
 ATT_MEM$membership_counts

MAJOR STRUCTURAL REVISIONS OR CHANGES:
  Ported to Server -CB (8/13)
  Uses new identifiers from counts (7/14)
  
TO DO:
  create attendance_counts & membership_counts AS views on Server

CREATED BY: AM2

ORIGIN DATE: Fall 2011
LAST MODIFIED: 7/14 (CB)
*/

ALTER VIEW ATT_MEM$att_percentages AS
SELECT att.studentid
      --attendance percentage, all absence types
      ,ISNULL(ROUND(((y1_mem - y1_abs_all) / y1_mem) * 100,1),0) AS y1_att_pct_total
      ,ISNULL(ROUND(((rt1_mem - rt1_abs_all) / rt1_mem) * 100,1),0) AS rt1_att_pct_total
      ,ISNULL(ROUND(((rt2_mem - rt2_abs_all) / rt2_mem) * 100,1),0) AS rt2_att_pct_total
      ,ISNULL(ROUND(((rt3_mem - rt3_abs_all) / rt3_mem) * 100,1),0) AS rt3_att_pct_total
      ,ISNULL(ROUND(((rt4_mem - rt4_abs_all) / rt4_mem) * 100,1),0) AS rt4_att_pct_total
      ,ISNULL(ROUND(((rt5_mem - rt5_abs_all) / rt5_mem) * 100,1),0) AS rt5_att_pct_total
      ,ISNULL(ROUND(((rt6_mem - rt6_abs_all) / rt6_mem) * 100,1),0) AS rt6_att_pct_total
      ,ISNULL(ROUND(((cur_mem - cur_abs_all) / cur_mem) * 100,1),0) AS cur_att_pct_total
      --attendance percentage, undocumented only
      ,ISNULL(ROUND(((y1_mem - y1_a) / y1_mem) * 100,1),0) AS y1_att_pct_undoc
      ,ISNULL(ROUND(((rt1_mem - rt1_a) / rt1_mem) * 100,1),0) AS rt1_att_pct_undoc
      ,ISNULL(ROUND(((rt2_mem - rt2_a) / rt2_mem) * 100,1),0) AS rt2_att_pct_undoc
      ,ISNULL(ROUND(((rt3_mem - rt3_a) / rt3_mem) * 100,1),0) AS rt3_att_pct_undoc 
      ,ISNULL(ROUND(((rt4_mem - rt4_a) / rt4_mem) * 100,1),0) AS rt4_att_pct_undoc
      ,ISNULL(ROUND(((rt5_mem - rt5_a) / rt5_mem) * 100,1),0) AS rt5_att_pct_undoc
      ,ISNULL(ROUND(((rt6_mem - rt6_a) / rt6_mem) * 100,1),0) AS rt6_att_pct_undoc   
      ,ISNULL(ROUND(((cur_mem - cur_a) / cur_mem) * 100,1),0) AS cur_att_pct_undoc   
      --tardy percentage, all tardy types
      ,ISNULL(ROUND((y1_t_all / y1_mem) * 100,1),0) AS y1_tardy_pct_total
      ,ISNULL(ROUND((rt1_t_all / rt1_mem) * 100,1),0) AS rt1_tardy_pct_total
      ,ISNULL(ROUND((rt2_t_all / rt2_mem) * 100,1),0) AS rt2_tardy_pct_total
      ,ISNULL(ROUND((rt3_t_all / rt3_mem) * 100,1),0) AS rt3_tardy_pct_total 
      ,ISNULL(ROUND((rt4_t_all / rt4_mem) * 100,1),0) AS rt4_tardy_pct_total
      ,ISNULL(ROUND((rt5_t_all / rt5_mem) * 100,1),0) AS rt5_tardy_pct_total
      ,ISNULL(ROUND((rt6_t_all / rt6_mem) * 100,1),0) AS rt6_tardy_pct_total   
      ,ISNULL(ROUND((cur_t_all / cur_mem) * 100,1),0) AS cur_tardy_pct_total   
      --tardy percentage, regular only
      ,ISNULL(ROUND((y1_t / y1_mem) * 100,1),0) AS y1_tardy_pct_reg
      ,ISNULL(ROUND((rt1_t / rt1_mem) * 100,1),0) AS rt1_tardy_pct_reg
      ,ISNULL(ROUND((rt2_t / rt2_mem) * 100,1),0) AS rt2_tardy_pct_reg
      ,ISNULL(ROUND((rt3_t / rt3_mem) * 100,1),0) AS rt3_tardy_pct_reg 
      ,ISNULL(ROUND((rt4_t / rt4_mem) * 100,1),0) AS rt4_tardy_pct_reg
      ,ISNULL(ROUND((rt5_t / rt5_mem) * 100,1),0) AS rt5_tardy_pct_reg
      ,ISNULL(ROUND((rt6_t / rt6_mem) * 100,1),0) AS rt6_tardy_pct_reg
      ,ISNULL(ROUND((cur_t / cur_mem) * 100,1),0) AS cur_tardy_pct_reg
      --tardy percentage, t10 only
      ,ISNULL(ROUND((y1_t10 / y1_mem) * 100,1),0) AS y1_tardy_pct_t10
      ,ISNULL(ROUND((rt1_t10 / rt1_mem) * 100,1),0) AS rt1_tardy_pct_t10
      ,ISNULL(ROUND((rt2_t10 / rt2_mem) * 100,1),0) AS rt2_tardy_pct_t10
      ,ISNULL(ROUND((rt3_t10 / rt3_mem) * 100,1),0) AS rt3_tardy_pct_t10 
      ,ISNULL(ROUND((rt4_t10 / rt4_mem) * 100,1),0) AS rt4_tardy_pct_t10
      ,ISNULL(ROUND((rt5_t10 / rt5_mem) * 100,1),0) AS rt5_tardy_pct_t10
      ,ISNULL(ROUND((rt6_t10 / rt6_mem) * 100,1),0) AS rt6_tardy_pct_t10
      ,ISNULL(ROUND((cur_t10 / cur_mem) * 100,1),0) AS cur_tardy_pct_t10
FROM att_mem$attendance_counts#static att WITH (NOLOCK)
LEFT OUTER JOIN ATT_MEM$membership_counts#static mem  WITH (NOLOCK)
  ON att.studentid = mem.studentid