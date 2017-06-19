USE KIPP_NJ
GO

ALTER VIEW DL$student_misc#extract AS

SELECT co.student_number
      ,co.SID
      ,co.year AS academic_year
      ,co.team
      ,co.advisor AS advisor_name
      ,co.advisor_cell
      ,co.advisor_email
      ,co.home_phone
      ,co.mother AS parent1_name
      ,co.mother_cell AS parent1_cell
      ,co.father AS parent2_name
      ,co.father_cell AS parent2_cell
      ,co.guardianemail
      ,co.lunch_balance
      ,co.dob
      ,CONCAT(co.STREET, ', ', co.CITY, ', ', co.STATE, ' ', co.ZIP) AS home_address
      
      ,nav.counselor_name AS ktc_counselor_name
      ,adp.phone_mobile AS ktc_counselor_phone
      ,ad.mail AS ktc_counselor_email

      ,gpa.GPA_Y1

      ,cat.H_Y1 AS HWQ_Y1
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..NAVIANCE$students_clean nav WITH(NOLOCK)
  ON co.student_number = nav.hs_student_id
LEFT OUTER JOIN KIPP_NJ..PEOPLE$ADP_detail adp WITH(NOLOCK)
  ON nav.counselor_name = CONCAT(adp.preferred_first, ' ', adp.preferred_last)
 AND adp.rn_curr = 1
LEFT OUTER JOIN KIPP_NJ..PEOPLE$AD_users#static ad WITH(NOLOCK)
  ON adp.associate_id = ad.associate_id
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_detail_long#static gpa WITH(NOLOCK)
  ON co.student_number = gpa.student_number
 AND co.year = gpa.academic_year
 AND gpa.is_curterm = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static cat WITH(NOLOCK)
  ON co.student_number = cat.student_number
 AND co.year = cat.academic_year
 AND cat.is_curterm = 1
 AND cat.COURSE_NUMBER = 'ALL'
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.schoolid != 999999
  AND co.rn = 1 