USE KIPP_NJ
GO

ALTER VIEW GRADES$asmt_scores_category_long AS

WITH reporting_weeks AS (
  SELECT week
        ,weekday_start
  FROM UTIL$reporting_weeks_days WITH(NOLOCK)
  WHERE academic_year = dbo.fn_Global_Academic_Year()
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
      ,scores.student_number      
      ,CONVERT(FLOAT,ROUND((scores.score / asmt.pointspossible) * 100,0)) AS pct      
FROM SECTIONS sec WITH(NOLOCK)
JOIN PS$category_weighting_setup#static cat WITH(NOLOCK)
  ON sec.DCID = cat.SECTIONSDCID
 AND ((sec.SCHOOLID = 73253 AND cat.finalgradename NOT LIKE 'Q%' AND cat.finalgradename NOT LIKE 'T%' AND cat.finalgradename NOT LIKE 'E%')
       OR sec.SCHOOLID != 73253 AND cat.FINALGRADENAME LIKE 'T%')
JOIN reporting_weeks rw WITH(NOLOCK)
  ON cat.STARTDATE <= rw.weekday_start
 AND cat.ENDDATE >= rw.weekday_start 
LEFT OUTER JOIN GRADES$assignments#STAGING asmt WITH(NOLOCK)
  ON cat.psm_sectionid = asmt.psm_sectionid
 AND cat.abbreviation = asmt.category
 AND rw.week = DATEPART(WEEK,asmt.assign_date)
 AND asmt.pointspossible > 0
 --AND cat.startdate <= asmt.assign_date
 --AND cat.enddate >= asmt.assign_date 
LEFT OUTER JOIN GRADES$assignment_scores#STAGING scores WITH(NOLOCK)
  ON asmt.assignmentid = scores.assignmentid
 AND scores.exempt != 1
WHERE sec.TERMID >= dbo.fn_Global_Term_Id()