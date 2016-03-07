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
           ,disc.logtype
           ,disc.logtypeid      
           ,COUNT(disc.studentid) AS n_logs_term
     FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
     JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
       ON co.year = d.academic_year
      AND co.schoolid = d.schoolid
      AND d.identifier = 'RT'
     LEFT OUTER JOIN KIPP_NJ..DISC$log#static disc WITH(NOLOCK)
       ON co.studentid = disc.studentid
      AND co.year = disc.academic_year
      AND d.time_per_name = disc.rt
     WHERE co.rn = 1
     GROUP BY co.student_number
             ,co.year
             ,d.time_per_name
             ,d.alt_name      
             ,disc.logtype
             ,disc.logtypeid      
    ) sub