USE KIPP_NJ
GO

ALTER VIEW REPORTING$promo_in_doubt#MS AS

WITH roster AS (
  SELECT s.studentid
        ,s.student_number
        ,s.lastfirst
        ,s.grade_level
        ,s.team
        ,s.advisor
        ,s.advisor_cell
        ,s.advisor_email
        ,s.last_name
        ,s.first_name
        ,CASE WHEN s.gender = 'M' THEN 'his' ELSE 'her' END AS pronoun
        ,s.schoolid
        ,CASE
          WHEN CHARINDEX(',', s.guardianemail) > 0 THEN LEFT(CONVERT(NVARCHAR,s.guardianemail), (CHARINDEX(',', s.guardianemail) - 1))
          ELSE s.guardianemail
         END AS guardianemail
  FROM KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)
  WHERE s.enroll_status = 0
    AND s.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND s.schoolid in (133570965,73252)
    AND s.rn = 1
 )

,gr_wide AS (
  SELECT student_number
        ,schoolid
        ,rc1_Y1 AS readingY1
        ,rc2_Y1 AS writingY1
        ,rc3_Y1 AS mathY1
        ,rc4_Y1 AS scienceY1
        ,rc5_Y1 AS socialY1
        ,rc1_T1 AS readingT1
        ,rc2_T1 AS writingT1
        ,rc3_T1 AS mathT1
        ,rc4_T1 AS scienceT1
        ,rc5_T1 AS socialT1
        ,rc1_T2 AS readingT2
        ,rc2_T2 AS writingT2
        ,rc3_T2 AS mathT2
        ,rc4_T2 AS scienceT2
        ,rc5_T2 AS socialT2
        ,rc1_T3 AS readingT3
        ,rc2_T3 AS writingT3
        ,rc3_T3 AS mathT3
        ,rc4_T3 AS scienceT3
        ,rc5_T3 AS socialT3
        ,CASE 
          WHEN schoolid = 133570965 THEN
           CASE WHEN rc1_Y1 < 68 THEN 1 ELSE 0 END
            + CASE WHEN rc2_y1 < 68 THEN 1 ELSE 0 END
            + CASE WHEN rc3_y1 < 68 THEN 1 ELSE 0 END
            + CASE WHEN rc4_y1 < 68 THEN 1 ELSE 0 END
            + CASE WHEN rc5_y1 < 68 THEN 1 ELSE 0 END
          WHEN schoolid = 73252 THEN 
           CASE WHEN rc1_Y1 < 65 THEN 1 ELSE 0 END
            + CASE WHEN rc2_y1 < 65 THEN 1 ELSE 0 END
            + CASE WHEN rc3_y1 < 65 THEN 1 ELSE 0 END
            + CASE WHEN rc4_y1 < 65 THEN 1 ELSE 0 END
            + CASE WHEN rc5_y1 < 65 THEN 1 ELSE 0 END
         END AS n_failing
        ,CASE
          WHEN schoolid = 73252 AND (rc1_Y1 < 65
                                     OR rc2_Y1 < 65
                                     OR rc3_Y1 < 65 
                                     OR rc4_Y1 < 65
                                     OR rc5_Y1 < 65) THEN 1 
          
          WHEN schoolid = 133570965 AND (rc1_Y1 < 68
                                         OR rc2_Y1 < 68
                                         OR rc3_Y1 < 68
                                         OR rc4_Y1 < 68
                                         OR rc5_Y1 < 68) THEN 1 
          ELSE 0 
         END AS is_failing         
  FROM KIPP_NJ..GRADES$wide_credit_core#MS#static WITH(NOLOCK)
 )

,att_status AS (
  SELECT student_number
        ,Y1_att_pts_pct
        ,promo_att_rise
        ,promo_att_team
        ,days_to_90
  FROM REPORTING$promo_status#MS WITH(NOLOCK)
 )

