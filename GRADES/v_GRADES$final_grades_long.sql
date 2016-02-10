USE KIPP_NJ
GO

ALTER VIEW GRADES$final_grades_long AS

WITH roster AS (
  SELECT co.student_number
        ,co.studentid      
        ,co.year AS academic_year
        ,co.schoolid      
        ,co.grade_level      
        ,CONCAT('RT',RIGHT(d.alt_name, 1)) AS rt
        ,d.alt_name AS term            
        ,CASE WHEN CONVERT(DATE,GETDATE()) BETWEEN d.start_date AND d.end_date THEN 1 ELSE 0 END AS is_curterm
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON co.schoolid = d.schoolid
   AND co.year = d.academic_year
   AND d.identifier = 'RT'
   AND d.alt_name != 'Summer School'     
  WHERE co.rn = 1
    AND co.schoolid != 999999
    AND ((co.grade_level >= 5) OR (co.grade_level = 4 AND co.schoolid = 73252))
 )     

,enr_grades AS (
  SELECT studentid        
        ,academic_year
        ,credittype
        ,course_number
        ,course_name
        ,sectionid
        ,teacher_name
        ,excludefromgpa
        ,credit_hours
        ,gradescaleid
        ,term
        /* if stored grade exists, use that */                
        ,COALESCE(stored_letter, pgf_letter) AS term_grade_letter
        ,COALESCE(stored_pct, pgf_pct) AS term_grade_percent
        /* F* rule for NCA and TEAM */
        ,CASE 
          WHEN schoolid = 73253 AND COALESCE(stored_pct, pgf_pct) < 50 THEN 'F*' 
          WHEN schoolid = 133570965 AND COALESCE(stored_pct, pgf_pct) < 55 THEN 'F*' 
          ELSE COALESCE(stored_letter, pgf_letter)
         END AS term_grade_letter_adjusted
        ,CASE 
          WHEN schoolid = 73253 AND COALESCE(stored_pct, pgf_pct) < 50 THEN 50 
          WHEN schoolid = 133570965 AND COALESCE(stored_pct, pgf_pct) < 55 THEN 55
          ELSE COALESCE(stored_pct, pgf_pct)
         END AS term_grade_percent_adjusted          
        ,term_gpa_points
  FROM
      (
       SELECT enr.studentid                   
             ,enr.SCHOOLID
             ,enr.academic_year
             ,enr.credittype      
             ,enr.course_number
             ,enr.course_name      
             ,enr.sectionid           
             ,enr.teacher_name      
             ,enr.excludefromgpa
             ,CASE WHEN enr.drop_flags = 1 AND sg.pct IS NULL THEN NULL ELSE enr.credit_hours END AS credit_hours
             ,enr.gradescaleid                  
      
             ,pgf.FINALGRADENAME AS term
             ,CASE WHEN enr.drop_flags = 1 AND sg.pct IS NULL THEN NULL ELSE ROUND(pgf.[PERCENT],0) END AS pgf_pct
             ,CASE WHEN enr.drop_flags = 1 AND sg.pct IS NULL THEN NULL ELSE pgf.GRADE END AS pgf_letter      
      
             ,ROUND(sg.PCT,0) AS stored_pct
             ,sg.GRADE AS stored_letter      
             
             ,CASE 
               WHEN enr.drop_flags = 1 AND sg.pct IS NULL THEN NULL                
               ELSE COALESCE(sg_scale.grade_points, scale.grade_points) 
              END AS term_gpa_points /* temp fix until stored grades are updated for honors courses */
             --,COALESCE(sg.gpa_points, scale.grade_points) AS term_gpa_points      
      
             --,enr.drop_flags
             --,enr.dateenrolled
             --,enr.dateleft
             ,ROW_NUMBER() OVER(
                PARTITION BY enr.student_number, enr.academic_year, enr.course_number, pgf.finalgradename
                  ORDER BY sg.PCT DESC, enr.drop_flags ASC, enr.dateenrolled DESC, enr.dateleft DESC) AS rn
       FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
       JOIN KIPP_NJ..PS$PGFINALGRADES pgf WITH(NOLOCK)  
         ON enr.studentid = pgf.studentid       
        AND enr.sectionid = pgf.sectionid 
        AND (pgf.FINALGRADENAME LIKE 'T%' OR pgf.FINALGRADENAME LIKE 'Q%')  
       LEFT OUTER JOIN KIPP_NJ..GRADES$grade_scales#static scale WITH(NOLOCK)
         ON enr.GRADESCALEID = scale.scale_id
        AND pgf.[PERCENT] >= scale.low_cut
        AND pgf.[PERCENT] < scale.high_cut
       LEFT OUTER JOIN KIPP_NJ..GRADES$STOREDGRADES#static sg WITH(NOLOCK)
         ON pgf.studentid = sg.STUDENTID 
        AND pgf.SECTIONID = sg.SECTIONID
        AND pgf.FINALGRADENAME = sg.STORECODE 
       LEFT OUTER JOIN KIPP_NJ..GRADES$grade_scales#static sg_scale WITH(NOLOCK)
         ON enr.GRADESCALEID = sg_scale.scale_id
        AND sg.PCT >= sg_scale.low_cut
        AND sg.PCT < sg_scale.high_cut
       WHERE enr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND enr.course_enr_status = 0

       UNION ALL

       SELECT enr.studentid                   
             ,enr.SCHOOLID
             ,enr.academic_year
             ,enr.credittype      
             ,enr.course_number
             ,enr.course_name      
             ,enr.sectionid           
             ,enr.teacher_name      
             ,enr.excludefromgpa
             ,enr.credit_hours
             ,enr.gradescaleid            
      
             ,sg.STORECODE AS term
             ,NULL AS pgf_pct
             ,NULL AS pgf_letter
      
             ,sg.PCT AS stored_pct
             ,sg.GRADE AS stored_letter      
             ,sg.gpa_points AS term_gpa_points
      
             ,1 AS rn
       FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
       JOIN KIPP_NJ..GRADES$STOREDGRADES#static sg WITH(NOLOCK)
         ON enr.studentid = sg.STUDENTID 
        AND enr.SECTIONID = sg.SECTIONID 
        AND (sg.STORECODE LIKE 'T%' OR sg.STORECODE LIKE 'Q%')
       WHERE enr.academic_year < KIPP_NJ.dbo.fn_Global_Academic_Year()
      ) sub
  WHERE rn = 1
 )

