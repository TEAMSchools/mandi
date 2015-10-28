USE KIPP_NJ
GO

ALTER VIEW KTC$team_and_family_roster AS 

WITH grads AS (
  SELECT co.studentid
        ,co.student_number
        ,co.lastfirst
        ,co.schoolid
        ,co.school_name
        ,co.grade_level                
        ,(KIPP_NJ.dbo.fn_Global_Academic_Year() - co.year) + co.grade_level AS curr_grade_level
        ,co.cohort
        ,co.highest_achieved
        ,ROW_NUMBER() OVER(
           PARTITION BY co.student_number
             ORDER BY co.exitdate DESC) AS rn
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  WHERE co.grade_level = 8
    AND co.exitcode = 'G1'           
    AND co.student_number NOT IN (2026,3049,3012)
    AND co.rn = 1
 )

,transfers AS (
  SELECT sub.studentid
        ,sub.student_number
        ,sub.lastfirst        
        ,sub.curr_grade_level
        ,sub.cohort
        ,sub.highest_achieved
        ,CASE WHEN s.GRADUATED_SCHOOLID = 0 THEN s.SCHOOLID ELSE s.GRADUATED_SCHOOLID END AS schoolid       
        ,CASE WHEN s.GRADUATED_SCHOOLID = 0 THEN sch2.ABBREVIATION ELSE sch.ABBREVIATION END AS school_name         
  FROM
      (
       SELECT co.studentid             
             ,co.student_number
             ,co.lastfirst
             --,co.schoolid
             --,co.school_name
             ,MAX(co.cohort) AS cohort
             ,co.highest_achieved
             ,(KIPP_NJ.dbo.fn_Global_Academic_Year() - MAX(co.year)) + MAX(co.grade_level) AS curr_grade_level
             ,DATEDIFF(YEAR, MIN(co.entrydate), MAX(co.exitdate)) AS years_enrolled             
             ,MIN(co.entrydate) AS orig_entrydate
             ,MAX(co.exitdate) AS final_exitdate
             ,DATEPART(YEAR,MAX(co.exitdate)) AS year_final_exitdate
       FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       WHERE co.grade_level != 99
         AND co.studentid NOT IN (SELECT studentid FROM grads)
         AND co.enroll_status != 0
       GROUP BY co.studentid, co.student_number, co.lastfirst, co.highest_achieved
      ) sub
  LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS#static s
    ON sub.student_number = s.STUDENT_NUMBER
  LEFT OUTER JOIN KIPP_NJ..PS$SCHOOLS#static sch
    ON s.GRADUATED_SCHOOLID = sch.SCHOOL_NUMBER
  LEFT OUTER JOIN KIPP_NJ..PS$SCHOOLS#static sch2
    ON s.SCHOOLID = sch2.SCHOOL_NUMBER
  WHERE ((years_enrolled = 1 AND final_exitdate >= CONVERT(DATE,CONVERT(VARCHAR,year_final_exitdate) + '-10-01')) OR (years_enrolled > 1))
 )

,roster AS (
  SELECT studentid
        ,student_number
        ,lastfirst
        ,schoolid
        ,school_name
        ,curr_grade_level
        ,cohort
        ,highest_achieved
  FROM grads  
  
  UNION
  
  SELECT studentid
        ,student_number
        ,lastfirst
        ,schoolid
        ,school_name
        ,curr_grade_level
        ,cohort
        ,highest_achieved
  FROM transfers    
 )

SELECT r.student_number
      ,r.lastfirst
      ,r.schoolid
      ,r.school_name
      ,r.curr_grade_level AS approx_grade_level      
      ,r.cohort
      ,CASE WHEN r.highest_achieved = 99 THEN 1 ELSE 0 END AS is_grad
      ,con.HOME_PHONE
      ,con.MOTHER
      ,con.MOTHER_HOME
      ,con.MOTHER_CELL
      ,con.MOTHER_DAY
      ,con.FATHER
      ,con.FATHER_HOME
      ,con.FATHER_CELL
      ,con.FATHER_DAY
      ,con.DOCTOR_NAME
      ,con.DOCTOR_PHONE
      ,con.EMERG_CONTACT_1
      ,con.EMERG_1_REL
      ,con.EMERG_PHONE_1
      ,con.EMERG_CONTACT_2
      ,con.EMERG_2_REL
      ,con.EMERG_PHONE_2
      ,con.EMERG_CONTACT_3
      ,con.EMERG_3_REL
      ,con.EMERG_3_PHONE
      ,con.EMERG_4_NAME
      ,con.EMERG_4_REL
      ,con.EMERG_4_PHONE
      ,con.EMERG_5_NAME
      ,con.EMERG_5_REL
      ,con.EMERG_5_PHONE
      ,con.RELEASE_1_NAME
      ,con.RELEASE_1_PHONE
      ,con.RELEASE_1_RELATION
      ,con.RELEASE_2_NAME
      ,con.RELEASE_2_PHONE
      ,con.RELEASE_2_RELATION
      ,con.RELEASE_3_NAME
      ,con.RELEASE_3_PHONE
      ,con.RELEASE_3_RELATION
      ,con.RELEASE_4_NAME
      ,con.RELEASE_4_PHONE
      ,con.RELEASE_4_RELATION
      ,con.RELEASE_5_NAME
      ,con.RELEASE_5_PHONE
      ,con.RELEASE_5_RELATION
FROM roster r
LEFT OUTER JOIN KIPP_NJ..PS$student_contact#static con WITH(NOLOCK)
  ON r.studentid = con.STUDENTID