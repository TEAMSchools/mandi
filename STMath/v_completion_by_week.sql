USE STMath
GO

ALTER VIEW completion_by_week AS
   
WITH week_numbers AS (
  SELECT week_ending_date
        ,ROW_NUMBER() OVER(           
           ORDER BY week_ending_date ASC) AS week_num
  FROM
      (
       SELECT DISTINCT 
              week_ending_date
       FROM STMath..progress_completion p WITH(NOLOCK)          
      ) sub
 )

,progress_with_week AS (
  SELECT p.IID
        ,p.Institution_name
        ,p.TCD
        ,p.Teacher_name
        ,p.SCD
        ,p.Student_name
        ,p.YCD
        ,p.start_year
        ,p.GCD
        ,p.num_lab_logins
        ,p.num_homework_logins
        ,p.K_5_Progress
        ,p.K_5_Mastery
        ,p.objective_name
        ,p.curr_obj_path
        ,p.cur_hurdle_num_tries
        ,p.last_login_date
        ,p.UUID
        ,p.fluency_progress
        ,p.fluency_mastery
        ,p.fluency_path
        ,p.fluency_time_spent
        ,p.school_student_id
        ,p.minutes_logged_last_week
        ,p.state_id
        ,p.first_login_date
        ,p.week_ending_date                
        ,CASE
          WHEN p.GCD = 'Kindergarten' THEN 0
          WHEN p.GCD = 'First Grade' THEN 1
          WHEN p.GCD = 'Second Grade' THEN 2
          WHEN p.GCD = 'Third Grade' THEN 3
          WHEN p.GCD = 'Fourth Grade' THEN 4
          WHEN p.GCD = 'Fifth Grade' THEN 5
          WHEN p.GCD = 'Sixth Grade' THEN 6
          WHEN p.GCD = 'Seventh Grade MSS' THEN 7
         END AS gcd_sort        
        ,w.week_num
        ,w.week_num + 1 AS next_week_num
  FROM STMath..progress_completion p WITH(NOLOCK)  
  JOIN week_numbers w WITH(NOLOCK)
    ON p.week_ending_date = w.week_ending_date
 )

SELECT s.id AS studentid
      ,s.grade_level AS stu_grade
      ,s.lastfirst
      ,p_base.start_year
      ,p_base.week_ending_date
      ,p_base.week_num
      ,p_base.GCD      
      ,p_base.gcd_sort
      ,CASE WHEN p_base.gcd_sort < p_next.gcd_sort THEN 100 ELSE p_base.K_5_Progress END AS K_5_Progress
FROM progress_with_week p_base WITH(NOLOCK)
JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
  ON p_base.school_student_id = s.student_number
--look ahead one week to find implicit completion, where a kid
--got moved ahead a library the next week.  in those cases, 
--tag the progress as 100
LEFT OUTER JOIN progress_with_week p_next WITH(NOLOCK)
  ON p_base.UUID = p_next.UUID
 AND p_base.next_week_num = p_next.week_num