USE KIPP_NJ
GO

ALTER VIEW PS$course_order_scaffold AS

SELECT sub.student_number
      ,sub.studentid
      ,sub.schoolid
      ,sub.academic_year
      ,CONVERT(VARCHAR,sub.term) AS term
      ,CONVERT(VARCHAR,sub.reporting_term) AS reporting_term
      ,sub.rt
      ,sub.is_curterm
      ,sub.credittype        
      ,sub.course_number
      ,sub.COURSE_NAME
      ,sub.CREDIT_HOURS
      ,sub.GRADESCALEID
      ,sub.EXCLUDEFROMGPA
      ,sec.sectionid
      ,sec.teacher_name
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.student_number, sub.academic_year, sub.term
           ORDER BY CASE
                     WHEN sub.credittype = 'ENG' THEN 01
                     WHEN sub.credittype = 'RHET' THEN 02
                     WHEN sub.credittype = 'MATH' THEN 03
                     WHEN sub.credittype = 'SCI' THEN 04
                     WHEN sub.credittype = 'SOC' THEN 05
                     WHEN sub.credittype = 'WLANG' THEN 11
                     WHEN sub.credittype = 'PHYSED' THEN 12
                     WHEN sub.credittype = 'ART' THEN 13
                     WHEN sub.credittype = 'STUDY' THEN 21
                     WHEN sub.credittype = 'COCUR' THEN 22
                     WHEN sub.credittype = 'ELEC' THEN 22
                     WHEN sub.credittype = 'LOG' THEN 22
                    END
                   ,sub.course_number) AS class_rn      
FROM
    (
     SELECT DISTINCT 
            co.student_number
           ,co.studentid           
           ,co.schoolid
           ,co.year AS academic_year
           ,dt.time_per_name AS reporting_term
           ,CASE
             WHEN co.schoolid = 73253 THEN dt.time_per_name
             ELSE CONCAT('RT', RIGHT(dt.time_per_name,1) - 1) 
            END AS rt
           ,dt.alt_name AS term
           ,enr.COURSE_NUMBER
           ,enr.CREDITTYPE
           ,enr.COURSE_NAME             
           ,enr.CREDIT_HOURS
           ,enr.GRADESCALEID
           ,enr.EXCLUDEFROMGPA

           ,CASE WHEN CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date THEN 1 ELSE 0 END AS is_curterm
     FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
     JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
       ON co.schoolid = dt.schoolid
      AND co.year = dt.academic_year
      AND dt.identifier = 'RT'
      AND dt.alt_name != 'Summer School'
     JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
       ON co.student_number = enr.student_number
      AND co.year = enr.academic_year
      --AND enr.CREDITTYPE NOT IN ('LOG')
      AND enr.COURSE_NUMBER NOT IN ('')
      AND enr.course_enr_status = 0
      AND enr.drop_flags = 0
     WHERE co.rn = 1       
    ) sub  
LEFT OUTER JOIN KIPP_NJ..PS$course_section_scaffold#static sec WITH(NOLOCK)
  ON sub.studentid = sec.studentid
 AND sub.academic_year = sec.year
 AND sub.term = sec.term
 AND sub.COURSE_NUMBER = sec.COURSE_NUMBER

UNION ALL

SELECT DISTINCT 
       co.student_number
      ,co.studentid
      ,co.schoolid
      ,co.year AS academic_year      
      ,CONVERT(VARCHAR,dt.alt_name) AS term
      ,CONVERT(VARCHAR,dt.time_per_name) AS reporting_term      
      ,CASE
        WHEN co.schoolid = 73253 THEN dt.time_per_name
        ELSE CONCAT('RT', RIGHT(dt.time_per_name,1) - 1) 
       END AS rt
      ,CASE WHEN CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date THEN 1 ELSE 0 END AS is_curterm
      ,'ALL' AS CREDITTYPE
      ,'ALL' AS COURSE_NUMBER      
      ,'ALL' AS COURSE_NAME             
      ,NULL AS CREDIT_HOURS
      ,NULL AS gradescaleid
      ,NULL AS excludefromgpa
      ,NULL AS sectionid
      ,NULL AS teacher_name
      ,NULL AS class_rn      
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
 AND dt.alt_name != 'Summer School'     
WHERE co.rn = 1       