USE KIPP_NJ
GO

ALTER VIEW LIT$dna_reasons AS

SELECT unique_id
      ,testid
      ,studentid      
      ,status
      ,dbo.GROUP_CONCAT_D(DISTINCT dna_reason, ' | ') AS dna_reason
FROM LIT$readingscores_long WITH(NOLOCK)
GROUP BY unique_id
        ,testid
        ,studentid
        ,read_lvl
        ,status