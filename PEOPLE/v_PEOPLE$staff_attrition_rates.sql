USE KIPP_NJ
GO

ALTER VIEW PEOPLE$staff_attrition_rates AS

WITH people AS (
  SELECT associate_id      
        --,CONCAT(preferred_first, ' ', preferred_last) AS preferred_firstlast        
        --,job_title
        --,location
        ,CASE          
          --WHEN location IN ('KIPP NJ','Room 9') THEN 0
          WHEN location = 'Rise Academy' THEN 73252
          WHEN location = 'Newark Collegiate Academy' THEN 73253
          WHEN location = 'SPARK Academy' THEN 73254
          WHEN location = 'THRIVE Academy' THEN 73255
          WHEN location = 'Seek Academy' THEN 73256
          WHEN location IN ('Life Academy','Life Upper') THEN 73257
          WHEN location = 'Bold Academy' THEN 73258
          WHEN location = 'Lanning Square Primary' THEN 179901
          WHEN location = 'Lanning Square Middle' THEN 179902
          WHEN location = 'TEAM Academy' THEN 133570965
         END AS adp_schoolid        
        ,termination_reason        
        ,KIPP_NJ.dbo.fn_DateToSY(hire_date) AS start_academic_year        
        ,KIPP_NJ.dbo.fn_DateToSY(termination_date) AS end_academic_year                        
        --,benefits_elig_class
  FROM KIPP_NJ..PEOPLE$ADP_detail WITH(NOLOCK)
  WHERE rn_curr = 1
    AND benefits_elig_class = 'Full Time Instructional'
 )

,years AS (
  SELECT n AS academic_year        
  FROM KIPP_NJ..UTIL$row_generator WITH(NOLOCK)
  WHERE n BETWEEN 2002 AND KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

,schoolid_history AS (
  SELECT *        
        ,ROW_NUMBER() OVER(
           PARTITION BY associate_id
             ORDER BY academic_year ASC) AS school_rn_base
        ,ROW_NUMBER() OVER(
           PARTITION BY associate_id
             ORDER BY academic_year DESC) AS school_rn_curr
  FROM
      (
       SELECT DISTINCT
              sec.academic_year
             ,sec.SCHOOLID AS ps_schoolid
             ,CASE
               WHEN ISNUMERIC(COALESCE(link.associate_id,t.TEACHERNUMBER)) = 1 THEN NULL
               ELSE COALESCE(link.associate_id,t.TEACHERNUMBER)
              END AS associate_id        
       FROM KIPP_NJ..PS$SECTIONS#static sec
       JOIN KIPP_NJ..PS$TEACHERS#static t
         ON sec.TEACHER = t.ID
       LEFT OUTER JOIN KIPP_NJ..PEOPLE$ADP_PS_linking link
         ON t.TEACHERNUMBER = link.TEACHERNUMBER  
      ) sub
 )

,clean_scaffold AS (
  SELECT associate_id
        --,preferred_firstlast
        --,location
        ,academic_year
        ,termination_reason           
        ,CASE        
          WHEN ps_schoolid IS NULL AND first_schoolid != last_schoolid THEN NULL
          ELSE COALESCE(ps_schoolid, adp_schoolid)
         END AS schoolid
  FROM
      (
       SELECT p.associate_id
             --,p.preferred_firstlast                  
             --,p.job_title
             --,p.location
             ,CASE WHEN y.academic_year = p.end_academic_year THEN p.termination_reason ELSE NULL END AS termination_reason
             ,y.academic_year                
             --,s.school_rn_base
             --,s.school_rn_curr
             ,s.ps_schoolid
             ,p.adp_schoolid                                
             ,MAX(CASE WHEN s.school_rn_base = 1 THEN s.ps_schoolid END) OVER(PARTITION BY p.associate_id) AS first_schoolid
             ,MAX(CASE WHEN s.school_rn_curr = 1 THEN s.ps_schoolid END) OVER(PARTITION BY p.associate_id) AS last_schoolid                
             --,ROW_NUMBER() OVER(
             --   PARTITION BY p.associate_id
             --     ORDER BY y.academic_year ASC) AS rn_base
       FROM people p
       JOIN years y
         ON p.start_academic_year <= y.academic_year
        AND ((p.end_academic_year >= y.academic_year) OR (p.end_academic_year IS NULL))
       LEFT OUTER JOIN schoolid_history s
         ON p.associate_id = s.associate_id
        AND y.academic_year = s.academic_year          
      ) sub
 )

SELECT schoolid
      ,academic_year
      ,CONVERT(FLOAT,AVG(is_attrition) * 100) AS pct_attrition
      ,CONVERT(FLOAT,AVG(is_wanted_attrition) * 100) AS pct_wanted_attrition
      ,CONVERT(FLOAT,AVG(is_unwanted_attrition) * 100) AS pct_unwanted_attrition
FROM
    (
     SELECT associate_id
           ,academic_year
           ,schoolid
           --,termination_reason
           ,CASE WHEN termination_reason IS NOT NULL THEN 1.0 ELSE 0.0 END AS is_attrition
           ,CASE WHEN termination_reason IN ('Attendance','Involuntary','Performance','Reorganization','End of Contract') THEN 1.0 ELSE 0.0 END AS is_wanted_attrition
           ,CASE WHEN termination_reason IN ('Personal','Resignation','Voluntary') THEN 1.0 ELSE 0.0 END AS is_unwanted_attrition
     FROM clean_scaffold
    ) sub
GROUP BY schoolid
        ,academic_year