USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$attendance_counts_long AS

WITH att_counts AS (
  SELECT STUDENTID
        ,academic_year
        ,rt        
        ,ATT_CODE
        ,counts_term        
  FROM
      (
       SELECT STUDENTID
             ,academic_year
             ,rt             
             ,att_code
             ,COUNT(ID) AS counts_term
       FROM
           (
            SELECT att.STUDENTID
                  ,att.academic_year            
                  ,dates.time_per_name AS rt                  
                  ,CASE
                    WHEN att.att_code IN ('X') THEN 'A'
                    WHEN att.att_code IN ('A-E','D') THEN 'AD'
                    WHEN att.att_code IN ('EA','E') THEN 'AE'
                    WHEN att.att_code IN ('A-E','D') THEN 'AD'
                    WHEN att.att_code IN ('S','Q') THEN 'ISS'
                    WHEN att.att_code IN ('OS') THEN 'OSS'
                    WHEN att.att_code IN ('TLE') THEN 'T'
                    WHEN att.att_code IN ('ET') THEN 'TE'
                    ELSE att.att_code
                   END AS att_code
                  ,att.ID                  
            FROM KIPP_NJ..ATT_MEM$ATTENDANCE att WITH (NOLOCK)
            JOIN KIPP_NJ..REPORTING$dates dates WITH (NOLOCK)
              ON att.att_date BETWEEN dates.start_date AND dates.end_date
             AND att.academic_year = dates.academic_year
             AND att.schoolid = dates.schoolid
             AND dates.identifier = 'RT' 
            WHERE att.att_code IS NOT NULL /* present */
              AND att.ATT_CODE NOT IN ('NM','OSSP','PLE','U','CS','CR','EV','SE') /* effectively present */
           ) sub
       GROUP BY STUDENTID
               ,academic_year            
               ,rt               
               ,att_code
      ) sub
 )

,scaffold AS (
  SELECT co.studentid        
        ,co.year AS academic_year
        ,d.time_per_name AS rt
        ,d.alt_name AS term
        ,att.ATT_CODE
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON co.schoolid = d.schoolid
   AND co.year = d.academic_year
   AND d.identifier = 'RT'
  JOIN KIPP_NJ..ATT_MEM$att_codes#static att WITH(NOLOCK)
    ON co.schoolid  = att.SCHOOLID   
   AND d.yearid = att.yearid
   AND att.att_code IS NOT NULL /* present */
   AND att.ATT_CODE NOT IN ('NM','OSSP','PLE','U','CS','CR','EV','SE') /* effectively present */
  WHERE co.rn = 1
 )

,counts_long AS (
  SELECT studentid
        ,academic_year
        ,rt
        ,term
        ,CONCAT(att_code,'_',field) AS pivot_field
        ,counts
  FROM
      (
       SELECT s.STUDENTID
             ,s.academic_year
             ,s.rt
             ,s.term
             ,s.att_code
             ,ISNULL(a.counts_term,0) AS counts_term
             ,SUM(ISNULL(a.counts_term,0)) OVER(PARTITION BY s.studentid, s.academic_year, s.att_code ORDER BY s.rt) AS counts_yr
       FROM scaffold s
       LEFT OUTER JOIN att_counts a
         ON s.studentid = a.STUDENTID
        AND s.academic_year = a.academic_year
        AND s.rt = a.rt
        AND s.ATT_CODE = a.att_code

       UNION ALL

       SELECT studentid
             ,academic_year
             ,rt
             ,term
             ,att_code
             ,counts_term
             ,SUM(counts_term) OVER(PARTITION BY studentid, academic_year ORDER BY rt) AS counts_year
       FROM
           (
            SELECT co.studentid
                  ,co.year AS academic_year      
                  ,d.time_per_name AS rt
                  ,d.alt_name AS term
                  ,'MEM' AS att_code
                  ,SUM(CONVERT(FLOAT,ISNULL(mem.membershipvalue,0))) AS counts_term      
            FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
            JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
              ON co.schoolid = d.schoolid 
             AND co.year = d.academic_year
             AND d.identifier = 'RT'
            LEFT OUTER JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
              ON co.studentid = mem.STUDENTID
             AND co.year = mem.academic_year
             AND CONVERT(DATE,mem.calendardate) BETWEEN d.start_date AND d.end_date
            WHERE co.rn = 1
            GROUP BY co.studentid
                    ,co.year
                    ,d.time_per_name
                    ,d.alt_name
           ) sub
      ) sub
  UNPIVOT(
    counts
    FOR field IN (counts_term, counts_yr)
   ) u
 )

SELECT *
      ,ISNULL(A_counts_yr,0) + ISNULL(AD_counts_yr,0) AS ABS_all_counts_yr
      ,ISNULL(A_counts_term,0) + ISNULL(AD_counts_term,0) AS ABS_all_counts_term
      ,ISNULL(T_counts_yr,0) + ISNULL(T10_counts_yr,0) AS TDY_all_counts_yr
      ,ISNULL(T_counts_term,0) + ISNULL(T10_counts_term,0) AS TDY_all_counts_term      

      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, academic_year
           ORDER BY rt DESC) AS rn_curterm
FROM counts_long
PIVOT(
  MAX(counts)
  FOR pivot_field IN ([A_counts_term]
                     ,[A_counts_yr]
                     ,[AD_counts_term]
                     ,[AD_counts_yr]
                     ,[AE_counts_term]
                     ,[AE_counts_yr]
                     ,[ISS_counts_term]
                     ,[ISS_counts_yr]
                     ,[OSS_counts_term]
                     ,[OSS_counts_yr]
                     ,[T_counts_term]
                     ,[T_counts_yr]
                     ,[T10_counts_term]
                     ,[T10_counts_yr]
                     ,[TE_counts_term]
                     ,[TE_counts_yr]
                     ,[MEM_counts_term]
                     ,[MEM_counts_yr])
 ) p