SELECT co.student_number
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
      ,CONCAT(co.STREET, ', '
             ,co.CITY, ', '
             ,co.STATE, ' '
             ,co.ZIP) AS home_address
      ,co.lunch_balance
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.schoolid != 999999
  AND co.rn = 1 