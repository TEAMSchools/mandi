USE KIPP_NJ
GO

ALTER VIEW DISC$log_counts_long AS

SELECT student_number
      ,academic_year
      ,time_per_name
      ,term
      ,logtype
      ,logtypeid
      ,n_logs_term
      ,SUM(n_logs_term) OVER(PARTITION BY student_number, academic_year, logtypeid ORDER BY time_per_name) AS n_logs_yr
FROM
    (
     SELECT co.student_number
           ,co.year AS academic_year
           ,d.time_per_name
           ,d.alt_name AS term
           ,logtype.logtype
           ,logtype.logtypeid      
           ,ISNULL(COUNT(disc.studentid),0) AS n_logs_term
     FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
     JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
       ON co.year = d.academic_year
      AND co.schoolid = d.schoolid
      AND d.identifier = 'RT'
     JOIN KIPP_NJ..DISC$logtypes#static logtype WITH(NOLOCK)
       ON logtype.logtypeid IN (3023, 3223, -100000)
     LEFT OUTER JOIN KIPP_NJ..DISC$log#static disc WITH(NOLOCK)
       ON co.studentid = disc.studentid
      AND co.year = disc.academic_year
      AND d.time_per_name = disc.rt
      AND logtype.logtypeid = disc.logtypeid
     WHERE co.rn = 1
     GROUP BY co.student_number
             ,co.year
             ,d.time_per_name
             ,d.alt_name      
             ,logtype.logtype
             ,logtype.logtypeid      
    ) sub