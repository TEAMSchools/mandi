USE Khan
GO

ALTER VIEW exercise$status_long#identifiers AS
WITH scaffold AS
    (SELECT c.studentid
           ,c.grade_level
           ,c.lastfirst
           ,s.first_name + ' ' + s.last_name AS stu_name
           ,sch.abbreviation
     FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH(NOLOCK)
     JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
       ON c.studentid = s.id
      AND s.enroll_status = 0
      AND c.year = 2013
      AND c.RN = 1
     JOIN KIPP_NJ..SCHOOLS sch WITH(NOLOCK)
       ON c.schoolid = sch.school_number
    )
   ,mastery_status AS
   (SELECT 'unstarted' AS ex_status
           ,0 AS ex_level
           ,0 AS mastery_flag
     UNION
     SELECT 'practiced'
           ,1
           ,0
     UNION
     SELECT 'mastery1'
           ,2
           ,0
     UNION
     SELECT 'mastery2'
           ,3
           ,1
     UNION
     SELECT 'mastery3'
           ,4
           ,1  
    )
   ,khan_obj AS
   (SELECT distinct e.exercise
    FROM Khan..composite_exercises e WITH(NOLOCK)
   )
SELECT sub.*
FROM
      (SELECT scaffold.*
             ,khan_obj.*
       FROM scaffold
       JOIN khan_obj
         ON 1=1
       ) sub
LEFT OUTER JOIN
  (SELECT c.*
         ,s.exercise_status
         ,s.date
         ,m.mastery_flag
         ,ROW_NUMBER() OVER
            (PARTITION BY c.studentid
                         ,c.exercise
             ORDER BY m.ex_level DESC
            ) AS rn
   FROM Khan..composite_exercises#identifiers c WITH(NOLOCK)
   JOIN Khan..exercise_states s WITH(NOLOCK)
     ON c.exercise = s.exercise
   JOIN mastery_status m WITH(NOLOCK)
     ON s.exercise_status = m.ex_status
  ) exer_status
ON sub.studentid = exer_status.studentid
AND sub.exercise = exer_status.exercise
AND exer_status.rn = 1