USE KIPP_NJ
GO

/*
This view combines current students (PS) and future students (Newark Enrolls)
with locations to create a long view of all students + locations
*/

ALTER VIEW OPS$students_locations#long AS

WITH students AS (
  SELECT s.student_number
        ,s.schoolid
        ,s.grade_level
        ,s.first_name
			     ,s.last_name
			     ,s.street
			     ,s.city
			     ,s.zip
  FROM PS$students#static s 
  WHERE s.enroll_status = 0
    AND s.grade_level <= 3
    AND s.schoolid NOT IN (73252, 179901, 179902)
	   --AND s.city LIKE '%Newark%'

 	UNION ALL

 	SELECT nen AS student_number
			     ,schoolid
		      ,grade_level
			     ,first AS first_name
			     ,last AS last_name
			     ,street
			     ,city
			     ,zip
	 FROM AUTOLOAD$GDOCS_OPS_students_new WITH(NOLOCK)
 )

SELECT	s.student_number
      ,s.schoolid
      ,s.grade_level
      ,s.first_name
      ,s.last_name
      ,s.street
      ,s.city
      ,s.zip
      ,l.type AS location_type
      ,l.name AS location_name
      ,l.address AS location_address
      ,l.zip AS location_zip
FROM KIPP_NJ..AUTOLOAD$GDOCS_OPS_locations l WITH(NOLOCK)
CROSS JOIN students s
WHERE l.name NOT LIKE '%Boys and Girls%' 
  AND l.name NOT LIKE '%Parent%'