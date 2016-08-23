USE KIPP_NJ
GO

ALTER VIEW ROSTERS$UCSTEP_combined AS

SELECT co.schoolid
      ,co.school_name AS schoolname
      ,enr.sectionid AS classid
      ,KIPP_NJ.dbo.fn_StripCharacters(enr.SECTION_NUMBER,'0-9') AS classname
      ,COALESCE(link.associate_id, enr.TEACHERNUMBER) AS teacherid      
      ,u.FIRST_NAME AS teacherfirst
      ,u.LAST_NAME AS teacherlast
      ,co.student_number AS studentid
      ,co.first_name AS firstname
      ,co.last_name AS lastname
      ,REPLACE(co.grade_level, 0, 'K') AS classgrade
      ,co.SID AS stateid
      ,co.gender
      ,'eng' AS language
      ,'eng' AS steplanguage
      ,CASE
        WHEN co.lunchstatus = 'F' THEN 1
        WHEN co.lunchstatus = 'R' THEN 2        
        WHEN co.lunchstatus = 'P' THEN 3
        ELSE 0
       END AS mealstatus
      ,CASE WHEN co.ETHNICITY = 'H' THEN 'T' ELSE 'F' END AS latino
      ,CASE 
        WHEN co.ethnicity = 'B' THEN 1000        
        WHEN co.ethnicity = 'A' THEN 999
        WHEN co.ethnicity = 'W' THEN 1002
        WHEN co.ethnicity = 'P' THEN 1001
       END AS race
      ,CASE WHEN co.SPEDLEP = 'SPED SPEECH' THEN 'T' ELSE 'F' END AS speechiep
      ,CASE WHEN co.SPED_code = 'SLD' THEN 'T' ELSE 'F' END AS sldiep
      ,CASE WHEN co.status_504 = 1 THEN 'T' ELSE 'F' END AS [504iep]
      ,CASE WHEN co.SPED_code = 'OHI' THEN 'T' ELSE 'F' END AS healthiep
      ,CASE 
        WHEN co.SPED_code IN ('OHI','SLD') OR co.SPEDLEP = 'SPED SPEECH' OR co.STATUS_504 = 1 
               OR co.SPEDLEP = 'No IEP' OR co.SPEDLEP IS NULL THEN 'F' 
        ELSE 'T' 
       END AS otheriep
      ,CASE WHEN co.LEP_STATUS = 1 THEN 'T' ELSE 'F' END AS ELL
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year
 AND enr.COURSE_NUMBER = 'HR'
 AND enr.rn_subject = 1
 AND enr.drop_flags = 0
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PEOPLE_teachernumber_associateid_link link WITH(NOLOCK)
  ON enr.TEACHERNUMBER = link.TEACHERNUMBER
LEFT OUTER JOIN KIPP_NJ..PS$USERS#static u WITH(NOLOCK)
  ON enr.TEACHERNUMBER = u.TEACHERNUMBER
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
  AND co.grade_level <= 4
  AND co.schoolid != 73252
  AND co.enroll_status = 0  