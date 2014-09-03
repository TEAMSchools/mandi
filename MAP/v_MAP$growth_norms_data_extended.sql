USE KIPP_NJ
GO

CREATE VIEW MAP$growth_norms_data_extended#2011 AS
WITH master_growth_norms AS
    (SELECT *
     FROM KIPP_NJ..MAP$growth_norms_data#2011
    )
--stuff in the table
SELECT *
FROM master_growth_norms
--missing stuff

--reading 11
UNION ALL
SELECT subject
      ,11
      ,startrit
      ,t41, t42, t44, t22, t12
      ,r41, r42, r44, r22, r12
      ,s41, s42, s44, s22, s12
FROM master_growth_norms
WHERE subject = 'Reading'
  AND startgrade = 10
--reading 12
UNION ALL
SELECT subject
      ,12
      ,startrit
      ,t41, t42, t44, t22, t12
      ,r41, r42, r44, r22, r12
      ,s41, s42, s44, s22, s12
FROM master_growth_norms
WHERE subject = 'Reading'
  AND startgrade = 10
--mathematics 11
UNION ALL
SELECT subject
      ,11
      ,startrit
      ,t41, t42, t44, t22, t12
      ,r41, r42, r44, r22, r12
      ,s41, s42, s44, s22, s12
FROM master_growth_norms
WHERE subject = 'Mathematics'
  AND startgrade = 10
--mathematics 12
UNION ALL
SELECT subject
      ,12
      ,startrit
      ,t41, t42, t44, t22, t12
      ,r41, r42, r44, r22, r12
      ,s41, s42, s44, s22, s12
FROM master_growth_norms
WHERE subject = 'Mathematics'
  AND startgrade = 10
--language usage 11
UNION ALL
SELECT subject
      ,11
      ,startrit
      ,t41, t42, t44, t22, t12
      ,r41, r42, r44, r22, r12
      ,s41, s42, s44, s22, s12
FROM master_growth_norms
WHERE subject = 'Language Usage'
  AND startgrade = 10
--language usage 12
UNION ALL
SELECT subject
      ,12
      ,startrit
      ,t41, t42, t44, t22, t12
      ,r41, r42, r44, r22, r12
      ,s41, s42, s44, s22, s12
FROM master_growth_norms
WHERE subject = 'Language Usage'
  AND startgrade = 10
--general science 11
UNION ALL
SELECT subject
      ,11
      ,startrit
      ,t41, t42, t44, t22, t12
      ,r41, r42, r44, r22, r12
      ,s41, s42, s44, s22, s12
FROM master_growth_norms
WHERE subject = 'General Science'
  AND startgrade = 10
--general science 12
UNION ALL
SELECT subject
      ,12
      ,startrit
      ,t41, t42, t44, t22, t12
      ,r41, r42, r44, r22, r12
      ,s41, s42, s44, s22, s12
FROM master_growth_norms
WHERE subject = 'General Science'
  AND startgrade = 10