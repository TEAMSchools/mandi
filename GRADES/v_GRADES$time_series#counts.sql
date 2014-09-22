USE SPI
GO

ALTER VIEW GRADES$TIME_SERIES#COUNTS AS

SELECT studentid
      ,date_value
      ,SUM(off_track) AS num_off
FROM
    (     
     -- time series refresh is jacked up for some reason
     -- we're using current grades from the grades refresh for the time being
     SELECT ms.STUDENTID
           ,ms.COURSE_NUMBER
           ,CONVERT(DATE,DATEADD(WEEK,-1,GETDATE())) AS date_value
           ,y1 AS synthetic_percent
           ,CASE 
             WHEN ms.SCHOOLID IN (73253) AND y1 < 70 THEN 1
             WHEN ms.SCHOOLID IN (73252, 133570965) AND y1 < 65 THEN 1
             ELSE 0
            END AS off_track
     FROM KIPP_NJ..GRADES$DETAIL#MS ms WITH(NOLOCK)
     JOIN KIPP_NJ..COURSES cou WITH(NOLOCK)
       ON ms.course_number = cou.course_number
      AND cou.excludefromhonorroll = 0

     UNION ALL

     SELECT hs.STUDENTID
           ,hs.COURSE_NUMBER
           ,CONVERT(DATE,DATEADD(WEEK,-1,GETDATE())) AS date_value
           ,y1 AS synthetic_percent
           ,CASE 
             WHEN hs.SCHOOLID IN (73253) AND y1 < 70 THEN 1
             WHEN hs.SCHOOLID IN (73252, 133570965) AND y1 < 65 THEN 1
             ELSE 0
            END AS off_track
     FROM KIPP_NJ..GRADES$DETAIL#NCA hs WITH(NOLOCK)
     JOIN KIPP_NJ..COURSES cou WITH(NOLOCK)
       ON hs.course_number = cou.course_number
      AND cou.excludefromhonorroll = 0


     --SELECT studentid
     --      ,gr.course_number
     --      ,date_value
     --      ,synthetic_percent
     --      ,CASE 
     --        WHEN cou.SCHOOLID IN (73253) AND CONVERT(FLOAT,gr.SYNTHETIC_PERCENT) < 70 THEN 1 
     --        WHEN cou.SCHOOLID IN (73252, 133570965) AND CONVERT(FLOAT,gr.SYNTHETIC_PERCENT) < 65 THEN 1 
     --        ELSE 0 
     --       END AS off_track
     --FROM SPI..GRADES$times_series_detail#static gr WITH(NOLOCK)
     --JOIN KIPP_NJ..COURSES cou WITH(NOLOCK)
     --  ON gr.course_number = cou.course_number
     -- AND cou.excludefromhonorroll = 0
     --WHERE gr.RT_NAME = 'Y1'
    ) sub
GROUP BY studentid
        ,date_value