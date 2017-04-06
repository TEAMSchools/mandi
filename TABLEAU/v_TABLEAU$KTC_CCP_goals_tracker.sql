USE KIPP_NJ
GO

ALTER VIEW TABLEAU$KTC_CCP_goals_tracker AS

WITH applications AS (
  SELECT hs_student_id
        ,COUNT(DISTINCT navianceid) AS n_apps_submitted
        ,NULL AS n_likely
        ,NULL AS n_target
        ,NULL AS n_reach        
        ,COUNT(DISTINCT CASE WHEN award = 1 THEN navianceid END) AS n_award_letters_collected
        ,AVG(EFC_from_FAFSA__c) AS avg_efc_from_FAFSA
  FROM
      (
       SELECT app.id AS application_id
             ,app.Applicant__c
             ,app.EFC_from_FAFSA__c              
             ,acc.CEEB_Code__c        
             ,nav.hs_student_id
             ,nav.navianceid
             ,nav.collegename
             ,nav.level
             ,nav.stage
             ,nav.result_code
             ,nav.award        
             ,ROW_NUMBER() OVER(
                PARTITION BY app.applicant__c, app.school__c
                  ORDER BY app.LastModifiedDate) AS rn
       FROM AlumniMirror..Application__c app WITH(NOLOCK)
       JOIN AlumniMirror..Account acc WITH(NOLOCK)
         ON app.School__c = acc.Id
       JOIN AlumniMirror..Contact c WITH(NOLOCK)
         ON app.Applicant__c = c.Id
       JOIN KIPP_NJ..NAVIANCE$college_apps_clean nav WITH(NOLOCK)
         ON c.School_Specific_ID__c = nav.hs_student_id
        AND CONVERT(VARCHAR,acc.CEEB_Code__c) = CONVERT(VARCHAR,nav.ceeb_code)
        AND nav.stage NOT IN ('cancelled','pending')
       WHERE app.Application_Submission_Status__c NOT IN ('Withdrew Application')
      ) sub
  GROUP BY hs_student_id
 )

SELECT co.student_number
      ,co.lastfirst      
      ,co.year
      ,co.schoolid
      ,co.grade_level      
      ,co.cohort
      ,co.enroll_status      

      ,s.counselor_name

      ,CASE WHEN ctcs.[1q_counselor_meeting_1_of_2] = 'completed' THEN 1 ELSE 0 END
         + CASE WHEN ctcs.[1q_counselor_meeting_2_of_2] = 'completed' THEN 1 ELSE 0 END 
         AS q1_counselor_meetings
      ,CASE WHEN ctcs.[2q_counselor_meeting_1_of_3] = 'completed' THEN 1 ELSE 0 END
         + CASE WHEN ctcs.[2q_counselor_meeting_2_of_3] = 'completed' THEN 1 ELSE 0 END
         + CASE WHEN ctcs.[2q_counselor_meeting_3_of_3] = 'completed' THEN 1 ELSE 0 END 
         AS q2_counselor_meetings
      ,CASE WHEN ctcs.[3q_counselor_meeting_1_of_3] = 'completed' THEN 1 ELSE 0 END
         + CASE WHEN ctcs.[3q_counselor_meeting_2_of_3] = 'completed' THEN 1 ELSE 0 END
         + CASE WHEN ctcs.[3q_counselor_meeting_3_of_3] = 'completed' THEN 1 ELSE 0 END 
         AS q3_counselor_meetings     
      ,CASE WHEN ctcs.[4q_counselor_meeting_1_of_3] = 'completed' THEN 1 ELSE 0 END
         + CASE WHEN ctcs.[4q_counselor_meeting_2_of_3] = 'completed' THEN 1 ELSE 0 END
         + CASE WHEN ctcs.[4q_counselor_meeting_3_of_3] = 'completed' THEN 1 ELSE 0 END 
         AS q4_counselor_meetings           
      ,CASE WHEN ctcs.[2015_taxes_or_income_submitted_to_counselor] IN ('completed','waived') THEN 1 ELSE 0 END AS submitted_tax_document_prev
      ,CASE WHEN ctcs.submit_2016_tax_or_income_documents_to_counselor IN ('completed','waived') THEN 1 ELSE 0 END AS submitted_tax_document_curr
      ,ctcs.submit_the_fafsa AS fafsa_submitted
      ,ctcs.submit_the_hessa_nj_college_bound AS hessa_submitted
      ,ctcs.registered_for_nov_sat AS is_registered_sat
      ,ctcs.registered_for_october_act AS is_registered_act
      ,CASE WHEN ctcs.senior_parent_meeting_1_of_2 = 'completed' THEN 1 ELSE 0 END
         + CASE WHEN ctcs.senior_parent_meeting_2_of_2 = 'completed' THEN 1 ELSE 0 END AS senior_parent_meetings
      ,CASE WHEN ctcs.teacher_lor_1_submitted_to_naviance = 'completed' THEN 1 ELSE 0 END
         + CASE WHEN ctcs.teacher_lor_2_submitted_to_naviance = 'completed' THEN 1 ELSE 0 END AS teacher_lors_submitted
      ,ctcs.common_app_complete_and_synced_to_naviance

      ,app.n_apps_submitted
      ,app.n_likely
      ,app.n_target
      ,app.n_reach
      ,app.n_award_letters_collected
      ,app.avg_efc_from_FAFSA

      ,CASE 
        WHEN co.grade_level != 11 THEN NULL
        WHEN enr.STUDENTID IS NOT NULL THEN 1 
        ELSE 0 
       END AS enrolled_junior_seminar

      ,act.composite AS highest_act_composite
      ,prep.scale_score AS act_pretest_composite
      ,CASE
        WHEN act.composite - prep.scale_score IS NULL THEN NULL
        WHEN act.composite - prep.scale_score >= 3 THEN 1
        ELSE 0
       END AS meeting_act_growth_goal

      ,gpa.cumulative_Y1_gpa
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..AUTOLOAD$NAVIANCE_0_students s WITH(NOLOCK)
  ON co.student_number = s.hs_student_id
JOIN KIPP_NJ..[AUTOLOAD$GDOCS_KTC_current_task_completion_status.csv] ctcs WITH(NOLOCK)
  ON co.student_number = ctcs.student_id
LEFT OUTER JOIN applications app
  ON co.student_number = app.hs_student_id
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.studentid = enr.STUDENTID
 AND co.year = enr.academic_year
 AND enr.COURSE_NUMBER = 'STUDY35'
 AND enr.drop_flags = 0
 AND enr.rn_subject = 1
LEFT OUTER JOIN KIPP_NJ..NAVIANCE$ACT_clean act WITH(NOLOCK)
  ON co.student_number = act.student_number
 AND act.rn_highest = 1
LEFT OUTER JOIN KIPP_NJ..ACT$test_prep_scores prep WITH(NOLOCK)
  ON co.student_number = prep.student_number
 AND co.year = prep.academic_year
 AND prep.subject_area = 'Composite'
 AND prep.administration_round = 'Pre-Test'
 AND prep.rn_dupe = 1  
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_cumulative#static gpa WITH(NOLOCK)
  ON co.studentid = gpa.studentid
 AND co.schoolid = gpa.schoolid
WHERE co.schoolid = 73253
  AND co.grade_level >= 11
  AND co.rn = 1