,exams AS (
  SELECT STUDENTID
        ,academic_year
        ,COURSE_NUMBER     
        ,E1
        ,E2
        ,CASE WHEN E1 < 50 THEN 50 ELSE E1 END AS E1_adjusted
        ,CASE WHEN E2 < 50 THEN 50 ELSE E2 END AS E2_adjusted
  FROM
      (
       SELECT STUDENTID
             ,academic_year
             ,COURSE_NUMBER           
             ,STORECODE
             ,PCT
       FROM KIPP_NJ..GRADES$STOREDGRADES#static WITH(NOLOCK)
       WHERE SCHOOLID = 73253
         AND STORECODE LIKE 'E%'
      ) sub
  PIVOT(
    MAX(pct)
    FOR storecode IN ([E1],[E2])
   ) p
 )

,grades_long AS (
  SELECT r.student_number
        ,r.studentid
        ,r.academic_year
        ,r.schoolid
        ,r.grade_level
        ,r.rt
        ,r.term      
        ,r.is_curterm
        ,gr.credittype
        ,gr.course_number
        ,gr.course_name
        ,gr.sectionid
        ,gr.teacher_name
        ,gr.excludefromgpa
        ,gr.credit_hours
        ,gr.gradescaleid      
        ,gr.term_grade_percent
        ,gr.term_grade_letter
        ,gr.term_grade_percent_adjusted
        ,gr.term_grade_letter_adjusted
        ,gr.term_gpa_points
        
        /* exam grades for Y1 calc, only for applicable terms */
        ,CASE WHEN r.term = 'Q2' THEN e.E1 ELSE NULL END AS E1           
        ,CASE WHEN r.term = 'Q2' THEN e.E1_adjusted ELSE NULL END AS E1_adjusted           
        ,CASE WHEN r.term = 'Q4' THEN e.E2 ELSE NULL END AS E2
        ,CASE WHEN r.term = 'Q4' THEN e.E2_adjusted ELSE NULL END AS E2_adjusted

        ,CASE
          WHEN gr.term_grade_percent IS NULL THEN NULL
          WHEN r.grade_level <= 8 THEN 1.0 / CONVERT(FLOAT,COUNT(r.student_number) OVER(PARTITION BY r.student_number, r.academic_year, gr.course_number))
          WHEN r.grade_level >= 9 THEN .225
         END AS term_grade_weight                 
        ,CASE WHEN r.term = 'Q2' AND e.E1 IS NOT NULL THEN 0.05 END AS E1_grade_weight
        ,CASE WHEN r.term = 'Q4' AND e.E2 IS NOT NULL THEN 0.05 END AS E2_grade_weight
  FROM roster r
  LEFT OUTER JOIN enr_grades gr
    ON r.studentid = gr.studentid
   AND r.academic_year = gr.academic_year
   AND r.term = gr.term
  LEFT OUTER JOIN exams e
    ON r.studentid = e.STUDENTID
   AND r.academic_year = e.academic_year
   AND gr.COURSE_NUMBER = e.COURSE_NUMBER
 )

