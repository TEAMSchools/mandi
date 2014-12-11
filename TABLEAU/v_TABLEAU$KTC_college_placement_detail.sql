USE KIPP_NJ
GO

ALTER VIEW TABLEAU$KTC_college_placement_detail AS

WITH roster AS (
  /*current students*/
  SELECT co.STUDENT_NUMBER
        ,co.lastfirst
        ,co.grade_level
        ,co.cohort
        ,co.schoolid
        ,CASE WHEN s.counselor_name = 'NULL' THEN NULL ELSE s.counselor_name END AS counselor_name                
  FROM COHORT$identifiers_long#static co WITH(NOLOCK)
  LEFT OUTER JOIN NAVIANCE$students_clean s WITH(NOLOCK)
    ON co.STUDENT_NUMBER = s.student_number
   AND s.rn = 1  
  WHERE co.rn = 1
    AND co.year = dbo.fn_Global_Academic_Year()
    AND co.grade_level >= 9
    AND co.grade_level <= 12
    AND co.enroll_status = 0
  
  UNION ALL

  /*alumni*/
  SELECT sub.STUDENT_NUMBER
        ,sub.lastfirst
        ,sub.grade_level
        ,sub.cohort
        ,sub.schoolid
        ,CASE WHEN s.counselor_name = 'NULL' THEN NULL ELSE s.counselor_name END AS counselor_name                
  FROM
      (
       SELECT co.STUDENT_NUMBER
             ,co.lastfirst
             ,co.grade_level + (dbo.fn_Global_Academic_Year() - co.year) AS grade_level
             ,co.cohort
             ,999999 AS schoolid
             ,ROW_NUMBER() OVER(
                PARTITION BY co.studentid
                  ORDER BY co.year DESC) AS last_yr
       FROM COHORT$identifiers_long#static co WITH(NOLOCK)
       WHERE co.schoolid != 999999
         AND co.highest_achieved = 99
         AND co.rn = 1
      ) sub
  LEFT OUTER JOIN NAVIANCE$students_clean s WITH(NOLOCK)
    ON sub.STUDENT_NUMBER = s.student_number
   AND s.rn = 1  
  WHERE sub.last_yr = 1
 )

,apps AS (
  SELECT r.STUDENT_NUMBER
        ,r.lastfirst
        ,r.grade_level
        ,r.cohort
        ,r.schoolid
        ,ISNULL(r.counselor_name, 'Unassigned') AS counselor_name
        ,apps.ceeb_code
        ,CASE WHEN apps.student_number IS NULL THEN 1.0 ELSE 0.0 END AS no_apply
        ,apps.collegename
        ,apps.inst_control
        ,apps.level
        ,apps.stage
        ,apps.result_code
        ,apps.attending
        ,apps.waitlisted
        ,apps.comments
  FROM roster r WITH(NOLOCK)
  LEFT OUTER JOIN NAVIANCE$college_apps_clean apps WITH(NOLOCK)
    ON r.student_number = apps.student_number      
  WHERE cohort >= dbo.fn_Global_Academic_Year()
 )

,match AS (
  SELECT sis_id AS student_number
        ,coll.ceeb_code__c AS ceeb_code
        ,college_name      
        ,selec_rank
        ,Adjusted_6_year_minority_graduation_rate__c AS minor_grad
        ,admit_odds
        ,application_bin        
  FROM [AlumniMirror].[dbo].[KTC$application_odds] odds WITH(NOLOCK)
  LEFT OUTER JOIN [AlumniMirror].[dbo].[CollegeMatch$college_list] coll WITH(NOLOCK)
    ON odds.college_id = coll.salesforce_id  
   --AND coll.CEEB_Code__c IS NOT NULL  
 )

,top_admit AS (
  SELECT match.*
        ,ROW_NUMBER()  OVER(
           PARTITION BY match.student_number
             ORDER BY (CASE
                        WHEN selec_rank = 'Most Competitive+' THEN 7
                        WHEN selec_rank = 'Most Competitive' THEN 6
                        WHEN selec_rank = 'Highly Competitive' THEN 5
                        WHEN selec_rank = 'Very Competitive' THEN 4
                        WHEN selec_rank = 'Competitive' THEN 3
                        WHEN selec_rank = 'Less Competitive' THEN 2
                        WHEN selec_rank = 'Noncompetitive' THEN 1
                       END) DESC, admit_odds ASC) AS comp_rank
  FROM match WITH(NOLOCK)
  JOIN apps WITH(NOLOCK)
    ON match.student_number = apps.student_number
   AND match.ceeb_code = apps.ceeb_code
   AND apps.result_code IN ('accepted', 'jan. admit', 'cond. accept', 'summer admit')
 )
 
SELECT student_number
      ,lastfirst
      ,grade_level
      ,cohort
      ,schoolid
      ,counselor_name
      ,collegename
      ,ceeb_code
      ,degree_type
      ,selec_rank
      ,minor_grad
      ,admit_odds
      ,application_bin
      ,top_admit_ceeb
      --,proj_grad_rate_matric
      --,proj_grad_rate_top      
      ,no_apply
      ,status
      ,result
FROM
    (
     SELECT apps.student_number
           ,apps.lastfirst
           ,apps.grade_level
           ,apps.cohort
           ,apps.schoolid
           ,apps.counselor_name
           ,ISNULL(apps.collegename, 'No app') AS collegename
           ,apps.ceeb_code
           ,LEFT(apps.level,1) AS degree_type
           ,match.selec_rank
           ,match.minor_grad
           ,match.admit_odds
           ,match.application_bin
           ,top_admit.ceeb_code AS top_admit_ceeb           
           ,ISNULL(apps.stage, 'No app') AS stage
           ,apps.result_code
           ,apps.attending
           --,CASE WHEN apps.level = '4Year' THEN 1.0 ELSE 0.0 END AS is_4yr
           --,CASE WHEN apps.stage != 'cancelled' THEN 1 ELSE 0.0 END AS is_submitted           
           --,CASE WHEN apps.result_code IN ('accepted', 'jan. admit', 'cond. accept', 'summer admit') THEN 1.0 ELSE 0.0 END AS is_accepted
           --,CASE WHEN apps.attending = 'yes' THEN 1.0 ELSE 0.0 END AS is_matriculating
           ,apps.no_apply      
           --,CASE WHEN apps.attending = 'yes' THEN match.minor_grad ELSE NULL END AS proj_grad_rate_matric
           --,CASE WHEN apps.result_code IN ('accepted', 'jan. admit', 'cond. accept', 'summer admit') AND apps.ceeb_code = top_admit.ceeb_code THEN top_admit.minor_grad END AS proj_grad_rate_top      
     FROM apps WITH(NOLOCK)
     LEFT OUTER JOIN match WITH(NOLOCK)
       ON apps.STUDENT_NUMBER = match.student_number
      AND apps.ceeb_code = match.CEEB_Code          
     LEFT OUTER JOIN top_admit WITH(NOLOCK)
       ON apps.student_number = top_admit.student_number
      AND top_admit.comp_rank = 1
    ) sub
UNPIVOT(
  result
  FOR status IN (stage, result_code, attending)
 ) u