USE Khan
GO

ALTER VIEW REPORTING$khan_math_missions#long AS
WITH missions AS
    (SELECT id
           ,[2] AS mission
     FROM Khan..topic_metadata tm
     WHERE domain_slug = 'math'
       AND kind = 'Exercise'
       AND deleted = 'False'
       AND hide = 'False'
       AND hide_meta = 'False'
       AND id NOT IN (
         'modeling-with-one-variable-equations-and-inequalities'
        ,'dividing-by-10'
        ,'dividing-by-2'
        ,'dividing-by-3'
        ,'dividing-by-4'
        ,'dividing-by-5'
        ,'dividing-by-6'
        ,'dividing-by-7'
        ,'dividing-by-8'
        ,'dividing-by-9'
        ,'multiplying-by-2'
        ,'multiplying-by-3'
        ,'multiplying-by-4'
        ,'multiplying-by-5'
        ,'multiplying-by-6'
        ,'multiplying-by-7'
        ,'multiplying-by-8'
        ,'multiplying-by-9'
        ,'tangents-to-polar-curves'
        ,'special-derivatives-quiz'
        ,'counting_1'
        ,'dividing_fractions_word problems_2'
       )
     )
SELECT s.studentid
      ,st.grade_level
      ,st.schoolid
      ,sub.*
FROM
      (SELECT s.student
             ,s.username
             ,s.nickname
             ,em.title
             ,w.mission
             ,CASE
                WHEN e.struggling = 'True' THEN 'struggling'
                ELSE e.level
              END AS exercise_status
             ,e.total_done
             ,e.total_correct
             ,e.streak
             ,e.last_done
             ,e.mastered
             ,CASE WHEN e.mastered = 'True' THEN 1 ELSE 0 END AS mastered_dummy
             ,CASE WHEN e.struggling = 'True' THEN 1 ELSE 0 END AS struggling_dummy
             ,w.id
             ,em.ka_url AS url
       FROM Khan..stu_detail s WITH (NOLOCK)
       JOIN missions w
         ON 1=1
       JOIN Khan..exercise_metadata em
         ON w.id = em.name
        --testing
        --AND s.nickname = 'clark87'
       LEFT OUTER JOIN Khan..composite_exercises e
         ON s.student = e.student
        AND w.id = e.exercise
       ) sub
JOIN Khan..stu_detail#identifiers s WITH (NOLOCK)
  ON sub.student = s.student
JOIN KIPP_NJ..STUDENTS st WITH (NOLOCK)
  ON s.studentid = st.id