USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessment_results_by_standard#cube AS

SELECT s.schoolid
      ,s.grade_level
      ,sub.*
FROM
    (
     SELECT sub.*
           ,ROW_NUMBER() OVER (
              PARTITION BY local_student_id
                          ,assessment_id
                          ,standard_custom_code
                ORDER BY std_source) AS rn
     FROM
         (
          SELECT local_student_id
                ,illum.assessment_id
                ,mastered
                ,points
                ,points_possible
                ,stds.up_the_tree AS standard_custom_code
                ,stds.depth
                ,CASE WHEN illum.custom_code = stds.up_the_tree THEN 'Original' ELSE 'Synthetic' END AS std_source
          FROM KIPP_NJ..ILLUMINATE$assessment_results_by_standard#static illum WITH(NOLOCK)
          JOIN KIPP_NJ..ILLUMINATE$standards_cube_long stds WITH(NOLOCK)
            ON illum.custom_code = stds.standard
         ) sub
    ) sub
JOIN PS$STUDENTS#static s WITH(NOLOCK)
  ON sub.local_student_id = s.student_number
WHERE rn = 1