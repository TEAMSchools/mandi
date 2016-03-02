USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_GRADES$NCA|refresh] AS

BEGIN
 
 -- SET NOCOUNT ON added to prevent extra result sets FROM
 -- interfering WITH SELECT statements.
 SET NOCOUNT ON;

 DECLARE
   @v_termid               INT      = KIPP_NJ.dbo.fn_Global_Term_Id(),
   @v_grade_1              VARCHAR(2) = 'Q1',   
   @v_grade_2              VARCHAR(2) = 'Q2',  
   /* 
   EXAMPLE FOR IN-BETWEEN TERMS CALCULATION (EG REPORT CARD PREP)
   EXAMPLE IS END OF Q2
   v_grade_3              VARCHAR2(2) := 'FOO'   ;
   v_grade_4              VARCHAR2(2) := 'FOO'   ;
   */
   @v_grade_3              VARCHAR(2) = 'Q3',
   @v_grade_4              VARCHAR(2) = 'FOO',
   @v_grade_5              VARCHAR(2) = 'E1',
   @v_grade_6              VARCHAR(2) = 'FOO',
   @v_grade_yr             VARCHAR(2) = 'FOO',
   @v_schoolly_d           INT     = 73253,
   
   --other variables
   @v_0                    INT     = 0,
   @v_1                    INT     = 1;

-- 1) Create temp tables
 -- temp table to hold stored grades
 CREATE TABLE #TEMP_GRADES$NCA#SG
  (
   StudentID INT
  ,Course_number VARCHAR(11)
  ,Storecode VARCHAR(10) 
  ,Grade VARCHAR(7)
  ,[Percent] FLOAT
  );

 -- temp table to hold pgfinalgrades
 CREATE TABLE #TEMP_GRADES$NCA#PGF
  (
   Sectionid INT
  ,Studentid INT
  ,FinalgradeName VARCHAR(8)
  ,[Percent] FLOAT
  ,Grade VARCHAR(7)
  ,Course_number VARCHAR(11)
  );

 -- temp table to hold term base
 CREATE TABLE #TEMP_TERM$BASE
  (
   Termid INT
  ,Points INT
  );
  
 -- staging table 1
 CREATE TABLE #TEMP_GRADES$NCA#STAGE_1
  (
   STUDENTID INT
  ,STUDENT_NUMBER FLOAT
  ,SCHOOLID INT
  ,LASTFIRST VARCHAR(135)
  ,GRADE_LEVEL INT
  ,COURSE_NUMBER VARCHAR(11)
  ,CREDITTYPE VARCHAR(20)
  ,COURSE_NAME VARCHAR(40)
  ,CREDIT_HOURS FLOAT
  );

 -- staging table 2
 CREATE TABLE #TEMP_GRADES$NCA#STAGE_2
  (
   [studentid] [INT] NULL,
   [student_number] [float] NULL,
   [schoolid] [INT] NULL,
   [lastfirst] [VARCHAR](135) NULL,
   [grade_level] [INT] NULL,
   [course_number] [VARCHAR](11) NULL,
   [credittype] [VARCHAR](20) NULL,
   [course_name] [VARCHAR](40) NULL,
   [credit_hours] [float] NULL,
   [Q1] [float] NULL,
   [Q2] [float] NULL,
   [Q3] [float] NULL,
   [Q4] [float] NULL,
   [e1] [float] NULL,
   [e2] [float] NULL,
   [Y1_stored] [float] NULL,
   [q1_letter] [VARCHAR](7) NULL,
   [q2_letter] [VARCHAR](7) NULL,
   [q3_letter] [VARCHAR](7) NULL,
   [q4_letter] [VARCHAR](7) NULL,
   [e1_letter] [VARCHAR](7) NULL,
   [e2_letter] [VARCHAR](7) NULL,
   [y1_letter_stored] [VARCHAR](7) NULL,
   [Q1_enr_sectionid] [INT] NULL,
   [Q2_enr_sectionid] [INT] NULL,
   [Q3_enr_sectionid] [INT] NULL,
   [Q4_enr_sectionid] [INT] NULL
  );
  
 -- production table/final table
 CREATE TABLE #TEMP_GRADES$NCA#STAGE_FINAL
  (
   [studentid] [INT] NULL,
   [student_number] [float] NULL,
   [schoolid] [INT] NULL,
   [lastfirst] [VARCHAR](135) NULL,
   [grade_level] [INT] NULL,
   [course_number] [VARCHAR](11) NULL,
   [credittype] [VARCHAR](20) NULL,
   [course_name] [VARCHAR](40) NULL,
   [credit_hours] [float] NULL,
   [q1] [float] NULL,
   [q2] [float] NULL,
   [q3] [float] NULL,
   [q4] [float] NULL,
   [e1] [float] NULL,
   [e2] [float] NULL,
   [y1] [float] NULL,
   [q1_letter] [VARCHAR](7) NULL,
   [q2_letter] [VARCHAR](7) NULL,
   [q3_letter] [VARCHAR](7) NULL,
   [q4_letter] [VARCHAR](7) NULL,
   [e1_letter] [VARCHAR](7) NULL,
   [e2_letter] [VARCHAR](7) NULL,
   [y1_letter] [VARCHAR](7) NULL,
   [q1_enr_sectionid] [INT] NULL,
   [q2_enr_sectionid] [INT] NULL,
   [q3_enr_sectionid] [INT] NULL,
   [q4_enr_sectionid] [INT] NULL,
   [qtr_valid] [INT] NULL,
   [exam_valid] [INT] NULL,
   [qtr_in_books] [INT] NULL,
   [exam_in_books] [INT] NOT NULL,
   [in_the_books] [float] NULL,
   [used_year] [numeric](15, 3) NULL,
   [course_y1] [VARCHAR](73) NULL,
   [failing_y1] [VARCHAR](73) NULL,
   [GPA_Points_Q1] [float] NULL,
   [GPA_Points_Q2] [float] NULL,
   [GPA_Points_Q3] [float] NULL,
   [GPA_Points_Q4] [float] NULL,
   [GPA_Points_E1] [float] NULL,
   [GPA_Points_E2] [float] NULL,
   [GPA_Points_Y1] [float] NULL,
   [credit_hours_Q1] [float] NULL,
   [credit_hours_Q2] [float] NULL,
   [credit_hours_Q3] [float] NULL,
   [credit_hours_Q4] [float] NULL,
   [credit_hours_E1] [float] NULL,
   [credit_hours_E2] [float] NULL,
   [credit_hours_Y1] [float] NULL,
   [weighted_points_Q1] [float] NULL,
   [weighted_points_Q2] [float] NULL,
   [weighted_points_Q3] [float] NULL,
   [weighted_points_Q4] [float] NULL,
   [weighted_points_E1] [float] NULL,
   [weighted_points_E2] [float] NULL,
   [weighted_points_Y1] [float] NULL,
   [Promo_Test] [INT] NOT NULL,
   [need_c] [VARCHAR](30) NULL,
   [need_b] [VARCHAR](30) NULL,
   [need_a] [VARCHAR](30) NULL,
   [need_d] [VARCHAR](30) NULL,
   [need_c_absolute] [VARCHAR](30) NULL,
   [need_b_absolute] [VARCHAR](30) NULL,
   [need_a_absolute] [VARCHAR](30) NULL,
   [need_d_absolute] [VARCHAR](30) NULL,
   [need_c_text] [VARCHAR](172) NULL
  );

 
