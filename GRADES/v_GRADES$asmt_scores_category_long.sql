USE KIPP_NJ
GO

ALTER VIEW GRADES$asmt_scores_category_long AS

SELECT asmt.sectionid      
      ,asmt.ASSIGNMENTID
      ,LEFT(finalgradename,1) AS finalgrade
      ,asmt.category
      ,DATEPART(WEEK,asmt.assign_date) AS week
      ,CONVERT(DATE,asmt.assign_date) AS assign_date
      ,asmt.assign_name      
      ,scores.student_number      
      ,CONVERT(FLOAT,ROUND((scores.score / asmt.pointspossible) * 100,0)) AS pct
FROM PS$category_weighting_setup#static cat WITH(NOLOCK)
JOIN GRADES$assignments#static asmt WITH(NOLOCK)
  ON cat.psm_sectionid = asmt.psm_sectionid
 AND cat.abbreviation = asmt.category
 AND cat.startdate <= asmt.assign_date
 AND cat.enddate >= asmt.assign_date
 AND asmt.pointspossible > 0
JOIN GRADES$assignment_scores#static scores WITH(NOLOCK)
  ON asmt.assignmentid = scores.assignmentid
 AND scores.exempt != 1
WHERE cat.finalgradename NOT LIKE 'Q%'
  AND cat.finalgradename NOT LIKE 'T%'
  AND cat.finalgradename NOT LIKE 'E%'