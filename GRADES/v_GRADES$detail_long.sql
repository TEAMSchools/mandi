USE KIPP_NJ
GO

ALTER VIEW GRADES$detail_long AS

WITH grades_long AS (
  SELECT STUDENTID
        ,CREDITTYPE
        ,COURSE_NUMBER
        ,COURSE_NAME
        ,term
        ,[PCT] AS term_pct
        ,[LETTER] AS term_letter
        ,y1_pct
        ,y1_letter
  FROM
      (
       SELECT STUDENTID
             ,CREDITTYPE
             ,COURSE_NUMBER
             ,COURSE_NAME
             ,LEFT(UPPER(field),2) AS term
             ,SUBSTRING(UPPER(field),4,6) AS measure
             ,value
             ,y1_pct
             ,y1_letter
       FROM 
           (
            SELECT studentid             
                  ,credittype
                  ,course_number
                  ,course_name
                  ,CONVERT(VARCHAR,t1) AS t1_pct
                  ,CONVERT(VARCHAR,t2) AS t2_pct
                  ,CONVERT(VARCHAR,t3) AS t3_pct
                  ,NULL AS q1_pct
                  ,NULL AS q2_pct
                  ,NULL AS q3_pct
                  ,NULL AS q4_pct
                  ,NULL AS e1_pct
                  ,NULL AS e2_pct
                  ,CONVERT(VARCHAR,y1) AS y1_pct
                  ,CONVERT(VARCHAR,T1_LETTER) AS t1_letter
                  ,CONVERT(VARCHAR,t2_LETTER) AS t2_letter
                  ,CONVERT(VARCHAR,t3_LETTER) AS t3_letter
                  ,NULL AS q1_LETTER
                  ,NULL AS q2_LETTER
                  ,NULL AS q3_LETTER
                  ,NULL AS q4_LETTER
                  ,NULL AS e1_LETTER
                  ,NULL AS e2_LETTER
                  ,CONVERT(VARCHAR,y1_LETTER) AS y1_letter
            FROM KIPP_NJ..GRADES$DETAIL#MS WITH(NOLOCK)

            UNION ALL

            SELECT studentid             
                  ,credittype
                  ,course_number
                  ,course_name
                  ,NULL AS t1_pct
                  ,NULL AS t2_pct
                  ,NULL AS t3_pct
                  ,CONVERT(VARCHAR,q1) AS q1_pct
                  ,CONVERT(VARCHAR,q2) AS q2_pct
                  ,CONVERT(VARCHAR,q3) AS q3_pct
                  ,CONVERT(VARCHAR,q4) AS q4_pct
                  ,CONVERT(VARCHAR,e1) AS e1_pct
                  ,CONVERT(VARCHAR,e2) AS e2_pct
                  ,CONVERT(VARCHAR,y1) AS y1_pct
                  ,NULL AS t1_letter
                  ,NULL AS t2_letter
                  ,NULL AS t3_letter
                  ,CONVERT(VARCHAR,q1_letter) AS q1_letter
                  ,CONVERT(VARCHAR,q2_letter) AS q2_letter
                  ,CONVERT(VARCHAR,q3_letter) AS q3_letter
                  ,CONVERT(VARCHAR,q4_letter) AS q4_letter
                  ,CONVERT(VARCHAR,e1_letter) AS e1_letter
                  ,CONVERT(VARCHAR,e2_letter) AS e2_letter
                  ,CONVERT(VARCHAR,y1_letter) AS y1_letter
            FROM KIPP_NJ..GRADES$DETAIL#NCA WITH(NOLOCK)
           ) sub
       UNPIVOT(
         value
         FOR field IN (t1_pct, t2_pct, t3_pct, q1_pct, q2_pct, q3_pct, q4_pct, t1_letter, t2_letter, t3_letter, q1_letter, q2_letter, q3_letter, q4_letter)
        ) u
      ) sub
  PIVOT(
    MAX(value)
    FOR measure IN ([PCT],[LETTER])
   ) p
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
  LEFT OUTER JOIN KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
    ON sub2.sectionid = sec.id
  LEFT OUTER JOIN KIPP_NJ..PS$COURSES#static cou WITH(NOLOCK)
    ON sec.course_number = cou.COURSE_NUMBER
  LEFT OUTER JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
    ON sec.teacher = t.id
 )

SELECT co.schoolid
      ,co.studentid
      ,co.student_number        
      ,dts.alt_name AS term
      ,sec.credittype
      ,sec.course_number      
      ,sec.course_name      
      ,sec.sectionid
      ,sec.section_number
      ,sec.teacher
      ,gr.term_pct
      ,gr.term_letter
      ,gr.y1_pct
      ,gr.y1_letter
      ,CASE WHEN dts.start_date <= CONVERT(DATE,GETDATE()) AND dts.end_date >= CONVERT(DATE,GETDATE()) THEN 1 ELSE 0 END AS curterm_flag
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dts WITH(NOLOCK)
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
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
  AND co.grade_level >= 5