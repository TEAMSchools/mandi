USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$teacher_student_ratio AS

WITH teacher_count AS (
  SELECT COUNT(associate_id) AS N_teachers
        ,CASE
          WHEN location = 'Newark Collegiate Academy' THEN 'HS'
          WHEN location IN ('Rise Academy','TEAM Academy') THEN 'MS'
          ELSE 'ES'
         END AS school_level
  FROM
      (
       SELECT associate_id
             ,location
             --,location
             --,department
             --,job_title
             ,ROW_NUMBER() OVER(
               PARTITION BY associate_id
                 ORDER BY position_start_date DESC) AS rn
       FROM KIPP_NJ..PEOPLE$ADP_detail WITH(NOLOCK)
       WHERE (position_start_date <= '2015-06-30' AND (termination_date >= '2014-10-15' OR termination_date IS NULL))       
         AND job_title IN ('Teacher'
                          ,'Fellow'
                          ,'Learning Specialist'
                          --,'Aide - Instructional'                        
                          --,'Dean of Instruction'
                          --,'Dean of Students'                          
                          --,'Paraprofessional'
                          --,'Social Worker'
                          )
      ) sub  
  WHERE rn = 1
  GROUP BY CASE
            WHEN location = 'Newark Collegiate Academy' THEN 'HS'
            WHEN location IN ('Rise Academy','TEAM Academy') THEN 'MS'
            ELSE 'ES'
           END
 )

,student_count AS (
  SELECT COUNT(studentid) AS N_students
        ,CASE
          WHEN schoolid = 73253 THEN 'HS'
          WHEN schoolid IN (73252,133570965) THEN 'MS'
          ELSE 'ES'
         END AS school_level
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  WHERE year = 2014
    AND rn = 1
    AND schoolid != 999999 
    AND entrydate <= '2014-10-15'
    AND exitdate >= '2014-10-15'
  GROUP BY CASE
            WHEN schoolid = 73253 THEN 'HS'
            WHEN schoolid IN (73252,133570965) THEN 'MS'
            ELSE 'ES'
           END
 )

SELECT s.school_level
      ,CONCAT(s.N_students / t.N_teachers, ':1') AS ratio
FROM student_count s
JOIN teacher_count t
  ON s.school_level = t.school_level