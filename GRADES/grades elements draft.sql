USE KIPP_NJ
GO

CREATE VIEW GRADES$category_grades_long

SELECT enr.student_number                   
      ,enr.SCHOOLID
      ,enr.academic_year
      ,enr.credittype      
      ,enr.course_number      
      ,enr.sectionid           
      ,enr.teacher_name            
      
      ,LEFT(pgf.FINALGRADENAME,1) AS grade_category
      ,CONCAT('RT', RIGHT(pgf.FINALGRADENAME,1)) AS reporting_term      
      
      ,ROUND(pgf.[PERCENT],0) AS pgf_pct
      --,pgf.GRADE AS pgf_letter      
      
      --,ROUND(sg.PCT,0) AS stored_pct
      --,sg.GRADE AS stored_letter            
      
      ,ROW_NUMBER() OVER(
         PARTITION BY enr.student_number, enr.academic_year, enr.course_number, pgf.finalgradename
           ORDER BY enr.drop_flags ASC, enr.dateenrolled DESC, enr.dateleft DESC) AS rn
FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
JOIN KIPP_NJ..PS$PGFINALGRADES pgf WITH(NOLOCK)  
  ON enr.studentid = pgf.studentid       
 AND enr.sectionid = pgf.sectionid 
 AND pgf.finalgradename != 'Y1' 
 AND pgf.FINALGRADENAME NOT LIKE 'T%' 
 AND pgf.FINALGRADENAME NOT LIKE 'Q%'
--LEFT OUTER JOIN KIPP_NJ..GRADES$STOREDGRADES#static sg WITH(NOLOCK)
--  ON pgf.studentid = sg.STUDENTID 
-- AND pgf.SECTIONID = sg.SECTIONID
-- AND pgf.FINALGRADENAME = sg.STORECODE 
WHERE enr.course_enr_status = 0