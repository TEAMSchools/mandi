USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_GRADES$MS|refresh] AS

BEGIN
 -- SET NOCOUNT ON added to prevent extra result sets from
 -- interfering with SELECT statements
 SET NOCOUNT ON;

 DECLARE 
   @v_sql                 VARCHAR(MAX),
   @v_termid              INT = dbo.fn_Global_Term_Id(),
   @v_grade_1             VARCHAR(2) = 'T1',
   @v_grade_2             VARCHAR(2) = 'T2',
   @v_grade_3             VARCHAR(2) = 'T3',
   @v_grade_yr            VARCHAR(2) = 'FOO',
  
   --PS$COURSES#static to exclude
   @v_course_ex_advisory  VARCHAR(8) = 'Adv',
   @v_course_ex_chk       VARCHAR(3) = 'CHK',
   @v_course_ex_hr        VARCHAR(2) = 'HR',
  
   --credit types to exclude
   @v_credit_ex_log       VARCHAR(3) = 'LOG',
  
   --other variables
   @v_0                   INT = 0;

 --1. temp PGF
 CREATE TABLE #TEMP_GRADES$MS#PGF
  (SectionId INT, 
  StudentId INT,
  FinalgradeName VARCHAR(8), 
  [Percent] FLOAT, 
  Grade VARCHAR(7),
  Course_Number VARCHAR(25)
  );

 --2. temp stored grades
 CREATE TABLE #TEMP_GRADES$MS#SG
  (Studentid INT,
  Course_Number VARCHAR(25),
  StoreCode VARCHAR(10),
  Grade VARCHAR(7),
  [Percent] FLOAT);

 --3. staging table 1
 CREATE TABLE #TEMP_GRADES$MS#STAGE_1
  (STUDENTID INT, 
  STUDENT_NUMBER FLOAT,
  SCHOOLID INT,
  LASTFIRST NVARCHAR(135),
  GRADE_LEVEL INT, 
  COURSE_NUMBER NVARCHAR(33),
  CREDITTYPE NVARCHAR(20),
  COURSE_NAME NVARCHAR(MAX),
  CREDIT_HOURS FLOAT
  );

 --4. staging table 2
 CREATE TABLE #TEMP_GRADES$MS#STAGE_2
  (STUDENTID INT,
  "STUDENT_NUMBER" FLOAT,
  "SCHOOLID" INT,
  "LASTFIRST" NVARCHAR(135),
  "GRADE_LEVEL" INT,
  "COURSE_NUMBER" VARCHAR(33),
  "CREDITTYPE" NVARCHAR(20),
  "COURSE_NAME" NVARCHAR(40),
  "CREDIT_HOURS" FLOAT,
  "T1" FLOAT,
  "T2" FLOAT,
  "T3" FLOAT,
  "Y1" FLOAT,
  "T1_LETTER" VARCHAR(7),
  "T2_LETTER" VARCHAR(7),
  "T3_LETTER" VARCHAR(7),
  "Y1_LETTER" VARCHAR(7),
  "T1_ENR_SECTIONID" INT,
  "T2_ENR_SECTIONID" INT,
  "T3_ENR_SECTIONID" INT
  );

 -- production table/final table
 CREATE TABLE #TEMP_GRADES$MS#STAGE_FINAL
  (
   [studentid] [INT] NULL,
   [student_number] [float] NULL,
   [schoolid] [INT] NULL,
   [lastfirst] [VARCHAR](135) NULL,
   [grade_level] [INT] NULL,
   [course_number] [VARCHAR](11) NULL,
   [credittype] [VARCHAR](20) NULL,
   [course_name] [VARCHAR](40) NULL,
   [credit_hours_t1] [float] NULL,
   [credit_hours_t2] [float] NULL,
   [credit_hours_t3] [float] NULL,
   [credit_hours_y1] [float] NULL,
   [t1] [float] NULL,
   [t2] [float] NULL,
   [t3] [float] NULL, 
   [y1] [float] NULL,
   [t1_letter] [VARCHAR](7) NULL,
   [t2_letter] [VARCHAR](7) NULL,
   [t3_letter] [VARCHAR](7) NULL,
   [y1_letter] [VARCHAR](7) NULL,
   [t1_enr_sectionid] [INT] NULL,
   [t2_enr_sectionid] [INT] NULL,
   [t3_enr_sectionid] [INT] NULL,   
   [term_valid] [INT] NULL,   
   --[qtr_in_books] [INT] NULL,   
   --[in_the_books] [float] NULL,
   --[used_year] [numeric](15, 3) NULL,
   [course_y1] [VARCHAR](73) NULL,
   [failing_y1] [VARCHAR](73) NULL,
   [GPA_Points_t1] [INT] NULL,
   [GPA_Points_t2] [INT] NULL,
   [GPA_Points_t3] [INT] NULL,   
   [GPA_Points_Y1] [INT] NULL,
   --[credit_hours_t1] [float] NULL,
   --[credit_hours_t2] [float] NULL,
   --[credit_hours_t3] [float] NULL,   
   --[credit_hours_Y1] [float] NULL,
   [weighted_points_t1] [float] NULL,
   [weighted_points_t2] [float] NULL,
   [weighted_points_t3] [float] NULL,   
   [weighted_points_Y1] [float] NULL,
   [Promo_Test] [INT] NOT NULL
   --[need_c] [VARCHAR](30) NULL,
   --[need_b] [VARCHAR](30) NULL,
   --[need_a] [VARCHAR](30) NULL,
   --[need_d] [VARCHAR](30) NULL,
   --[need_c_absolute] [VARCHAR](30) NULL,
   --[need_b_absolute] [VARCHAR](30) NULL,
   --[need_a_absolute] [VARCHAR](30) NULL,
   --[need_d_absolute] [VARCHAR](30) NULL,
   --[need_c_text] [VARCHAR](172) NULL
  );

 --Step 1: insert into temmporary tables (SG and PGF)
 --this is over the linked server to PS production server

 --pgfinalgrades
 SET @v_sql = '
  SELECT CONVERT(INT, sectionid) AS sectionid
        ,CONVERT(INT, studentid) AS studentid
        ,finalgradename
        ,[percent]
        ,grade
        ,course_number
  FROM OPENQUERY(PS_TEAM,''
    SELECT TO_CHAR(pgf.sectionid) AS sectionid
          ,TO_CHAR(pgf.studentid) AS studentid
          ,pgf.finalgradename
          ,CASE WHEN pgf.grade = ''''--'''' THEN NULL ELSE pgf.percent END AS percent
          ,CASE WHEN pgf.grade = ''''--'''' THEN NULL ELSE pgf.grade END AS grade
          ,cc.course_number
    FROM pgfinalgrades pgf
    JOIN cc
      ON pgf.sectionid = cc.sectionid
     AND pgf.studentid = cc.studentid
     AND cc.termid >= ' + CONVERT(VARCHAR,  @v_termid) + '
     AND cc.schoolid IN (73252, 133570965)         
    WHERE pgf.finalgradename IN (''''' + @v_grade_1 + ''''','''''+ @v_grade_2 +''''','''''+ @v_grade_3 +''''')      
  '');
