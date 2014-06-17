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
  END
  
  IF OBJECT_ID(N'tempdb..#GRADES$elemegnts_s2') IS NOT NULL
  BEGIN
    DROP TABLE [#GRADES$elements_s2]
  END

  IF OBJECT_ID(N'tempdb..#GRADES$elements_s3') IS NOT NULL
  BEGIN
    DROP TABLE [#GRADES$elements_s3]
  END

  IF OBJECT_ID(N'tempdb..#GRADES$elements_final') IS NOT NULL
  BEGIN
    DROP TABLE [#GRADES$elements_final]
  END
 
  SELECT CAST(studentid AS INT) AS studentid
        ,CAST(schoolid AS INT) AS schoolid
        ,CAST(yearid AS INT) AS yearid
        ,finalgradename
        ,CAST([percent] AS FLOAT) AS [percent]
        ,course_number
        ,pgf_type
        ,CAST(pgf_seq_num AS INT) AS pgf_seq_num
        ,CAST(date1 AS DATE) AS start_date
        ,CAST(date2 AS DATE) AS end_date
  INTO #GRADES$elements_s1
  FROM OPENQUERY(PS_TEAM, '
    SELECT pgf.sectionid
          ,pgf.studentid
          ,pgf.finalgradename
          ,pgf.percent
          ,cc.course_number
          ,cc.schoolid
          --break out the TYPE from the SEQUENCE
          ,SUBSTR(pgf.finalgradename, 0, 1) AS pgf_type
          ,SUBSTR(pgf.finalgradename, 2, 2) AS pgf_seq_num
          ,termbins.date1
          ,termbins.date2
          ,termbins.yearid
    FROM pgfinalgrades pgf
    JOIN cc
      ON pgf.sectionid = cc.sectionid 
     AND pgf.studentid = cc.studentid
     
     --are we concerned about spurious 0s?
     AND pgf.percent != 0
     
     AND cc.termid >= 2300
     --JUST FOR TESTING
     --AND cc.studentid = 2542
     --never use T trimester grades
     AND SUBSTR(pgf.finalgradename, 0, 1) != ''T''
     --Rise uses Q for HW quality, others should be EXCLUDED
     AND (cc.schoolid = 73252 OR
     (cc.schoolid != 73252 AND SUBSTR(pgf.finalgradename, 0, 1) != ''Q''))  
     JOIN termbins
       ON cc.termid = termbins.termid
      AND cc.schoolid = termbins.schoolid
      AND pgf.finalgradename = termbins.storecode
      --ignore the future
      AND termbins.date1 <= TRUNC(SYSDATE)
  ') sub
  
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
           WHEN --this statement counts how many values were evaulated by the max statement in sq_2
             (sub_1.grade_1_ct + sub_1.grade_2_ct + sub_1.grade_3_ct + sub_1.grade_4_ct) >  
                --this statement counts how many grade_1-grade_4 records are not null
              ((CASE
                  WHEN sub_1.grade_1 IS NOT NULL THEN 1
                  ELSE 0
                END)
              +(CASE
                  WHEN sub_1.grade_2 IS NOT NULL THEN 1
                  ELSE 0
                END)
              +(CASE
                  WHEN sub_1.grade_3 IS NOT NULL THEN 1
                  ELSE 0
                END)
              +(CASE
                  WHEN sub_1.grade_4 IS NOT NULL THEN 1
                  ELSE 0
                END))
           THEN 'Flag'
           ELSE NULL
         END AS underlying_audit
  INTO [#GRADES$elements_s2]
  FROM
       (SELECT temp_ele.studentid
              ,temp_ele.schoolid
              ,temp_ele.yearid
              ,temp_ele.course_number
              ,temp_ele.pgf_type
              ,MAX(CASE 
                     WHEN temp_ele.pgf_seq_num = 1 THEN temp_ele.[percent]
                     ELSE NULL
                   END) AS grade_1
              ,MAX(CASE 
                     WHEN temp_ele.pgf_seq_num = 2 THEN temp_ele.[percent]
                     ELSE NULL
                   end) AS grade_2
              ,MAX(CASE 
                     WHEN temp_ele.pgf_seq_num = 3 THEN temp_ele.[percent]
                     ELSE NULL
                   END) AS grade_3
              ,MAX(CASE 
                     WHEN temp_ele.pgf_seq_num = 4 THEN temp_ele.[percent]
                     ELSE NULL
                   END) AS grade_4
              ,SUM(CASE
                     WHEN temp_ele.pgf_seq_num = 1 THEN 1
                     ELSE 0
                   END) AS grade_1_ct
              ,SUM(CASE
                     WHEN temp_ele.pgf_seq_num = 2 THEN 1
                     ELSE 0
                   END) AS grade_2_ct
              ,SUM(CASE
                     WHEN temp_ele.pgf_seq_num = 3 THEN 1
                     ELSE 0
                   END) AS grade_3_ct
              ,SUM(CASE
                     WHEN temp_ele.pgf_seq_num = 4 THEN 1
                     ELSE 0
                   END) AS grade_4_ct           
        FROM #GRADES$elements_s1 temp_ele
        GROUP BY temp_ele.studentid
                ,temp_ele.schoolid
                ,temp_ele.yearid
                ,temp_ele.course_number
                ,temp_ele.pgf_type
        ) sub_1
  
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
        ,ROLLUP(course_number)
  
  SELECT ele.*
        ,scales.letter_grade
  INTO [#GRADES$elements_final]
  FROM [#GRADES$elements_s3] ele
  JOIN KIPP_NJ..GRADES$grade_scales#static scales WITH(NOLOCK)
    ON ele.simple_avg >= scales.low_cut 
   AND ele.simple_avg <  scales.high_cut
   AND scales.scale_name = 'NCA 2011'
  
  EXEC('TRUNCATE TABLE dbo.[GRADES$elements]');
 
  INSERT INTO [GRADES$elements]
  SELECT *
  FROM [#GRADES$elements_final]; 
    
END