-- 2) insert into temporary tables (SG AND PGF)
-- this IS over the linked server to PS production server
 
 --pgfinalgrades
 DECLARE @v_sql VARCHAR(MAX) = '
   SELECT CONVERT(INT,sectionid) AS sectionid
         ,CONVERT(INT,studentid) AS studentid
         ,finalgradename
         ,[percent]
         ,grade
         ,course_number
   FROM OPENQUERY(PS_TEAM,''
     SELECT TO_CHAR(cc.sectionid) AS sectionid
           ,TO_CHAR(cc.studentid) AS studentid
           ,pgf.finalgradename
           ,CASE WHEN pgf.grade = ''''--'''' THEN NULL ELSE pgf.percent END AS percent
           ,CASE WHEN pgf.grade = ''''--'''' THEN NULL ELSE pgf.grade END AS grade
           ,cc.course_number
     FROM cc
     LEFT OUTER JOIN pgfinalgrades pgf     
       ON cc.sectionid = pgf.sectionid
      AND cc.studentid = pgf.studentid
      AND pgf.finalgradename IN (''''' + @v_grade_1 + ''''', ''''' + @v_grade_2 + ''''', ''''' + @v_grade_3 + ''''', ''''' + @v_grade_4 + ''''')       
     WHERE cc.termid >= ' + CONVERT(VARCHAR,@v_termid) + '
       AND cc.schoolid = ' + CONVERT(VARCHAR,@v_schoolly_d) + '     
   '');
 '; 
 
 INSERT INTO #TEMP_GRADES$NCA#PGF
 EXEC (@v_sql);
 
 --stored grades
 SET @v_sql = '
   SELECT CONVERT(INT,STUDENTID) AS STUDENTID
         ,COURSE_NUMBER
         ,STORECODE
         ,GRADE
         ,[PERCENT]
   FROM OPENQUERY(PS_TEAM,''
     SELECT TO_CHAR(STUDENTID) AS STUDENTID
           ,COURSE_NUMBER
           ,STORECODE
           ,GRADE
           ,PERCENT
     FROM STOREDGRADES
     WHERE termid >= ' + CONVERT(VARCHAR,  @v_termid) + '
       AND schoolid = ' + CONVERT(VARCHAR, @v_schoolly_d) + '
   '');
 '; 
 
 INSERT INTO #TEMP_GRADES$NCA#SG
 EXEC (@v_sql);

 --term base
 SET @v_sql = '
   SELECT CONVERT(INT, TERMID) AS TERMID
         ,CONVERT(INT, POINTS) AS POINTS
   FROM OPENQUERY(PS_TEAM,''
     SELECT TO_CHAR(TERMID) AS TERMID
           ,CASE
            WHEN STORECODE LIKE ''''Q%'''' THEN ''''225''''
            WHEN STORECODE LIKE ''''E%'''' THEN ''''50''''
            ELSE ''''0''''
            END AS POINTS
     FROM TERMBINS
     WHERE SCHOOLID = ' + CONVERT(VARCHAR, @v_schoolly_d) + '
      AND TERMID >= ' + CONVERT(VARCHAR,  @v_termid) + '
      AND STORECODE IN (''''Q1'''',''''Q2'''',''''Q3'''',''''Q4'''',''''E1'''',''''E2'''')
   '')
 '
 
 INSERT INTO #TEMP_TERM$BASE
 EXEC(@v_sql);

-- 3) insert course enrollments into staging table 1 from temp table
 INSERT INTO #TEMP_GRADES$NCA#STAGE_1
 SELECT co.studentid
       ,s.student_number
       ,co.schoolid
       ,co.lastfirst
       ,co.grade_level
       ,cc.course_number
       ,c.credittype
       ,c.course_name
       ,c.credit_hours
 FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
 JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
   ON co.STUDENTID = s.ID
 JOIN PS$CC#static cc WITH(NOLOCK)
   ON co.studentid = cc.studentid
  AND cc.termid >= @v_termid
 JOIN PS$COURSES#static c WITH(NOLOCK)
   ON cc.course_number = c.course_number 
  AND c.excludefromgpa != @v_1 --exclude courses that will never count towards GPA
 WHERE co.YEAR = KIPP_NJ.dbo.fn_Global_Academic_Year()
   AND co.schoolid = @v_schoolly_d
   AND co.rn = 1;


