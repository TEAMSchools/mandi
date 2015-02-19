USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$attendance_counts AS

-- attendance codes by date
WITH attendance_long AS (
  --all terms and overall
  SELECT att.STUDENTID
        ,att.att_date
        ,att.att_code                  
        ,dates.time_per_name AS RT
  FROM ATT_MEM$ATTENDANCE att WITH (NOLOCK)
  JOIN REPORTING$dates dates WITH (NOLOCK)
    ON att.att_date >= dates.start_date
   AND att.att_date <= dates.end_date
   AND att.schoolid = dates.schoolid
   AND dates.identifier = 'RT'
   AND dates.academic_year = dbo.fn_Global_Academic_Year()
  WHERE att.att_code IS NOT NULL 

  UNION ALL

  --current term
  SELECT att.studentid
        ,att.att_date
        ,att.att_code                  
        ,'CUR' AS RT                  
  FROM ATT_MEM$ATTENDANCE att WITH (NOLOCK)
  JOIN REPORTING$dates curterm WITH (NOLOCK)
    ON att.schoolid = curterm.schoolid         
   AND att.ATT_DATE >= curterm.start_date
   AND att.ATT_DATE <= curterm.end_date
   AND curterm.identifier = 'RT'
   AND curterm.academic_year = dbo.fn_Global_Academic_Year()
  WHERE att.att_code IS NOT NULL
    AND curterm.start_date <= CONVERT(DATE,GETDATE())
    AND curterm.end_date >= CONVERT(DATE,GETDATE())

  UNION ALL

    --trip term
  SELECT att.studentid
        ,att.att_date
        ,att.att_code                  
        ,'TRIP' AS RT                  
  FROM KIPP_NJ..ATT_MEM$ATTENDANCE att WITH (NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates trip WITH (NOLOCK)
    ON att.schoolid = trip.schoolid         
   AND att.ATT_DATE >= trip.start_date
   AND att.ATT_DATE <= trip.end_date
   AND trip.identifier = 'ATT'
   AND trip.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  WHERE att.att_code IS NOT NULL
    AND trip.start_date <= CONVERT(DATE,GETDATE())
    AND trip.end_date >= CONVERT(DATE,GETDATE())
 )

-- early dismissals by date, both excused and unexcused
,early_dis AS (
  SELECT disc.studentid      
        ,dates.time_per_name AS rt
        ,CASE 
          WHEN disc.subtype = 'Left Early' THEN 'LE'
          WHEN disc.subtype = 'Left Early (Excused)' THEN 'LEX'
          ELSE NULL
         END AS att_code           
  FROM KIPP_NJ..DISC$log#static disc WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates dates WITH(NOLOCK)
    ON disc.schoolid = dates.schoolid
   AND disc.entry_date >= dates.start_date
   AND disc.entry_date <= dates.end_date
   AND dates.identifier = 'RT'
  WHERE disc.logtypeid = 3953

  UNION ALL

  SELECT disc.studentid      
        ,'CUR' AS rt
        ,CASE 
          WHEN disc.subtype = 'Left Early' THEN 'LE'
          WHEN disc.subtype = 'Left Early (Excused)' THEN 'LEX'
          ELSE NULL
         END AS att_code
  FROM DISC$log#static disc WITH(NOLOCK)
  JOIN REPORTING$dates curterm WITH(NOLOCK)
    ON disc.schoolid = curterm.schoolid
   AND disc.entry_date >= curterm.start_date
   AND disc.entry_date <= curterm.end_date
   AND curterm.identifier = 'RT'
  WHERE disc.logtypeid = 3953
    AND disc.subtype IS NOT NULL
    AND curterm.start_date <= GETDATE()
    AND curterm.end_date >= GETDATE()   

  UNION ALL

  SELECT disc.studentid      
        ,'TRIP' AS RT                  
        ,CASE 
          WHEN disc.subtype = 'Left Early' THEN 'LE'
          WHEN disc.subtype = 'Left Early (Excused)' THEN 'LEX'
          ELSE NULL
         END AS att_code
  FROM DISC$log#static disc WITH(NOLOCK)
  JOIN REPORTING$dates trip WITH(NOLOCK)
    ON disc.schoolid = trip.schoolid
   AND disc.entry_date >= trip.start_date
   AND disc.entry_date <= trip.end_date
   AND trip.identifier = 'ATT'
  WHERE disc.logtypeid = 3953
    AND disc.subtype IS NOT NULL
    AND trip.start_date <= GETDATE()
    AND trip.end_date >= GETDATE()   
 )

-- uniform violations by date
,uniform AS (
  SELECT studentid
        ,dates.time_per_name AS rt
        ,dt.has_uniform
  FROM ES_DAILY$tracking_long#static dt WITH(NOLOCK)
  JOIN REPORTING$dates dates WITH(NOLOCK)
    ON dt.schoolid = dates.schoolid
   AND dt.att_date >= dates.start_date
   AND dt.att_date <= dates.end_date
   AND dates.identifier = 'RT'
  WHERE dt.has_uniform = 0
     
  UNION ALL

  SELECT studentid
        ,curterm.time_per_name AS rt
        ,dt.has_uniform
  FROM ES_DAILY$tracking_long#static dt WITH(NOLOCK)
  JOIN REPORTING$dates curterm WITH(NOLOCK)
    ON dt.schoolid = curterm.schoolid
   AND dt.att_date >= curterm.start_date
   AND dt.att_date <= curterm.end_date
   AND curterm.identifier = 'RT'
  WHERE dt.has_uniform = 0
    AND curterm.start_date <= GETDATE()
    AND curterm.end_date >= GETDATE()       

  UNION ALL

  SELECT studentid
        ,'TRIP' AS RT                  
        ,dt.has_uniform
  FROM ES_DAILY$tracking_long#static dt WITH(NOLOCK)
  JOIN REPORTING$dates trip WITH (NOLOCK)
    ON dt.schoolid = trip.schoolid
   AND dt.att_date >= trip.start_date
   AND dt.att_date <= trip.end_date
   AND trip.identifier = 'ATT'
  WHERE dt.has_uniform = 0
    AND trip.start_date <= CONVERT(DATE,GETDATE())
    AND trip.end_date >= CONVERT(DATE,GETDATE())
 )

SELECT studentid

      -- y1 codes
      ,ISNULL([Y1_A],0) AS Y1_A
      ,ISNULL([Y1_AD],0) AS Y1_AD
      ,ISNULL([Y1_AE],0) AS Y1_AE
      ,ISNULL([Y1_CR],0) AS Y1_CR
      ,ISNULL([Y1_CS],0) AS Y1_CS
      ,ISNULL([Y1_EV],0) AS Y1_EV
      ,ISNULL([Y1_ISS],0) AS Y1_ISS
      ,ISNULL([Y1_OSS],0) AS Y1_OSS
      ,ISNULL([Y1_T],0) AS Y1_T
      ,ISNULL([Y1_T10],0) AS Y1_T10
      ,ISNULL([Y1_TE],0) AS Y1_TE
      -- from logs/tracking
      ,ISNULL([Y1_LE],0) AS Y1_LE
      ,ISNULL([Y1_LEX],0) AS Y1_LEX
      ,ISNULL([Y1_UNI],0) AS Y1_UNI
      -- totals
      ,ISNULL([Y1_A],0)
         + ISNULL([Y1_AD],0) AS Y1_ABS_ALL
      ,ISNULL([Y1_T],0)
         + ISNULL([Y1_T10],0)
         + ISNULL([Y1_TE],0) AS Y1_T_ALL
      
      -- current term codes
      ,ISNULL([CUR_A],0) AS CUR_A
      ,ISNULL([CUR_AD],0) AS CUR_AD
      ,ISNULL([CUR_AE],0) AS CUR_AE
      ,ISNULL([CUR_CR],0) AS CUR_CR
      ,ISNULL([CUR_CS],0) AS CUR_CS
      ,ISNULL([CUR_EV],0) AS CUR_EV
      ,ISNULL([CUR_ISS],0) AS CUR_ISS
      ,ISNULL([CUR_OSS],0) AS CUR_OSS
      ,ISNULL([CUR_T],0) AS CUR_T
      ,ISNULL([CUR_T10],0) AS CUR_T10
      ,ISNULL([CUR_TE],0) AS CUR_TE
      -- from logs/tracking
      ,ISNULL([CUR_LE],0) AS CUR_LE
      ,ISNULL([CUR_LEX],0) AS CUR_LEX
      ,ISNULL([CUR_UNI],0) AS CUR_UNI
      -- totals
      ,ISNULL([CUR_A],0)
         + ISNULL([CUR_AD],0) AS CUR_ABS_ALL
      ,ISNULL([CUR_T],0)
         + ISNULL([CUR_T10],0)
         + ISNULL([CUR_TE],0) AS CUR_T_ALL

      -- trip term codes
      ,ISNULL([TRIP_A],0) AS TRIP_A
      ,ISNULL([TRIP_AD],0) AS TRIP_AD
      ,ISNULL([TRIP_AE],0) AS TRIP_AE
      ,ISNULL([TRIP_CR],0) AS TRIP_CR
      ,ISNULL([TRIP_CS],0) AS TRIP_CS
      ,ISNULL([TRIP_EV],0) AS TRIP_EV
      ,ISNULL([TRIP_ISS],0) AS TRIP_ISS
      ,ISNULL([TRIP_OSS],0) AS TRIP_OSS
      ,ISNULL([TRIP_T],0) AS TRIP_T
      ,ISNULL([TRIP_T10],0) AS TRIP_T10
      ,ISNULL([TRIP_TE],0) AS TRIP_TE
      -- from logs/tracking
      ,ISNULL([TRIP_LE],0) AS TRIP_LE
      ,ISNULL([TRIP_LEX],0) AS TRIP_LEX
      ,ISNULL([TRIP_UNI],0) AS TRIP_UNI
      -- totals
      ,ISNULL([TRIP_A],0)
         + ISNULL([TRIP_AD],0) AS TRIP_ABS_ALL
      ,ISNULL([TRIP_T],0)
         + ISNULL([TRIP_T10],0)
         + ISNULL([TRIP_TE],0) AS TRIP_T_ALL
      
      -- rt1 codes
      ,ISNULL([RT1_A],0) AS RT1_A
      ,ISNULL([RT1_AD],0) AS RT1_AD
      ,ISNULL([RT1_AE],0) AS RT1_AE
      ,ISNULL([RT1_CR],0) AS RT1_CR
      ,ISNULL([RT1_CS],0) AS RT1_CS
      ,ISNULL([RT1_EV],0) AS RT1_EV
      ,ISNULL([RT1_ISS],0) AS RT1_ISS
      ,ISNULL([RT1_OSS],0) AS RT1_OSS
      ,ISNULL([RT1_T],0) AS RT1_T
      ,ISNULL([RT1_T10],0) AS RT1_T10
      ,ISNULL([RT1_TE],0) AS RT1_TE
      -- from logs/tracking
      ,ISNULL([RT1_LE],0) AS RT1_LE
      ,ISNULL([RT1_LEX],0) AS RT1_LEX
      ,ISNULL([RT1_UNI],0) AS RT1_UNI
      -- totals
      ,ISNULL([RT1_A],0)
         + ISNULL([RT1_AD],0) AS RT1_ABS_ALL
      ,ISNULL([RT1_T],0)
         + ISNULL([RT1_T10],0)
         + ISNULL([RT1_TE],0) AS RT1_T_ALL            
     
      -- rt2 codes
      ,ISNULL([RT2_A],0) AS RT2_A
      ,ISNULL([RT2_AD],0) AS RT2_AD
      ,ISNULL([RT2_AE],0) AS RT2_AE
      ,ISNULL([RT2_CR],0) AS RT2_CR
      ,ISNULL([RT2_CS],0) AS RT2_CS
      ,ISNULL([RT2_EV],0) AS RT2_EV
      ,ISNULL([RT2_ISS],0) AS RT2_ISS
      ,ISNULL([RT2_OSS],0) AS RT2_OSS
      ,ISNULL([RT2_T],0) AS RT2_T
      ,ISNULL([RT2_T10],0) AS RT2_T10
      ,ISNULL([RT2_TE],0) AS RT2_TE
      -- from logs/tracking
      ,ISNULL([RT2_LE],0) AS RT2_LE
      ,ISNULL([RT2_LEX],0) AS RT2_LEX
      ,ISNULL([RT2_UNI],0) AS RT2_UNI
      -- totals
      ,ISNULL([RT2_A],0)
         + ISNULL([RT2_AD],0) AS RT2_ABS_ALL
      ,ISNULL([RT2_T],0)
         + ISNULL([RT2_T10],0)
         + ISNULL([RT2_TE],0) AS RT2_T_ALL      

      -- rt3 codes
      ,ISNULL([RT3_A],0) AS RT3_A
      ,ISNULL([RT3_AD],0) AS RT3_AD
      ,ISNULL([RT3_AE],0) AS RT3_AE
      ,ISNULL([RT3_CR],0) AS RT3_CR
      ,ISNULL([RT3_CS],0) AS RT3_CS
      ,ISNULL([RT3_EV],0) AS RT3_EV
      ,ISNULL([RT3_ISS],0) AS RT3_ISS
      ,ISNULL([RT3_OSS],0) AS RT3_OSS
      ,ISNULL([RT3_T],0) AS RT3_T
      ,ISNULL([RT3_T10],0) AS RT3_T10
      ,ISNULL([RT3_TE],0) AS RT3_TE
      -- from logs/tracking
      ,ISNULL([RT3_LE],0) AS RT3_LE
      ,ISNULL([RT3_LEX],0) AS RT3_LEX
      ,ISNULL([RT3_UNI],0) AS RT3_UNI
      -- totals
      ,ISNULL([RT3_A],0)
         + ISNULL([RT3_AD],0) AS RT3_ABS_ALL
      ,ISNULL([RT3_T],0)
         + ISNULL([RT3_T10],0)
         + ISNULL([RT3_TE],0) AS RT3_T_ALL      
     
      -- rt4 codes
      ,ISNULL([RT4_A],0) AS RT4_A
      ,ISNULL([RT4_AD],0) AS RT4_AD
      ,ISNULL([RT4_AE],0) AS RT4_AE
      ,ISNULL([RT4_CR],0) AS RT4_CR
      ,ISNULL([RT4_CS],0) AS RT4_CS
      ,ISNULL([RT4_EV],0) AS RT4_EV
      ,ISNULL([RT4_ISS],0) AS RT4_ISS
      ,ISNULL([RT4_OSS],0) AS RT4_OSS
      ,ISNULL([RT4_T],0) AS RT4_T
      ,ISNULL([RT4_T10],0) AS RT4_T10
      ,ISNULL([RT4_TE],0) AS RT4_TE
      -- from logs/tracking
      ,ISNULL([RT4_LE],0) AS RT4_LE
      ,ISNULL([RT4_LEX],0) AS RT4_LEX
      ,ISNULL([RT4_UNI],0) AS RT4_UNI
      -- totals
      ,ISNULL([RT4_A],0)
         + ISNULL([RT4_AD],0) AS RT4_ABS_ALL
      ,ISNULL([RT4_T],0)
         + ISNULL([RT4_T10],0)
         + ISNULL([RT4_TE],0) AS RT4_T_ALL      

      -- rt5 codes
      ,ISNULL([RT5_A],0) AS RT5_A
      ,ISNULL([RT5_AD],0) AS RT5_AD
      ,ISNULL([RT5_AE],0) AS RT5_AE
      ,ISNULL([RT5_CR],0) AS RT5_CR
      ,ISNULL([RT5_CS],0) AS RT5_CS
      ,ISNULL([RT5_EV],0) AS RT5_EV
      ,ISNULL([RT5_ISS],0) AS RT5_ISS
      ,ISNULL([RT5_OSS],0) AS RT5_OSS
      ,ISNULL([RT5_T],0) AS RT5_T
      ,ISNULL([RT5_T10],0) AS RT5_T10
      ,ISNULL([RT5_TE],0) AS RT5_TE
      -- from logs/tracking
      ,ISNULL([RT5_LE],0) AS RT5_LE
      ,ISNULL([RT5_LEX],0) AS RT5_LEX
      ,ISNULL([RT5_UNI],0) AS RT5_UNI
      -- totals
      ,ISNULL([RT5_A],0)
         + ISNULL([RT5_AD],0) AS RT5_ABS_ALL
      ,ISNULL([RT5_T],0)
         + ISNULL([RT5_T10],0)
         + ISNULL([RT5_TE],0) AS RT5_T_ALL      
     
      -- rt6 codes
      ,ISNULL([RT6_A],0) AS RT6_A
      ,ISNULL([RT6_AD],0) AS RT6_AD
      ,ISNULL([RT6_AE],0) AS RT6_AE
      ,ISNULL([RT6_CR],0) AS RT6_CR
      ,ISNULL([RT6_CS],0) AS RT6_CS
      ,ISNULL([RT6_EV],0) AS RT6_EV
      ,ISNULL([RT6_ISS],0) AS RT6_ISS
      ,ISNULL([RT6_OSS],0) AS RT6_OSS
      ,ISNULL([RT6_T],0) AS RT6_T
      ,ISNULL([RT6_T10],0) AS RT6_T10
      ,ISNULL([RT6_TE],0) AS RT6_TE
      -- from logs/tracking
      ,ISNULL([RT6_LE],0) AS RT6_LE
      ,ISNULL([RT6_LEX],0) AS RT6_LEX
      ,ISNULL([RT6_UNI],0) AS RT6_UNI
      -- totals
      ,ISNULL([RT6_A],0)
         + ISNULL([RT6_AD],0) AS RT6_ABS_ALL
      ,ISNULL([RT6_T],0)
         + ISNULL([RT6_T10],0)
         + ISNULL([RT6_TE],0) AS RT6_T_ALL
     
      -- trip abs calculations
      ,ROUND(ISNULL([TRIP_A],0)
              + ((ISNULL([TRIP_T],0) + ISNULL([TRIP_T10],0)) / 3)
              + (ISNULL([TRIP_LE],0) / 3)
              + (ISNULL([TRIP_UNI],0) / 6)
             ,1) AS CUR_TRIP_ABS
      ,ROUND(ISNULL([RT1_A],0)
              + ((ISNULL([RT1_T],0) + ISNULL([RT1_T10],0)) / 3)
              + (ISNULL([RT1_LE],0) / 3)
              + (ISNULL([RT1_UNI],0) / 6)
             ,1) AS RT1_TRIP_ABS
      ,ROUND(ISNULL([RT2_A],0)
              + ((ISNULL([RT2_T],0) + ISNULL([RT2_T10],0)) / 3)
              + (ISNULL([RT2_LE],0) / 3)
              + (ISNULL([RT2_UNI],0) / 6)
             ,1) AS RT2_TRIP_ABS
      ,ROUND(ISNULL([RT3_A],0)
              + ((ISNULL([RT3_T],0) + ISNULL([RT3_T10],0)) / 3)
              + (ISNULL([RT3_LE],0) / 3)
              + (ISNULL([RT3_UNI],0) / 6)
             ,1) AS RT3_TRIP_ABS
      ,ROUND(ISNULL([RT4_A],0)
              + ((ISNULL([RT4_T],0) + ISNULL([RT4_T10],0)) / 3)
              + (ISNULL([RT4_LE],0) / 3)
              + (ISNULL([RT4_UNI],0) / 6)
             ,1) AS RT4_TRIP_ABS
      ,ROUND(ISNULL([RT5_A],0)
              + ((ISNULL([RT5_T],0) + ISNULL([RT5_T10],0)) / 3)
              + (ISNULL([RT5_LE],0) / 3)
              + (ISNULL([RT5_UNI],0) / 6)
             ,1) AS RT5_TRIP_ABS
      ,ROUND(ISNULL([RT6_A],0)
              + ((ISNULL([RT6_T],0) + ISNULL([RT6_T10],0)) / 3)
              + (ISNULL([RT6_LE],0) / 3)
              + (ISNULL([RT6_UNI],0) / 6)
             ,1) AS RT6_TRIP_ABS
      ,ROUND(ISNULL([Y1_A],0)
              + ((ISNULL([Y1_T],0) + ISNULL([Y1_T10],0)) / 3)
              + (ISNULL([Y1_LE],0) / 3)
              + (ISNULL([Y1_UNI],0) / 6)
             ,1) AS Y1_TRIP_ABS
FROM
    (
     -- union attendance, early dismissals, and uniform violations by RT
     -- also union w/o RT grouping for year totals
     SELECT co.studentid           
           ,RT + '_' + ATT_CODE AS rt_hash
           ,CONVERT(FLOAT,COUNT(*)) AS N
     FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
     LEFT OUTER JOIN attendance_long att WITH(NOLOCK)
       ON co.studentid = att.STUDENTID      
     WHERE co.year = dbo.fn_Global_Academic_Year()
       AND co.rn = 1
       AND co.schoolid != 999999
     GROUP BY co.STUDENTID      
             ,RT
             ,ATT_CODE

     UNION ALL

     SELECT co.studentid           
           ,'Y1_' + ATT_CODE AS rt_hash
           ,CONVERT(FLOAT,COUNT(*)) AS N
     FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
     LEFT OUTER JOIN attendance_long att WITH(NOLOCK)
       ON co.studentid = att.STUDENTID
      AND rt != 'CUR' 
     WHERE co.year = dbo.fn_Global_Academic_Year()
       AND co.rn = 1     
       AND co.schoolid != 999999
     GROUP BY co.studentid                   
             ,ATT_CODE

     UNION ALL

     SELECT co.studentid
           ,rt + '_' + att_code AS rt_hash
           ,CONVERT(FLOAT,COUNT(*)) AS N
     FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
     LEFT OUTER JOIN early_dis ed WITH(NOLOCK)
       ON co.studentid = ed.studentid
     WHERE co.year = dbo.fn_Global_Academic_Year()
       AND co.rn = 1
       AND co.schoolid != 999999
     GROUP BY co.studentid        
             ,rt
             ,att_code

     UNION ALL

     SELECT co.studentid
           ,'Y1_' + att_code AS rt_hash
           ,CONVERT(FLOAT,COUNT(*)) AS N
     FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
     LEFT OUTER JOIN early_dis ed WITH(NOLOCK)
       ON co.studentid = ed.studentid
     WHERE co.year = dbo.fn_Global_Academic_Year()
       AND co.rn = 1
       AND co.schoolid != 999999
     GROUP BY co.studentid        
             ,att_code

     UNION ALL

     SELECT co.studentid
           ,rt + '_UNI' AS rt_hash
           ,CONVERT(FLOAT,COUNT(*)) AS N
     FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
     LEFT OUTER JOIN uniform uni WITH(NOLOCK)
       ON co.studentid = uni.studentid
     WHERE co.year = dbo.fn_Global_Academic_Year()
       AND co.rn = 1
       AND co.schoolid != 999999
     GROUP BY co.studentid        
             ,rt             

     UNION ALL

     SELECT co.studentid
           ,'Y1_UNI' AS rt_hash
           ,CONVERT(FLOAT,COUNT(*)) AS N
     FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
     LEFT OUTER JOIN uniform uni WITH(NOLOCK)
       ON co.studentid = uni.studentid
     WHERE co.year = dbo.fn_Global_Academic_Year()
       AND co.rn = 1
       AND co.schoolid != 999999
     GROUP BY co.studentid  
    ) sub

PIVOT (
  MAX(N)  
  FOR rt_hash IN ([CUR_A]
                 ,[CUR_AD]
                 ,[CUR_AE]
                 ,[CUR_CR]
                 ,[CUR_CS]
                 ,[CUR_EV]
                 ,[CUR_ISS]
                 ,[CUR_OSS]
                 ,[CUR_T]
                 ,[CUR_T10]
                 ,[CUR_TE]
                 ,[RT1_A]
                 ,[RT1_AD]
                 ,[RT1_AE]
                 ,[RT1_CR]
                 ,[RT1_CS]
                 ,[RT1_EV]
                 ,[RT1_ISS]
                 ,[RT1_OSS]
                 ,[RT1_T]
                 ,[RT1_T10]
                 ,[RT1_TE]
                 ,[RT2_A]
                 ,[RT2_AD]
                 ,[RT2_AE]
                 ,[RT2_CR]
                 ,[RT2_CS]
                 ,[RT2_EV]
                 ,[RT2_ISS]
                 ,[RT2_OSS]
                 ,[RT2_T]
                 ,[RT2_T10]
                 ,[RT2_TE]
                 ,[RT3_A]
                 ,[RT3_AD]
                 ,[RT3_AE]
                 ,[RT3_CR]
                 ,[RT3_CS]
                 ,[RT3_EV]
                 ,[RT3_ISS]
                 ,[RT3_OSS]
                 ,[RT3_T]
                 ,[RT3_T10]
                 ,[RT3_TE]
                 ,[RT4_A]
                 ,[RT4_AD]
                 ,[RT4_AE]
                 ,[RT4_CR]
                 ,[RT4_CS]
                 ,[RT4_EV]
                 ,[RT4_ISS]
                 ,[RT4_OSS]
                 ,[RT4_T]
                 ,[RT4_T10]
                 ,[RT4_TE]
                 ,[RT5_A]
                 ,[RT5_AD]
                 ,[RT5_AE]
                 ,[RT5_CR]
                 ,[RT5_CS]
                 ,[RT5_EV]
                 ,[RT5_ISS]
                 ,[RT5_OSS]
                 ,[RT5_T]
                 ,[RT5_T10]
                 ,[RT5_TE]
                 ,[RT6_A]
                 ,[RT6_AD]
                 ,[RT6_AE]
                 ,[RT6_CR]
                 ,[RT6_CS]
                 ,[RT6_EV]
                 ,[RT6_ISS]
                 ,[RT6_OSS]
                 ,[RT6_T]
                 ,[RT6_T10]
                 ,[RT6_TE]
                 ,[Y1_A]
                 ,[Y1_AD]
                 ,[Y1_AE]
                 ,[Y1_CR]
                 ,[Y1_CS]
                 ,[Y1_EV]
                 ,[Y1_ISS]
                 ,[Y1_OSS]
                 ,[Y1_T]
                 ,[Y1_T10]
                 ,[Y1_TE]
                 ,[CUR_LE]
                 ,[CUR_LEX]
                 ,[CUR_UNI]
                 ,[RT1_LE]
                 ,[RT1_LEX]
                 ,[RT1_UNI]
                 ,[RT2_LE]
                 ,[RT2_LEX]
                 ,[RT2_UNI]
                 ,[RT3_LE]
                 ,[RT3_LEX]
                 ,[RT3_UNI]
                 ,[RT4_LE]
                 ,[RT4_LEX]
                 ,[RT4_UNI]
                 ,[RT5_LE]
                 ,[RT5_LEX]
                 ,[RT5_UNI]
                 ,[RT6_LE]
                 ,[RT6_LEX]
                 ,[RT6_UNI]
                 ,[Y1_LE]
                 ,[Y1_LEX]
                 ,[Y1_UNI]
                 ,[TRIP_LE]
                 ,[TRIP_LEX]
                 ,[TRIP_UNI]
                 ,[TRIP_A]
                 ,[TRIP_AD]
                 ,[TRIP_AE]
                 ,[TRIP_CR]
                 ,[TRIP_CS]
                 ,[TRIP_EV]
                 ,[TRIP_ISS]
                 ,[TRIP_OSS]
                 ,[TRIP_T]
                 ,[TRIP_T10]
                 ,[TRIP_TE])
 ) p