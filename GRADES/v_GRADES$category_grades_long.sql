USE KIPP_NJ
GO

ALTER VIEW GRADES$category_grades_long AS

SELECT sub.student_number
      ,sub.SCHOOLID
      ,sub.academic_year
      ,sub.CREDITTYPE
      ,sub.COURSE_NUMBER
      ,sub.sectionid
      ,sub.teacher_name
      ,sub.reporting_term
      ,sub.rt      
      ,sub.grade_category
      ,sub.grade_category_pct
      
      ,ROUND(AVG(sub.grade_category_pct) OVER(PARTITION BY sub.student_number, sub.academic_year, sub.course_number, sub.grade_category ORDER BY sub.reporting_term),0) AS grade_category_pct_y1
      ,CASE WHEN sub.academic_year = dt.academic_year AND sub.reporting_term = dt.time_per_name THEN 1 ELSE 0 END AS is_curterm
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
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON sub.schoolid = dt.schoolid
 AND CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT'
WHERE sub.rn = 1