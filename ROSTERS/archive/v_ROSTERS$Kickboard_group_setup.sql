USE KIPP_NJ
GO

ALTER VIEW ROSTERS$Kickboard_group_setup AS

SELECT enr.schoolid
      ,enr.COURSE_NUMBER
      ,enr.SECTION_NUMBER
      ,enr.dateenrolled
      ,enr.dateleft
      ,CONCAT(enr.COURSE_NUMBER, '-', enr.SECTION_NUMBER) AS GroupExternalID
      ,CONCAT(enr.COURSE_NAME, ' ('
             ,CASE 
               WHEN enr.SECTION_NUMBER LIKE '_IEP' OR enr.SECTION_NUMBER LIKE 'IEP_'  OR enr.SECTION_NUMBER LIKE '_IEP_' OR enr.SECTION_NUMBER LIKE 'SG%' THEN enr.SECTION_NUMBER 
               ELSE KIPP_NJ.dbo.fn_StripCharacters(enr.SECTION_NUMBER,'0-9')
              END , ')'
         ) AS GroupName
      ,enr.student_number AS StudentExternalID
      ,s.LAST_NAME AS StudentLastName
      ,s.FIRST_NAME AS StudentFirstName
      ,s.GRADE_LEVEL AS Grade
      ,COALESCE(link.associate_id, enr.TEACHERNUMBER) AS StaffExternalID	
      ,COALESCE(
         LTRIM(RTRIM(CASE
                      WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) = 0 THEN NULL
                      WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, CHARINDEX(' ',adp.preferred_name) + 1, LEN(adp.preferred_name))
                      WHEN CHARINDEX(',',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, 1, CHARINDEX(',',adp.preferred_name) - 1)
                     END))
        ,adp.[last_name]) AS StaffLastName
      ,COALESCE(
         LTRIM(RTRIM(CASE
                      WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) = 0 THEN SUBSTRING(adp.preferred_name, 1, LEN(adp.preferred_name))
                      WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, 1, CHARINDEX(' ',adp.preferred_name))
                      WHEN CHARINDEX(',',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, CHARINDEX(',',adp.preferred_name) + 1, LEN(adp.preferred_name))
                     END)) 
        ,adp.[first_name]) AS StaffFirstName
FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON enr.student_number = s.STUDENT_NUMBER
 AND s.ENROLL_STATUS = 0
LEFT OUTER JOIN KIPP_NJ..PEOPLE$ADP_PS_linking link WITH(NOLOCK)
  ON enr.TEACHERNUMBER = link.TEACHERNUMBER
 AND link.is_master = 1
LEFT OUTER JOIN KIPP_NJ..PEOPLE$ADP_detail adp WITH(NOLOCK)
  ON COALESCE(link.associate_id, enr.TEACHERNUMBER) = adp.associate_id
 AND adp.rn_curr = 1
WHERE enr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND enr.SCHOOLID IN (133570965, 179902)
  AND enr.drop_flags = 0
  AND enr.COURSE_NUMBER != 'HR'