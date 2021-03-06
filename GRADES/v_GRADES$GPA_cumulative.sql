USE KIPP_NJ
GO

ALTER VIEW GRADES$GPA_cumulative AS

SELECT studentid
      ,schoolid
      
      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),(weighted_points / credit_hours)), 2)) AS cumulative_Y1_gpa
      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),(unweighted_points / credit_hours)), 2)) AS cumulative_Y1_gpa_unweighted
      ,earned_credits_cum      
      ,potential_credits_cum

      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),(weighted_points_projected / credit_hours_projected)), 2)) AS cumulative_Y1_gpa_projected
      ,earned_credits_cum_projected

      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),(weighted_points_projected_s1 / credit_hours_projected_s1)), 2)) AS cumulative_Y1_gpa_projected_s1
      ,earned_credits_cum_projected_s1
FROM
    (
     SELECT studentid AS studentid
           ,schoolid AS schoolid
           
           ,ROUND(SUM(CONVERT(FLOAT,weighted_points)),3) AS weighted_points
           ,ROUND(SUM(CONVERT(FLOAT,unweighted_points)),3) AS unweighted_points
           ,CASE WHEN SUM(CONVERT(FLOAT,potentialcrhrs)) = 0 THEN NULL ELSE SUM(CONVERT(FLOAT,potentialcrhrs)) END AS credit_hours
           ,SUM(earnedcrhrs) AS earned_credits_cum            
           ,SUM(CASE WHEN academic_year < KIPP_NJ.dbo.fn_Global_Academic_Year() THEN earnedcrhrs ELSE potentialcrhrs END) AS potential_credits_cum            

           ,ROUND(SUM(CONVERT(FLOAT,weighted_points_projected)),3) AS weighted_points_projected
           ,CASE WHEN SUM(CONVERT(FLOAT,potentialcrhrs_projected)) = 0 THEN NULL ELSE SUM(CONVERT(FLOAT,potentialcrhrs_projected)) END AS credit_hours_projected
           ,SUM(earnedcrhrs_projected) AS earned_credits_cum_projected

           ,ROUND(SUM(CONVERT(FLOAT,weighted_points_projected_s1)),3) AS weighted_points_projected_s1
           ,CASE WHEN SUM(CONVERT(FLOAT,potentialcrhrs_projected_s1)) = 0 THEN NULL ELSE SUM(CONVERT(FLOAT,potentialcrhrs_projected_s1)) END AS credit_hours_projected_s1
           ,SUM(earnedcrhrs_projected_s1) AS earned_credits_cum_projected_s1
     FROM 
         (
          SELECT sg.studentid                
                ,sg.academic_year
                ,sg.schoolid                   
                ,sg.COURSE_NUMBER
                ,sg.potentialcrhrs                   
                ,sg.earnedcrhrs                   
                ,(sg.potentialcrhrs * sg.gpa_points) AS weighted_points
                ,(sg.potentialcrhrs * scale_unweighted.grade_points) AS unweighted_points
                
                ,sg.potentialcrhrs AS potentialcrhrs_projected
                ,sg.earnedcrhrs AS earnedcrhrs_projected
                ,(sg.potentialcrhrs * sg.gpa_points) AS weighted_points_projected

                ,sg.potentialcrhrs AS potentialcrhrs_projected_s1
                ,sg.earnedcrhrs AS earnedcrhrs_projected_s1
                ,(sg.potentialcrhrs * sg.gpa_points) AS weighted_points_projected_s1
          FROM KIPP_NJ..GRADES$STOREDGRADES#static sg WITH(NOLOCK)          
          LEFT OUTER JOIN KIPP_NJ..GRADES$grade_scales#static scale_unweighted WITH(NOLOCK)
            ON sg.[percent] >= scale_unweighted.low_cut
           AND sg.[percent] < scale_unweighted.high_cut
           AND CASE
                WHEN sg.schoolid != 73253 THEN sg.GRADESCALE_NAME
                WHEN sg.academic_year <= 2015 THEN 'NCA 2011' /* default pre-2016 */
                WHEN sg.academic_year >= 2016 THEN 'KIPP NJ 2016 (5-12)' /* default 2016+ */
               END = scale_unweighted.scale_name
          WHERE sg.storecode = 'Y1'
            AND sg.excludefromgpa = 0
          
          UNION ALL

          SELECT gr.studentid
                ,gr.academic_year
                ,gr.schoolid
                ,gr.course_number
                ,NULL AS potentialcrhrs
                ,NULL AS earnedcrhrs
                ,NULL AS weighted_points
                ,NULL AS unweighted_points
                
                ,gr.credit_hours AS potentialcrhrs_projected
                ,CASE WHEN gr.y1_grade_letter NOT LIKE 'F%' THEN gr.credit_hours ELSE 0 END AS earnedcrhrs_projected
                ,(gr.credit_hours * gr.y1_gpa_points) AS weighted_points_projected

                ,NULL AS potentialcrhrs_projected_s1
                ,NULL AS earnedcrhrs_projected_s1
                ,NULL AS weighted_points_projected_s1
          FROM KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK) 
          LEFT OUTER JOIN KIPP_NJ..GRADES$STOREDGRADES#static sg WITH(NOLOCK)
             ON gr.studentid = sg.STUDENTID
            AND gr.course_number = sg.COURSE_NUMBER
            AND gr.academic_year = sg.academic_year
            AND sg.STORECODE = 'Y1'           
          WHERE gr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
            AND gr.is_curterm = 1
            AND gr.excludefromgpa = 0
            AND sg.STUDENTID IS NULL

          UNION ALL

          SELECT gr.studentid
                ,gr.academic_year
                ,gr.schoolid
                ,gr.course_number
                ,NULL AS potentialcrhrs
                ,NULL AS earnedcrhrs
                ,NULL AS weighted_points
                ,NULL AS unweighted_points
                
                ,NULL AS potentialcrhrs_projected
                ,NULL AS earnedcrhrs_projected
                ,NULL AS weighted_points_projected

                ,gr.credit_hours AS potentialcrhrs_projected_s1
                ,CASE WHEN gr.y1_grade_letter NOT LIKE 'F%' THEN gr.credit_hours ELSE 0 END AS earnedcrhrs_projected_s1
                ,(gr.credit_hours * gr.y1_gpa_points) AS weighted_points_projected_s1
          FROM KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK) 
          LEFT OUTER JOIN KIPP_NJ..GRADES$STOREDGRADES#static sg WITH(NOLOCK)
            ON gr.studentid = sg.STUDENTID
           AND gr.course_number = sg.COURSE_NUMBER
           AND gr.academic_year = sg.academic_year
           AND sg.STORECODE = 'Y1'           
          WHERE gr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
            AND gr.term = 'Q2'
            AND gr.excludefromgpa = 0
            AND sg.STUDENTID IS NULL
         ) sub
     GROUP BY studentid, schoolid
    ) sub