USE SPI
GO

ALTER VIEW GRADES$TIME_SERIES#COUNTS AS

SELECT studentid
      ,date_value
      ,SUM(off_track) AS num_off
FROM
    (
     SELECT studentid
           ,gr.course_number
           ,date_value
           ,synthetic_percent
           ,CASE 
             WHEN cou.SCHOOLID IN (73253) AND CONVERT(FLOAT,gr.SYNTHETIC_PERCENT) < 70 THEN 1 
             WHEN cou.SCHOOLID IN (73252, 133570965) AND CONVERT(FLOAT,gr.SYNTHETIC_PERCENT) < 70 THEN 1 
             ELSE 0 
            END AS off_track
     FROM SPI..GRADES$times_series_detail#static gr WITH(NOLOCK)
     JOIN KIPP_NJ..COURSES cou WITH(NOLOCK)
       ON gr.course_number = cou.course_number
      AND cou.excludefromhonorroll = 0
     WHERE gr.RT_NAME = 'Y1'
    ) sub
GROUP BY studentid
        ,date_value