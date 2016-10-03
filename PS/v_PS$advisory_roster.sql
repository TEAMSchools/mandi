USE KIPP_NJ
GO

ALTER VIEW PS$advisory_roster AS

SELECT STUDENTID
      ,academic_year
      ,teachernumber
      ,advisor
      ,SECTION_NUMBER
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, academic_year
           ORDER BY dateleft DESC) AS rn
FROM
    (
     SELECT enr.STUDENTID           
           ,enr.DATELEFT
           ,enr.academic_year           
           ,enr.TEACHERNUMBER
           ,enr.teacher_name AS advisor      
           ,KIPP_NJ.dbo.fn_StripCharacters(enr.section_number,'0-9') AS section_number
     FROM KIPP_NJ..PS$course_enrollments#static enr wITH(NOLOCK)
     WHERE enr.COURSE_NUMBER = 'HR'
       AND enr.SCHOOLID NOT IN (133570965, 73253)

     UNION ALL

     SELECT enr.STUDENTID           
           ,enr.DATELEFT
           ,enr.academic_year           
           ,enr.TEACHERNUMBER
           ,enr.teacher_name AS advisor      
           ,KIPP_NJ.dbo.fn_StripCharacters(enr.section_number,'0-9') AS section_number
     FROM KIPP_NJ..PS$course_enrollments#static enr wITH(NOLOCK)
     WHERE enr.COURSE_NUMBER = 'ADVISORY'
       AND enr.SCHOOLID IN (133570965, 73253)
    ) sub