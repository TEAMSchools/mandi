USE KIPP_NJ
GO

ALTER VIEW DISC$culture_counts#NCA AS

WITH curterm AS (
  SELECT academic_year
        ,time_per_name
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT' 
    AND CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date
    AND schoolid = 73253
 )

,teacher_merits AS (
  SELECT merits.studentid             
        ,merits.academic_year
        --teacher merits
        ,COUNT(merits.rn) AS teacher_merits_y1
        ,SUM(CASE WHEN merits.rt = 'RT1' THEN 1 ELSE 0 END) AS teacher_merits_rt1
        ,SUM(CASE WHEN merits.rt = 'RT2' THEN 1 ELSE 0 END) AS teacher_merits_rt2
        ,SUM(CASE WHEN merits.rt = 'RT3' THEN 1 ELSE 0 END) AS teacher_merits_rt3
        ,SUM(CASE WHEN merits.rt = 'RT4' THEN 1 ELSE 0 END) AS teacher_merits_rt4        
        ,SUM(CASE WHEN merits.rt = curterm.time_per_name THEN 1 ELSE 0 END) AS teacher_merits_cur
  FROM KIPP_NJ..DISC$log#static merits WITH(NOLOCK)
  JOIN curterm    
    ON merits.academic_year = curterm.academic_year
  WHERE logtypeid = 3023
    AND subtypeid != 99
  GROUP BY merits.studentid, merits.academic_year
 )

,perfect_wks AS (
  SELECT studentid
        ,student_number
        ,perfect.academic_year        
        ,(perfect.perfect_wks_y1 * 3) AS perfect_week_merits_y1
        ,(perfect.perfect_wks_rt1 * 3) AS perfect_week_merits_rt1
        ,(perfect.perfect_wks_rt2 * 3) AS perfect_week_merits_rt2
        ,(perfect.perfect_wks_rt3 * 3) AS perfect_week_merits_rt3
        ,(perfect.perfect_wks_rt4 * 3) AS perfect_week_merits_rt4        
        ,(perfect.perfect_wks_cur * 3) AS perfect_week_merits_cur
  FROM KIPP_NJ..DISC$perfect_weeks#NCA perfect WITH(NOLOCK)
 )

,demerits AS (
  SELECT studentid                       
        ,demerits.academic_year
        ,COUNT(demerits.rn) AS total_demerits_y1
        ,SUM(CASE when demerits.rt = 'RT1' THEN 1 ELSE 0 END) AS total_demerits_rt1
        ,SUM(CASE when demerits.rt = 'RT2' THEN 1 ELSE 0 END) AS total_demerits_rt2
        ,SUM(CASE when demerits.rt = 'RT3' THEN 1 ELSE 0 END) AS total_demerits_rt3
        ,SUM(CASE when demerits.rt = 'RT4' THEN 1 ELSE 0 END) AS total_demerits_rt4
        ,SUM(CASE WHEN demerits.rt = curterm.time_per_name THEN 1 ELSE 0 END) AS total_demerits_cur                                              
  FROM KIPP_NJ..DISC$log#static demerits WITH(NOLOCK)
  JOIN curterm
    ON demerits.academic_year = curterm.academic_year    
  WHERE logtypeid = 3223
  GROUP BY studentid, demerits.academic_year
 )

