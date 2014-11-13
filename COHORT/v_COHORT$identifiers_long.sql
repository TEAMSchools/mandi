USE KIPP_NJ
GO

ALTER VIEW COHORT$identifiers_long AS

SELECT co.schoolid
      ,sch.abbreviation AS school_name      
      ,co.studentid
      ,co.student_number      
      ,cs.SID
      ,co.lastfirst
      ,s.first_name
      ,s.last_name
      ,s.first_name + ' ' + s.last_name AS full_name
      ,co.grade_level
      ,co.year            
      ,co.cohort
      ,co.entrydate
      ,co.exitdate
      ,s.TEAM
      ,cs.ADVISOR
      ,s.GENDER
      ,s.ETHNICITY
      ,CASE WHEN co.year = dbo.fn_Global_Academic_Year() THEN s.LUNCHSTATUS ELSE lunch.lunch_status END AS lunchstatus
      ,cs.SPEDLEP            
      ,cs.LEP_STATUS
      ,s.enroll_status
      ,co.rn
      ,co.year_in_network
      ,ms.school AS entry_school_name
      ,ms.schoolid AS entry_schoolid
      ,gr.grade_level AS entry_grade_level
      ,s.DOB
      ,cs.DEFAULT_STUDENT_WEB_ID AS STUDENT_WEB_ID
      ,cs.DEFAULT_STUDENT_WEB_PASSWORD AS STUDENT_WEB_PASSWORD
      ,cs.DEFAULT_FAMILY_WEB_ID AS FAMILY_WEB_ID
      ,cs.DEFAULT_FAMILY_WEB_PASSWORD AS FAMILY_WEB_PASSWORD
      ,cs.LUNCH_BALANCE
      ,cs.ADVISOR_CELL
      ,cs.ADVISOR_EMAIL
      ,s.STREET
      ,s.CITY
      ,s.STATE
      ,s.ZIP
      ,s.HOME_PHONE
      ,s.MOTHER      
      ,cs.MOTHER_HOME
      ,cs.MOTHER_CELL
      ,cs.MOTHER_DAY
      ,s.FATHER      
      ,cs.FATHER_HOME
      ,cs.FATHER_CELL
      ,cs.FATHER_DAY
      ,blobs.guardianemail
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
FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH (NOLOCK)
JOIN KIPP_NJ..SCHOOLS sch WITH (NOLOCK)
  ON co.schoolid = sch.school_number
JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
  ON co.studentid = s.ID
JOIN KIPP_NJ..CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON co.studentid = cs.STUDENTID
LEFT OUTER JOIN KIPP_NJ..COHORT$middle_school_attended ms WITH(NOLOCK)
  ON co.studentid = ms.studentid
LEFT OUTER JOIN KIPP_NJ..COHORT$comprehensive_long#static gr WITH(NOLOCK)
  ON co.studentid = gr.studentid
 AND gr.year_in_network = 1
LEFT OUTER JOIN KIPP_NJ..PS$student_BLObs#static blobs WITH(NOLOCK)
  ON co.studentid = blobs.STUDENTID
LEFT OUTER JOIN PS$lunch_status_long#static lunch WITH(NOLOCK)
  ON co.studentid = lunch.studentid
 AND co.year = lunch.year
LEFT OUTER JOIN PS$emerg_release_contact emerg WITH(NOLOCK)
  ON co.studentid = emerg.STUDENTID