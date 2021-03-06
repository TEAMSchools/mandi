USE KIPP_NJ
GO

ALTER PROCEDURE sp_GRADES$StoredGradesImport    
  @schoolid INT,
  @storecode VARCHAR(2),
  @termid INT,
  @academic_year INT
AS

DECLARE @sql NVARCHAR(MAX)

BEGIN

  IF (@storecode != 'Y1')
    BEGIN
      SET @sql = '
        SELECT gbooks.*
              ,scale.grade_points AS gpa_points
              ,scale.scale_name AS gradescale_name
        FROM OPENQUERY(PS_TEAM,''
          SELECT cc.studentid                
                ,cc.section_number AS sectionnumber_NOIMPORT                
                ,cc.schoolid                
                ,cc.termid
                ,cc.sectionid            
                
                ,s.student_number
                ,s.grade_level
                ,s.lastfirst AS lastfirst_NOIMPORT
                ,s.student_number || ''''_''''  || c.course_number AS dupeaudit_NOIMPORT            

                ,c.course_name
                ,c.course_number            
                ,c.credittype AS credit_type
                ,c.excludefromgpa
                ,c.excludefromclassrank
                ,c.excludefromhonorroll
                ,c.gradescaleid AS gradescaleid_NOIMPORT
                
                ,t.lastfirst AS teacher_name
                
                ,pgf.finalgradename AS storecode
                ,CASE
                  WHEN pgf.percent < 50 THEN ''''F*''''                  
                  ELSE pgf.grade
                 END AS grade
                ,CASE
                  WHEN pgf.percent < 50 THEN 50                  
                  ELSE pgf.percent
                 END AS percent                
          FROM ps.cc cc
          JOIN ps.students s
            ON cc.studentid = s.id           
          JOIN ps.courses c
            ON cc.course_number = c.course_number
           AND c.course_number NOT IN (''''HR'''',''''STUDY10'''',''''STUDY11'''',''''CHK'''')
          JOIN ps.teachers t
            ON cc.teacherid = t.id
          JOIN ps.pgfinalgrades pgf
            ON cc.studentid = pgf.studentid
           AND cc.sectionid = pgf.sectionid
           AND pgf.grade != ''''--''''    
           AND pgf.finalgradename = ''''' + @storecode + '''''            
          WHERE cc.termid >= ' + CONVERT(VARCHAR,@termid) + '    
            AND cc.schoolid = ' + CONVERT(VARCHAR,@schoolid)  + '
        '') gbooks
        LEFT OUTER JOIN GRADES$grade_scales#static scale WITH(NOLOCK)
          ON gbooks.gradescaleid_NOIMPORT = scale.scale_id
         AND gbooks.[percent] >= scale.low_cut
         AND gbooks.[percent] < scale.high_cut
      '
      EXEC sp_executesql @sql  
    END
  
  ELSE IF (@storecode = 'Y1')
    BEGIN
      SELECT CONVERT(VARCHAR,gr.STUDENT_NUMBER) + '_' + gr.COURSE_NUMBER AS dupeaudit_NOIMPORT
            ,gr.STUDENT_NUMBER
            ,gr.studentid
            ,gr.SCHOOLID
            ,gr.GRADE_LEVEL
            ,@termid AS termid
            ,gr.COURSE_NAME
            ,gr.COURSE_NUMBER
            ,gr.CREDITTYPE AS credit_type
            ,co.excludefromgpa
            ,co.excludefromclassrank
            ,co.excludefromhonorroll
            ,co.CREDIT_HOURS AS potentialcrhrs
            ,CASE WHEN gr.y1_grade_letter NOT LIKE 'F%' THEN co.CREDIT_HOURS ELSE 0 END AS earnedcrhrs
            ,'Y1' AS storecode
            ,gr.y1_grade_letter AS grade
            ,gr.y1_grade_percent AS [percent]
            ,scale.grade_points AS gpa_points
            ,scale.scale_name AS gradescale_name
      FROM KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
      JOIN KIPP_NJ..PS$COURSES#static co WITH(NOLOCK)
        ON gr.COURSE_NUMBER = co.COURSE_NUMBER       
      LEFT OUTER JOIN KIPP_NJ..GRADES$grade_scales#static scale WITH(NOLOCK)
        ON co.gradescaleid = scale.scale_id 
       AND gr.y1_grade_percent >= scale.low_cut
       AND gr.y1_grade_percent < scale.high_cut
      WHERE gr.SCHOOLID = @schoolid
        AND gr.academic_year = @academic_year
        AND gr.is_curterm = 1
        AND gr.Y1_grade_percent_adjusted IS NOT NULL
    END

END
GO

