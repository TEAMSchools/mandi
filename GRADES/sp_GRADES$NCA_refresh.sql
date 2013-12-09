USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- ============================================
ALTER PROCEDURE [dbo].[sp_GRADES$NCA|refresh]
AS
BEGIN
 -- SET NOCOUNT ON added to prevent extra result sets from
 -- interfering with SELECT statements.
 SET NOCOUNT ON;

 DECLARE
  @v_termid               INT      = dbo.fn_Global_Term_Id(),
  @v_grade_1              VARCHAR(2) = 'Q1',   
  @v_grade_2              VARCHAR(2) = 'Q2',
  /* 
  EXAMPLE FOR IN-BETWEEN TERMS CALCULATION (EG REPORT CARD PREP)
  EXAMPLE IS END OF Q2
  v_grade_3              VARCHAR2(2) := 'FOO'   ;
  v_grade_4              VARCHAR2(2) := 'FOO'   ;
  */
  @v_grade_3              VARCHAR(2) = 'Q3',
  @v_grade_4              VARCHAR(2) = 'Q4',
  @v_grade_5              VARCHAR(2) = 'E1',
  @v_grade_6              VARCHAR(2) = 'E2',
  @v_grade_yr             VARCHAR(2) = 'Y1',
  @v_schoolly_d           INT     = 73253,
  
  --other variables
  @v_0                    INT     = 0,
  @v_1                    INT     = 1;

 --1. temp table to hold stored grades
 CREATE TABLE #TEMP_GRADES$NCA#SG
 (
  StudentID INT
  ,Course_number VARCHAR(11)
  ,Storecode VARCHAR(10) 
  ,Grade VARCHAR(7)
  ,[Percent] FLOAT
 );

 --2. temp table to hold pgfinalgrades
 CREATE TABLE #TEMP_GRADES$NCA#PGF
 (
  Sectionid INT
        ,Studentid INT
        ,FinalgradeName VARCHAR(8)
        ,[Percent] FLOAT
        ,Grade VARCHAR(7)
        ,Course_number VARCHAR(11)
 )

 --3. temp table to hold term base
 CREATE TABLE #TEMP_TERM$BASE
 (
  Termid INT, 
  Points INT
 );
 
 --4. staging table 1
 CREATE TABLE #TEMP_GRADES$NCA#STAGE_1
  (STUDENTID INT, 
  STUDENT_NUMBER FLOAT,
  SCHOOLID INT,
  LASTFIRST VARCHAR(135),
  GRADE_LEVEL INT, 
  COURSE_NUMBER VARCHAR(11),
  CREDITTYPE VARCHAR(20),
  COURSE_NAME VARCHAR(40),
  CREDIT_HOURS FLOAT
  );

 --5. staging table 2
  CREATE TABLE #TEMP_GRADES$NCA#STAGE_2(
  [studentid] [int] NULL,
  [student_number] [float] NULL,
  [schoolid] [int] NULL,
  [lastfirst] [varchar](135) NULL,
  [grade_level] [int] NULL,
  [course_number] [varchar](11) NULL,
  [credittype] [varchar](20) NULL,
  [course_name] [varchar](40) NULL,
  [credit_hours] [float] NULL,
  [Q1] [float] NULL,
  [Q2] [float] NULL,
  [Q3] [float] NULL,
  [Q4] [float] NULL,
  [e1] [float] NULL,
  [e2] [float] NULL,
  [Y1_stored] [float] NULL,
  [q1_letter] [varchar](7) NULL,
  [q2_letter] [varchar](7) NULL,
  [q3_letter] [varchar](7) NULL,
  [q4_letter] [varchar](7) NULL,
  [e1_letter] [varchar](7) NULL,
  [e2_letter] [varchar](7) NULL,
  [y1_letter_stored] [varchar](7) NULL,
  [Q1_enr_sectionid] [int] NULL,
  [Q2_enr_sectionid] [int] NULL,
  [Q3_enr_sectionid] [int] NULL,
  [Q4_enr_sectionid] [int] NULL
 );
 
 --6. production table/final table
 CREATE TABLE #TEMP_GRADES$NCA#STAGE_FINAL
 (
  [studentid] [int] NULL,
  [student_number] [float] NULL,
  [schoolid] [int] NULL,
  [lastfirst] [varchar](135) NULL,
  [grade_level] [int] NULL,
  [course_number] [varchar](11) NULL,
  [credittype] [varchar](20) NULL,
  [course_name] [varchar](40) NULL,
  [credit_hours] [float] NULL,
  [q1] [float] NULL,
  [q2] [float] NULL,
  [q3] [float] NULL,
  [q4] [float] NULL,
  [e1] [float] NULL,
  [e2] [float] NULL,
  [y1] [float] NULL,
  [q1_letter] [varchar](7) NULL,
  [q2_letter] [varchar](7) NULL,
  [q3_letter] [varchar](7) NULL,
  [q4_letter] [varchar](7) NULL,
  [e1_letter] [varchar](7) NULL,
  [e2_letter] [varchar](7) NULL,
  [y1_letter] [varchar](7) NULL,
  [q1_enr_sectionid] [int] NULL,
  [q2_enr_sectionid] [int] NULL,
  [q3_enr_sectionid] [int] NULL,
  [q4_enr_sectionid] [int] NULL,
  [qtr_valid] [int] NULL,
  [exam_valid] [int] NULL,
  [qtr_in_books] [int] NULL,
  [exam_in_books] [int] NOT NULL,
  [in_the_books] [float] NULL,
  [used_year] [numeric](15, 3) NULL,
  [course_y1] [varchar](73) NULL,
  [failing_y1] [varchar](73) NULL,
  [GPA_Points_Q1] [int] NULL,
  [GPA_Points_Q2] [int] NULL,
  [GPA_Points_Q3] [int] NULL,
  [GPA_Points_Q4] [int] NULL,
  [GPA_Points_E1] [int] NULL,
  [GPA_Points_E2] [int] NULL,
  [GPA_Points_Y1] [int] NULL,
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
  [Promo_Test] [int] NOT NULL,
  [need_c] [varchar](30) NULL,
  [need_b] [varchar](30) NULL,
  [need_a] [varchar](30) NULL,
  [need_d] [varchar](30) NULL,
  [need_c_absolute] [varchar](30) NULL,
  [need_b_absolute] [varchar](30) NULL,
  [need_a_absolute] [varchar](30) NULL,
  [need_d_absolute] [varchar](30) NULL,
  [need_c_text] [varchar](172) NULL
 )
 
 --Step 1: insert into temporary tables (SG and PGF)
 --this is over the linked server to PS production server
 --pgfinalgrades
 DECLARE @v_sql VARCHAR(MAX) =
  'SELECT  Convert(INT, sectionid) AS sectionid, 
    Convert(INT, studentid) AS studentid, 
    finalgradename, 
    [percent],
    grade,
    course_number
  FROM OPENQUERY(PS_TEAM,''SELECT   TO_CHAR(pgf.sectionid) as sectionid
          ,TO_CHAR(pgf.studentid) as studentid
          ,pgf.finalgradename
          ,pgf.percent
          ,pgf.grade
          ,cc.course_number
        FROM pgfinalgrades pgf
        JOIN cc
         ON pgf.sectionid = cc.sectionid 
         AND pgf.studentid = cc.studentid 	 
         AND cc.termid >= ' + CONVERT(VARCHAR,  @v_termid) + '
         AND cc.schoolid = ' + CONVERT(VARCHAR, @v_schoolly_d) + '
        WHERE pgf.finalgradename IN (''''' + @v_grade_1 + ''''','''''+ @v_grade_2 +''''','''''+ @v_grade_3 +''''','''''+ @v_grade_4 +''''')
          AND pgf.percent > ' + CONVERT(VARCHAR, @v_0) + '
        '');'; 
 
 INSERT INTO #TEMP_GRADES$NCA#PGF
 EXEC (@v_sql);
 
 --stored grades
 SET @v_sql = 
 'SELECT CONVERT(INT, STUDENTID) AS STUDENTID, 
   COURSE_NUMBER,
   STORECODE,
   GRADE,
   [PERCENT]
    FROM OPENQUERY(PS_TEAM, ''
    SELECT TO_CHAR(STUDENTID) AS STUDENTID
    ,COURSE_NUMBER
    ,STORECODE
    ,GRADE
    ,PERCENT
     FROM STOREDGRADES
    WHERE termid >= ' + CONVERT(VARCHAR,  @v_termid) + '
   AND schoolid = ' + CONVERT(VARCHAR, @v_schoolly_d) + ''');';

 INSERT INTO #TEMP_GRADES$NCA#SG
 EXEC (@v_sql);

 --term base
 SET @v_sql = 
 'SELECT CONVERT(INT, TERMID) AS TERMID, 
   CONVERT(INT, POINTS) AS POINTS
    FROM OPENQUERY(PS_TEAM, ''
   SELECT TO_CHAR(TERMID) AS TERMID
    ,CASE
     WHEN STORECODE LIKE ''''Q%'''' THEN ''''225''''
     WHEN STORECODE LIKE ''''E%'''' THEN ''''50''''
     ELSE ''''0''''
     END AS POINTS
   FROM TERMBINS
   WHERE SCHOOLID = ' + CONVERT(VARCHAR, @v_schoolly_d) + '
   AND TERMID >= ' + CONVERT(VARCHAR,  @v_termid) + '
   AND STORECODE
    IN (''''' + @v_grade_1 + ''''','''''+ @v_grade_2 +''''','''''+ @v_grade_3 +''''','''''+ @v_grade_4 +''''','''''+ @v_grade_5 +''''','''''+ @v_grade_6 +''''')'');';

 INSERT INTO #TEMP_TERM$BASE
 EXEC(@v_sql);

 --step 2
 INSERT INTO #TEMP_GRADES$NCA#STAGE_1
 SELECT s.id AS studentid
  ,s.student_number
  ,s.schoolid
  ,s.lastfirst
  ,s.grade_level
  ,cc.course_number
  ,c.credittype
  ,c.course_name
  ,c.credit_hours
 FROM students s
 JOIN cc ON s.id = cc.studentid
  AND cc.termid >= @v_termid
 JOIN courses c ON cc.course_number = c.course_number
 --exclude courses that will never count towards GPA
 AND c.excludefromgpa != @v_1
 WHERE s.enroll_status = @v_0
 AND s.schoolid = @v_schoolly_d;


 --step 3: assemble student enrollments and course grades into staging table
 --(no calculations yet)
 --students w/ all course enrollments this year
 --course enrollments are defined as anything that *was not dropped* 
 --during this school year
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
 --gradebook (PGFinalGrades) grades
 --FYI, assumption here is that a student is never enrolled in the same course
 --and term more than once
 LEFT OUTER JOIN #TEMP_GRADES$NCA#PGF pgf
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
 ), 
 level_sg AS (
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
 --stored (StoredGrades) grades
 LEFT OUTER JOIN #temp_grades$nca#sg sg
  ON (sg.studentid = level_1.studentid
  AND sg.course_number = level_1.course_number
  AND storecode IN (@v_grade_1, @v_grade_2, @v_grade_3, @v_grade_4, @v_grade_5, @v_grade_6, @v_grade_yr))
 GROUP BY level_1.studentid
   ,level_1.student_number
   ,level_1.schoolid
   ,level_1.lastfirst
   ,level_1.grade_level
   ,level_1.course_number
   ,level_1.credittype
   ,level_1.course_name
   ,level_1.credit_hours)

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
  ,CASE WHEN level_sg.q1_percent IS NOT NULL THEN level_sg.q1_percent ELSE level_pgf.q1_percent END AS Q1
  ,CASE WHEN level_sg.q2_percent IS NOT NULL THEN level_sg.q2_percent ELSE level_pgf.q2_percent END AS Q2
  ,CASE WHEN level_sg.q3_percent IS NOT NULL THEN level_sg.q3_percent ELSE level_pgf.q3_percent END AS Q3
  ,CASE WHEN level_sg.q4_percent IS NOT NULL THEN level_sg.q4_percent ELSE level_pgf.q4_percent END AS Q4
  ,level_sg.e1_percent AS e1
  ,level_sg.e2_percent AS e2
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
 FROM level_pgf JOIN level_sg 
  ON (level_pgf.studentid = level_sg.studentid
   AND level_pgf.student_number = level_sg.student_number
   AND level_pgf.schoolid = level_sg.schoolid
   AND level_pgf.lastfirst = level_sg.lastfirst
   AND level_pgf.grade_level = level_sg.grade_level
   AND level_pgf.course_number = level_sg.course_number
   AND level_pgf.credittype = level_sg.credittype
   AND level_pgf.course_name = level_sg.course_name
   AND level_pgf.credit_hours	= level_sg.credit_hours);

 --step 3: average Y1
 WITH level_1 AS 
 (SELECT stage_1.*
              ,(case 
                  when Q1 is null then 0 else 1 
                end) 
              + (case 
                  when Q2 is null then 0 else 1 
                end)
              + (case 
                  when Q3 is null then 0 else 1 
                end)
              + (case 
                  when Q4 is null then 0 else 1 
                end) qtr_valid
               ,case 
                  when E1 is null then 0 else 1 
                end 
              + case 
                  when E2 is null then 0 else 1 
                end exam_valid
              ,(case 
                  when Q1 is null then 0 else 1 
                end) 
              + (case 
                  when Q2 is null then 0 else 1 
                end)
              + (case 
                  when Q3 is null then 0 else 1 
                end) qtr_in_books
             ,case 
                  when E1 is null then 0 else 1 
                end exam_in_books
        FROM #TEMP_GRADES$NCA#STAGE_2 stage_1
 ),
 stage_2 AS
 (
 SELECT level_1.*
  --this weights quarterly grades and exam grades  
  ,CASE 
   WHEN Y1_stored IS NOT NULL THEN Y1_stored
   WHEN qtr_valid + exam_valid = 0 then null
   ELSE ROUND (
      (
       ((COALESCE(Q1, 0) + COALESCE(Q2, 0) + COALESCE(Q3, 0) + COALESCE(Q4, 0)) * 0.225) +
       ((COALESCE(E1, 0) + COALESCE(E2, 0)) * 0.05)
      ) / 
      ((qtr_valid * 22.5) + (exam_valid * 5)) * 100
     , 0)
   end as Y1
  ,case 
   when qtr_in_books + exam_in_books = 0 then null 
   else round (
      (
       ((COALESCE(Q1, 0) + COALESCE(Q2, 0) + COALESCE(Q3, 0)) * 0.225) +
       ((COALESCE(E1, 0)) * 0.05)
      ) / 
      ((qtr_in_books * 22.5) + (exam_in_books * 5)) * 100
     , 1)
   end as in_the_books
  ,(qtr_in_books*.225)+(exam_in_books*.05) as used_year
 FROM level_1),
 --SIGH
 --you have to account for varying denominators
 --to do that you need to know how many valid grades this enrollment will count for
 --we look for all instances of a student's enrollment, join to a representation
 --(a weighted representation) of how many named grade entities exist for that
 --termid
 --BECAUSE a kid can enroll in BOTH Q1 and say Q3 we have to SUM that by course
 --number.  it's true.
 term_denominators AS (
 SELECT cc.studentid
   ,cc.course_number
   ,SUM(term_weights.points) AS points
 FROM cc JOIN
  (SELECT termid
    ,SUM(points)/10 AS points
   FROM #TEMP_TERM$BASE 
   GROUP BY termid
  )  term_weights
  ON term_weights.termid = cc.termid
 WHERE cc.schoolid = @v_schoolly_d
  AND cc.termid >= @v_termid
 GROUP BY cc.studentid
   ,cc.course_number
 ),
 stage_3_1 AS
 (
 SELECT stage_2.*
   --we really need to find a better way to calculate GPA and letter
   --grades because this just makes me cringe.  maybe join to grade scales?
   ,case 
    when y1_letter_stored is not null then y1_letter_stored
    else CONVERT(VARCHAR, gradescale_y1.letter_grade)
   end as y1_letter
   ,gradescale_Y1.grade_points AS GPA_Points_Y1
   ,COURSE_NAME + ' [' + CONVERT(VARCHAR, ROUND(Y1, 0)) + ']' AS COURSE_Y1
   ,CASE 
    WHEN Y1 < 65 THEN COURSE_NAME + ' [' + CONVERT(VARCHAR, ROUND(Y1, 0)) + ']'
    ELSE NULL
   END AS FAILING_Y1
   ,GRADESCALE_Q1.GRADE_POINTS AS GPA_POINTS_Q1
   ,GRADESCALE_Q2.GRADE_POINTS AS GPA_POINTS_Q2
   ,GRADESCALE_Q3.GRADE_POINTS AS GPA_POINTS_Q3
   ,GRADESCALE_Q4.GRADE_POINTS AS GPA_POINTS_Q4
   ,GRADESCALE_E1.GRADE_POINTS AS GPA_POINTS_E1
   ,GRADESCALE_E2.GRADE_POINTS AS GPA_POINTS_E2              
   ,case when Q1 is not null then credit_hours else null end as credit_hours_Q1
   ,case when Q2 is not null then credit_hours else null end as credit_hours_Q2
   ,case when Q3 is not null then credit_hours else null end as credit_hours_Q3       
   ,case when Q4 is not null then credit_hours else null end as credit_hours_Q4
   ,case when E1 is not null then credit_hours else null end as credit_hours_E1
   ,case when E2 is not null then credit_hours else null end as credit_hours_E2
   ,case when Y1 is not null then credit_hours else null end as credit_hours_Y1
   ,(term_denominators.points - (100 * used_year)) / 100 AS year_remaining 
        FROM stage_2
        JOIN (SELECT gradescaleid
                    ,course_number
                FROM COURSES) courses   
          ON stage_2.course_number = courses.course_number
        
        LEFT OUTER JOIN GRADES$grade_scales AS gradescale_Q1 
          ON courses.gradescaleid = gradescale_Q1.scale_id
         AND stage_2.Q1 >= gradescale_Q1.low_cut 
         AND stage_2.Q1 < gradescale_Q1.high_cut
        
        LEFT OUTER JOIN GRADES$grade_scales AS gradescale_Q2 
          ON courses.gradescaleid = gradescale_Q2.scale_id
         AND stage_2.Q2 >= gradescale_Q2.low_cut 
         AND stage_2.Q2 < gradescale_Q2.high_cut
        
        LEFT OUTER JOIN GRADES$grade_scales AS gradescale_Q3 
          ON courses.gradescaleid = gradescale_Q3.scale_id
         AND stage_2.Q3 >= gradescale_Q3.low_cut 
         AND stage_2.Q3 < gradescale_Q3.high_cut
        
        LEFT OUTER JOIN GRADES$grade_scales AS gradescale_Q4 
          ON courses.gradescaleid = gradescale_Q4.scale_id
         AND stage_2.Q4 >= gradescale_Q4.low_cut 
         AND stage_2.Q4 < gradescale_Q4.high_cut
         
        LEFT OUTER JOIN GRADES$grade_scales AS gradescale_E1 
          ON courses.gradescaleid = gradescale_E1.scale_id
         AND stage_2.E1 >= gradescale_E1.low_cut 
         AND stage_2.E1 < gradescale_E1.high_cut
         
        LEFT OUTER JOIN GRADES$grade_scales AS gradescale_E2 
          ON courses.gradescaleid = gradescale_E2.scale_id
         AND stage_2.E2 >= gradescale_E2.low_cut 
         AND stage_2.E2 < gradescale_E2.high_cut
         
        LEFT OUTER JOIN GRADES$grade_scales AS gradescale_Y1 
          ON courses.gradescaleid = gradescale_Y1.scale_id 
         AND stage_2.Y1 >= gradescale_Y1.low_cut 
         AND stage_2.Y1 < gradescale_Y1.high_cut

        JOIN term_denominators
          ON term_denominators.course_number = stage_2.course_number
          AND term_denominators.studentid = stage_2.studentid)

 INSERT INTO #TEMP_GRADES$NCA#STAGE_FINAL
  SELECT  
    studentid
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
  ,credit_hours_Q1 * GPA_points_Q1 as weighted_points_Q1
  ,credit_hours_Q2 * GPA_points_Q2 as weighted_points_Q2
  ,credit_hours_Q3 * GPA_points_Q3 as weighted_points_Q3
  ,credit_hours_Q4 * GPA_points_Q4 as weighted_points_Q4
  ,credit_hours_E1 * GPA_points_E1 as weighted_points_E1
  ,credit_hours_E2 * GPA_points_E2 as weighted_points_E2
  ,credit_hours_Y1 * GPA_points_Y1 as weighted_points_Y1
  ,case when Y1 < 70 then 1 else 0 end Promo_Test    
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
   ELSE CONVERT(VARCHAR, ROUND((((used_year + year_remaining) * 90) - (in_the_books * used_year)) / year_remaining,1))
   END AS need_a
  ,CASE
   WHEN year_remaining = 0 THEN NULL
   WHEN ROUND((((used_year + year_remaining) * 60) - (in_the_books * used_year)) / year_remaining,1) < 60 THEN '<60 (hidden)'
   ELSE CONVERT(VARCHAR, ROUND((((used_year + year_remaining) * 60) - (in_the_books * used_year)) / year_remaining,1))
   END AS need_d
  ,CASE
   WHEN year_remaining = 0 THEN NULL
   ELSE CONVERT(VARCHAR, ROUND((((used_year + year_remaining) * 70) - (in_the_books * used_year)) / year_remaining,1))
   END AS need_c_absolute
  ,CASE
   WHEN year_remaining = 0 THEN NULL
   ELSE CONVERT(VARCHAR, ROUND((((used_year + year_remaining) * 80) - (in_the_books * used_year)) / year_remaining,1))
   END AS need_b_absolute
  ,CASE
   WHEN year_remaining = 0 THEN NULL
   ELSE CONVERT(VARCHAR, ROUND((((used_year + year_remaining) * 90) - (in_the_books * used_year)) / year_remaining,1))
   END AS need_a_absolute
  ,CASE
   WHEN year_remaining = 0 THEN NULL
   ELSE CONVERT(VARCHAR, ROUND((((used_year + year_remaining) * 60) - (in_the_books * used_year)) / year_remaining,1))
   END AS need_d_absolute
  ,'(((' + CONVERT(VARCHAR, used_year) + '+' + CONVERT(VARCHAR, year_remaining) + ') * 70) - (' + CONVERT(VARCHAR, in_the_books) + ' * ' + CONVERT(VARCHAR, used_year) + ')) /' + CONVERT(VARCHAR, year_remaining) AS need_c_text     
 FROM STAGE_3_1;
 
 --step 5: truncate the grades$detail#nca table
 EXEC ('TRUNCATE TABLE GRADES$DETAIL#NCA');

 --step 6: append to result table
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
   SELECT 
    [studentid]
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

