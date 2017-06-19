USE gabby
GO

ALTER VIEW powerschool.cohort_identifiers AS

SELECT co.studentid
      ,co.academic_year
      ,co.yearid
      ,co.schoolid
      ,co.grade_level
      ,co.entrydate
      ,co.exitdate                
      ,co.entrycode
      ,co.exitcode
      ,co.exitcomment      
      ,co.cohort
      ,co.is_retained_year      
      ,co.year_in_network      
      ,co.year_in_school    
      ,co.rn_year
      ,co.rn_all  
      ,MIN(CASE WHEN co.year_in_network = 1 THEN co.schoolid END) OVER(PARTITION BY co.studentid) AS entry_schoolid
      ,MIN(CASE WHEN co.year_in_network = 1 THEN co.grade_level END) OVER(PARTITION BY co.studentid) AS entry_grade_level      
      ,MAX(co.is_retained_year) OVER(PARTITION BY co.studentid) AS is_retained_ever
      ,CASE 
        WHEN co.grade_level = 99 THEN 'Graduated'
        WHEN co.prev_grade_level IS NULL THEN 'New'        
        WHEN co.prev_grade_level < co.grade_level THEN 'Promoted'
        WHEN co.prev_grade_level = co.grade_level THEN 'Retained'
        WHEN co.prev_grade_level > co.grade_level THEN 'Demoted'                
       END AS boy_status
      ,CASE 
        WHEN co.academic_year = gabby.utility.GLOBAL_ACADEMIC_YEAR() THEN NULL
        WHEN co.exitcode = 'G1' THEN 'Graduated'
        WHEN co.exitcode LIKE 'T%' THEN 'Transferred'        
        WHEN co.prev_grade_level < co.grade_level THEN 'Promoted'
        WHEN co.prev_grade_level = co.grade_level THEN 'Retained'
        WHEN co.prev_grade_level > co.grade_level THEN 'Demoted'
       END AS eoy_status      

      ,s.student_number      
      ,s.lastfirst
      ,s.first_name
      ,s.middle_name
      ,s.last_name      
      ,s.state_studentnumber
      ,s.enroll_status      
      ,s.gender
      ,s.ethnicity      
      ,s.dob      
      ,s.street
      ,s.city
      ,s.state
      ,s.zip      
      ,s.guardianemail
      ,s.home_phone
      ,s.mother
      ,s.father
      ,s.grade_level AS highest_achieved

      ,scf.mother_home_phone
      ,scf.father_home_phone
      
      ,suf.newark_enrollment_number
      ,suf.c_504_status
      ,suf.lunch_balance            
      ,suf.mother_cell
      ,suf.parent_motherdayphone
      ,suf.father_cell
      ,suf.parent_fatherdayphone
      ,suf.release_1_name
      ,suf.release_2_name
      ,suf.release_3_name
      ,suf.release_4_name
      ,suf.release_5_name
      ,suf.release_1_phone
      ,suf.release_2_phone
      ,suf.release_3_phone
      ,suf.release_4_phone
      ,suf.release_5_phone      
      
      --,logins.student_web_id
      --,logins.STUDENT_WEB_PASSWORD
      --,logins.student_web_id + '.fam' AS FAMILY_WEB_ID
      --,logins.STUDENT_WEB_PASSWORD AS FAMILY_WEB_PASSWORD

      ,CASE
        WHEN gen.name = 'Out of District' THEN sp.programid
        ELSE CONVERT(INT,CONCAT(co.schoolid, sp.programid)) 
       END AS reporting_schoolid
      ,COALESCE(gen.name, sch.abbreviation) AS school_name
      ,CASE
        WHEN sch.high_grade = 12 THEN 'HS'
        WHEN sch.high_grade = 8 THEN 'MS'
        WHEN sch.high_grade = 4 THEN 'ES'
       END AS school_level

      ,CASE 
        WHEN co.schoolid = 73253 THEN adv.advisory_name
        WHEN co.schoolid IN (179902, 133570965) THEN gabby.utility.STRIP_CHARACTERS(s.team,'0-9')
        ELSE adv.advisory_name
       END AS team
      ,CASE WHEN co.schoolid = 179902 THEN suf.advisor ELSE adv.advisor_name END AS advisor_name
      ,CASE WHEN co.schoolid = 179902 THEN suf.advisor_cell ELSE adv.advisor_phone END AS advisor_phone
      ,CASE WHEN co.schoolid = 179902 THEN suf.advisor_email ELSE adv.advisor_email END AS advisor_email

      --,CASE 
      --  WHEN co.academic_year = gabby.utility.Global_Academic_Year() AND co.rn_year = 1 THEN mcs.MealBenefitStatus 
      --  WHEN s.ENROLL_STATUS = 2 AND co.academic_year = MAX(co.academic_year) OVER(PARTITION BY co.studentid) THEN s.LUNCHSTATUS
      --  ELSE co.lunchstatus 
      -- END AS lunchstatus      
      --,CASE 
      --  WHEN co.academic_year = gabby.utility.Global_Academic_Year() AND co.rn_year = 1 THEN mcs.description 
      --  WHEN s.ENROLL_STATUS = 2 AND co.academic_year = MAX(co.academic_year) OVER(PARTITION BY co.studentid) THEN s.LUNCHSTATUS
      --  ELSE co.lunchstatus 
      -- END AS lunch_app_status                 
      ,CASE 
        WHEN co.academic_year = gabby.utility.GLOBAL_ACADEMIC_YEAR() THEN ISNULL(scf.spedlep, 'No IEP') 
        --ELSE ISNULL(sped.SPEDLEP,'No IEP') 
       END AS iep_status
      ,CASE 
        WHEN co.academic_year = gabby.utility.GLOBAL_ACADEMIC_YEAR() THEN nj.specialed_classification
        --ELSE sped.SPEDCODE
       END AS specialed_classification
      ,CASE 
        WHEN nj.lepbegindate IS NULL THEN NULL
        WHEN nj.lependdate < co.entrydate THEN NULL
        WHEN nj.lepbegindate <= co.exitdate THEN 1       
       END AS lep_status      
