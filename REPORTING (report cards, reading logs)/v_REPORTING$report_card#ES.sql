USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#ES AS

WITH roster AS (
 SELECT cs.STUDENTID
       ,s.STUDENT_NUMBER      
       ,s.LASTFIRST
       ,s.LAST_NAME
       ,s.FIRST_NAME
       ,co.GRADE_LEVEL
       ,co.SCHOOLID
       ,s.TEAM
       ,cs.LUNCH_BALANCE
       ,s.STREET AS address
       ,s.CITY
       ,s.STATE
       ,s.ZIP
       ,s.HOME_PHONE
       ,cs.MOTHER_CELL
       ,cs.MOTHER_DAY
       ,cs.FATHER_CELL
       ,cs.FATHER_DAY
       ,cs.GUARDIANEMAIL
 FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
 JOIN STUDENTS s WITH(NOLOCK)
   ON co.STUDENTID = s.ID
  AND s.ENROLL_STATUS = 0
 LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
   ON co.STUDENTID = cs.STUDENTID
 WHERE co.YEAR = dbo.fn_Global_Academic_Year()
   AND co.GRADE_LEVEL < 5
   AND co.RN = 1
)

,attendance AS (
  SELECT att.id AS studentid
        ,cur_absences_total
        ,cur_absences_doc AS excused_absences
        ,cur_tardies_total
        ,cur_early_dismiss
        ,trip_absences
        ,trip_status
  FROM ATT_MEM$attendance_counts att
  WHERE att.grade_level < 5
 )

,reporting_week AS (
  SELECT time_per_name AS week_num        
        ,start_date
        ,end_date
        ,REPLACE(time_per_name,'_',' ') + ': ' + LEFT(CONVERT(VARCHAR,start_date,101),5) + ' - ' + LEFT(CONVERT(VARCHAR,end_date,101),5) AS week_title
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE DATEADD(WEEK,-2,GETDATE()) >= start_date
    AND DATEADD(WEEK,-2,GETDATE()) <= end_date
    AND identifier = 'FSA'
 )

SELECT r.studentid
      ,r.student_number
      ,lastfirst
      ,last_name
      ,first_name
      ,grade_level
      ,schoolid
      ,team
      ,lunch_balance
      ,address
      ,city
      ,state
      ,zip
      ,home_phone
      ,mother_cell
      ,mother_day
      ,father_cell
      ,father_day
      ,guardianemail
      ,week_num
      ,start_date
      ,end_date
      ,week_title
      ,cur_absences_total
      ,excused_absences
      ,cur_tardies_total
      ,cur_early_dismiss
      ,trip_absences
      ,trip_status
      ,fsa_week
      ,fsa_prof_1
      ,fsa_prof_2
      ,fsa_prof_3
      ,fsa_prof_4
      ,fsa_prof_5
      ,fsa_prof_6
      ,fsa_prof_7
      ,fsa_prof_8
      ,fsa_prof_9
      ,fsa_prof_10
      ,fsa_score_1
      ,fsa_score_2
      ,fsa_score_3
      ,fsa_score_4
      ,fsa_score_5
      ,fsa_score_6
      ,fsa_score_7
      ,fsa_score_8
      ,fsa_score_9
      ,fsa_score_10
      ,fsa_subject_1
      ,fsa_subject_2
      ,fsa_subject_3
      ,fsa_subject_4
      ,fsa_subject_5
      ,fsa_subject_6
      ,fsa_subject_7
      ,fsa_subject_8
      ,fsa_subject_9
      ,fsa_subject_10
FROM roster r
LEFT OUTER JOIN reporting_week
  ON 1 = 1
JOIN attendance att
  ON r.STUDENTID = att.studentid
LEFT OUTER JOIN REPORTING$FSA_scores_wide fsa WITH(NOLOCK)
  ON r.STUDENTID = fsa.studentid
 AND reporting_week.week_num = fsa.fsa_week