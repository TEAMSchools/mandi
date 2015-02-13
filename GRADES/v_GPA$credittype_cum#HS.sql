USE KIPP_NJ
GO

ALTER VIEW GPA$credittype_cum#HS AS

WITH gpa_credittype AS (
  SELECT studentid
        ,[ART]
        ,[ENG]      
        ,[MATH]
        ,[PHYSED]
        ,[RHET]
        ,[SCI]
        ,[SOC]
        ,[WLANG]
  FROM
      (
       SELECT studentid
             ,credit_type
             ,ROUND(weighted_points / credit_hours,2) AS cum_gpa      
       FROM
           (
            SELECT studentid AS studentid           
                  ,credit_type
                  ,ROUND(SUM(CONVERT(FLOAT,weighted_points)),3) AS weighted_points
                  ,CASE
                    WHEN SUM(CONVERT(FLOAT,potentialcrhrs)) = 0 THEN NULL
                    ELSE SUM(CONVERT(FLOAT,potentialcrhrs))
                   END AS credit_hours
            FROM 
                (
                 SELECT sg.studentid
                       ,ISNULL(sg.credittype,'TRANSF') AS credit_type
                       ,(sg.potential_crhrs * sg.grade_points) AS weighted_points
                       ,sg.potential_crhrs AS potentialcrhrs
                 FROM GRADES$storedgrades#identifiers sg
                 WHERE sg.term = 'Y1'   
                   AND sg.excludefromgpa != 1
                    --AND sg.credit_type IS NOT NULL -- no transfer classes! UPDATE (2/13/15): this was wrong I think                                      
                ) sub
            GROUP BY studentid, credit_type
           ) sub_1
      ) sub_2    

  PIVOT (
    MAX(cum_gpa)
    FOR credit_type IN ([ART]
                       ,[ENG]                     
                       ,[MATH]
                       ,[PHYSED]
                       ,[RHET]
                       ,[SCI]
                       ,[SOC]
                       ,[WLANG])
   ) piv
 )
 
SELECT s.LASTFIRST
      ,s.GRADE_LEVEL
      ,cs.ADVISOR
      --,cs.SPEDLEP
      ,gpa_credittype.*
FROM STUDENTS s WITH(NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.ID = cs.STUDENTID
LEFT OUTER JOIN gpa_credittype
  ON s.ID = gpa_credittype.studentid
WHERE s.ENROLL_STATUS = 0
  AND s.GRADE_LEVEL = 12