FROM gabby.powerschool.cohort co
LEFT OUTER JOIN gabby.powerschool.students s
  ON co.studentid = s.ID
LEFT OUTER JOIN gabby.powerschool.u_studentsuserfields suf
  ON s.dcid = suf.studentsdcid
LEFT OUTER JOIN gabby.powerschool.studentcorefields scf
  ON s.dcid = scf.studentsdcid
LEFT OUTER JOIN gabby.powerschool.s_nj_stu_x nj
  ON s.dcid = nj.studentsdcid
LEFT OUTER JOIN gabby.powerschool.schools sch
  ON co.schoolid = sch.school_number
LEFT OUTER JOIN gabby.powerschool.spenrollments sp --WITH(NOEXPAND)
  ON co.studentid = sp.studentid
 AND co.exitdate BETWEEN sp.enter_date AND sp.exit_date
 AND sp.programid IN (4573, 5074, 5075, 5173) 
 /* ProgramIDs for schools within schools 
     * 4573 = Pathways (ES)
     * 5074 = Pathways (MS)
     * 5075 = Whittier (ES)
     * 5713 = Out-of-District
 */
LEFT OUTER JOIN gabby.powerschool.gen
  ON sp.programid = gen.id
 AND gen.cat = 'specprog'
LEFT OUTER JOIN gabby.powerschool.advisory adv WITH(NOLOCK)
  ON co.studentid = adv.studentid
 AND co.yearid = adv.yearid
 AND adv.rn_year = 1

--LEFT OUTER JOIN KIPP_NJ..ROSTERS$PS_access_accounts logins WITH(NOLOCK)
--  ON co.STUDENT_NUMBER = logins.STUDENT_NUMBER
--LEFT OUTER JOIN gabby.powerschool.SPED#ARCHIVE sped WITH(NOLOCK)
--  ON co.studentid = sped.studentid
-- AND co.academic_year  = sped.academic_year
--LEFT OUTER JOIN KIPP_NJ..MCS$lunch_info mcs WITH(NOLOCK)
--  ON co.STUDENT_NUMBER = mcs.StudentNumber