USE KIPP_NJ
GO

ALTER VIEW LIT$dna_reasons AS

SELECT unique_id
      ,testid
      ,studentid      
      ,dbo.GROUP_CONCAT_D(dna_reason, ' | ') AS dna_reason
FROM LIT$readingscores_long WITH(NOLOCK)
WHERE status = 'Did Not Achieve'
GROUP BY unique_id
        ,testid
        ,studentid
        ,read_lvl