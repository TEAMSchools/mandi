USE KIPP_NJ
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_GRADES$elements|refresh] AS

BEGIN
  IF OBJECT_ID(N'tempdb..#GRADES$elements_s1') IS NOT NULL
  BEGIN
    DROP TABLE [#GRADES$elements_s1]
  END;
  
  IF OBJECT_ID(N'tempdb..#GRADES$elements_s2') IS NOT NULL
  BEGIN
    DROP TABLE [#GRADES$elements_s2]
  END;

  IF OBJECT_ID(N'tempdb..#GRADES$elements_s3') IS NOT NULL
  BEGIN
    DROP TABLE [#GRADES$elements_s3]
  END;

  IF OBJECT_ID(N'tempdb..#GRADES$elements_final') IS NOT NULL
  BEGIN
    DROP TABLE [#GRADES$elements_final]
  END;
 
  SELECT studentid
        ,schoolid
        ,yearid
        ,finalgradename
        ,[percent]
        ,COURSE_NUMBER
        ,pgf_type
        ,pgf_seq_num
  INTO #GRADES$elements_s1  
  FROM
      (
       SELECT CONVERT(INT,oq.studentid) AS studentid
             ,CONVERT(INT,cc.schoolid) AS schoolid
             ,LEFT(cc.termid, 2) AS yearid
             ,finalgradename
             ,CONVERT(FLOAT,[percent]) AS [percent]
             ,course_number      
             ,LEFT(oq.finalgradename, 1) AS pgf_type
             ,RIGHT(oq.finalgradename, 1) AS pgf_seq_num              
       FROM OPENQUERY(PS_TEAM, '
         SELECT pgf.sectionid
               ,pgf.studentid
               ,pgf.finalgradename
               ,pgf.percent                
         FROM pgfinalgrades pgf  
         WHERE pgf.startdate >= TO_DATE(''2014-08-01'',''YYYY-MM-DD'')
           AND pgf.startdate <= TRUNC(SYSDATE)    
           AND pgf.percent != 0
           AND SUBSTR(pgf.finalgradename, 0, 1) != ''T''
       ') oq
       JOIN CC WITH(NOLOCK)
         ON oq.sectionid = cc.sectionid
        AND oq.studentid = cc.STUDENTID
      ) sub
  --Rise uses Q for HW quality, others should be EXCLUDED
  WHERE (sub.schoolid = 73252 OR (sub.schoolid != 73252 AND sub.pgf_type != 'Q'));
  
  SELECT sub_1.studentid
        ,sub_1.schoolid
        ,sub_1.yearid
        ,sub_1.course_number
        ,sub_1.pgf_type
        ,sub_1.grade_1
        ,sub_1.grade_2
        ,sub_1.grade_3
        ,sub_1.grade_4
        ,sub_1.grade_1_ct
        ,sub_1.grade_2_ct
        ,sub_1.grade_3_ct
        ,sub_1.grade_4_ct
         -- are the number of values evaluated by MAX larger than the number of non-null grade_1/grade_2 grades?
        ,CASE
           WHEN 
             (sub_1.grade_1_ct + sub_1.grade_2_ct + sub_1.grade_3_ct + sub_1.grade_4_ct) --this statement counts how many values were evaulated by the max statement in sq_2                
                >
             ((CASE WHEN sub_1.grade_1 IS NOT NULL THEN 1 ELSE 0 END) -- this statement counts how many grade_1-grade_4 records are not null
                + (CASE WHEN sub_1.grade_2 IS NOT NULL THEN 1 ELSE 0 END)
                + (CASE WHEN sub_1.grade_3 IS NOT NULL THEN 1 ELSE 0 END)
                + (CASE WHEN sub_1.grade_4 IS NOT NULL THEN 1 ELSE 0 END))
             THEN 'Flag'
           ELSE NULL
         END AS underlying_audit
  INTO [#GRADES$elements_s2]
  FROM
      (
       SELECT temp_ele.studentid
             ,temp_ele.schoolid
             ,temp_ele.yearid
             ,temp_ele.course_number
             ,temp_ele.pgf_type
             ,MAX(CASE WHEN temp_ele.pgf_seq_num = 1 THEN temp_ele.[percent] ELSE NULL END) AS grade_1
             ,MAX(CASE WHEN temp_ele.pgf_seq_num = 2 THEN temp_ele.[percent] ELSE NULL END) AS grade_2
             ,MAX(CASE WHEN temp_ele.pgf_seq_num = 3 THEN temp_ele.[percent] ELSE NULL END) AS grade_3
             ,MAX(CASE WHEN temp_ele.pgf_seq_num = 4 THEN temp_ele.[percent] ELSE NULL END) AS grade_4
             ,SUM(CASE WHEN temp_ele.pgf_seq_num = 1 THEN 1 ELSE 0 END) AS grade_1_ct
             ,SUM(CASE WHEN temp_ele.pgf_seq_num = 2 THEN 1 ELSE 0 END) AS grade_2_ct
             ,SUM(CASE WHEN temp_ele.pgf_seq_num = 3 THEN 1 ELSE 0 END) AS grade_3_ct
             ,SUM(CASE WHEN temp_ele.pgf_seq_num = 4 THEN 1 ELSE 0 END) AS grade_4_ct           
       FROM #GRADES$elements_s1 temp_ele
       GROUP BY temp_ele.studentid
               ,temp_ele.schoolid
               ,temp_ele.yearid
               ,temp_ele.course_number
               ,temp_ele.pgf_type
      ) sub_1;
  
  SELECT studentid
        ,schoolid
        ,yearid
        ,CASE GROUPING(course_number) 
           WHEN 1 THEN 'all_courses'
           ELSE course_number
         END AS course_number
        ,pgf_type
        ,ROUND(AVG(grade_1),0) AS grade_1
        ,ROUND(AVG(grade_2),0) AS grade_2
        ,ROUND(AVG(grade_3),0) AS grade_3
        ,ROUND(AVG(grade_4),0) AS grade_4
        ,ROUND(AVG(ROUND(
           (ISNULL(grade_1, 0) + ISNULL(grade_2, 0) + ISNULL(grade_3, 0) + ISNULL(grade_4, 0)) / 
             (grade_1_ct + grade_2_ct + grade_3_ct + grade_4_ct)
           ,1)),0) AS simple_avg
  INTO [#GRADES$elements_s3]
  FROM [#GRADES$elements_s2]
  GROUP BY studentid
        ,schoolid
        ,yearid
        ,pgf_type
        ,ROLLUP(course_number);
  
  SELECT ele.*
        ,scales.letter_grade
  INTO [#GRADES$elements_final]
  FROM [#GRADES$elements_s3] ele
  JOIN KIPP_NJ..GRADES$grade_scales#static scales WITH(NOLOCK)
    ON ele.simple_avg >= scales.low_cut 
   AND ele.simple_avg <  scales.high_cut
   AND scales.scale_name = 'NCA 2011';
  
  EXEC('TRUNCATE TABLE dbo.[GRADES$elements]');
 
  INSERT INTO [GRADES$elements]
  SELECT *
  FROM [#GRADES$elements_final]; 
    
END