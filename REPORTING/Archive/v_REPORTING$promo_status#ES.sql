USE KIPP_NJ
GO

ALTER VIEW REPORTING$promo_status#ES AS
WITH scaffold AS
    (SELECT c.studentid
           ,s.student_number
           ,c.grade_level
           ,c.schoolid
           ,sch.abbreviation AS school
           ,c.year
           ,CAST(c.entrydate AS date) AS entrydate
           ,CAST(c.exitdate AS date) AS exitdate
           ,CAST(rd.date AS DATE) AS date
           ,CAST(DATEPART(month, rd.date) AS VARCHAR) + '/' + CAST(DATEPART(day, rd.date) AS VARCHAR) AS date_no_year
     FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH (NOLOCK)
     JOIN KIPP_NJ..SCHOOLS sch WITH (NOLOCK)
       ON c.schoolid = sch.school_number
     JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
       ON c.studentid = s.id
     JOIN KIPP_NJ..UTIL$reporting_days#static rd WITH (NOLOCK)
       ON rd.date >= c.entrydate
      AND rd.date <  c.exitdate
      --no sundays or saturdays
      AND rd.dw_numeric != 7
      AND rd.dw_numeric != 1
      AND rd.date <= CAST(GETDATE() AS date)
     WHERE c.schoolid IN (73254, 73255, 73256, 73257, 179901)
       AND c.year = dbo.fn_Global_Academic_Year()
       AND c.rn = 1
       --testing
       --AND c.studentid = 2859
       --AND CAST(rd.date AS date) <= '10/15/2013'
     )

    ,criteria AS
    (SELECT 'RT2' AS valid_for
           ,0 AS grade_level
           ,1 AS step_std
           ,-1 AS fp_std 
           ,9 AS att_std
     UNION ALL
     SELECT 'RT2'
           ,1
           ,5
           ,-1
           ,8
     UNION ALL
     SELECT 'RT2'
           ,2
           ,8
           ,-1
           ,8
     UNION ALL
     SELECT 'RT2'
           ,3
           ,11
           ,15
           ,8
     UNION ALL
     SELECT 'RT2'
           ,4
           ,12
           ,19
           ,8
    )

   ,term_disambig AS
   (SELECT rd.schoolid
          ,rd.start_date
          ,rd.end_date
          ,rd.time_per_name
    FROM KIPP_NJ..REPORTING$dates rd WITH(NOLOCK)
    WHERE rd.yearid = LEFT(dbo.fn_Global_Term_Id(),2)
      AND rd.identifier = 'RT'
      AND rd.time_hierarchy = 2
   )

   ,step AS
   (SELECT sub.*
    FROM
          (SELECT c.studentid
                 ,CAST(rd.date AS date) AS date
                 ,step.read_lvl AS step_level
                 ,step.lvl_num AS step_numeric
                 ,ROW_NUMBER() OVER
                    (PARTITION BY c.studentid
                                 ,CAST(rd.date AS date)
                     ORDER BY CAST(step.test_date AS date) DESC
                             ,step.lvl_num DESC
                     ) AS rn
           FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH(NOLOCK)
           JOIN KIPP_NJ..UTIL$reporting_days#static rd WITH (NOLOCK)
             ON rd.date >= c.entrydate
            AND rd.date <  c.exitdate
            AND rd.date <= CAST(GETDATE() AS date)   
            --AND rd.date = CAST(GETDATE() AS date)
           JOIN KIPP_NJ..LIT$test_events#identifiers step WITH(NOLOCK)
             ON c.studentid = step.studentid
            AND step.status = 'Achieved'
            AND step.test_date >= '08/01/2013'
            AND CAST(step.test_date AS date) <= CAST(rd.date AS date) 
           WHERE c.year = dbo.fn_Global_Academic_Year()
             AND c.rn = 1
             AND c.schoolid IN (73254, 73255, 73256)
             --AND c.studentid = 2859
           ) sub
    WHERE rn = 1
    )

   ,math_ua AS
   (SELECT studentid
          ,date
          ,time_per_name
          ,AVG(percent_correct) AS unit_assess_avg
    FROM     
          (SELECT c.studentid
                 ,CAST(rd.date AS date) AS date
                 ,assess_ov.percent_correct
                 ,assess.title
                 ,rt.time_per_name
           FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH(NOLOCK)
           JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
             ON c.studentid = s.id
           JOIN KIPP_NJ..UTIL$reporting_days#static rd WITH (NOLOCK)
             ON rd.date >= c.entrydate
            AND rd.date <= c.exitdate
            AND rd.date <= CAST(GETDATE() AS date)
            AND c.year = dbo.fn_Global_Academic_Year()
            AND c.rn = 1
            --testing
            --AND c.studentid = 2859
            --AND rd.date <= '10-15-2013'
           JOIN KIPP_NJ..ILLUMINATE$assessment_results_overall#static assess_ov  WITH(NOLOCK)
             ON s.student_number = assess_ov.student_number
            AND assess_ov.date_taken <= rd.date
            AND assess_ov.date_taken >= c.entrydate
           JOIN
               (SELECT DISTINCT assessment_id
                      ,schoolid
                      ,subject
                      ,title
                FROM KIPP_NJ..ILLUMINATE$assessments#static s WITH(NOLOCK)
                WHERE s.subject = 'Mathematics'
                  AND s.title  LIKE '%UA%'
                  AND s.deleted_at IS NULL) assess
                  
             ON assess_ov.assessment_id = assess.assessment_id
           JOIN
               (SELECT rd.schoolid
                       ,rd.start_date
                       ,rd.end_date
                       ,rd.time_per_name
                 FROM KIPP_NJ..REPORTING$dates rd WITH(NOLOCK)
                 WHERE rd.yearid = LEFT(dbo.fn_Global_Term_Id(),2)
                   AND rd.identifier = 'RT'
                   AND rd.time_hierarchy = 2
                ) rt
             ON assess.schoolid = rt.schoolid
            AND assess_ov.date_taken >= rt.start_date
            AND assess_ov.date_taken <= rt.end_date
           ) sub
    GROUP BY studentid
            ,date
            ,time_per_name
    )

