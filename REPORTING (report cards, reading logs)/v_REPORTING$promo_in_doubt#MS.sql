USE KIPP_NJ
GO

ALTER VIEW REPORTING$promo_in_doubt#MS AS

WITH roster AS (
  SELECT s.student_number
        ,s.lastfirst
        ,s.grade_level
        ,s.team
        ,cs.advisor
        ,cs.advisor_cell
        ,cs.advisor_email
        ,s.last_name
        ,s.first_name
        ,CASE WHEN s.gender = 'm' THEN 'his' ELSE 'her' END AS pronoun
        ,s.schoolid
  FROM students s WITH(NOLOCK)
  LEFT OUTER JOIN custom_students cs WITH(NOLOCK)
    ON s.id = cs.studentid
  WHERE s.enroll_status = 0
    AND s.schoolid in (133570965,73252)
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
        ,CASE WHEN schoolid = 133570965 AND rc1_Y1 < 70 THEN 1 WHEN schoolid = 73252 AND rc1_Y1 < 65 THEN 1 ELSE 0 END
          + CASE WHEN schoolid = 133570965 AND rc2_y1 < 70 THEN 1 WHEN schoolid = 73252 AND rc2_y1 < 65 THEN 1 ELSE 0 END
          + CASE WHEN schoolid = 133570965 AND rc3_y1 < 70 THEN 1 WHEN schoolid = 73252 AND rc3_y1 < 65 THEN 1 ELSE 0 END
          + CASE WHEN schoolid = 133570965 AND rc4_y1 < 70 THEN 1 WHEN schoolid = 73252 AND rc4_y1 < 65 THEN 1 ELSE 0 END
          + CASE WHEN schoolid = 133570965 AND rc5_y1 < 70 THEN 1 WHEN schoolid = 73252 AND rc5_y1 < 65 THEN 1 ELSE 0 END
          AS n_failing
        ,CASE 
          WHEN schoolid = 133570965 AND (CASE WHEN rc1_Y1 < 70 THEN 1 ELSE 0 END
                                          + CASE WHEN rc2_Y1 < 70 THEN 1 ELSE 0 END
                                          + CASE WHEN rc3_Y1 < 70 THEN 1 ELSE 0 END
                                          + CASE WHEN rc4_Y1 < 70 THEN 1 ELSE 0 END
                                          + CASE WHEN rc5_Y1 < 70 THEN 1 ELSE 0 END) > 0 THEN 1 
          WHEN schoolid = 73252 AND (CASE WHEN rc1_Y1 < 65 THEN 1 ELSE 0 END
                                      + CASE WHEN rc2_Y1 < 65 THEN 1 ELSE 0 END
                                      + CASE WHEN rc3_Y1 < 65 THEN 1 ELSE 0 END
                                      + CASE WHEN rc4_Y1 < 65 THEN 1 ELSE 0 END
                                      + CASE WHEN rc5_Y1 < 65 THEN 1 ELSE 0 END) > 0 THEN 1 
          ELSE 0 
         END AS is_failing         
  FROM grades$wide_credit_core#ms WITH(NOLOCK)
 )

,att_status AS (
  SELECT student_number
        ,Y1_att_pts_pct
        ,promo_status_att
  FROM reporting$promo_status#team WITH(NOLOCK)

  UNION ALL

  SELECT student_number
        ,Y1_att_pts_pct
        ,promo_status_att
  FROM reporting$promo_status#rise WITH(NOLOCK)
 )

,Y1_avg AS (
  SELECT *
  FROM
      (
       SELECT student_number
             ,ROUND(AVG(Y1),0) AS yaverage
             ,SUM(CASE WHEN Y1 < 70 THEN 1 ELSE 0 END) AS n_failing
       FROM
           (
            SELECT student_number
                  ,course_number
                  ,Y1
            FROM grades$detail#ms WITH(NOLOCK)
            WHERE credittype in ('math','eng','sci','soc','rhet')
           ) sub
       GROUP BY student_number
      ) sub
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
               WHEN schoolid = 73252 AND ROUND((((used_year + 1) * 65) - (in_the_books * used_year)) / 1,1) < 65 THEN 65
               WHEN schoolid = 73252 AND ROUND((((used_year + 1) * 65) - (in_the_books * used_year)) / 1,1) >= 65 THEN ROUND((((used_year + 1) * 65) - (in_the_books * used_year)) / 1,1)
               WHEN schoolid = 133570965 AND ROUND((((used_year + 1) * 70) - (in_the_books * used_year)) / 1,1) < 70 THEN 70
               WHEN schoolid = 133570965 AND ROUND((((used_year + 1) * 70) - (in_the_books * used_year)) / 1,1) >= 70 THEN ROUND((((used_year + 1) * 70) - (in_the_books * used_year)) / 1,1)
               ELSE NULL
              END AS need_c
       FROM
           (
            SELECT student_number
                  ,schoolid
                  ,CASE
                    WHEN credittype = 'eng' THEN 'read'
                    WHEN credittype = 'rhet' THEN 'writing'
                    WHEN credittype = 'sci' THEN 'science'
                    WHEN credittype = 'soc' THEN 'social'
                    WHEN credittype = 'math' THEN 'math'
                   END AS credittype
                  ,CASE WHEN T1 is NULL THEN 0 ELSE 1 END 
                    + CASE WHEN T2 is NULL THEN 0 ELSE 1 END 
                    + CASE WHEN T3 is NULL THEN 0 ELSE 1 END
                    AS used_year
                  ,Y1 AS in_the_books
            FROM grades$detail#ms WITH(NOLOCK)
            WHERE credittype in ('math','eng','sci','soc','rhet')
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
        ,letter_level AS fp
        ,gleq AS fp_gleq
  FROM lit$fp_test_events_long#identifiers#static WITH(NOLOCK)
  WHERE achv_curr_all = 1
    AND schoolid in (133570965, 73252)
 )

SELECT roster.*
      ,att_status.Y1_att_pts_pct
      ,att_status.promo_status_att
      ,fp.fp
      ,fp.fp_gleq
      ,Y1_avg.yaverage
      ,Y1_avg.n_failing
      ,gr_wide.is_failing
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