-- 4) assemble student enrollments AND course grades into staging table (no calculations yet)
 --students w/ all course enrollments this year
 --course enrollments are defined AS anything that *was NOT dropped* during this school year
 WITH level_pgf AS (
   SELECT level_1.studentid
         ,level_1.student_number
         ,level_1.schoolid
         ,level_1.lastfirst
         ,level_1.grade_level
         ,level_1.course_number
         ,level_1.credittype
         ,level_1.course_name
         ,level_1.credit_hours
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_1 THEN pgf.[percent] END) AS q1_percent
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_2 THEN pgf.[percent] END) AS q2_percent
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_3 THEN pgf.[percent] END) AS q3_percent
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_4 THEN pgf.[percent] END) AS q4_percent
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_1 THEN pgf.grade END) AS q1_grade
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_2 THEN pgf.grade END) AS q2_grade
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_3 THEN pgf.grade END) AS q3_grade
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_4 THEN pgf.grade END) AS q4_grade
         --enrollment IDs
         ,MAX(CASE WHEN pgf.FinalgradeName = @v_grade_1 THEN pgf.sectionid END) AS q1_sectionid
         ,MAX(CASE WHEN pgf.FinalgradeName = @v_grade_2 THEN pgf.sectionid END) AS q2_sectionid
         ,MAX(CASE WHEN pgf.FinalgradeName = @v_grade_3 THEN pgf.sectionid END) AS q3_sectionid
         ,MAX(CASE WHEN pgf.FinalgradeName = @v_grade_4 THEN pgf.sectionid END) AS q4_sectionid
   FROM #TEMP_GRADES$NCA#STAGE_1 AS level_1   
   --FYI, assumption here IS that a student IS never enrolled IN the same course AND term more than once
   LEFT OUTER JOIN #TEMP_GRADES$NCA#PGF pgf -- gradebook (PGFinalGrades) grades
     ON pgf.studentid = level_1.studentid
    AND pgf.course_number = level_1.course_number
    AND pgf.finalgradename IN (@v_grade_1, @v_grade_2, @v_grade_3, @v_grade_4)
   GROUP BY level_1.studentid
           ,level_1.student_number
           ,level_1.schoolid
           ,level_1.lastfirst
           ,level_1.grade_level
           ,level_1.course_number
           ,level_1.credittype
           ,level_1.course_name
           ,level_1.credit_hours
  )
 
 ,level_sg AS (
   SELECT level_1.studentid
         ,level_1.student_number
         ,level_1.schoolid
         ,level_1.lastfirst
         ,level_1.grade_level
         ,level_1.course_number
         ,level_1.credittype
         ,level_1.course_name
         ,level_1.credit_hours
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_1 THEN sg.[percent] END) AS q1_percent
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_2 THEN sg.[percent] END) AS q2_percent
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_3 THEN sg.[percent] END) AS q3_percent
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_4 THEN sg.[percent] END) AS q4_percent
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_5 THEN sg.[percent] END) AS e1_percent
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_6 THEN sg.[percent] END) AS e2_percent
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_yr THEN sg.[percent] END) AS y1_percent
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_1 THEN sg.grade END) AS q1_grade
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_2 THEN sg.grade END) AS q2_grade
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_3 THEN sg.grade END) AS q3_grade
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_4 THEN sg.grade END) AS q4_grade
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_5 THEN sg.grade END) AS e1_grade
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_6 THEN sg.grade END) AS e2_grade
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_yr THEN sg.grade END) AS y1_grade
   FROM #TEMP_GRADES$NCA#STAGE_1 AS level_1  
   LEFT OUTER JOIN #temp_grades$nca#sg sg -- stored (StoredGrades) grades
     ON (
         sg.studentid = level_1.studentid
         AND sg.course_number = level_1.course_number
         AND storecode IN (@v_grade_1, @v_grade_2, @v_grade_3, @v_grade_4, @v_grade_5, @v_grade_6, @v_grade_yr)
        )
   GROUP BY level_1.studentid
           ,level_1.student_number
           ,level_1.schoolid
           ,level_1.lastfirst
           ,level_1.grade_level
           ,level_1.course_number
           ,level_1.credittype
           ,level_1.course_name
           ,level_1.credit_hours
  )

 INSERT INTO #TEMP_GRADES$NCA#STAGE_2
 SELECT level_pgf.studentid
       ,level_pgf.student_number
       ,level_pgf.schoolid
       ,level_pgf.lastfirst
       ,level_pgf.grade_level
       ,level_pgf.course_number
       ,level_pgf.credittype
       ,level_pgf.course_name
       ,level_pgf.credit_hours
       ,ROUND(CASE WHEN level_sg.q1_percent IS NOT NULL THEN level_sg.q1_percent ELSE level_pgf.q1_percent END,0) AS Q1
       ,ROUND(CASE WHEN level_sg.q2_percent IS NOT NULL THEN level_sg.q2_percent ELSE level_pgf.q2_percent END,0) AS Q2
       ,ROUND(CASE WHEN level_sg.q3_percent IS NOT NULL THEN level_sg.q3_percent ELSE level_pgf.q3_percent END,0) AS Q3
       ,ROUND(CASE WHEN level_sg.q4_percent IS NOT NULL THEN level_sg.q4_percent ELSE level_pgf.q4_percent END,0) AS Q4
       ,ROUND(level_sg.e1_percent,0) AS e1
       ,ROUND(level_sg.e2_percent,0) AS e2
       ,level_sg.y1_percent AS Y1_stored
       --letter grades
       ,CASE WHEN level_sg.q1_grade IS NOT NULL THEN level_sg.q1_grade ELSE level_pgf.q1_grade END AS q1_letter
       ,CASE WHEN level_sg.q2_grade IS NOT NULL THEN level_sg.q2_grade ELSE level_pgf.q2_grade END AS q2_letter
       ,CASE WHEN level_sg.q3_grade IS NOT NULL THEN level_sg.q3_grade ELSE level_pgf.q3_grade END AS q3_letter
       ,CASE WHEN level_sg.q4_grade IS NOT NULL THEN level_sg.q4_grade ELSE level_pgf.q4_grade END AS q4_letter
       ,level_sg.e1_grade AS e1_letter
       ,level_sg.e2_grade AS e2_letter
       ,level_sg.y1_grade AS y1_letter_stored
       ,level_pgf.q1_sectionid AS Q1_enr_sectionid
       ,level_pgf.q2_sectionid AS Q2_enr_sectionid
       ,level_pgf.q3_sectionid AS Q3_enr_sectionid
       ,level_pgf.q4_sectionid AS Q4_enr_sectionid
 FROM level_pgf 
 JOIN level_sg 
   ON (
       level_pgf.studentid = level_sg.studentid
       AND level_pgf.student_number = level_sg.student_number
       AND level_pgf.schoolid = level_sg.schoolid
       AND level_pgf.lastfirst = level_sg.lastfirst
       AND level_pgf.grade_level = level_sg.grade_level
       AND level_pgf.course_number = level_sg.course_number
       AND level_pgf.credittype = level_sg.credittype
       AND level_pgf.course_name = level_sg.course_name
       AND level_pgf.credit_hours	= level_sg.credit_hours
      );

