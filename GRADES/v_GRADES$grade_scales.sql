USE KIPP_NJ
GO

ALTER VIEW GRADES$grade_scales AS
WITH ps_style AS
    (SELECT *
     FROM OPENQUERY(PS_TEAM, '
       WITH base AS
          (SELECT id
                 ,name
                 ,description
           FROM gradescaleitem
           WHERE gradescaleid = -1
             AND NAME IN (''NCA 2011'', ''Default'', ''TEAM Academy 2010'',''NCA Honors'')
          ) 

       SELECT base.*
             ,entries.name AS letter_grade
             ,entries.cutoffpercentage
             ,entries.grade_points
       FROM base
       JOIN gradescaleitem entries
         ON base.ID = entries.gradescaleid
       ORDER BY entries.cutoffpercentage ASC
     ')
     )

SELECT sub.id AS scale_id
      ,sub.name AS scale_name
      ,CAST(sub.description AS VARCHAR) AS description
      ,sub.letter_grade
      ,sub.grade_points
      ,sub.low_cut
      ,CASE 
         WHEN sub.low_cut > 90 AND sub.high_cut IS NULL THEN 1000
         ELSE sub.high_cut
       END AS high_cut
FROM
  (SELECT base.id
         ,base.name
         ,base.description
         ,base.letter_grade
         ,base.grade_points
         ,base.cutoffpercentage AS low_cut
         ,high.cutoffpercentage AS high_cut
         ,ROW_NUMBER() OVER
            (PARTITION BY base.id
                         ,base.cutoffpercentage
             ORDER BY high.cutoffpercentage ASC) AS rn
   FROM ps_style base
   LEFT OUTER JOIN ps_style high
     ON base.id = high.id
    AND base.cutoffpercentage < high.cutoffpercentage
   ) sub
WHERE rn = 1
--ORDER BY scale_name
--        ,low_cut ASC