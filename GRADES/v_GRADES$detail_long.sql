USE KIPP_NJ
GO

ALTER VIEW GRADES$detail_long AS

WITH grades_long AS (
  SELECT STUDENTID
        ,CREDITTYPE
        ,COURSE_NUMBER
        ,COURSE_NAME
        ,UPPER(term) AS term
        ,term_pct
        ,Y1 AS y1_pct
  FROM 
      (
       SELECT studentid             
             ,credittype
             ,course_number
             ,course_name
             ,t1
             ,t2
             ,t3
             ,NULL AS q1
             ,NULL AS q2
             ,NULL AS q3
             ,NULL AS q4
             ,y1      
       FROM KIPP_NJ..GRADES$DETAIL#MS WITH(NOLOCK)

       UNION ALL

       SELECT studentid             
             ,credittype
             ,course_number
             ,course_name
             ,NULL AS t1
             ,NULL AS t2
             ,NULL AS t3
             ,q1
             ,q2
             ,q3
             ,q4
             ,y1      
       FROM KIPP_NJ..GRADES$DETAIL#NCA WITH(NOLOCK)
      ) sub
  UNPIVOT(
    term_pct
    FOR term IN (t1, t2, t3, q1, q2, q3, q4)
   ) u
 )

,sections_long AS (
  SELECT sub2.studentid      
        ,sub2.credittype
        ,sub2.course_number
        ,cou.COURSE_NAME        
        ,sub2.term
        ,sec.section_number
        ,sub2.sectionid
        ,t.lastfirst AS teacher
  FROM
      (
       SELECT studentid           
             ,credittype
             ,course_number
             ,LEFT(field, 2) AS term
             ,sectionid
       FROM
           (
            SELECT studentid                                  
                  ,credittype
                  ,course_number
                  ,q1_enr_sectionid
                  ,q2_enr_sectionid
                  ,q3_enr_sectionid
                  ,q4_enr_sectionid
                  ,NULL AS t1_enr_sectionid
                  ,NULL AS t2_enr_sectionid
                  ,NULL AS t3_enr_sectionid
            FROM KIPP_NJ..GRADES$DETAIL#NCA WITH(NOLOCK)

            UNION ALL

            SELECT studentid                                  
                  ,credittype
                  ,course_number
                  ,NULL AS q1_enr_sectionid
                  ,NULL AS q2_enr_sectionid
                  ,NULL AS q3_enr_sectionid
                  ,NULL AS q4_enr_sectionid
                  ,t1_enr_sectionid
                  ,t2_enr_sectionid
                  ,t3_enr_sectionid
            FROM KIPP_NJ..GRADES$DETAIL#MS WITH(NOLOCK)
           ) sub
       UNPIVOT (
         sectionid
         FOR field IN (q1_enr_sectionid
                      ,q2_enr_sectionid
                      ,q3_enr_sectionid
                      ,q4_enr_sectionid
                      ,t1_enr_sectionid
                      ,t2_enr_sectionid
                      ,t3_enr_sectionid)
        ) u
      ) sub2
  LEFT OUTER JOIN KIPP_NJ..SECTIONS sec WITH(NOLOCK)
    ON sub2.sectionid = sec.id
  LEFT OUTER JOIN KIPP_NJ..COURSES cou WITH(NOLOCK)
    ON sec.course_number = cou.COURSE_NUMBER
  LEFT OUTER JOIN KIPP_NJ..TEACHERS t WITH(NOLOCK)
    ON sec.teacher = t.id
 )

SELECT co.schoolid
      ,co.studentid
      ,co.student_number        
      ,dts.alt_name AS term
      ,sec.credittype
      ,sec.course_number      
      ,sec.course_name      
      ,sec.section_number
      ,sec.teacher
      ,gr.term_pct
      ,gr.y1_pct
FROM COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN REPORTING$dates dts WITH(NOLOCK)
  ON co.schoolid = dts.schoolid
 AND co.year = dts.academic_year 
 AND co.exitdate >= dts.end_date
 AND dts.identifier = 'RT'
LEFT OUTER JOIN sections_long sec WITH(NOLOCK)
  ON co.studentid = sec.studentid
 AND dts.alt_name = sec.term
LEFT OUTER JOIN grades_long gr WITH(NOLOCK)
  ON sec.studentid = gr.STUDENTID
 AND sec.term = gr.term
 AND sec.course_number = gr.COURSE_NUMBER
WHERE co.year = dbo.fn_Global_Academic_Year()
  AND co.rn = 1
  AND co.grade_level >= 5