-- 5) Run calculations and load into final table
 
 -- valid terms
 WITH level_1 AS (
   SELECT stage_1.*
         ,(CASE WHEN Q1 IS NULL THEN 0 ELSE 1 END)
           + (CASE WHEN Q2 IS NULL THEN 0 ELSE 1 END)
           + (CASE WHEN Q3 IS NULL THEN 0 ELSE 1 END)
           + (CASE WHEN Q4 IS NULL THEN 0 ELSE 1 END)
          AS qtr_valid
         ,(CASE WHEN E1 IS NULL THEN 0 ELSE 1 END)
           + (CASE WHEN E2 IS NULL THEN 0 ELSE 1 END)
          AS exam_valid
         ,(CASE WHEN Q1 IS NULL THEN 0 ELSE 1 END)
           + (CASE WHEN Q2 IS NULL THEN 0 ELSE 1 END)
           + (CASE WHEN Q3 IS NULL THEN 0 ELSE 1 END)
          AS qtr_in_books
         ,CASE WHEN E1 IS NULL THEN 0 ELSE 1 END AS exam_in_books
   FROM #TEMP_GRADES$NCA#STAGE_2 stage_1
  )
 
 -- Y1 grades calculated by weighting quarterly grades AND exam grades
 ,stage_2 AS (
   SELECT level_1.*          
          ,CASE 
            WHEN Y1_stored IS NOT NULL THEN Y1_stored
            WHEN qtr_valid + exam_valid = 0 THEN NULL
            --
            ELSE ROUND (
                  (((CASE WHEN Q1 < 50 THEN 50 ELSE COALESCE(Q1, 0) END -- quarterly grades
                       + CASE WHEN Q2 < 50 THEN 50 ELSE COALESCE(Q2, 0) END
                       + CASE WHEN Q3 < 50 THEN 50 ELSE COALESCE(Q3, 0) END
                       + CASE WHEN Q4 < 50 THEN 50 ELSE COALESCE(Q4, 0) END) * 0.225) 
                 + ((CASE WHEN E1 < 50 THEN 50 ELSE COALESCE(E1, 0) END -- exams
                       + CASE WHEN E2 < 50 THEN 50 ELSE COALESCE(E2, 0) END) * 0.05)) 
                   / 
                  ((qtr_valid * 22.5) + (exam_valid * 5)) * 100 -- number of valid terms
                 ,0)
           END AS Y1
          ,CASE 
            WHEN qtr_in_books + exam_in_books = 0 THEN NULL 
            ELSE ROUND (
                  (((CASE WHEN Q1 IS NULL THEN 0 WHEN Q1 < 50 THEN 50 ELSE COALESCE(Q1, 0) END -- quarterly grades
                       + CASE WHEN Q2 IS NULL THEN 0 WHEN Q2 < 50 THEN 50 ELSE COALESCE(Q2, 0) END
                       + CASE WHEN Q3 IS NULL THEN 0 WHEN Q3 < 50 THEN 50 ELSE COALESCE(Q3, 0) END) * 0.225) 
                 + ((CASE WHEN E1 IS NULL THEN 0 WHEN E1 < 50 THEN 50 ELSE COALESCE(E1, 0) END) * 0.05)) 
                   / 
                  ((qtr_in_books * 22.5) + (exam_in_books * 5)) * 100                 
                 ,0)
           END AS in_the_books
          ,(qtr_in_books * .225) + (exam_in_books * .05) AS used_year
          ,CASE 
            WHEN Y1_stored IS NOT NULL THEN Y1_stored
            WHEN qtr_valid + exam_valid = 0 THEN NULL
            -- tests whether this grade should be an F*
            -- same as Y1 calc but replaces 50's with 49's 
            -- to differentiate between actual 50's and sub-50 scores
            WHEN ROUND (
                  (((CASE WHEN Q1 < 50 THEN 49 ELSE COALESCE(Q1, 0) END -- quarterly grades
                       + CASE WHEN Q2 < 50 THEN 49 ELSE COALESCE(Q2, 0) END
                       + CASE WHEN Q3 < 50 THEN 49 ELSE COALESCE(Q3, 0) END
                       + CASE WHEN Q4 < 50 THEN 49 ELSE COALESCE(Q4, 0) END) * 0.225) 
                 + ((CASE WHEN E1 < 50 THEN 49 ELSE COALESCE(E1, 0) END -- exams
                       + CASE WHEN E2 < 50 THEN 49 ELSE COALESCE(E2, 0) END) * 0.05)) 
                   / 
                  ((qtr_valid * 22.5) + (exam_valid * 5)) * 100 -- number of valid terms
                 ,0) < 50 THEN 1 
            ELSE NULL
           END AS f_star_flag
   FROM level_1
  )
 
 -- number of valid terms for "need to get" calculations
 ,term_denominators AS (
   --SIGH
   --you have to account for varying denominators
   --to do that, you need to know how many valid grades this enrollment will count for
   --we look for all instances of a student's enrollment, JOIN to a representation (a weighted representation) 
   --of how many named grade entities exist for that termid
   --BECAUSE a kid can enroll IN BOTH Q1 AND say Q3 we have to SUM that by course number.  it's true.
   SELECT cc.studentid
         ,cc.course_number
         ,SUM(term_weights.points) AS points
   FROM KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
   JOIN (
         SELECT termid
               ,SUM(points)/10 AS points
         FROM #TEMP_TERM$BASE 
         GROUP BY termid
        ) term_weights
     ON term_weights.termid = cc.termid
   WHERE cc.schoolid = @v_schoolly_d
     AND cc.termid >= @v_termid
   GROUP BY cc.studentid
           ,cc.course_number
  )
 
 -- GPA points and credit hours based on each course's grade scale
 ,stage_3_1 AS (
   SELECT stage_2.*                   
         ,CASE 
           WHEN y1_letter_stored IS NOT NULL THEN y1_letter_stored
           WHEN stage_2.f_star_flag = 1 THEN 'F*'
           ELSE CONVERT(VARCHAR, gradescale_y1.letter_grade)
          END AS y1_letter
         ,gradescale_Y1.grade_points AS GPA_Points_Y1
         ,COURSE_NAME + ' [' + CONVERT(VARCHAR, ROUND(Y1,0)) + ']' AS COURSE_Y1
         ,CASE 
           WHEN Y1 < 65 THEN COURSE_NAME + ' [' + CONVERT(VARCHAR, ROUND(Y1,0)) + ']'
           ELSE NULL
          END AS FAILING_Y1
         ,GRADESCALE_Q1.GRADE_POINTS AS GPA_POINTS_Q1
         ,GRADESCALE_Q2.GRADE_POINTS AS GPA_POINTS_Q2
         ,GRADESCALE_Q3.GRADE_POINTS AS GPA_POINTS_Q3
         ,GRADESCALE_Q4.GRADE_POINTS AS GPA_POINTS_Q4
         ,GRADESCALE_E1.GRADE_POINTS AS GPA_POINTS_E1
         ,GRADESCALE_E2.GRADE_POINTS AS GPA_POINTS_E2              
         ,CASE WHEN Q1 IS NOT NULL THEN credit_hours ELSE NULL END AS credit_hours_Q1
         ,CASE WHEN Q2 IS NOT NULL THEN credit_hours ELSE NULL END AS credit_hours_Q2
         ,CASE WHEN Q3 IS NOT NULL THEN credit_hours ELSE NULL END AS credit_hours_Q3       
         ,CASE WHEN Q4 IS NOT NULL THEN credit_hours ELSE NULL END AS credit_hours_Q4
         ,CASE WHEN E1 IS NOT NULL THEN credit_hours ELSE NULL END AS credit_hours_E1
         ,CASE WHEN E2 IS NOT NULL THEN credit_hours ELSE NULL END AS credit_hours_E2
         ,CASE WHEN Y1 IS NOT NULL THEN credit_hours ELSE NULL END AS credit_hours_Y1
         ,(term_denominators.points - (100 * used_year)) / 100 AS year_remaining 
   FROM stage_2
   JOIN (
         SELECT gradescaleid
               ,course_number
         FROM PS$COURSES#static WITH(NOLOCK)
        ) courses   
     ON stage_2.course_number = courses.course_number   
   JOIN term_denominators
     ON term_denominators.course_number = stage_2.course_number
    AND term_denominators.studentid = stage_2.studentid
   LEFT OUTER JOIN GRADES$grade_scales#static gradescale_Q1 WITH(NOLOCK)
     ON courses.gradescaleid = gradescale_Q1.scale_id
    AND stage_2.Q1 >= gradescale_Q1.low_cut 
    AND stage_2.Q1 < gradescale_Q1.high_cut   
   LEFT OUTER JOIN GRADES$grade_scales#static gradescale_Q2 WITH(NOLOCK)
     ON courses.gradescaleid = gradescale_Q2.scale_id
    AND stage_2.Q2 >= gradescale_Q2.low_cut 
    AND stage_2.Q2 < gradescale_Q2.high_cut   
   LEFT OUTER JOIN GRADES$grade_scales#static gradescale_Q3 WITH(NOLOCK)
     ON courses.gradescaleid = gradescale_Q3.scale_id
    AND stage_2.Q3 >= gradescale_Q3.low_cut 
    AND stage_2.Q3 < gradescale_Q3.high_cut   
   LEFT OUTER JOIN GRADES$grade_scales#static gradescale_Q4 WITH(NOLOCK)
     ON courses.gradescaleid = gradescale_Q4.scale_id
    AND stage_2.Q4 >= gradescale_Q4.low_cut 
    AND stage_2.Q4 < gradescale_Q4.high_cut    
   LEFT OUTER JOIN GRADES$grade_scales#static gradescale_E1 WITH(NOLOCK)
     ON courses.gradescaleid = gradescale_E1.scale_id
    AND stage_2.E1 >= gradescale_E1.low_cut 
    AND stage_2.E1 < gradescale_E1.high_cut    
   LEFT OUTER JOIN GRADES$grade_scales#static gradescale_E2 WITH(NOLOCK)
     ON courses.gradescaleid = gradescale_E2.scale_id
    AND stage_2.E2 >= gradescale_E2.low_cut 
    AND stage_2.E2 < gradescale_E2.high_cut    
   LEFT OUTER JOIN GRADES$grade_scales#static gradescale_Y1 WITH(NOLOCK)
     ON courses.gradescaleid = gradescale_Y1.scale_id 
    AND stage_2.Y1 >= gradescale_Y1.low_cut 
    AND stage_2.Y1 < gradescale_Y1.high_cut   
  )

 -- calculate "need to get" scores and load into final table
 INSERT INTO #TEMP_GRADES$NCA#STAGE_FINAL
 SELECT studentid
       ,student_number
       ,schoolid
       ,lastfirst
       ,grade_level
       ,course_number
       ,credittype
       ,course_name
       ,credit_hours
       ,q1
       ,q2
       ,q3
       ,q4
       ,e1
       ,e2
       ,y1
       ,q1_letter
       ,q2_letter
       ,q3_letter
       ,q4_letter
       ,e1_letter
       ,e2_letter
       ,y1_letter
       ,q1_enr_sectionid
       ,q2_enr_sectionid
       ,q3_enr_sectionid
       ,q4_enr_sectionid
       ,qtr_valid
       ,exam_valid
       ,qtr_in_books
       ,exam_in_books
       ,in_the_books
       ,used_year
       ,course_y1
       ,failing_y1
       ,GPA_Points_Q1
       ,GPA_Points_Q2
       ,GPA_Points_Q3
       ,GPA_Points_Q4
       ,GPA_Points_E1
       ,GPA_Points_E2
       ,GPA_Points_Y1
       ,credit_hours_Q1
       ,credit_hours_Q2
       ,credit_hours_Q3
       ,credit_hours_Q4
       ,credit_hours_E1
       ,credit_hours_E2
       ,credit_hours_Y1
       -- weighted GPA points
       ,credit_hours_Q1 * GPA_points_Q1 AS weighted_points_Q1
       ,credit_hours_Q2 * GPA_points_Q2 AS weighted_points_Q2
       ,credit_hours_Q3 * GPA_points_Q3 AS weighted_points_Q3
       ,credit_hours_Q4 * GPA_points_Q4 AS weighted_points_Q4
       ,credit_hours_E1 * GPA_points_E1 AS weighted_points_E1
       ,credit_hours_E2 * GPA_points_E2 AS weighted_points_E2
       ,credit_hours_Y1 * GPA_points_Y1 AS weighted_points_Y1
       ,CASE WHEN Y1 < 70 THEN 1 ELSE 0 END Promo_Test    
       ----Laz/Andrew hand fix for Q4.
       ,CASE
         WHEN year_remaining = 0 THEN NULL
         WHEN ROUND((((used_year + year_remaining) * 70) - (in_the_books * used_year)) / year_remaining,1) < 70 THEN '<70 (hidden)'
         ELSE CONVERT(VARCHAR, ROUND((((used_year + year_remaining) * 70) - (in_the_books * used_year)) / year_remaining,1))
        END AS need_c
       ,CASE
         WHEN year_remaining = 0 THEN NULL
         WHEN ROUND((((used_year + year_remaining) * 80) - (in_the_books * used_year)) / year_remaining,1) < 80 THEN '<80 (hidden)'
         ELSE CONVERT(VARCHAR, ROUND((((used_year + year_remaining) * 80) - (in_the_books * used_year)) / year_remaining,1))
        END AS need_b
       ,CASE
         WHEN year_remaining = 0 THEN NULL
         WHEN ROUND((((used_year + year_remaining) * 90) - (in_the_books * used_year)) / year_remaining,1) < 90 THEN '<90 (hidden)'
         ELSE CONVERT(VARCHAR,ROUND((((used_year + year_remaining) * 90) - (in_the_books * used_year)) / year_remaining,1))
        END AS need_a
       ,CASE
         WHEN year_remaining = 0 THEN NULL
         WHEN ROUND((((used_year + year_remaining) * 60) - (in_the_books * used_year)) / year_remaining,1) < 60 THEN '<60 (hidden)'
         ELSE CONVERT(VARCHAR,ROUND((((used_year + year_remaining) * 60) - (in_the_books * used_year)) / year_remaining,1))
        END AS need_d
       ,CASE
         WHEN year_remaining = 0 THEN NULL
         ELSE CONVERT(VARCHAR,ROUND((((used_year + year_remaining) * 70) - (in_the_books * used_year)) / year_remaining,1))
         END AS need_c_absolute
       ,CASE
         WHEN year_remaining = 0 THEN NULL
         ELSE CONVERT(VARCHAR,ROUND((((used_year + year_remaining) * 80) - (in_the_books * used_year)) / year_remaining,1))
         END AS need_b_absolute
       ,CASE
         WHEN year_remaining = 0 THEN NULL
         ELSE CONVERT(VARCHAR,ROUND((((used_year + year_remaining) * 90) - (in_the_books * used_year)) / year_remaining,1))
        END AS need_a_absolute
       ,CASE
         WHEN year_remaining = 0 THEN NULL
         ELSE CONVERT(VARCHAR,ROUND((((used_year + year_remaining) * 60) - (in_the_books * used_year)) / year_remaining,1))
        END AS need_d_absolute
       ,'(((' + CONVERT(VARCHAR, used_year) + '+' 
         + CONVERT(VARCHAR, year_remaining) + ') * 70) - (' 
         + CONVERT(VARCHAR, in_the_books) + ' * ' 
         + CONVERT(VARCHAR, used_year) + ')) /' 
         + CONVERT(VARCHAR, year_remaining) 
         AS need_c_text
 FROM STAGE_3_1;


