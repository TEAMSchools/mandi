USE KIPP_NJ
GO

/*
This view combines current students (PS) and future students (Newark Enrolls)
with locations to create a long view of all students + locations
*/

ALTER VIEW OPS$students_locations#long AS

WITH roster AS (
  SELECT nen AS student_number
			     ,schoolid
		      ,grade_level
        ,CASE
          WHEN grade_level <= 4 THEN 'ES'
          WHEN grade_level <= 8 THEN 'MS'
         END AS school_level
			     ,first AS first_name
			     ,last AS last_name
			     ,street
			     ,city
			     ,zip
        ,1 AS is_new
        ,geocode
	 FROM AUTOLOAD$GDOCS_OPS_students_new WITH(NOLOCK)
  
  --UNION ALL

  --SELECT s.student_number
  --      ,s.schoolid
  --      ,s.grade_level
  --      ,s.first_name
		--	     ,s.last_name
		--	     ,s.street
		--	     ,s.city
		--	     ,s.zip
  --      ,0 AS is_new
  --FROM PS$students#static s WITH(NOLOCK)
  --WHERE s.enroll_status = 0
  --  --AND s.grade_level <= 3
  --  --AND s.schoolid NOT IN (73252, 179901, 179902)
	 --  --AND s.city LIKE '%Newark%'
 )

SELECT	s.student_number
      ,s.schoolid
      ,s.grade_level
      ,s.first_name
      ,s.last_name
      ,s.street
      ,s.city
      ,s.zip
      ,s.is_new
      ,s.school_level
      ,s.geocode
      ,l.type AS location_type
      ,l.name AS location_name
      ,l.address AS location_address
      --,l.zip AS location_zip
FROM KIPP_NJ..AUTOLOAD$GDOCS_OPS_locations l WITH(NOLOCK)
JOIN roster s
  ON l.school_level = s.school_level
WHERE l.name NOT LIKE '%Boys and Girls%' 
  AND l.name NOT LIKE '%Parent%'
  AND l.type != 'BUS_STOP'
  AND NOT (l.name = 'KIPP BOLD' AND s.grade_level = 8)