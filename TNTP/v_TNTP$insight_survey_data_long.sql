USE KIPP_NJ
GO

ALTER VIEW TNTP$insight_survey_data_long AS

SELECT academic_year
      ,term
      ,school
      ,CASE
        WHEN school IN ('KIPP Newark Average','KIPP NJ Average','KIPP NJ Charters Average','KIPP NJ Network Average') THEN 0
        WHEN school = 'TEAM Academy' THEN 133570965
        WHEN school = 'Rise Academy' THEN 73252
        WHEN school = 'Newark Collegiate Academy' THEN 73253
        WHEN school = 'SPARK Academy' THEN 73254
        WHEN school = 'THRIVE Academy' THEN 73255
        WHEN school = 'Seek Academy' THEN 73256
        WHEN school IN ('Life Academy - Lower','Life Academy - Upper','Life Academy at Bragaw') THEN 73257
        WHEN school = 'BOLD Academy' THEN 73258
        WHEN school IN ('Revolution Primary','KIPP Lanning Square Primary School') THEN 179901
        WHEN school = 'KIPP Lanning Square Middle School' THEN 179902        
        WHEN school = 'Newark Charters Site Average' THEN 99 
        WHEN school = 'Newark Charters Top Quartile' THEN 9975
        WHEN school IN ('New Jersey Charter Schools Site Average','New Jersey Charters Average') THEN 999
        WHEN school = 'New Jersey Charters Top Quartile' THEN 99975
        WHEN school = 'National Charters Site Average' THEN 9999
        WHEN school = 'National Charters Top Quartile Average' THEN 999975
       END AS schoolid
      ,domain
      ,LTRIM(RTRIM(REPLACE(field,'*',''))) AS field
      ,value
FROM KIPP_NJ..[AUTOLOAD$GDOCS_TNTP_insight_survey_data] WITH(NOLOCK)