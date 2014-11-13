USE STMath
GO

ALTER VIEW summary_by_enrollment AS
WITH observed_completion AS
    (SELECT studentid
           ,SUM(K_5_Progress) AS total_completion
     FROM STMath..prep_blended_tracker_long
     WHERE comp_type = 'Observed'
       AND school_year = 2014
     GROUP BY studentid
     )
    ,stu_enr AS (
     SELECT s.id AS studentid
           ,sect.course_number AS Course
           ,sect.section_number AS section
           ,t.first_name + ' ' + t.last_name AS teacher
     FROM KIPP_NJ..STUDENTS s     
     JOIN KIPP_NJ..CC cc
       ON s.id = cc.studentid
      AND cc.dateenrolled <= GETDATE()
      AND cc.dateleft >= GETDATE()
      AND s.grade_level >= 5
      AND s.grade_level <= 8
     JOIN KIPP_NJ..COURSES
       ON cc.course_number = courses.course_number
      AND courses.credittype LIKE '%MATH%'
     JOIN KIPP_NJ..SECTIONS sect
       ON cc.sectionid = sect.id
     JOIN KIPP_NJ..TEACHERS t
       ON sect.teacher = t.id
     UNION ALL
     SELECT s.id
           ,sect.course_number
           ,sect.section_number
           ,t.first_name + ' ' + t.last_name AS teacher
     FROM KIPP_NJ..STUDENTS s     
     JOIN KIPP_NJ..CC cc
       ON s.id = cc.studentid
      AND cc.dateenrolled <= GETDATE()
      AND cc.dateleft >= GETDATE()
      AND s.grade_level <= 4
     JOIN KIPP_NJ..COURSES
       ON cc.course_number = courses.course_number
      AND courses.course_number LIKE '%HR%'
     JOIN KIPP_NJ..SECTIONS sect
       ON cc.sectionid = sect.id
     JOIN KIPP_NJ..TEACHERS t
       ON sect.teacher = t.id
     )
    ,max_week AS
    (SELECT MAX(w.week_num) AS max_week
     FROM STMath..completion_by_week w
    )
    ,prev_week_completion AS
    (SELECT studentid
           ,SUM(progress) AS total_completion
     FROM
           (SELECT st.studentid
                  ,st.start_year
                  ,st.gcd_sort
                  ,CAST(MAX(K_5_Progress) AS NUMERIC(4,1)) AS progress
            FROM STMath..completion_by_week st
            JOIN max_week
              ON st.week_num <= max_week.max_week - 1
             AND st.start_year = 2014
            GROUP BY st.studentid
                    ,st.start_year
                    ,st.gcd_sort
           ) sub
     GROUP BY studentid
     )
    ,cur_gcd AS
    (SELECT st.studentid
           ,st.GCD
     FROM STMath..completion_by_week st
     JOIN max_week
       ON st.week_num = max_week.max_week
     )
SELECT s.id AS studentid
      ,s.student_number
      ,s.first_name + ' ' + s.last_name AS [Student]
      ,s.lastfirst
      ,s.schoolid
      ,s.grade_level
      ,stu_enr.Course
      ,stu_enr.section
      ,stu_enr.teacher
      ,cur_gcd.GCD AS cur_lib
      ,st.total_completion
      ,st.total_completion - prev_week_completion.total_completion AS [change]
      ,ROW_NUMBER() OVER
        (PARTITION BY s.schoolid, s.grade_level
         ORDER BY st.total_completion DESC
        ) AS sch_gr_completion_rank
      ,ROW_NUMBER() OVER
        (PARTITION BY s.schoolid
         ORDER BY st.total_completion DESC
        ) AS sch_completion_rank
      ,ROW_NUMBER() OVER
        (PARTITION BY s.grade_level
         ORDER BY st.total_completion DESC
        ) AS network_gr_completion_rank
      ,ROW_NUMBER() OVER
        (PARTITION BY s.schoolid, s.grade_level
         ORDER BY st.total_completion - prev_week_completion.total_completion DESC
        ) AS sch_gr_change_rank
      ,ROW_NUMBER() OVER
        (PARTITION BY s.schoolid
         ORDER BY st.total_completion - prev_week_completion.total_completion DESC
        ) AS sch_change_rank
      ,ROW_NUMBER() OVER
        (PARTITION BY s.grade_level
         ORDER BY st.total_completion - prev_week_completion.total_completion DESC
        ) AS network_gr_change_rank
FROM KIPP_NJ..STUDENTS s
LEFT OUTER JOIN observed_completion st
  ON s.id = st.studentid
LEFT OUTER JOIN stu_enr
  ON s.id = stu_enr.studentid
LEFT OUTER JOIN cur_gcd
  ON st.studentid = cur_gcd.studentid
LEFT OUTER JOIN prev_week_completion
  ON st.studentid = prev_week_completion.studentid
WHERE s.enroll_status = 0