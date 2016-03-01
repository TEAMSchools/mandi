USE KIPP_NJ
GO

ALTER VIEW GRADES$asmt_scores_category_long AS

WITH reporting_weeks AS (
  SELECT week
        ,weekday_start
  FROM KIPP_NJ..UTIL$reporting_weeks_days#static WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

SELECT sec.SCHOOLID
      ,sec.id AS sectionid           
      ,LEFT(cat.FINALGRADENAME,1) AS finalgrade
      ,CONVERT(FLOAT,cat.WEIGHTING) AS fg_weighting
      ,cat.ABBREVIATION AS category      
      ,rw.week
      ,asmt.ASSIGNMENTID
      ,CONVERT(DATE,asmt.assign_date) AS assign_date      
      ,asmt.assign_name      
      ,scores.STUDENTIDENTIFIER AS student_number      
      ,CONVERT(FLOAT,ROUND((scores.score / asmt.pointspossible) * 100,0)) AS pct      
FROM KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
JOIN KIPP_NJ..PS$category_weighting_setup#static cat WITH(NOLOCK)
  ON sec.DCID = cat.SECTIONSDCID
 AND ((sec.SCHOOLID = 73253 AND cat.finalgradename NOT LIKE 'Q%' AND cat.finalgradename NOT LIKE 'T%' AND cat.finalgradename NOT LIKE 'E%')
       OR sec.SCHOOLID != 73253 AND cat.FINALGRADENAME LIKE 'T%')
JOIN reporting_weeks rw WITH(NOLOCK)
  ON cat.STARTDATE <= rw.weekday_start
 AND cat.ENDDATE >= rw.weekday_start 
LEFT OUTER JOIN KIPP_NJ..GRADES$assignments#STAGING asmt WITH(NOLOCK)
  ON cat.psm_sectionid = asmt.psm_sectionid
 AND cat.abbreviation = asmt.category
 AND rw.week = DATEPART(WEEK,asmt.assign_date)
 AND asmt.pointspossible > 0
 --AND cat.startdate <= asmt.assign_date
 --AND cat.enddate >= asmt.assign_date 
LEFT OUTER JOIN KIPP_NJ..GRADES$assignment_scores#STAGING scores WITH(NOLOCK)
  ON asmt.assignmentid = scores.assignmentid
 AND scores.exempt != 1
WHERE sec.TERMID >= KIPP_NJ.dbo.fn_Global_Term_Id()