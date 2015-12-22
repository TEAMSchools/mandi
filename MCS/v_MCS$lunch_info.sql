USE KIPP_NJ
GO

ALTER VIEW MCS$lunch_info AS

SELECT StudentNumber
      ,Balance
      ,MealBenefitStatus
      ,shortdesc
      ,description
FROM
    (
     SELECT CONVERT(INT,c.[StudentNumber]) AS [StudentNumber]
           ,c.[ReimbursableOnlyBalance] + c.[UnallocatedBalance] AS [Balance]
           ,LEFT(cat.[ShortDesc], 1) AS [MealBenefitStatus] /* Returns F.R,P*/
           ,cat.[ShortDesc]
           ,e.[Description]
           ,ROW_NUMBER() OVER(
              PARTITION BY c.StudentNumber
                ORDER BY c.PermanentStatusDate DESC) AS rn
     FROM [RM9-RE\RE_ENTERPRISE].[Newton].[dbo].[CUSTOMER] c WITH(NOLOCK)
     INNER JOIN [RM9-RE\RE_ENTERPRISE].[Newton].[dbo].[STUDENT_GUID_LINK] g WITH(NOLOCK)
       ON c.[CUSTOMER_RECID] = g.[CustomerID]
     INNER JOIN [RM9-RE\RE_ENTERPRISE].[Newton].[dbo].[CUSTOMER_CATEGORY] cat WITH(NOLOCK)
       ON c.[Customer_CategoryID] = cat.[CUSTOMER_CATEGORY_RECID]
     INNER JOIN [RM9-RE\RE_ENTERPRISE].[Franklin].[dbo].STUDENT s WITH(NOLOCK)
       ON g.StudentGUID = s.GlobalUID
     INNER JOIN [RM9-RE\RE_ENTERPRISE].[Franklin].[dbo].[ELIGIBILITY] e WITH(NOLOCK)
       ON s.[EligibilityID] = e.[ELIGIBILITY_RECID]
     WHERE cat.[IsStudent] = 1 /*Only Students*/
       AND ISNUMERIC(c.[StudentNumber]) = 1
    ) sub
WHERE rn = 1