USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$att_percentages AS
/* CASE statments are a hotfix, ATT & MEM counts need to go long */

SELECT att.studentid
      --attendance percentage, all absence types
      ,ISNULL(ROUND(((CASE WHEN y1_mem = 0 THEN NULL ELSE y1_mem END - y1_abs_all) / CASE WHEN y1_mem = 0 THEN NULL ELSE y1_mem END) * 100,1),0) AS y1_att_pct_total
      ,ISNULL(ROUND(((CASE WHEN rt1_mem = 0 THEN NULL ELSE rt1_mem END - rt1_abs_all) / CASE WHEN rt1_mem = 0 THEN NULL ELSE rt1_mem END) * 100,1),0) AS rt1_att_pct_total
      ,ISNULL(ROUND(((CASE WHEN rt2_mem = 0 THEN NULL ELSE rt2_mem END - rt2_abs_all) / CASE WHEN rt2_mem = 0 THEN NULL ELSE rt2_mem END) * 100,1),0) AS rt2_att_pct_total
      ,ISNULL(ROUND(((rt3_mem - rt3_abs_all) / rt3_mem) * 100,1),0) AS rt3_att_pct_total
      ,ISNULL(ROUND(((rt4_mem - rt4_abs_all) / rt4_mem) * 100,1),0) AS rt4_att_pct_total
      ,ISNULL(ROUND(((rt5_mem - rt5_abs_all) / rt5_mem) * 100,1),0) AS rt5_att_pct_total
      ,ISNULL(ROUND(((rt6_mem - rt6_abs_all) / rt6_mem) * 100,1),0) AS rt6_att_pct_total
      ,ISNULL(ROUND(((cur_mem - cur_abs_all) / cur_mem) * 100,1),0) AS cur_att_pct_total
      --attendance percentage, undocumented only
      ,ISNULL(ROUND(((CASE WHEN y1_mem = 0 THEN NULL ELSE y1_mem END - y1_a) / CASE WHEN y1_mem = 0 THEN NULL ELSE y1_mem END) * 100,1),0) AS y1_att_pct_undoc
      ,ISNULL(ROUND(((CASE WHEN rt1_mem = 0 THEN NULL ELSE rt1_mem END - rt1_a) / CASE WHEN rt1_mem = 0 THEN NULL ELSE rt1_mem END) * 100,1),0) AS rt1_att_pct_undoc
      ,ISNULL(ROUND(((CASE WHEN rt2_mem = 0 THEN NULL ELSE rt2_mem END - rt2_a) / CASE WHEN rt2_mem = 0 THEN NULL ELSE rt2_mem END) * 100,1),0) AS rt2_att_pct_undoc
      ,ISNULL(ROUND(((rt3_mem - rt3_a) / rt3_mem) * 100,1),0) AS rt3_att_pct_undoc 
      ,ISNULL(ROUND(((rt4_mem - rt4_a) / rt4_mem) * 100,1),0) AS rt4_att_pct_undoc
      ,ISNULL(ROUND(((rt5_mem - rt5_a) / rt5_mem) * 100,1),0) AS rt5_att_pct_undoc
      ,ISNULL(ROUND(((rt6_mem - rt6_a) / rt6_mem) * 100,1),0) AS rt6_att_pct_undoc   
      ,ISNULL(ROUND(((cur_mem - cur_a) / cur_mem) * 100,1),0) AS cur_att_pct_undoc   
      --tardy percentage, all tardy types
      ,ISNULL(ROUND((y1_t_all / CASE WHEN y1_mem = 0 THEN NULL ELSE y1_mem END) * 100,1),0) AS y1_tardy_pct_total
      ,ISNULL(ROUND((rt1_t_all / CASE WHEN rt1_mem = 0 THEN NULL ELSE rt1_mem END) * 100,1),0) AS rt1_tardy_pct_total
      ,ISNULL(ROUND((rt2_t_all / CASE WHEN rt2_mem = 0 THEN NULL ELSE rt2_mem END) * 100,1),0) AS rt2_tardy_pct_total
      ,ISNULL(ROUND((rt3_t_all / rt3_mem) * 100,1),0) AS rt3_tardy_pct_total 
      ,ISNULL(ROUND((rt4_t_all / rt4_mem) * 100,1),0) AS rt4_tardy_pct_total
      ,ISNULL(ROUND((rt5_t_all / rt5_mem) * 100,1),0) AS rt5_tardy_pct_total
      ,ISNULL(ROUND((rt6_t_all / rt6_mem) * 100,1),0) AS rt6_tardy_pct_total   
      ,ISNULL(ROUND((cur_t_all / cur_mem) * 100,1),0) AS cur_tardy_pct_total   
      --tardy percentage, regular only
      ,ISNULL(ROUND((y1_t / CASE WHEN y1_mem = 0 THEN NULL ELSE y1_mem END) * 100,1),0) AS y1_tardy_pct_reg
      ,ISNULL(ROUND((rt1_t / CASE WHEN rt1_mem = 0 THEN NULL ELSE rt1_mem END) * 100,1),0) AS rt1_tardy_pct_reg
      ,ISNULL(ROUND((rt2_t / CASE WHEN rt2_mem = 0 THEN NULL ELSE rt2_mem END) * 100,1),0) AS rt2_tardy_pct_reg
      ,ISNULL(ROUND((rt3_t / rt3_mem) * 100,1),0) AS rt3_tardy_pct_reg 
      ,ISNULL(ROUND((rt4_t / rt4_mem) * 100,1),0) AS rt4_tardy_pct_reg
      ,ISNULL(ROUND((rt5_t / rt5_mem) * 100,1),0) AS rt5_tardy_pct_reg
      ,ISNULL(ROUND((rt6_t / rt6_mem) * 100,1),0) AS rt6_tardy_pct_reg
      ,ISNULL(ROUND((cur_t / cur_mem) * 100,1),0) AS cur_tardy_pct_reg
      --tardy percentage, t10 only
      ,ISNULL(ROUND((y1_t10 / CASE WHEN y1_mem = 0 THEN NULL ELSE y1_mem END) * 100,1),0) AS y1_tardy_pct_t10
      ,ISNULL(ROUND((rt1_t10 / CASE WHEN rt1_mem = 0 THEN NULL ELSE rt1_mem END) * 100,1),0) AS rt1_tardy_pct_t10
      ,ISNULL(ROUND((rt2_t10 / CASE WHEN rt2_mem = 0 THEN NULL ELSE rt2_mem END) * 100,1),0) AS rt2_tardy_pct_t10
      ,ISNULL(ROUND((rt3_t10 / rt3_mem) * 100,1),0) AS rt3_tardy_pct_t10 
      ,ISNULL(ROUND((rt4_t10 / rt4_mem) * 100,1),0) AS rt4_tardy_pct_t10
      ,ISNULL(ROUND((rt5_t10 / rt5_mem) * 100,1),0) AS rt5_tardy_pct_t10
      ,ISNULL(ROUND((rt6_t10 / rt6_mem) * 100,1),0) AS rt6_tardy_pct_t10
      ,ISNULL(ROUND((cur_t10 / cur_mem) * 100,1),0) AS cur_tardy_pct_t10
FROM att_mem$attendance_counts#static att WITH (NOLOCK)
LEFT OUTER JOIN ATT_MEM$membership_counts#static mem  WITH (NOLOCK)
  ON att.studentid = mem.studentid