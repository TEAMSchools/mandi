USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$att_codes AS

SELECT SCHOOLID
      ,YEARID
      ,ATT_CODE
      ,DESCRIPTION
      ,CASE 
        WHEN PRESENCE_STATUS_CD = 'Present' THEN 1
        WHEN PRESENCE_STATUS_CD = 'Absent' THEN 0
        ELSE NULL
       END AS PRESENCE_STATUS
FROM OPENQUERY(PS_TEAM,'
  SELECT dcid
        ,schoolid
        ,yearid
        ,att_code
        ,description
        ,presence_status_cd
  FROM attendance_code
')