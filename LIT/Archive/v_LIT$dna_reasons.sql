USE KIPP_NJ
GO

ALTER VIEW LIT$dna_reasons AS

SELECT unique_id
      ,testid
      ,studentid      
      ,status
      ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT dna_reason, ' | ') AS dna_reason
FROM KIPP_NJ..LIT$readingscores_long#static WITH(NOLOCK)
WHERE status IS NOT NULL
GROUP BY unique_id
        ,testid
        ,studentid
        ,read_lvl
        ,status