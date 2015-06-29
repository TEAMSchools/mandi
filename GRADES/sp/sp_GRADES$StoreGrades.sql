USE KIPP_NJ
GO

ALTER PROCEDURE sp_GRADES$StoreGrades    
  @schoolid INT,
  @storecode VARCHAR(2)
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
          SELECT s.lastfirst AS lastfirst_NOIMPORT
                ,s.student_number || ''''_''''  || c.course_number AS dupeaudit_NOIMPORT            
                ,cc.section_number AS sectionnumber_NOIMPORT
                ,s.student_number
                ,s.schoolid
                ,s.grade_level
                ,cc.termid
                ,cc.sectionid            
                ,c.course_name
                ,c.course_number            
                ,c.credittype AS credit_type
                ,c.excludefromgpa
                ,c.excludefromclassrank
                ,c.excludefromhonorroll
                ,t.lastfirst AS teacher_name
                ,pgf.finalgradename AS storecode
                ,CASE
                  WHEN s.schoolid = 73253 AND pgf.percent < 50 THEN ''''F*''''
                  WHEN s.schoolid = 133570965 AND pgf.percent < 55 THEN ''''F*''''
                  ELSE pgf.grade
                 END AS grade
                ,CASE
                  WHEN s.schoolid = 73253 AND pgf.percent < 50 THEN 50
                  WHEN s.schoolid = 133570965 AND pgf.percent < 55 THEN 55
                  ELSE pgf.percent
                 END AS percent
                ,c.gradescaleid AS gradescaleid_NOIMPORT
          FROM ps.students s
          JOIN ps.cc cc
            ON cc.studentid = s.id
           AND cc.termid >= ' + CONVERT(VARCHAR,dbo.fn_Global_Term_Id()) + '    
          JOIN ps.courses c
            ON cc.course_number = c.course_number
           AND c.course_number NOT IN (''''HR'''',''''STUDY10'''',''''STUDY11'''',''''CHK'''')
          JOIN ps.teachers t
            ON cc.teacherid = t.id
          JOIN ps.pgfinalgrades pgf
            ON pgf.studentid = s.id
           AND pgf.sectionid = cc.sectionid
           AND pgf.grade != ''''--''''    
           AND pgf.finalgradename = ''''' + @storecode + '''''    
          WHERE s.enroll_status = 0    
            AND s.schoolid = ' + CONVERT(VARCHAR,@schoolid)  + '
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
      SELECT gr.LASTFIRST AS lastfirst_NOIMPORT
            ,CONVERT(VARCHAR,gr.STUDENT_NUMBER) + '_' + gr.COURSE_NUMBER AS dupeaudit_NOIMPORT
            ,gr.STUDENT_NUMBER
            ,gr.SCHOOLID
            ,gr.GRADE_LEVEL
            ,dbo.fn_Global_Term_Id() AS termid
            ,gr.COURSE_NAME
            ,gr.COURSE_NUMBER
            ,gr.CREDITTYPE AS credit_type
            ,co.excludefromgpa
            ,co.excludefromclassrank
            ,co.excludefromhonorroll
            ,co.CREDIT_HOURS AS potentialcrhrs
            ,CASE 
              WHEN gr.schoolid = 73253 AND gr.y1 >= 70 THEN co.CREDIT_HOURS 
              WHEN gr.SCHOOLID IN (73252, 133570965) AND gr.y1 >= 65 THEN co.CREDIT_HOURS
              ELSE 0
             END AS earnedcrhrs
            ,'Y1' AS storecode
            ,gr.y1_letter AS grade
            ,CASE
              WHEN gr.SCHOOLID = 133570965 AND gr.y1 < 55 THEN 55
              WHEN gr.SCHOOLID = 73253 AND gr.y1 < 50 THEN 50
              ELSE gr.y1
             END AS [percent]
            ,scale.grade_points AS gpa_points
            ,scale.scale_name AS gradescale_name
      FROM GRADES$DETAIL#MS gr WITH(NOLOCK)
      JOIN COURSES co WITH(NOLOCK)
        ON gr.COURSE_NUMBER = co.COURSE_NUMBER
       AND gr.SCHOOLID = co.SCHOOLID
      LEFT OUTER JOIN GRADES$grade_scales#static scale WITH(NOLOCK)
        ON co.gradescaleid = scale.scale_id
       AND gr.Y1 >= scale.low_cut
       AND gr.Y1 < scale.high_cut
      WHERE gr.SCHOOLID = @schoolid
        AND gr.Y1 IS NOT NULL
      
      UNION ALL

      SELECT gr.LASTFIRST AS lastfirst_NOIMPORT
            ,CONVERT(VARCHAR,gr.STUDENT_NUMBER) + '_' + gr.COURSE_NUMBER AS dupeaudit_NOIMPORT
            ,gr.STUDENT_NUMBER
            ,gr.SCHOOLID
            ,gr.GRADE_LEVEL
            ,dbo.fn_Global_Term_Id() AS termid
            ,gr.COURSE_NAME
            ,gr.COURSE_NUMBER
            ,gr.CREDITTYPE      
            ,co.excludefromgpa
            ,co.excludefromclassrank
            ,co.excludefromhonorroll
            ,co.CREDIT_HOURS AS potentialcrhrs
            ,CASE 
              WHEN gr.schoolid IN (133570965, 73253) AND gr.y1 >= 70 THEN co.CREDIT_HOURS 
              WHEN gr.SCHOOLID = 73252 AND gr.y1 >= 65 THEN co.CREDIT_HOURS
              ELSE 0
             END AS earnedcrhrs
            ,'Y1' AS storecode
            ,gr.y1_letter AS grade
            ,CASE
              WHEN gr.SCHOOLID = 133570965 AND gr.y1 < 55 THEN 55
              WHEN gr.SCHOOLID = 73253 AND gr.y1 < 50 THEN 50
              ELSE gr.y1
             END AS [percent]
            ,scale.grade_points AS gpa_points
            ,scale.scale_name AS gradescale_name
      FROM GRADES$DETAIL#NCA gr WITH(NOLOCK)
      JOIN COURSES co WITH(NOLOCK)
        ON gr.COURSE_NUMBER = co.COURSE_NUMBER
       AND gr.schoolid = co.schoolid
      LEFT OUTER JOIN GRADES$grade_scales#static scale WITH(NOLOCK)
        ON co.gradescaleid = scale.scale_id
       AND gr.Y1 >= scale.low_cut
       AND gr.Y1 < scale.high_cut
      WHERE gr.SCHOOLID = @schoolid
        AND gr.Y1 IS NOT NULL
    END

END
GO
