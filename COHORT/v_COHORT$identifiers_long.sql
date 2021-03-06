USE KIPP_NJ
GO

ALTER VIEW COHORT$identifiers_long AS

SELECT co.schoolid
      ,CASE
        WHEN sp.program_name = 'Out of District' THEN sp.programid
        ELSE CONVERT(BIGINT,CONCAT(co.schoolid, sp.programid)) 
       END AS reporting_schoolid
      ,CASE
        WHEN co.schoolid = 73252 THEN 'MS'
        WHEN co.grade_level <= 4 THEN 'ES'
        WHEN co.grade_level BETWEEN 5 AND 8 THEN 'MS'
        WHEN co.grade_level >= 9 THEN 'HS'
       END AS school_level
      ,co.studentid
      ,co.student_number      
      ,co.lastfirst
      ,co.grade_level
      ,co.year            
      ,co.cohort
      ,co.entrycode
      ,co.exitcode
      ,co.entrydate
      ,co.exitdate
      ,ROW_NUMBER() OVER(
         PARTITION BY co.studentid, co.year
           ORDER BY co.entrydate DESC) AS rn
      ,co.year_in_network
      ,ROW_NUMBER() OVER(
         PARTITION BY co.studentid, co.schoolid
           ORDER BY co.year ASC) AS year_in_school

      ,COALESCE(sp.program_name, sch.abbreviation) AS school_name

      ,s.first_name
      ,s.MIDDLE_NAME
      ,s.last_name
      ,s.first_name + ' ' + s.last_name AS full_name
      ,CASE 
        WHEN co.SCHOOLID = 73253 THEN advisory.advisor
        WHEN co.SCHOOLID IN (179902, 133570965) THEN KIPP_NJ.dbo.fn_StripCharacters(s.TEAM,'0-9')
        ELSE advisory.section_number 
       END AS team
      ,s.GENDER
      ,s.ETHNICITY
      ,s.enroll_status
      ,s.DOB      
      ,s.STREET
      ,s.CITY
      ,s.STATE
      ,s.ZIP        
      ,CASE 
        WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.rn = 1 THEN mcs.MealBenefitStatus 
        WHEN s.ENROLL_STATUS = 2 AND co.year = MAX(co.year) OVER(PARTITION BY co.studentid) THEN s.LUNCHSTATUS
        ELSE co.lunchstatus 
       END AS lunchstatus      
      ,CASE 
        WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.rn = 1 THEN mcs.description 
        WHEN s.ENROLL_STATUS = 2 AND co.year = MAX(co.year) OVER(PARTITION BY co.studentid) THEN s.LUNCHSTATUS
        ELSE co.lunchstatus 
       END AS lunch_app_status     
      ,s.state_studentnumber AS SID

      ,CASE WHEN co.SCHOOLID IN (179902) THEN cs.ADVISOR ELSE advisory.advisor END AS advisor
      ,CASE WHEN co.SCHOOLID IN (179902) THEN cs.ADVISOR_CELL ELSE adp.phone_mobile END AS ADVISOR_CELL
      ,CASE WHEN co.SCHOOLID IN (179902) THEN cs.ADVISOR_EMAIL ELSE dir.mail END AS ADVISOR_EMAIL
      ,logins.student_web_id
      ,logins.STUDENT_WEB_PASSWORD
      ,logins.student_web_id + '.fam' AS FAMILY_WEB_ID
      ,logins.STUDENT_WEB_PASSWORD AS FAMILY_WEB_PASSWORD
      ,cs.LUNCH_BALANCE      
      ,cs.STATUS_504
      ,CASE 
        WHEN cs.NJ_LEPBEGINDATE IS NULL THEN NULL
        WHEN cs.NJ_LEPENDDATE < co.entrydate THEN NULL
        WHEN cs.NJ_LEPBEGINDATE <= co.exitdate THEN 1       
       END AS LEP_STATUS
      ,cs.NEWARK_ENROLLMENT_NUMBER
      ,CASE 
        WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() THEN ISNULL(cs.SPEDLEP,'No IEP') 
        ELSE ISNULL(sped.SPEDLEP,'No IEP') 
       END AS SPEDLEP
      ,CASE 
        WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() THEN cs.SPECIAL_EDUCATION
        ELSE sped.SPEDCODE
       END AS SPED_code
      
      ,ms.school_name AS entry_school_name
      ,ms.schoolid AS entry_schoolid
      
      ,gr.grade_level AS entry_grade_level
      ,gr.highest_achieved      
      
      ,blobs.EXITCOMMENT    
      ,blobs.guardianemail

      ,emerg.HOME_PHONE
      ,emerg.MOTHER      
      ,emerg.MOTHER_HOME
      ,emerg.MOTHER_CELL
      ,emerg.MOTHER_DAY
      ,emerg.FATHER      
      ,emerg.FATHER_HOME
      ,emerg.FATHER_CELL
      ,emerg.FATHER_DAY
      ,emerg.Release_1_Name
      ,emerg.Release_2_Name
      ,emerg.Release_3_Name
      ,emerg.Release_4_Name
      ,emerg.Release_5_Name
      ,emerg.Release_1_Phone
      ,emerg.Release_2_Phone
      ,emerg.Release_3_Phone
      ,emerg.Release_4_Phone
      ,emerg.Release_5_Phone      
      
      ,CASE 
        WHEN co.grade_level = 99 THEN 'Graduated'
        WHEN past.grade_level < co.grade_level THEN 'Promoted'
        WHEN past.grade_level = co.grade_level THEN 'Retained'
        WHEN past.grade_level > co.grade_level THEN 'Demoted'        
        WHEN past.grade_level IS NULL THEN 'New'
       END AS BOY_status
      ,CASE 
        WHEN future.grade_level = 99 THEN 'Graduated'
        WHEN future.grade_level > co.grade_level THEN 'Promoted'
        WHEN future.grade_level = co.grade_level THEN 'Retained'
        WHEN future.grade_level < co.grade_level THEN 'Demoted'        
        WHEN future.grade_level IS NULL THEN 'Transferred'
        WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() THEN NULL
       END AS EOY_status      

      ,ret.retained_yr_flag
      ,ret.retained_ever_flag
      ,ROW_NUMBER() OVER(
         PARTITION BY co.studentid
           ORDER BY co.year DESC, co.rn ASC) AS all_years_rn
FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH (NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$SCHOOLS#static sch WITH (NOLOCK)
  ON co.schoolid = sch.school_number
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON co.studentid = s.ID
LEFT OUTER JOIN KIPP_NJ..MCS$lunch_info#static mcs WITH(NOLOCK)
  ON co.STUDENT_NUMBER = mcs.StudentNumber
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_custom#static cs WITH(NOLOCK)
  ON co.studentid = cs.STUDENTID
LEFT OUTER JOIN KIPP_NJ..ROSTERS$PS_access_accounts#static logins WITH(NOLOCK)
  ON co.STUDENT_NUMBER = logins.STUDENT_NUMBER
LEFT OUTER JOIN KIPP_NJ..PS$advisory_roster#static advisory WITH(NOLOCK)
  ON co.studentid = advisory.STUDENTID
 AND co.year = advisory.academic_year
 AND advisory.rn = 1
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PEOPLE_teachernumber_associateid_link link WITH(NOLOCK)
  ON advisory.teachernumber = LTRIM(RTRIM(STR(link.teachernumber)))
 AND link.is_master = 1
LEFT OUTER JOIN KIPP_NJ..PEOPLE$ADP_detail adp WITH(NOLOCK)
  ON COALESCE(link.associate_id, advisory.teachernumber) = adp.associate_id
 AND adp.rn_curr = 1
LEFT OUTER JOIN KIPP_NJ..PEOPLE$AD_users#static dir WITH(NOLOCK)
  ON adp.position_id = dir.employeenumber
 AND dir.is_active = 1
LEFT OUTER JOIN KIPP_NJ..PS$SPED#ARCHIVE sped WITH(NOLOCK)
  ON co.studentid = sped.studentid
 AND co.year  = sped.academic_year
LEFT OUTER JOIN KIPP_NJ..COHORT$middle_school_attended ms WITH(NOLOCK)
  ON co.studentid = ms.studentid
LEFT OUTER JOIN KIPP_NJ..COHORT$comprehensive_long#static gr WITH(NOLOCK)
  ON co.studentid = gr.studentid
 AND gr.year_in_network = 1
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_BLObs#static blobs WITH(NOLOCK)
  ON co.studentid = blobs.STUDENTID
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_contact#static emerg WITH(NOLOCK)
  ON co.studentid = emerg.STUDENTID
LEFT OUTER JOIN KIPP_NJ..COHORT$student_promo_order#static future WITH(NOLOCK)
  ON co.STUDENT_NUMBER = future.student_number
 AND co.year = future.past_year
LEFT OUTER JOIN COHORT$student_promo_order#static past WITH(NOLOCK)
  ON co.STUDENT_NUMBER = past.student_number
 AND co.year = past.future_year
LEFT OUTER JOIN KIPP_NJ..COHORT$retention_flags#static ret WITH(NOLOCK)
  ON co.studentid = ret.studentid
 AND co.year = ret.year
LEFT OUTER JOIN KIPP_NJ..PS$SPENROLLMENTS#static sp WITH(NOLOCK)
  ON co.studentid = sp.studentid
 AND co.entrydate BETWEEN sp.enter_date AND sp.exit_date
 AND sp.programid IN (4573, 5074, 5075, 5173) /* ProgramIDs for schools within schools */