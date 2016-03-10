USE KIPP_NJ
GO

ALTER VIEW PS$course_order_scaffold AS

SELECT student_number
      ,academic_year
      ,term
      ,reporting_term
      ,is_curterm
      ,credittype        
      ,course_number
      ,COURSE_NAME
      ,CREDIT_HOURS
      ,GRADESCALEID
      ,EXCLUDEFROMGPA
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year, term
           ORDER BY CASE
                     WHEN credittype = 'ENG' THEN 01
                     WHEN credittype = 'RHET' THEN 02
                     WHEN credittype = 'MATH' THEN 03
                     WHEN credittype = 'SCI' THEN 04
                     WHEN credittype = 'SOC' THEN 05
                     WHEN credittype = 'WLANG' THEN 11
                     WHEN credittype = 'PHYSED' THEN 12
                     WHEN credittype = 'ART' THEN 13
                     WHEN credittype = 'STUDY' THEN 21
                     WHEN credittype = 'COCUR' THEN 22
                     WHEN credittype = 'ELEC' THEN 22
                     WHEN credittype = 'LOG' THEN 22
                    END
                   ,course_number) AS class_rn      
FROM
    (
     SELECT DISTINCT 
            co.student_number
           ,co.year AS academic_year
           ,dt.time_per_name AS reporting_term
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
      AND enr.CREDITTYPE NOT IN ('LOG')
      AND enr.COURSE_NUMBER NOT IN ('')
      AND enr.course_enr_status = 0
      AND enr.drop_flags = 0
     WHERE co.rn = 1       
    ) sub  

UNION ALL

SELECT DISTINCT 
       co.student_number
      ,co.year AS academic_year
      ,dt.alt_name AS term
      ,dt.time_per_name AS reporting_term      
      ,CASE WHEN CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date THEN 1 ELSE 0 END AS is_curterm
      ,'ALL' AS CREDITTYPE
      ,'ALL' AS COURSE_NUMBER      
      ,'ALL' AS COURSE_NAME             
      ,NULL AS CREDIT_HOURS
      ,NULL AS gradescaleid
      ,NULL AS excludefromgpa
      ,NULL AS class_rn      
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
 AND dt.alt_name != 'Summer School'     
WHERE co.rn = 1       