,discipline AS (
  SELECT studentid 
        ,academic_year
        ,ISNULL([Detention_rt1],0) AS Detention_rt1
        ,ISNULL([Detention_rt2],0) AS Detention_rt2
        ,ISNULL([Detention_rt3],0) AS Detention_rt3
        ,ISNULL([Detention_rt4],0) AS Detention_rt4
        ,ISNULL([Detention_y1],0) AS Detention_y1
        ,ISNULL([Detention_cur],0) AS Detention_cur
        ,ISNULL([ISS_rt1],0) AS ISS_rt1
        ,ISNULL([ISS_rt2],0) AS ISS_rt2
        ,ISNULL([ISS_rt3],0) AS ISS_rt3
        ,ISNULL([ISS_rt4],0) AS ISS_rt4
        ,ISNULL([ISS_y1],0) AS ISS_y1
        ,ISNULL([ISS_cur],0) AS ISS_cur
        ,ISNULL([OSS_rt1],0) AS OSS_rt1
        ,ISNULL([OSS_rt2],0) AS OSS_rt2
        ,ISNULL([OSS_rt3],0) AS OSS_rt3
        ,ISNULL([OSS_rt4],0) AS OSS_rt4
        ,ISNULL([OSS_y1],0) AS OSS_y1
        ,ISNULL([OSS_cur],0) AS OSS_cur
        ,ISNULL([ISS_rt1],0) + ISNULL([OSS_rt1],0) AS suspensions_rt1
        ,ISNULL([ISS_rt2],0) + ISNULL([OSS_rt2],0) AS suspensions_rt2
        ,ISNULL([ISS_rt3],0) + ISNULL([OSS_rt3],0) AS suspensions_rt3
        ,ISNULL([ISS_rt4],0) + ISNULL([OSS_rt4],0) AS suspensions_rt4
        ,ISNULL([ISS_y1],0) + ISNULL([OSS_y1],0) AS suspensions_y1        
        ,ISNULL([ISS_cur],0) + ISNULL([OSS_cur],0) AS suspensions_cur
  FROM
      (
       SELECT studentid             
             ,academic_year
             ,subtype + '_' + RT AS hash
             ,COUNT(subtype) AS n
       FROM KIPP_NJ..DISC$log#static disc WITH(NOLOCK)
       WHERE logtypeid = -100000
         AND subtype IN ('Detention', 'ISS', 'OSS')
       GROUP BY studentid, subtype, rt, academic_year

       UNION ALL

       SELECT disc.studentid             
             ,disc.academic_year
             ,disc.subtype + '_cur' AS hash
             ,COUNT(disc.subtype) AS n
       FROM KIPP_NJ..DISC$log#static disc WITH(NOLOCK)
       JOIN curterm
         ON disc.academic_year = curterm.academic_year
        AND disc.RT = curterm.time_per_name
       WHERE disc.logtypeid = -100000
         AND disc.subtype IN ('Detention', 'ISS', 'OSS')
       GROUP BY disc.studentid, disc.subtype, disc.RT, disc.academic_year

       UNION ALL

       SELECT studentid             
             ,academic_year
             ,subtype + '_y1' AS hash
             ,COUNT(subtype) AS n
       FROM KIPP_NJ..DISC$log#static disc WITH(NOLOCK)
       WHERE logtypeid = -100000
         AND subtype IN ('Detention', 'ISS', 'OSS')
       GROUP BY studentid, subtype, academic_year
      ) sub
  
  PIVOT (
    MAX(n)
    FOR hash IN ([Detention_rt1]
                ,[Detention_rt2]
                ,[Detention_rt3]
                ,[Detention_rt4]
                ,[Detention_y1]
                ,[Detention_cur]
                ,[ISS_rt1]
                ,[ISS_rt2]
                ,[ISS_rt3]
                ,[ISS_rt4]
                ,[ISS_y1]
                ,[ISS_cur]
                ,[OSS_rt1]
                ,[OSS_rt2]
                ,[OSS_rt3]
                ,[OSS_rt4]
                ,[OSS_y1]
                ,[OSS_cur])
   ) p
 )