-- 6) truncate the grades$detail#nca table
 EXEC ('TRUNCATE TABLE GRADES$DETAIL#NCA');


-- 7) append to result table
 INSERT INTO dbo.GRADES$DETAIL#NCA 
   ([studentid]
   ,[student_number]
   ,[schoolid]
   ,[lastfirst]
   ,[grade_level]
   ,[course_number]
   ,[credittype]
   ,[course_name]
   ,[credit_hours]
   ,[q1]
   ,[q2]
   ,[q3]
   ,[q4]
   ,[e1]
   ,[e2]
   ,[y1]
   ,[q1_letter]
   ,[q2_letter]
   ,[q3_letter]
   ,[q4_letter]
   ,[e1_letter]
   ,[e2_letter]
   ,[y1_letter]
   ,[q1_enr_sectionid]
   ,[q2_enr_sectionid]
   ,[q3_enr_sectionid]
   ,[q4_enr_sectionid]
   ,[qtr_valid]
   ,[exam_valid]
   ,[qtr_in_books]
   ,[exam_in_books]
   ,[in_the_books]
   ,[used_year]
   ,[course_y1]
   ,[failing_y1]
   ,[GPA_Points_Q1]
   ,[GPA_Points_Q2]
   ,[GPA_Points_Q3]
   ,[GPA_Points_Q4]
   ,[GPA_Points_E1]
   ,[GPA_Points_E2]
   ,[GPA_Points_Y1]
   ,[credit_hours_Q1]
   ,[credit_hours_Q2]
   ,[credit_hours_Q3]
   ,[credit_hours_Q4]
   ,[credit_hours_E1]
   ,[credit_hours_E2]
   ,[credit_hours_Y1]
   ,[weighted_points_Q1]
   ,[weighted_points_Q2]
   ,[weighted_points_Q3]
   ,[weighted_points_Q4]
   ,[weighted_points_E1]
   ,[weighted_points_E2]
   ,[weighted_points_Y1]
   ,[Promo_Test]
   ,[need_c]
   ,[need_b]
   ,[need_a]
   ,[need_d]
   ,[need_c_absolute]
   ,[need_b_absolute]
   ,[need_a_absolute]
   ,[need_d_absolute]
   ,[need_c_text])
 SELECT [studentid]
       ,[student_number]
       ,[schoolid]
       ,[lastfirst]
       ,[grade_level]
       ,[course_number]
       ,[credittype]
       ,[course_name]
       ,[credit_hours]
       ,[q1]
       ,[q2]
       ,[q3]
       ,[q4]
       ,[e1]
       ,[e2]
       ,[y1]
       ,[q1_letter]
       ,[q2_letter]
       ,[q3_letter]
       ,[q4_letter]
       ,[e1_letter]
       ,[e2_letter]
       ,[y1_letter]
       ,[q1_enr_sectionid]
       ,[q2_enr_sectionid]
       ,[q3_enr_sectionid]
       ,[q4_enr_sectionid]
       ,[qtr_valid]
       ,[exam_valid]
       ,[qtr_in_books]
       ,[exam_in_books]
       ,[in_the_books]
       ,[used_year]
       ,[course_y1]
       ,[failing_y1]
       ,[GPA_Points_Q1]
       ,[GPA_Points_Q2]
       ,[GPA_Points_Q3]
       ,[GPA_Points_Q4]
       ,[GPA_Points_E1]
       ,[GPA_Points_E2]
       ,[GPA_Points_Y1]
       ,[credit_hours_Q1]
       ,[credit_hours_Q2]
       ,[credit_hours_Q3]
       ,[credit_hours_Q4]
       ,[credit_hours_E1]
       ,[credit_hours_E2]
       ,[credit_hours_Y1]
       ,[weighted_points_Q1]
       ,[weighted_points_Q2]
       ,[weighted_points_Q3]
       ,[weighted_points_Q4]
       ,[weighted_points_E1]
       ,[weighted_points_E2]
       ,[weighted_points_Y1]
       ,[Promo_Test]
       ,[need_c]
       ,[need_b]
       ,[need_a]
       ,[need_d]
       ,[need_c_absolute]
       ,[need_b_absolute]
       ,[need_a_absolute]
       ,[need_d_absolute]
       ,[need_c_text]
 FROM #TEMP_GRADES$NCA#STAGE_FINAL;
 
END

GO