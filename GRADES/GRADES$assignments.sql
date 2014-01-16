USE KIPP_NJ
GO

INSERT INTO GRADES$assignments
SELECT *
FROM
     (
      SELECT schoolid      
            ,studentid
            ,student_number
            ,course_number      
            ,section_number
            ,sectionid
            ,name
            ,CONVERT(DATE,datedue) AS due_date
            ,pointspossible
            ,CASE WHEN score = '--' THEN NULL ELSE score END AS score
            ,[percent]
            ,grade
            ,exempt
            ,RTRIM(LTRIM(category)) AS category      
      FROM OPENQUERY(PS_TEAM,'
             SELECT s.schoolid             
                   ,s.id AS studentid
                   ,s.student_number
                   ,cc.course_number             
                   ,cc.section_number
                   ,ssid.sectionid      
                   ,pga.name      
                   ,pga.datedue
                   ,pga.pointspossible            
                   ,ssa.score
                   ,ssa.percent
                   ,ssa.grade
                   ,ssa.exempt
                   ,pgc.name AS category             
             FROM students s
             JOIN cc
               ON s.id = cc.studentid
              AND cc.termid >= 2300
             JOIN sectionscoresid ssid
               ON s.id = ssid.studentid
              AND cc.sectionid = ssid.sectionid
             JOIN sectionscoresassignments ssa
              ON ssid.DCID = ssa.FDCID
             JOIN pgassignments pga
               ON ssa.assignment = pga.id
              AND ssid.sectionid = pga.sectionid
              --AND pga.datedue >= TO_DATE(''2014-01-01'',''YYYY-MM-DD'')
             JOIN pgcategories pgc
               ON pga.pgcategoriesid = pgc.id
              AND ssid.sectionid = pgc.sectionid
              AND pgc.name LIKE ''%Homework%''
             WHERE s.enroll_status = 0
               AND s.schoolid = 73252
               AND s.grade_level = 8
             ') assignments
     ) sub