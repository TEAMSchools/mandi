USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$student_membership AS

SELECT co.student_number      
      ,co.year AS academic_year
      ,co.school_name
      ,co.grade_level
      ,SUM(CONVERT(INT,attmem.ATTENDANCEVALUE)) AS att
      ,SUM(CONVERT(INT,attmem.MEMBERSHIPVALUE)) AS mem
      ,SUM(CONVERT(INT,attmem.MEMBERSHIPVALUE)) - SUM(CONVERT(INT,attmem.ATTENDANCEVALUE)) AS absences
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP attmem WITH(NOLOCK)
  ON co.studentid = attmem.STUDENTID
 AND co.year = attmem.academic_year
WHERE co.schoolid != 999999
  AND co.rn = 1
GROUP BY co.student_number      
        ,co.school_name
        ,co.grade_level
        ,co.year 