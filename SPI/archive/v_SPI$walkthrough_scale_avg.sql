USE SPI
GO

ALTER VIEW SPI$walkthrough_scale_avg AS

WITH prep AS (
  SELECT r.rubric
        ,r.element
        ,r.school
        ,r.round
        ,r.date
        ,r.rater
        ,r.score
        ,r.num_yes
        ,r.num_no        
        ,CASE 
          WHEN r.rubric = 'culture' THEN r.score
          WHEN (r.num_yes IS NULL AND r.num_no IS NULL) THEN r.score
          WHEN ISNULL(r.num_yes, 0.0) + ISNULL(r.num_no, 0.0) = 0.0 THEN 0.0
          WHEN (r.num_yes IS NOT NULL OR r.num_no IS NOT NULL) THEN CAST(r.num_yes / (r.num_yes + r.num_no) AS NUMERIC(4,2)) * 10
         END AS use_this
  FROM SPI..walkthrough$raw_long r WITH(NOLOCK)
 )

SELECT prep.school
      --,prep.round      
      ,prep.rubric
      ,unq.scale      
      ,prep.school + '_' + unq.scale AS reporting_hash
      ,CAST(AVG(use_this) AS NUMERIC(4,1)) AS scale_avg
FROM prep WITH(NOLOCK)
JOIN SPI..walkthrough$scales unq WITH(NOLOCK)
  ON prep.rubric = unq.rubric
 AND prep.element = unq.element
GROUP BY prep.school
        --,prep.round        
        ,prep.rubric
        ,unq.scale