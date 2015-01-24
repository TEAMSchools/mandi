USE STMath
GO

ALTER VIEW summary_by_enrollment AS

WITH observed_completion AS (
  SELECT studentid
        ,SUM(K_5_Progress) AS total_completion
  FROM STMath..prep_blended_tracker_long WITH(NOLOCK)
  WHERE comp_type = 'Observed'
    AND school_year = 2014
  GROUP BY studentid
 )

,stu_enr AS (
  SELECT co.studentid
        ,enr.course_number AS Course
        ,enr.section_number AS section
        ,enr.teacher_name AS teacher
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
    ON co.studentid = enr.studentid
   AND ((co.grade_level >= 5 AND enr.credittype = 'MATH') OR (co.grade_level <= 4 AND enr.COURSE_NUMBER = 'HR'))
   AND enr.dateenrolled <= CONVERT(DATE,GETDATE())
   AND enr.dateleft >= CONVERT(DATE,GETDATE())
  WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND co.rn = 1  
    AND co.grade_level <= 8
 )

,max_week AS (
  SELECT MAX(w.week_num) AS max_week
  FROM STMath..completion_by_week w
 )

,prev_week_completion AS (
  SELECT studentid
        ,SUM(progress) AS total_completion
  FROM
      (
       SELECT st.studentid
             ,st.start_year
             ,st.gcd_sort
             ,CAST(MAX(K_5_Progress) AS NUMERIC(4,1)) AS progress
       FROM STMath..completion_by_week st WITH(NOLOCK)
       JOIN max_week WITH(NOLOCK)
         ON st.week_num <= max_week.max_week - 1
        AND st.start_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
       GROUP BY st.studentid
               ,st.start_year
               ,st.gcd_sort
      ) sub
  GROUP BY studentid
 )

,cur_gcd AS (
  SELECT st.studentid
        ,st.GCD
  FROM STMath..completion_by_week st WITH(NOLOCK)
  JOIN max_week
    ON st.week_num = max_week.max_week
 )

SELECT s.studentid
      ,s.student_number
      ,s.full_name AS [Student]      
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
FROM KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)
LEFT OUTER JOIN observed_completion st WITH(NOLOCK)
  ON s.studentid = st.studentid
LEFT OUTER JOIN stu_enr WITH(NOLOCK)
  ON s.studentid = stu_enr.studentid
LEFT OUTER JOIN cur_gcd WITH(NOLOCK)
  ON st.studentid = cur_gcd.studentid
LEFT OUTER JOIN prev_week_completion WITH(NOLOCK)
  ON st.studentid = prev_week_completion.studentid
WHERE s.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND s.rn = 1
  AND s.grade_level <= 8
  AND s.enroll_status = 0