SELECT co.studentid
      ,co.student_number   
      ,co.year AS academic_year   
      ,ISNULL(tm.teacher_merits_y1,0) AS teacher_merits_y1
      ,ISNULL(tm.teacher_merits_rt1,0) AS teacher_merits_rt1
      ,ISNULL(tm.teacher_merits_rt2,0) AS teacher_merits_rt2
      ,ISNULL(tm.teacher_merits_rt3,0) AS teacher_merits_rt3
      ,ISNULL(tm.teacher_merits_rt4,0) AS teacher_merits_rt4
      ,ISNULL(tm.teacher_merits_cur,0) AS teacher_merits_cur
      ,ISNULL(pw.perfect_week_merits_y1,0) AS perfect_week_merits_y1
      ,ISNULL(pw.perfect_week_merits_rt1,0) AS perfect_week_merits_rt1
      ,ISNULL(pw.perfect_week_merits_rt2,0) AS perfect_week_merits_rt2
      ,ISNULL(pw.perfect_week_merits_rt3,0) AS perfect_week_merits_rt3
      ,ISNULL(pw.perfect_week_merits_rt4,0) AS perfect_week_merits_rt4
      ,ISNULL(pw.perfect_week_merits_cur,0) AS perfect_week_merits_cur
      ,ISNULL(tm.teacher_merits_y1,0) + ISNULL(pw.perfect_week_merits_y1,0) AS total_merits_y1
      ,ISNULL(tm.teacher_merits_rt1,0) + ISNULL(pw.perfect_week_merits_rt1,0) AS total_merits_rt1
      ,ISNULL(tm.teacher_merits_rt2,0) + ISNULL(pw.perfect_week_merits_rt2,0) AS total_merits_rt2
      ,ISNULL(tm.teacher_merits_rt3,0) + ISNULL(pw.perfect_week_merits_rt3,0) AS total_merits_rt3
      ,ISNULL(tm.teacher_merits_rt4,0) + ISNULL(pw.perfect_week_merits_rt4,0) AS total_merits_rt4
      ,ISNULL(tm.teacher_merits_cur,0) + ISNULL(pw.perfect_week_merits_cur,0) AS total_merits_cur
      ,ISNULL(d.total_demerits_y1,0) AS total_demerits_y1
      ,ISNULL(d.total_demerits_rt1,0) AS total_demerits_rt1
      ,ISNULL(d.total_demerits_rt2,0) AS total_demerits_rt2
      ,ISNULL(d.total_demerits_rt3,0) AS total_demerits_rt3
      ,ISNULL(d.total_demerits_rt4,0) AS total_demerits_rt4
      ,ISNULL(d.total_demerits_cur,0) AS total_demerits_cur
      ,ISNULL(disc.Detention_rt1,0) AS Detention_rt1
      ,ISNULL(disc.Detention_rt2,0) AS Detention_rt2
      ,ISNULL(disc.Detention_rt3,0) AS Detention_rt3
      ,ISNULL(disc.Detention_rt4,0) AS Detention_rt4
      ,ISNULL(disc.Detention_y1,0) AS Detention_y1
      ,ISNULL(disc.Detention_cur,0) AS Detention_cur
      ,ISNULL(disc.ISS_rt1,0) AS ISS_rt1
      ,ISNULL(disc.ISS_rt2,0) AS ISS_rt2
      ,ISNULL(disc.ISS_rt3,0) AS ISS_rt3
      ,ISNULL(disc.ISS_rt4,0) AS ISS_rt4
      ,ISNULL(disc.ISS_y1,0) AS ISS_y1
      ,ISNULL(disc.ISS_cur,0) AS ISS_cur
      ,ISNULL(disc.OSS_rt1,0) AS OSS_rt1
      ,ISNULL(disc.OSS_rt2,0) AS OSS_rt2
      ,ISNULL(disc.OSS_rt3,0) AS OSS_rt3
      ,ISNULL(disc.OSS_rt4,0) AS OSS_rt4
      ,ISNULL(disc.OSS_y1,0) AS OSS_y1
      ,ISNULL(disc.OSS_cur,0) AS OSS_cur
      ,ISNULL(disc.suspensions_rt1,0) AS suspensions_rt1
      ,ISNULL(disc.suspensions_rt2,0) AS suspensions_rt2
      ,ISNULL(disc.suspensions_rt3,0) AS suspensions_rt3
      ,ISNULL(disc.suspensions_rt4,0) AS suspensions_rt4
      ,ISNULL(disc.suspensions_y1,0) AS suspensions_y1
      ,ISNULL(disc.suspensions_cur,0) AS suspensions_cur
FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
LEFT OUTER JOIN teacher_merits tm
  ON co.studentid = tm.studentid
 AND co.year = tm.academic_year
LEFT OUTER JOIN perfect_wks pw
  ON co.studentid = pw.studentid
 AND co.year = pw.academic_year
LEFT OUTER JOIN demerits d 
  ON co.studentid = d.studentid
 AND co.year = d.academic_year
LEFT OUTER JOIN discipline disc
  ON co.studentid = disc.studentid
 AND co.year = disc.academic_year
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.schoolid = 73253
  AND co.rn = 1