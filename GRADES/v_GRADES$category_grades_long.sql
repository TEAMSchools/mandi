USE KIPP_NJ
GO

ALTER VIEW GRADES$category_grades_long AS

SELECT student_number
      ,SCHOOLID
      ,academic_year
      ,CREDITTYPE
      ,COURSE_NUMBER
      ,sectionid
      ,teacher_name
      ,reporting_term
      ,rt
      ,grade_category
      ,grade_category_pct
FROM
    (
     /* NCA */
     SELECT enr.student_number                   
           ,enr.SCHOOLID
           ,enr.academic_year
           ,enr.credittype      
           ,enr.course_number      
           ,enr.sectionid           
           ,enr.teacher_name            
      
           ,LEFT(pgf.FINALGRADENAME,1) AS grade_category
           ,CONCAT('RT', RIGHT(pgf.FINALGRADENAME,1)) AS reporting_term            
           ,CONCAT('RT', RIGHT(pgf.FINALGRADENAME,1)) AS rt
           ,ROUND(pgf.[PERCENT],0) AS grade_category_pct               
      
           ,ROW_NUMBER() OVER(
              PARTITION BY enr.student_number, enr.academic_year, enr.course_number, pgf.finalgradename
                ORDER BY enr.drop_flags ASC, enr.dateenrolled DESC, enr.dateleft DESC) AS rn
     FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
     JOIN KIPP_NJ..PS$PGFINALGRADES pgf WITH(NOLOCK)  
       ON enr.studentid = pgf.studentid       
      AND enr.sectionid = pgf.sectionid 
      AND pgf.finalgradename != 'Y1'       
      AND pgf.FINALGRADENAME NOT LIKE 'Q%'
     WHERE enr.course_enr_status = 0
       AND enr.SCHOOLID = 73253

     UNION ALL

     /* MS */
     SELECT enr.student_number                   
           ,enr.SCHOOLID
           ,enr.academic_year
           ,enr.credittype      
           ,enr.course_number      
           ,enr.sectionid           
           ,enr.teacher_name            
      
           ,CASE
             WHEN LEFT(pgf.FINALGRADENAME,1) = 'Q' THEN 'E'
             ELSE LEFT(pgf.FINALGRADENAME,1)
            END AS grade_category
           ,CONCAT('RT', RIGHT(pgf.FINALGRADENAME,1) + 1) AS reporting_term            
           ,CONCAT('RT', RIGHT(pgf.FINALGRADENAME,1)) AS rt
           ,ROUND(pgf.[PERCENT],0) AS grade_category_pct               
      
           ,ROW_NUMBER() OVER(
              PARTITION BY enr.student_number, enr.academic_year, enr.course_number, pgf.finalgradename
                ORDER BY enr.drop_flags ASC, enr.dateenrolled DESC, enr.dateleft DESC) AS rn
     FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
     JOIN KIPP_NJ..PS$PGFINALGRADES pgf WITH(NOLOCK)  
       ON enr.studentid = pgf.studentid       
      AND enr.sectionid = pgf.sectionid 
      AND pgf.finalgradename != 'Y1'       
      AND ((pgf.academic_year <= 2014 AND  pgf.FINALGRADENAME NOT LIKE 'T%') OR (pgf.academic_year >= 2015 AND pgf.FINALGRADENAME NOT LIKE 'Q%'))
     WHERE enr.course_enr_status = 0
       AND enr.SCHOOLID != 73253
    ) sub
WHERE rn = 1