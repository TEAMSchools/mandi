WITH scaffold AS (
  SELECT subject
        ,MAX(raw_score) AS max_raw_score
  FROM KIPP_NJ..AUTOLOAD$GDOCS_ACT_key_cleanup WITH(NOLOCK)
  GROUP BY subject
  UNION ALL
  SELECT subject
        ,max_raw_score - 1 
  FROM scaffold 
  WHERE max_raw_score > 0
)

SELECT 2016 AS academic_year /* UPDATE */
      ,'Pre-Test' AS administration_round /* UPDATE */
      ,s.subject
      ,s.max_raw_score AS raw_score
      ,MAX(a.scale_score) OVER(PARTITION BY s.subject ORDER BY s.max_raw_score) AS scale_score
FROM scaffold s
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_ACT_key_cleanup a
  ON s.subject = a.subject
 AND s.max_raw_score = a.raw_score