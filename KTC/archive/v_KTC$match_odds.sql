USE KIPP_NJ
GO
CREATE VIEW KTC$match_odds AS
WITH colleges AS (
  SELECT a.Id AS college_id
        ,a.Name AS college_name
        ,a.Type
         --use estimated ACT when ACT25 not reported
        ,CASE
           WHEN a.ACT25__c IS NULL THEN concord.ACT
           ELSE a.ACT25__c
         END AS act25
        ,ROUND((a.SATmath25__c + a.SATread25__c), -1) AS sat25
        ,CASE
           --model has a 'Most Competitive+' but Barron's does not.  Treat top 40 as +
           WHEN a.Competitiveness_Index__c >= 2.16 THEN 'Most Competitive+'
           --merge '2 year (Noncompetiti'	and '2 year (Competitive)'
           WHEN a.Competitiveness_Index__c LIKE '2 year%' THEN '2 year'
           --scrub the * from end of strings
           ELSE REPLACE(Competitiveness_Ranking__c, '*', '')
         END AS competitiveness_ranking
        ,a.Competitiveness_Index__c AS competitiveness_index
        ,a.BillingCity AS city
        ,a.BillingState AS state
        ,a.Website
        ,a.College_Navigator_Link__c AS nces_link
        ,a.NCESid__c AS ncesid
        ,a.Geographic_Region__c AS region
        ,a.KIPP_Acceptance_Rate__c AS kipp_acceptance_rate
        ,a.KIPP_Matriculation_Rate__c AS kipp_matriculation_rate
        ,a.Total_KIPP_Applications__c AS kipp_applications
        ,a.Total_KIPP_Acceptances__c AS total_kipp_applications
        ,a.X6_yr_minority_completion_rate__c AS minority_completion_rate_6yr
  FROM [AlumniMirror].[dbo].Account a WITH(NOLOCK)
  JOIN [AlumniMirror].[dbo].RecordType rt WITH(NOLOCK)
    ON a.RecordTypeId = rt.Id
  LEFT OUTER JOIN [KIPP_NJ].[dbo].[KTC$act_sat_concordance#dense] concord WITH(NOLOCK)
    --rount to nearest 10
    ON ROUND((a.SATmath25__c + a.SATread25__c), -1) = concord.SAT
  WHERE rt.Name = 'College'
    AND (Total_KIPP_Applications__c > 0 OR Metro_Area__c IN ('NYC', 'Philadelphia', 'Newark'))
    AND a.Competitiveness_Index__c IS NOT NULL
    AND a.Competitiveness_Ranking__c != 'Not Available'
    AND a.Competitiveness_Ranking__c IS NOT NULL  
  ),
  app_count AS
 (SELECT app.applied_to_id AS school_id,
         COUNT(*) AS n
  FROM AlumniMirror..vwApp_Detail app WITH(NOLOCK)
  WHERE applied_dummy = 1
  GROUP BY app.applied_to_id
  ),
  ranking AS
 (SELECT a.school_id,
         a.n,
         ROW_NUMBER() OVER (ORDER BY a.n DESC) AS rank
  FROM app_count a
 ),
  top_n AS
  (SELECT ranking.*,
          colleges.*
   FROM ranking
   JOIN colleges
     ON ranking.school_id = colleges.college_id
   WHERE ranking.rank < 75),
  stu_roster AS
  (SELECT m.*,
          top_n.*
   FROM top_n
   JOIN KIPP_NJ..KTC$match_data m
     ON  1=1
  ),
  with_coef AS
 (SELECT stu_roster.*,
        coef.intercept
        --gpa term
         + (coef.gpa_coef * stu_roster.gpa) 
        --act term
         + (coef.act_coef * (stu_roster.best_any_act - stu_roster.act25)) AS logit
 FROM stu_roster
 LEFT OUTER JOIN KIPP_NJ..KTC$match_coefficients coef
   ON stu_roster.competitiveness_ranking = coef.ranking_name
 ),
 odds AS (
   SELECT w.lastfirst,
          w.studentid,
          w.cur_grade,
          w.gpa,
          w.best_any_act AS act,
          w.college_name,
          w.state,
          w.region,
          w.ncesid,
          w.kipp_acceptance_rate,
          w.kipp_matriculation_rate,
          w.minority_completion_rate_6yr AS minor_grad,
          w.act25,
          ROUND(100 * (EXP(logit)) / (1 + EXP(logit)),0) AS admit_odds,
          ROUND(logit, 3) AS logit  
  FROM with_coef w
)
SELECT TOP 100000000000 *
FROM odds
ORDER BY cur_grade, lastfirst, college_name