SELECT scaffold.*
      ,term_disambig.time_per_name
      ,criteria.step_std
      ,criteria.fp_std
      ,criteria.att_std
      ,step.step_numeric
      ,math_ua.unit_assess_avg
      ,att.att_points

       --OFF TRACK evaluators
      ,CASE
         WHEN step.step_numeric < criteria.step_std THEN 'Off Track'
         WHEN step.step_numeric >= criteria.step_std THEN 'On Track'
       END AS step_status
      ,CASE
         WHEN scaffold.grade_level = 3 AND math_ua.unit_assess_avg < 70 THEN 'Off Track'
         WHEN scaffold.grade_level = 3 AND math_ua.unit_assess_avg >= 70 THEN 'On Track'
       END AS math_ua_status
      ,CASE
         WHEN att.att_points >= criteria.att_std THEN 'Off Track'
         WHEN att.att_points <  criteria.att_std THEN 'On Track'
       END AS att_status
FROM scaffold
JOIN term_disambig
  ON scaffold.schoolid = term_disambig.schoolid
 AND scaffold.date >= term_disambig.start_date
 AND scaffold.date <= term_disambig.end_date
LEFT OUTER JOIN criteria
  ON scaffold.grade_level = criteria.grade_level
 AND term_disambig.time_per_name = criteria.valid_for
JOIN step
  ON scaffold.studentid = step.studentid
 AND scaffold.date = step.date
LEFT OUTER JOIN math_ua
  ON scaffold.studentid = math_ua.studentid
 AND scaffold.date = math_ua.date
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$att_percentages#time_series#static att WITH(NOLOCK)
  ON CAST(scaffold.studentid AS int) = CAST(att.studentid AS int)
 AND CAST(scaffold.date AS date) = CAST(att.date_value AS date)