';

 INSERT INTO #TEMP_GRADES$MS#PGF
 EXEC (@v_sql); 

 --stored grades
 SET @v_sql = 
 'SELECT CONVERT(INT, studentid) AS studentid
        ,course_number
        ,storecode
        ,grade
        ,[percent]
  FROM OPENQUERY(PS_TEAM, ''
    SELECT TO_CHAR(studentid) AS studentid
          ,course_number
          ,storecode
          ,grade
          ,percent
    FROM storedgrades
    WHERE termid >= ' + CONVERT(VARCHAR,@v_termid) + '
      AND credit_type   != ''''' + @v_credit_ex_log + '''''
      AND course_number != ''''' + @v_course_ex_hr + '''''
      AND course_number != ''''' + @v_course_ex_chk + '''''
      AND schoolid IN (73252, 133570965)
  '');';

 INSERT INTO #TEMP_GRADES$MS#SG
 EXEC (@v_sql);

 --step 2: assemble student enrollments and course grades into first staging table
 --(no calculations yet)
 --KIPP_NJ..PS$STUDENTS#static w/ all course enrollments this year
 --course enrollments are defined AS anything that *was not dropped* 
 --during this school year
 WITH level_1 AS (
   --goal: get ALL enrollments that were EVER active for this school year
   --however, for same student/same course pairings, we only want to return
   --one listing.  the row_number statement decodes the most recent enrollment
   --so, for instance, if a student had 3 enrollments  (2201,2202,2203 - 
   --T1, T2, T3) the most recent would be returned
   SELECT co.STUDENTID AS studentid
         ,s.student_number
         ,co.schoolid
         ,co.lastfirst
         ,co.grade_level
         ,cc.course_number
         ,c.credittype
         ,c.course_name
         ,c.credit_hours
         ,ROW_NUMBER() OVER (
             PARTITION BY co.studentid
                         ,cc.course_number
                 ORDER BY cc.dateleft DESC) AS rn
   FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
   JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
     ON co.STUDENTID = s.ID
   JOIN PS$CC#static cc WITH(NOLOCK)
     ON co.STUDENTID = cc.studentid
    AND cc.sectionid > 0
    AND cc.termid >= @v_termid
    --exclude a bunch of PS$COURSES#static that will never count towards GPA
    AND cc.course_number != @v_course_ex_advisory
    AND cc.course_number != @v_course_ex_chk
    AND cc.course_number != @v_course_ex_hr
   JOIN PS$COURSES#static c WITH(NOLOCK)
     ON cc.course_number = c.course_number
    AND c.CREDITTYPE NOT IN ('LOG')
   WHERE co.YEAR = dbo.fn_Global_Academic_Year()
     AND co.schoolid IN (73252, 133570965)
     AND co.rn = 1
  )

 INSERT INTO #TEMP_GRADES$MS#STAGE_1
 SELECT STUDENTID
       ,STUDENT_NUMBER
       ,SCHOOLID
       ,LASTFIRST
       ,GRADE_LEVEL
       ,COURSE_NUMBER
       ,CREDITTYPE
       ,COURSE_NAME
       ,CREDIT_HOURS
 FROM level_1 
 WHERE RN = 1;
 
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
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_1 THEN pgf.[percent] END) AS T1
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_2 THEN pgf.[percent] END) AS T2
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_3 THEN pgf.[percent] END) AS T3
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_1 THEN pgf.grade END) AS T1_grade
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_2 THEN pgf.grade END) AS T2_grade
         ,MAX(CASE WHEN pgf.finalgradename = @v_grade_3 THEN pgf.grade END) AS T3_grade
         ,MAX(CASE WHEN pgf.FinalgradeName = @v_grade_1 THEN  pgf.sectionid END) AS T1_enr_sectionid
         ,MAX(CASE WHEN pgf.FinalgradeName = @v_grade_2 THEN  pgf.sectionid END) AS T2_enr_sectionid
         ,MAX(CASE WHEN pgf.FinalgradeName = @v_grade_3 THEN  pgf.sectionid END) AS T3_enr_sectionid
   FROM #TEMP_GRADES$MS#STAGE_1 AS level_1
   --gradebook (PGFinalGrades) grades
   --FYI, assumption here is that a student is never enrolled in the same course
   --and term more than once
   LEFT OUTER JOIN #TEMP_GRADES$MS#PGF pgf
     ON level_1.studentid     = pgf.studentid
    AND level_1.course_number = pgf.course_number
    AND pgf.finalgradename IN (@v_grade_1, @v_grade_2, @v_grade_3)    
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
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_1 THEN sg.[percent] END) AS T1
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_2 THEN sg.[percent] END) AS T2
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_3 THEN sg.[percent] END) AS T3
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_yr THEN sg.[percent] END) AS Y1
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_1 THEN sg.grade END) AS T1_grade
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_2 THEN sg.grade END) AS T2_grade
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_3 THEN sg.grade END) AS T3_grade
         ,MAX(CASE WHEN sg.StoreCode = @v_grade_yr THEN sg.grade END) AS y1_grade
   FROM #TEMP_GRADES$MS#STAGE_1 AS level_1
   --stored (StoredGrades) grades
   FULL JOIN #TEMP_GRADES$MS#SG sg
     ON level_1.studentid = sg.studentid
    AND level_1.course_number = sg.course_number
    AND sg.storecode IN (@v_grade_1, @v_grade_2, @v_grade_3, @v_grade_yr)
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

 INSERT INTO #TEMP_GRADES$MS#STAGE_2
 SELECT level_pgf.studentid
       ,level_pgf.student_number
       ,level_pgf.schoolid
       ,level_pgf.lastfirst
       ,level_pgf.grade_level
       ,level_pgf.course_number
       ,level_pgf.credittype
       ,level_pgf.course_name
       ,level_pgf.credit_hours
       ,CASE WHEN level_sg.T1 IS NOT NULL THEN level_sg.T1 ELSE level_pgf.T1 END AS T1
       ,CASE WHEN level_sg.T2 IS NOT NULL THEN level_sg.T2 ELSE level_pgf.T2 END AS T2
       ,CASE WHEN level_sg.T3 IS NOT NULL THEN level_sg.T3 ELSE level_pgf.T3 END AS T3
       ,level_sg.Y1
       ,CASE WHEN level_sg.T1_grade IS NOT NULL THEN level_sg.T1_grade ELSE level_pgf.T1_grade END AS T1_grade
       ,CASE WHEN level_sg.T2_grade IS NOT NULL THEN level_sg.T2_grade ELSE level_pgf.T2_grade END AS T2_grade
       ,CASE WHEN level_sg.T3_grade IS NOT NULL THEN level_sg.T3_grade ELSE level_pgf.T3_grade END AS T3_grade
       ,level_sg.y1_grade
       ,level_pgf.T1_enr_sectionid
       ,level_pgf.T2_enr_sectionid
       ,level_pgf.T3_enr_sectionid
 FROM level_pgf 
 JOIN level_sg 
   ON level_pgf.studentid = level_sg.studentid
  AND level_pgf.student_number = level_sg.student_number
  AND level_pgf.schoolid = level_sg.schoolid
  AND level_pgf.lastfirst = level_sg.lastfirst
  AND level_pgf.grade_level = level_sg.grade_level
  AND level_pgf.course_number = level_sg.course_number
  AND level_pgf.credittype = level_sg.credittype
  AND level_pgf.course_name = level_sg.course_name
  AND level_pgf.credit_hours	= level_sg.credit_hours;


 --step 3: load into final staging table
 --average Y1 grade from trimester elements
 --this needs to be selected and put into temp table THEN truncate THEN instert into final
 WITH level_1 AS (
   SELECT stage_2.*
         ,(CASE WHEN T1 IS NULL THEN 0 ELSE 1 END 
            + CASE WHEN T2 IS NULL THEN 0 ELSE 1 END 
            + CASE WHEN T3 IS NULL THEN 0 ELSE 1 END) AS term_valid
   FROM #TEMP_GRADES$MS#STAGE_2 stage_2
  )

 ,TEMP_GRADES$MS#STAGE_2 AS (
    SELECT studentid
          ,student_number
          ,schoolid
          ,lastfirst
          ,grade_level
          ,course_number
          ,credittype
          ,course_name
          ,credit_hours
          ,t1
          ,t2
          ,t3
          ,CASE
            WHEN Y1 IS NOT NULL THEN Y1 --if there's already a Y1 in SG, leave it be            
            WHEN term_valid = 0 THEN NULL --if there are no valid trimester grade components, leave it null            
            ELSE ROUND((COALESCE(T1, 0) + COALESCE(T2, 0) + COALESCE(T3, 0)) / term_valid, 0) --otherwise, add up T1, T2 and T3 and average away!
           END AS Y1
          ,t1_letter
          ,t2_letter
          ,t3_letter
          ,y1_letter
          ,t1_enr_sectionid
          ,t2_enr_sectionid
          ,t3_enr_sectionid
          ,term_valid
    FROM level_1
   )
 
 --credit hours, letter conversion, weights
 ,level_2 AS (
    SELECT studentid
          ,student_number
          ,schoolid
          ,lastfirst
          ,grade_level
          ,course_number
          ,credittype
          ,course_name
          ,T1
          ,T2
          ,T3
          ,Y1
          ,T1_letter
          ,T2_letter
          ,T3_letter
          ,T1_enr_sectionid
          ,T2_enr_sectionid
          ,T3_enr_sectionid
          ,term_valid
          ,course_name + ' [' + CONVERT(VARCHAR, ROUND(Y1, 0)) + ']' AS course_Y1
          ,CASE
            WHEN Y1 < 65 THEN course_name + ' [' + CONVERT(VARCHAR, ROUND(Y1, 0)) + ']'
            ELSE NULL
           END failing_Y1
          ,gradescale_T1.grade_points AS gpa_points_T1
          ,gradescale_T2.grade_points AS gpa_points_T2
          ,gradescale_T3.grade_points AS gpa_points_T3    
          ,gradescale_Y1.grade_points AS gpa_points_Y1
          ,gradescale_Y1.letter_grade AS Y1_letter
          ,CASE WHEN T1 IS NOT NULL THEN credit_hours ELSE NULL END AS credit_hours_T1
          ,CASE WHEN T2 IS NOT NULL THEN credit_hours ELSE NULL END AS credit_hours_T2
          ,CASE WHEN T3 IS NOT NULL THEN credit_hours ELSE NULL END AS credit_hours_T3       
          ,CASE WHEN Y1 IS NOT NULL THEN credit_hours ELSE NULL END AS credit_hours_Y1
    FROM TEMP_GRADES$MS#STAGE_2 stage_2
    LEFT OUTER JOIN GRADES$grade_scales#static gradescale_T1 WITH(NOLOCK)
      ON gradescale_T1.scale_id = 1
     AND stage_2.T1 >= gradescale_T1.low_cut 
     AND stage_2.T1 < gradescale_T1.high_cut   
    LEFT OUTER JOIN GRADES$grade_scales#static gradescale_T2 WITH(NOLOCK)
      ON gradescale_T2.scale_id = 1
     AND stage_2.T2 >= gradescale_T2.low_cut 
     AND stage_2.T2 < gradescale_T2.high_cut   
    LEFT OUTER JOIN GRADES$grade_scales#static gradescale_T3 WITH(NOLOCK)
      ON gradescale_T3.scale_id = 1
     AND stage_2.T3 >= gradescale_T3.low_cut 
     AND stage_2.T3 < gradescale_T3.high_cut
    LEFT OUTER JOIN GRADES$grade_scales#static gradescale_Y1 WITH(NOLOCK)
      ON gradescale_Y1.scale_id = 1
     AND stage_2.Y1 >= gradescale_Y1.low_cut 
     AND stage_2.Y1 < gradescale_Y1.high_cut   
   )
 
 INSERT INTO #TEMP_GRADES$MS#STAGE_FINAL
 SELECT studentid
       ,student_number
       ,schoolid
       ,CAST(lastfirst AS VARCHAR(35)) lastfirst
       ,grade_level
       ,CAST(course_number AS VARCHAR(11)) course_number
       ,CAST(credittype AS VARCHAR(20)) credittype
       ,CAST(course_name AS VARCHAR(40)) course_name
       ,credit_hours_T1
       ,credit_hours_T2
       ,credit_hours_T3
       ,credit_hours_Y1
       ,T1
       ,T2
       ,T3
       ,Y1
       ,T1_letter
       ,T2_letter
       ,T3_letter
       ,Y1_letter
       ,T1_enr_sectionid
       ,T2_enr_sectionid
       ,T3_enr_sectionid
       ,term_valid
       ,CAST(course_Y1 AS VARCHAR(400)) course_Y1
       ,CAST(failing_Y1 AS VARCHAR(400)) failing_Y1
       ,GPA_points_T1
       ,GPA_points_T2
       ,GPA_points_T3
       ,GPA_points_Y1
       ,credit_hours_T1 * GPA_points_T1 AS weighted_points_T1
       ,credit_hours_T2 * GPA_points_T2 AS weighted_points_T2
       ,credit_hours_T3 * GPA_points_T3 AS weighted_points_T3
       ,credit_hours_Y1 * GPA_points_Y1 AS weighted_points_Y1
       ,CASE 
         WHEN Y1 < 65 THEN 1 
         ELSE 0 
        END AS Promo_Test 
 FROM level_2;
 

 --step 4: truncate the grades$detail#ms table
 EXEC ('TRUNCATE TABLE GRADES$DETAIL#MS');


 --step 5: insert into destination table
 INSERT INTO dbo.GRADES$DETAIL#MS
 SELECT * 
 FROM #TEMP_GRADES$MS#STAGE_FINAL;

END

GO