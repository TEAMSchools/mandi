USE KIPP_NJ
GO

ALTER VIEW DISC$recent_incidents_wide AS

WITH dlogs AS (
  SELECT studentid        
        ,CASE
          WHEN logtypeid = 3023 THEN 'Merit'
          WHEN logtypeid = 3223 THEN 'Demerit'
          WHEN logtypeid = -100000 THEN 'Discipline'
         END AS log_type
        ,subtype
        ,entry_author
        ,entry_date
        ,subject
        ,discipline_details
        ,rn
  FROM DISC$log#static WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

,incidents_long AS (
  SELECT studentid
        ,log_type
        ,CONCAT('DISC_0', rn, '_', field) AS pivot_field
        ,value
  FROM
      (
       SELECT dlog01.studentid      
             ,dlog01.log_type            
             ,dlog01.rn
             ,CONVERT(VARCHAR(256),SUBSTRING(dlog01.entry_author, 0, CHARINDEX(',',dlog01.entry_author+','))) AS given_by
             ,CONVERT(VARCHAR(256),dlog01.entry_date) AS date_reported
             ,CONVERT(VARCHAR(256),dlog01.subject) AS subject
             ,CONVERT(VARCHAR(256),dlog01.subtype) AS subtype
             ,CONVERT(VARCHAR(256),dlog01.discipline_details) AS incident
       FROM dlogs dlog01 WITH (NOLOCK)       
       WHERE dlog01.log_type IS NOT NULL
      ) sub
  UNPIVOT(
    value
    FOR field IN (given_by
                 ,date_reported
                 ,subject
                 ,subtype
                 ,incident)
   ) u
  WHERE rn <= 5
 )

SELECT *
FROM incidents_long
PIVOT(
  MAX(value)
  FOR pivot_field IN ([DISC_01_date_reported]
                     ,[DISC_01_given_by]
                     ,[DISC_01_incident]
                     ,[DISC_01_subject]
                     ,[DISC_01_subtype]
                     ,[DISC_02_date_reported]
                     ,[DISC_02_given_by]
                     ,[DISC_02_incident]
                     ,[DISC_02_subject]
                     ,[DISC_02_subtype]
                     ,[DISC_03_date_reported]
                     ,[DISC_03_given_by]
                     ,[DISC_03_incident]
                     ,[DISC_03_subject]
                     ,[DISC_03_subtype]
                     ,[DISC_04_date_reported]
                     ,[DISC_04_given_by]
                     ,[DISC_04_incident]
                     ,[DISC_04_subject]
                     ,[DISC_04_subtype]
                     ,[DISC_05_date_reported]
                     ,[DISC_05_given_by]
                     ,[DISC_05_incident]
                     ,[DISC_05_subject]
                     ,[DISC_05_subtype])
 ) p