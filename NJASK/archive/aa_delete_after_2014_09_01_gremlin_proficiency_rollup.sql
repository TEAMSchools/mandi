USE [KIPP_NJ]
GO

/****** Object:  View [dbo].[aa_delete_after_2014_09_01_gremlin_proficiency_rollup]    Script Date: 4/15/2015 9:55:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[aa_delete_after_2014_09_01_gremlin_proficiency_rollup] AS
SELECT cur.test_year + 1 AS year
      ,CASE GROUPING(sch.abbreviation)
         WHEN 1 THEN 'Network'
         ELSE sch.abbreviation
       END AS school
      ,cur.subject
      ,cur.test_grade_level AS grade_level
      ,COUNT(*) AS n_tested
      ,AVG(njask_scale_score) AS avg_scale
      ,CAST(ROUND(AVG(CASE 
         WHEN njask_scale_score >= 200 THEN 0.0
         WHEN njask_scale_score < 200 THEN 1.0
       END) * 100, 0) AS NUMERIC(3,0)) AS part_prof
      ,CAST(ROUND(AVG(CASE 
         WHEN njask_scale_score >= 250 THEN 0.0
         WHEN njask_scale_score >= 200 THEN 1.0
         WHEN njask_scale_score < 200 THEN 0.0
       END) * 100, 0) AS NUMERIC(3,0)) AS prof
      ,CAST(ROUND(AVG(CASE 
         WHEN njask_scale_score >= 250 THEN 1.0
         WHEN njask_scale_score < 250 THEN 0.0
       END) * 100, 0) AS NUMERIC(3,0)) AS adv_prof
      ,CAST(ROUND(AVG(CASE 
         WHEN njask_scale_score >= 200 THEN 1.0
         WHEN njask_scale_score < 200 THEN 0.0
       END) * 100, 0) AS NUMERIC(3,0)) AS pct_prof
FROM KIPP_NJ..aa_delete_after_2014_09_01_njask_2013 cur
JOIN KIPP_NJ..SCHOOLS sch
  ON cur.test_schoolid = sch.school_number
GROUP BY cur.test_year
        ,CUBE(sch.abbreviation)
        ,cur.subject
        ,cur.test_grade_level

GO


