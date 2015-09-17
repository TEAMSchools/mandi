USE KIPP_NJ
GO

ALTER VIEW COHORT$identifiers_long AS

WITH advisory AS (
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
      ) sub
 )

,promo AS (
  SELECT year 
        ,year - 1 AS past_year
        ,year + 1 AS future_year
        ,student_number      
        ,grade_level
  FROM KIPP_NJ..COHORT$comprehensive_long#static WITH(NOLOCK)
  WHERE rn = 1
 )

,retention_flags AS (
  SELECT sub.studentid
        ,sub.year
        ,retained_yr_flag
        ,MAX(retained_yr_flag) OVER(PARTITION BY sub.studentid) AS retained_ever_flag
  FROM
      (
       SELECT co.studentid      
             ,co.year
             --,co.grade_level
             --,LAG(co.grade_level, 1) OVER(PARTITION BY co.studentid ORDER BY co.year ASC) AS prev_grade
             ,CASE 
               WHEN co.grade_level != 99 AND co.grade_level <= LAG(co.grade_level, 1) OVER(PARTITION BY co.studentid ORDER BY co.year ASC) THEN 1 
               ELSE 0 
              END AS retained_yr_flag
       FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
       WHERE co.rn = 1       
      ) sub
 )

SELECT co.schoolid
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
      ,co.rn
      ,co.year_in_network
      ,ROW_NUMBER() OVER(
         PARTITION BY co.studentid, co.schoolid
           ORDER BY co.year ASC) AS year_in_school

      ,sch.abbreviation AS school_name

      ,s.first_name
      ,s.MIDDLE_NAME
      ,s.last_name
      ,s.first_name + ' ' + s.last_name AS full_name
      ,CASE WHEN co.year < KIPP_NJ.dbo.fn_Global_Academic_Year() THEN advisory.section_number ELSE s.TEAM END AS team
      ,s.GENDER
      ,s.ETHNICITY
      ,s.enroll_status
      ,s.DOB      
      ,s.STREET
      ,s.CITY
      ,s.STATE
      ,s.ZIP        
      ,CASE WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() THEN mcs.MealBenefitStatus ELSE lunch.lunchstatus END AS lunchstatus      
      ,s.state_studentnumber AS SID

      ,advisory.advisor AS advisor
      ,adp.phone_mobile AS ADVISOR_CELL
      ,dir.mail AS ADVISOR_EMAIL
      ,logins.student_web_id
      ,logins.STUDENT_WEB_PASSWORD
      ,logins.student_web_id + '.fam' AS FAMILY_WEB_ID
      ,logins.STUDENT_WEB_PASSWORD AS FAMILY_WEB_PASSWORD
      ,cs.LUNCH_BALANCE      
      ,cs.STATUS_504
      ,cs.LEP_STATUS
      ,cs.NEWARK_ENROLLMENT_NUMBER
      ,CASE WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() THEN ISNULL(cs.SPEDLEP,'No IEP') ELSE ISNULL(COALESCE(sped.SPEDLEP, cs.spedlep),'No IEP') END AS SPEDLEP
      ,CASE WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() THEN cs.SPEDLEP_CODE ELSE COALESCE(sped.SPEDCODE, cs.spedlep) END AS SPED_code
      
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
FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH (NOLOCK)
JOIN KIPP_NJ..PS$SCHOOLS#static sch WITH (NOLOCK)
  ON co.schoolid = sch.school_number
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON co.studentid = s.ID
LEFT OUTER JOIN KIPP_NJ..PS$LunchStatus#ARCHIVE lunch WITH(NOLOCK)
  ON co.studentid = lunch.studentid
 AND co.year = lunch.academic_year
LEFT OUTER JOIN KIPP_NJ..MCS$lunch_info#static mcs WITH(NOLOCK)
  ON co.STUDENT_NUMBER = mcs.StudentNumber
JOIN KIPP_NJ..PS$CUSTOM_STUDENTS#static cs WITH(NOLOCK)
  ON co.studentid = cs.STUDENTID
LEFT OUTER JOIN KIPP_NJ..ROSTERS$PS_access_accounts logins WITH(NOLOCK)
  ON co.STUDENT_NUMBER = logins.STUDENT_NUMBER
LEFT OUTER JOIN advisory WITH(NOLOCK)
  ON co.studentid = advisory.STUDENTID
 AND co.year = advisory.academic_year
 AND advisory.rn = 1
LEFT OUTER JOIN KIPP_NJ..PEOPLE$ADP_PS_linking link WITH(NOLOCK)
  ON advisory.teachernumber = link.teachernumber
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
LEFT OUTER JOIN KIPP_NJ..PS$student_BLOBs#static blobs WITH(NOLOCK)
  ON co.studentid = blobs.STUDENTID
LEFT OUTER JOIN KIPP_NJ..PS$student_contact#static emerg WITH(NOLOCK)
  ON co.studentid = emerg.STUDENTID
LEFT OUTER JOIN promo future WITH(NOLOCK)
  ON co.STUDENT_NUMBER = future.student_number
 AND co.year = future.past_year
LEFT OUTER JOIN promo past WITH(NOLOCK)
  ON co.STUDENT_NUMBER = past.student_number
 AND co.year = past.future_year
LEFT OUTER JOIN retention_flags ret WITH(NOLOCK)
  ON co.studentid = ret.studentid
 AND co.year = ret.year