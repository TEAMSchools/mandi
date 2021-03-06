USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$staff_attrition AS

WITH roster AS (
  SELECT associate_id
        ,LEFT(position_id,3) AS entity
        ,preferred_first
        ,preferred_last
        ,position_start_date
        ,termination_date        
        ,benefits_elig_class
        ,KIPP_NJ.dbo.fn_DateToSY(position_start_date) AS start_academic_year
        ,KIPP_NJ.dbo.fn_DateToSY(termination_date) AS end_academic_year
  FROM KIPP_NJ..PEOPLE$ADP_detail
 )

,years AS (
  SELECT n AS academic_year
  FROM KIPP_NJ..UTIL$row_generator
  WHERE n BETWEEN 2000 AND KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

,scaffold AS (
  SELECT associate_id
        ,entity
        ,preferred_first
        ,preferred_last
        ,benefits_elig_class
        ,academic_year
        ,termination_date
        ,academic_year_entrydate
        ,academic_year_exitdate
  FROM
      (
       SELECT r.associate_id
             ,r.entity
             ,r.preferred_first
             ,r.preferred_last                          
             ,r.benefits_elig_class
             ,CASE WHEN r.end_academic_year =  y.academic_year THEN r.termination_date END AS termination_date
      
             ,y.academic_year

             ,CASE WHEN r.start_academic_year = y.academic_year THEN r.position_start_date ELSE DATEFROMPARTS(y.academic_year, 7, 1) END AS academic_year_entrydate
             ,CASE                 
               WHEN r.end_academic_year = y.academic_year THEN COALESCE(r.termination_date, DATEFROMPARTS((y.academic_year + 1), 6, 30))
               ELSE DATEFROMPARTS((y.academic_year + 1), 6, 30)
              END AS academic_year_exitdate
             ,ROW_NUMBER() OVER(
                PARTITION BY r.associate_id, y.academic_year
                  ORDER BY r.position_start_date DESC, COALESCE(r.termination_date,CONVERT(DATE,GETDATE())) DESC) AS rn_dupe_academic_year
       FROM roster r
       JOIN years y
         ON y.academic_year BETWEEN r.start_academic_year AND COALESCE(r.end_academic_year, KIPP_NJ.dbo.fn_Global_Academic_Year())
      ) sub
  WHERE rn_dupe_academic_year = 1
 )

SELECT d.associate_id
      ,d.entity
      ,d.preferred_first
      ,d.preferred_last
      ,d.benefits_elig_class
      ,d.academic_year      
      ,d.academic_year_entrydate      
      ,d.academic_year_exitdate
      ,CASE 
        WHEN d.academic_year_entrydate <= DATEFROMPARTS((d.academic_year + 1), 4, 30) AND d.academic_year_exitdate >= DATEFROMPARTS(d.academic_year, 9, 1) THEN 1         
        ELSE 0 
       END AS is_denominator      

      ,n.academic_year_exitdate AS next_academic_year_exitdate
      ,d.termination_date     
      ,COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS(d.academic_year + 2, 6, 30)) AS attrition_exitdate 
      ,CASE
        WHEN COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS(d.academic_year + 2, 6, 30)) < DATEFROMPARTS(d.academic_year + 1, 9, 1) THEN 1
        ELSE 0
       END AS is_attrition
FROM scaffold d
LEFT OUTER JOIN scaffold n
  ON d.associate_id = n.associate_id
 AND d.academic_year = (n.academic_year - 1)