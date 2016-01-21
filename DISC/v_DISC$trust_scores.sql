USE KIPP_NJ
GO

ALTER VIEW DISC$trust_scores AS

SELECT student_number      
      ,KIPP_NJ.dbo.fn_Global_Academic_Year() AS academic_year
      ,UPPER(RIGHT(field, 2)) AS term
      ,LEFT(KIPP_NJ.dbo.fn_StripCharacters(field, '^0-9'), 1) AS rater_number      
      ,LEFT(field, CHARINDEX('_', field) - 1) AS domain      
      ,value AS score
FROM KIPP_NJ..AUTOLOAD$GDOCS_CULTURE_team_trust_roster WITH(NOLOCK)
UNPIVOT(
  value
  FOR field IN (independence_1_q1
               ,independence_1_q2
               ,independence_1_q3
               ,independence_1_q4
               ,independence_2_q1
               ,independence_2_q2
               ,independence_2_q3
               ,independence_2_q4
               ,independence_3_q1
               ,independence_3_q2
               ,independence_3_q3
               ,independence_3_q4
               ,independence_4_q1
               ,independence_4_q2
               ,independence_4_q3
               ,independence_4_q4
               ,independence_5_q1
               ,independence_5_q2
               ,independence_5_q3
               ,independence_5_q4
               ,independence_6_q1
               ,independence_6_q2
               ,independence_6_q3
               ,independence_6_q4
               ,independence_7_q1
               ,independence_7_q2
               ,independence_7_q3
               ,independence_7_q4
               ,independence_8_q1
               ,independence_8_q2
               ,independence_8_q3
               ,independence_8_q4
               ,responds_1_q1
               ,responds_1_q2
               ,responds_1_q3
               ,responds_1_q4
               ,responds_2_q1
               ,responds_2_q2
               ,responds_2_q3
               ,responds_2_q4
               ,responds_3_q1
               ,responds_3_q2
               ,responds_3_q3
               ,responds_3_q4
               ,responds_4_q1
               ,responds_4_q2
               ,responds_4_q3
               ,responds_4_q4
               ,responds_5_q1
               ,responds_5_q2
               ,responds_5_q3
               ,responds_5_q4
               ,responds_6_q1
               ,responds_6_q2
               ,responds_6_q3
               ,responds_6_q4
               ,responds_7_q1
               ,responds_7_q2
               ,responds_7_q3
               ,responds_7_q4
               ,responds_8_q1
               ,responds_8_q2
               ,responds_8_q3
               ,responds_8_q4)
 ) u