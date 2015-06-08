USE KIPP_NJ
GO

ALTER VIEW MAP$growth_norms_data_extended#2011 AS

WITH master_growth_norms AS (
  SELECT *
  FROM KIPP_NJ..MAP$growth_norms_data#2011 WITH(NOLOCK)
 )

--stuff in the table
SELECT *
FROM master_growth_norms
WHERE startgrade < 10

--slightly massage the 10th grade existing data
--(because they report NULL for spring to spring)
UNION ALL

SELECT m.subject
      ,m.startgrade
      ,m.startrit
      ,m.t41, m.t42, m.t44, back_1.t22, m.t12
      ,m.r41, m.r42, m.r44, back_1.r22, m.r12
      ,m.s41, m.s42, m.s44, back_1.s22, m.s12
FROM master_growth_norms m
JOIN master_growth_norms back_1 
  ON m.subject = back_1.subject
 AND m.startrit = back_1.startrit
 AND m.startgrade - 1 = back_1.startgrade
WHERE m.startgrade = 10

--now do the missing stuff (grade 11 and 12)

--grade 11
UNION ALL

SELECT m.subject
      ,11 AS startgrade
      ,m.startrit
      ,m.t41, m.t42, m.t44, back_1.t22, m.t12
      ,m.r41, m.r42, m.r44, back_1.r22, m.r12
      ,m.s41, m.s42, m.s44, back_1.s22, m.s12
FROM master_growth_norms m
JOIN master_growth_norms back_1 
  ON m.subject = back_1.subject
 AND m.startrit = back_1.startrit
 AND m.startgrade - 1 = back_1.startgrade
WHERE m.startgrade = 10

--grade 12
UNION ALL

SELECT m.subject
      ,12 AS startgrade
      ,m.startrit
      ,m.t41, m.t42, m.t44, back_1.t22, m.t12
      ,m.r41, m.r42, m.r44, back_1.r22, m.r12
      ,m.s41, m.s42, m.s44, back_1.s22, m.s12
FROM master_growth_norms m
JOIN master_growth_norms back_1 
  ON m.subject = back_1.subject
 AND m.startrit = back_1.startrit
 AND m.startgrade - 1 = back_1.startgrade
WHERE m.startgrade = 10
