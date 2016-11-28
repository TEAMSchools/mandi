USE KIPP_NJ
GO

ALTER VIEW TABLEAU$ops_dashboard AS

SELECT co.student_number
      ,co.lastfirst
      ,co.YEAR AS academic_year      
      ,KIPP_NJ.dbo.fn_Global_Academic_Year() AS current_academic_year
      ,co.entrydate
      ,co.exitdate
      ,co.exitcode
      ,co.school_level
      ,co.reporting_schoolid AS SCHOOLID
      ,co.GRADE_LEVEL
      ,co.ENROLL_STATUS
      ,co.spedlep AS iep_status
      ,co.sped_code
      ,co.LEP_STATUS
      ,co.lunchstatus
      ,co.lunch_app_status
      ,co.ethnicity
      ,co.gender            
      ,co.rn
      ,LEAD(co.entrydate, 1) OVER(PARTITION BY co.student_number, co.rn ORDER BY co.year ASC) AS next_entrydate
      ,LEAD(co.exitdate, 1) OVER(PARTITION BY co.student_number, co.rn ORDER BY co.year ASC) AS next_exitdate
      ,LEAD(co.schoolid, 1) OVER(PARTITION BY co.student_number, co.rn ORDER BY co.year ASC) AS next_schoolid
      ,LEAD(co.year, 1) OVER(PARTITION BY co.student_number, co.rn ORDER BY co.year ASC) AS next_academic_year

      ,t.target_enrollment
      ,t.sped_enrollment AS target_enrollment_sped
      ,t.fr_enrollment AS target_enrollment_fr      

      ,iep.NJ_SE_REFERRALDATE
      ,iep.NJ_SE_PARENTALCONSENTDATE
      ,iep.NJ_SE_ELIGIBILITYDDATE
      ,iep.NJ_SE_EARLYINTERVENTION
      ,iep.NJ_SE_INITIALIEPMEETINGDATE
      ,iep.NJ_SE_PARENTALCONSENTOBTAINED
      ,iep.NJ_SE_CONSENTTOIMPLEMENTDATE
      ,iep.NJ_SE_LATESTIEPMEETINGDATE      
      ,iep.NJ_SE_REEVALUATIONDATE
      ,iep.NJ_SE_DELAYREASON
      ,iep.NJ_SE_PLACEMENT
      ,iep.NJ_SE_INELIGIBLE
      ,iep.NJ_TIMEINREGULARPROGRAM
      ,iep.TI_SERV_COUNSELING
      ,iep.TI_SERV_OCCUP
      ,iep.TI_SERV_PHYSICAL
      ,iep.TI_SERV_SPEECH
      ,iep.TI_SERV_OTHER
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)            
LEFT OUTER JOIN KIPP_NJ..PS$IEP_details#static iep WITH(NOLOCK)
  ON co.studentid = iep.studentid
 AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_FINANCE_enrollment_targets t WITH(NOLOCK)
  ON co.year = t.academic_year
 AND co.reporting_schoolid = t.schoolid
 AND co.grade_level = t.grade_level