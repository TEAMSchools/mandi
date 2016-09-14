USE KIPP_NJ
GO

ALTER VIEW GRADES$grade_scales AS

WITH ps_style AS (
  SELECT *
  FROM OPENQUERY(PS_TEAM,'
    WITH base AS (
      SELECT DCID
            ,ID
            ,NAME
            ,DESCRIPTION
      FROM GRADESCALEITEM
      WHERE GRADESCALEID = -1        
     ) 

    SELECT BASE.*
          ,ENTRIES.NAME AS LETTER_GRADE
          ,ENTRIES.CUTOFFPERCENTAGE
          ,ENTRIES.GRADE_POINTS
    FROM BASE
    JOIN GRADESCALEITEM ENTRIES
      ON BASE.ID = ENTRIES.GRADESCALEID
    ORDER BY ENTRIES.CUTOFFPERCENTAGE ASC
  ')
 )

SELECT sub.dcid
      ,sub.id AS scale_id
      ,sub.name AS scale_name
      ,CONVERT(VARCHAR,sub.description) AS description
      ,sub.letter_grade
      ,sub.grade_points
      ,sub.low_cut
      ,CASE WHEN sub.low_cut > 90 AND sub.high_cut IS NULL THEN 1000 ELSE sub.high_cut END AS high_cut
FROM
    (
     SELECT base.dcid
           ,base.id
           ,base.name
           ,base.description
           ,base.letter_grade
           ,base.grade_points
           ,base.cutoffpercentage AS low_cut
           ,high.cutoffpercentage AS high_cut
           ,ROW_NUMBER() OVER(
              PARTITION BY base.id, base.cutoffpercentage
                ORDER BY high.cutoffpercentage ASC) AS rn
     FROM ps_style base WITH(NOLOCK)
     LEFT OUTER JOIN ps_style high WITH(NOLOCK)
       ON base.id = high.id
      AND base.cutoffpercentage < high.cutoffpercentage
    ) sub
WHERE rn = 1