,Y1_avg AS (
  SELECT student_number
        ,ROUND(AVG(Y1),0) AS yaverage
        ,SUM(CASE WHEN Y1 < 65 THEN 1 ELSE 0 END) AS n_failing
        ,CASE WHEN SUM(CASE WHEN Y1 < 65 THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS is_failing
  FROM
      (
       SELECT student_number
             ,course_number
             ,Y1
       FROM GRADES$DETAIL#MS WITH(NOLOCK)
       WHERE credittype IN ('MATH','ENG','SCI','SOC','RHET')
      ) sub
  GROUP BY student_number
 )

,homework AS (  
  SELECT studentid
        ,simple_avg AS H_avg        
        ,CASE
          WHEN ((65 * 3) - (ISNULL(grade_1,65) + ISNULL(grade_2,65))) < 65 THEN 65
          WHEN ((65 * 3) - (ISNULL(grade_1,65) + ISNULL(grade_2,65))) >= 65 THEN ((65 * 3) - (ISNULL(grade_1,65) + ISNULL(grade_2,65)))          
         END AS hw_need_c
  FROM GRADES$elements WITH(NOLOCK)
  WHERE schoolid IN (73252, 133570965)
    AND pgf_type = 'H'
    AND course_number = 'all_courses'
 )
 
,need_c AS ( 
  SELECT student_number
        ,[mathneed]
        ,[readneed]
        ,[scienceneed]
        ,[socialneed]
        ,[writingneed]
  FROM
      ( 
       SELECT student_number
             ,credittype + 'need' AS credittype
             ,CASE
               WHEN ROUND((((used_year + 1) * 65) - (in_the_books * used_year)) / 1,1) < 65 THEN 65
               WHEN ROUND((((used_year + 1) * 65) - (in_the_books * used_year)) / 1,1) > 100 THEN 100
               WHEN ROUND((((used_year + 1) * 65) - (in_the_books * used_year)) / 1,1) >= 65 THEN ROUND((((used_year + 1) * 65) - (in_the_books * used_year)) / 1,1)               
               ELSE NULL
              END AS need_c
       FROM
           (
            SELECT student_number
                  ,schoolid
                  ,CASE
                    WHEN CREDITTYPE = 'ENG' THEN 'READ'
                    WHEN CREDITTYPE = 'RHET' THEN 'WRITING'
                    WHEN CREDITTYPE = 'SCI' THEN 'SCIENCE'
                    WHEN CREDITTYPE = 'SOC' THEN 'SOCIAL'
                    WHEN CREDITTYPE = 'MATH' THEN 'MATH'
                   END AS credittype
                  ,CASE WHEN T1 IS NULL THEN 0 ELSE 1 END
                    + CASE WHEN T2 IS NULL THEN 0 ELSE 1 END
                    AS used_year
                  ,ROUND((T1 + T2) / 2,0) AS in_the_books
            FROM GRADES$DETAIL#MS WITH(NOLOCK)
            WHERE credittype IN ('MATH','ENG','SCI','SOC','RHET')
           ) sub
      ) sub2
   
  PIVOT(
    MAX(need_c)
    FOR credittype in ([mathneed]
                      ,[readneed]
                      ,[scienceneed]
                      ,[socialneed]
                      ,[writingneed])
   ) p
 )

,fp AS (
  SELECT student_number
        ,read_lvl AS fp
        ,gleq AS fp_gleq
        ,met_goal
  FROM LIT$all_test_events#identifiers#static WITH(NOLOCK)
  WHERE achv_curr_all = 1
    AND schoolid in (133570965, 73252)
 )

SELECT roster.*
      ,att_status.Y1_att_pts_pct
      ,CASE
        WHEN roster.schoolid = 73252 THEN att_status.promo_att_rise
        WHEN roster.schoolid = 133570965 THEN att_status.promo_att_team
       END AS promo_status_att
      ,att_status.days_to_90 AS days_to_perfect
      ,fp.fp
      ,fp.fp_gleq
      ,fp.met_goal AS fp_met_goal
      ,Y1_avg.yaverage
      ,y1_avg.n_failing
      ,y1_avg.is_failing
      ,gr_wide.readingY1
      ,gr_wide.writingY1
      ,gr_wide.mathY1
      ,gr_wide.scienceY1
      ,gr_wide.socialY1
      ,gr_wide.readingT1
      ,gr_wide.writingT1
      ,gr_wide.mathT1
      ,gr_wide.scienceT1
      ,gr_wide.socialT1
      ,gr_wide.readingT2
      ,gr_wide.writingT2
      ,gr_wide.mathT2
      ,gr_wide.scienceT2
      ,gr_wide.socialT2
      ,gr_wide.readingT3
      ,gr_wide.writingT3
      ,gr_wide.mathT3
      ,gr_wide.scienceT3
      ,gr_wide.socialT3
      ,need_c.mathneed
      ,need_c.readneed
      ,need_c.writingneed
      ,need_c.scienceneed
      ,need_c.socialneed
      ,homework.hw_need_c
      ,homework.H_avg
FROM roster
LEFT OUTER JOIN att_status
  ON roster.student_number = att_status.student_number 
LEFT OUTER JOIN fp
  ON roster.student_number = fp.student_number
LEFT OUTER JOIN Y1_avg
  ON roster.student_number = Y1_avg.student_number
LEFT OUTER JOIN gr_wide
  ON roster.student_number = gr_wide.student_number
LEFT OUTER JOIN need_c
  ON roster.student_number = need_c.student_number
LEFT OUTER JOIN homework
  ON roster.studentid = homework.studentid  