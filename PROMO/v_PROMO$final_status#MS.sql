USE KIPP_NJ
GO

ALTER VIEW PROMO$final_status#MS AS

SELECT student_number      
      ,CASE 
        WHEN promo_status_final LIKE '%transfer%' THEN LEFT(promo_status_final,CHARINDEX('-', promo_status_final) - 2) 
        ELSE promo_status_final 
       END AS promo_status_final
FROM
    (
     SELECT [student_number]      
           ,[Final Status] AS promo_status_final
     FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROMO_rise] WITH(NOLOCK)

     UNION

     SELECT [student_number]      
           ,[Final Status] AS promo_status_final
     FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROMO_team] WITH(NOLOCK)
    ) sub