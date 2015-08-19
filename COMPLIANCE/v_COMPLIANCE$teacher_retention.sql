USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$teacher_retention AS

WITH teacher_baseline AS (
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
       WHERE (hire_date <= '2013-10-15' AND (termination_date >= '2013-10-15' OR termination_date IS NULL))       
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
  GROUP BY CUBE(CASE
            WHEN location = 'Newark Collegiate Academy' THEN 'HS'
            WHEN location IN ('Rise Academy','TEAM Academy') THEN 'MS'
            ELSE 'ES'
           END)
 )

,teacher_stayed AS (
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
       WHERE (hire_date <= '2013-10-15' AND (termination_date >= '2014-10-15' OR termination_date IS NULL))       
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
  GROUP BY CUBE(CASE
            WHEN location = 'Newark Collegiate Academy' THEN 'HS'
            WHEN location IN ('Rise Academy','TEAM Academy') THEN 'MS'
            ELSE 'ES'
           END)
 )

SELECT ISNULL(b.school_level,'ALL') AS school_level
      ,ROUND((CONVERT(FLOAT,s.N_teachers) / CONVERT(FLOAT,b.N_teachers)) * 100,0) AS teacher_retention_rate
FROM teacher_baseline b
JOIN teacher_stayed s
  ON ISNULL(b.school_level,'ALL') = ISNULL(s.school_level,'ALL')