USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$membership_counts AS

WITH membership_long AS (
  SELECT studentid
        ,CONVERT(DATE,calendardate) AS calendardate
        ,CONVERT(INT,membershipvalue) AS membershipvalue
        ,dates.time_per_name AS RT     
  FROM KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH (NOLOCK)
  JOIN REPORTING$dates dates WITH (NOLOCK)
    ON mem.calendardate >= dates.start_date
   AND mem.calendardate <= dates.end_date       
   AND mem.schoolid = dates.schoolid
   AND dates.identifier = 'RT'  
  WHERE mem.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      
  UNION ALL

  SELECT studentid
        ,CONVERT(DATE,calendardate) AS calendardate
        ,CONVERT(INT,membershipvalue) AS membershipvalue
        ,'CUR' AS RT            
  FROM KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH (NOLOCK)
  JOIN REPORTING$dates curterm WITH (NOLOCK)
    ON mem.schoolid = curterm.schoolid      
   AND mem.CALENDARDATE >= curterm.start_date
   AND mem.CALENDARDATE <= curterm.end_date
   AND curterm.identifier = 'RT'
  WHERE CONVERT(DATE,GETDATE()) BETWEEN curterm.start_date AND curterm.end_date
    AND mem.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

SELECT STUDENTID
      ,[RT1_MEM]
      ,[RT2_MEM]
      ,[RT3_MEM]
      ,[RT4_MEM]
      ,[RT5_MEM]
      ,[RT6_MEM]
      ,[CUR_MEM]
      ,[Y1_MEM]
FROM
    (
     SELECT STUDENTID           
           ,RT + '_MEM' AS rt_hash
           ,SUM(MEMBERSHIPVALUE) AS N
     FROM membership_long
     GROUP BY STUDENTID      
             ,RT             

     UNION ALL

     SELECT STUDENTID           
           ,'Y1_MEM' AS rt_hash
           ,SUM(MEMBERSHIPVALUE) AS N
     FROM membership_long
     WHERE rt != 'CUR'
     GROUP BY STUDENTID
    ) sub

PIVOT (
  MAX(N)
  FOR rt_hash IN ([RT1_MEM]
                 ,[RT2_MEM]
                 ,[RT3_MEM]
                 ,[RT4_MEM]
                 ,[RT5_MEM]
                 ,[RT6_MEM]
                 ,[CUR_MEM]
                 ,[Y1_MEM])
 ) p