SELECT sub.student_number
      ,sub.studentid
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_level
      ,sub.rt
      ,sub.term
      ,sub.is_curterm
      ,sub.credittype
      ,sub.course_number
      ,sub.course_name
      ,sub.sectionid
      ,sub.teacher_name
      ,sub.excludefromgpa
      ,sub.gradescaleid
      ,sub.credit_hours
      ,sub.term_gpa_points
      ,sub.term_grade_letter
      ,sub.term_grade_percent
      ,sub.term_grade_letter_adjusted
      ,sub.term_grade_percent_adjusted
      ,sub.e1
      ,sub.e1_adjusted
      ,sub.e2
      ,sub.e2_adjusted
      ,sub.weighted_grade_total
      ,sub.weighted_points_total
      ,sub.y1_grade_percent
      ,sub.y1_grade_percent_adjusted
      ,CASE
        WHEN sub.schoolid = 73253 AND sub.y1_grade_percent_adjusted = 50 AND sub.y1_grade_percent < 50 THEN 'F*'
        WHEN sub.schoolid = 133570965 AND sub.y1_grade_percent_adjusted = 55 AND sub.y1_grade_percent < 55 THEN 'F*'
        ELSE scale.letter_grade 
       END AS y1_grade_letter
      ,scale.grade_points AS y1_gpa_points
FROM
    (
     SELECT student_number
           ,studentid
           ,academic_year
           ,schoolid
           ,grade_level
           ,rt
           ,term
           ,is_curterm
           ,credittype
           ,course_number
           ,course_name
           ,sectionid
           ,teacher_name
           ,excludefromgpa
           ,gradescaleid
           ,credit_hours
           ,term_gpa_points
           ,term_grade_letter
           ,term_grade_percent
           ,term_grade_letter_adjusted
           ,term_grade_percent_adjusted
           ,e1
           ,e1_adjusted
           ,e2
           ,e2_adjusted
           ,weighted_grade_total
           ,weighted_grade_total_adjusted
           ,weighted_points_total
           ,ROUND((weighted_grade_total / weighted_points_total) * 100,0) AS y1_grade_percent
           ,ROUND((weighted_grade_total_adjusted / weighted_points_total) * 100,0) AS y1_grade_percent_adjusted
     FROM
         (
          SELECT student_number
                ,studentid
                ,academic_year
                ,schoolid
                ,grade_level
                ,rt
                ,term
                ,is_curterm
                ,credittype
                ,course_number
                ,course_name
                ,sectionid
                ,teacher_name
                ,excludefromgpa
                ,gradescaleid
                ,credit_hours      
                ,term_gpa_points
                ,term_grade_letter
                ,term_grade_percent            
                ,term_grade_letter_adjusted
                ,term_grade_percent_adjusted
                ,e1
                ,e1_adjusted
                ,e2
                ,e2_adjusted
      
                /* Y1 calc -- weighted avg */                
                /* (weighted term grade + weighted exam grades) / total weighted points possible */
                ,SUM(
                   (term_grade_percent * term_grade_weight) 
                     + ISNULL((e1 * e1_grade_weight),0) 
                     + ISNULL((e2 * e2_grade_weight),0)
                  ) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY rt ASC) AS weighted_grade_total /* does NOT use F* grades */
                ,SUM(
                   (term_grade_percent_adjusted * term_grade_weight) 
                     + ISNULL((e1_adjusted * e1_grade_weight),0) 
                     + ISNULL((e2_adjusted * e2_grade_weight),0)
                  ) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY rt ASC) AS weighted_grade_total_adjusted /* uses F* adjusted grade */
                ,SUM(
                   (term_grade_weight * 100)
                     + ISNULL((E1_grade_weight * 100),0)
                     + ISNULL((E2_grade_weight * 100),0)
                  ) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY rt ASC) AS weighted_points_total
          FROM grades_long               
         ) sub
    ) sub
LEFT OUTER JOIN KIPP_NJ..GRADES$grade_scales#static scale WITH(NOLOCK)
  ON sub.gradescaleid = scale.scale_id
 AND sub.y1_grade_percent >= scale.low_cut
 AND sub.y1_grade_percent < scale.high_cut