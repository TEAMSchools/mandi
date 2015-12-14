USE KIPP_NJ
GO

ALTER VIEW TNTP$insight_survey_data_long AS

SELECT academic_year
      ,term
      ,school
      ,CASE
        WHEN school = 'Rise Academy' THEN 73252
        WHEN school = 'Newark Collegiate Academy' THEN 73253
        WHEN school = 'SPARK Academy' THEN 73254
        WHEN school = 'THRIVE Academy' THEN 73255
        WHEN school = 'Seek Academy' THEN 73256
        WHEN school = 'Life Academy - Lower' THEN 73257
        WHEN school = 'Life Academy - Upper' THEN 73257
        WHEN school = 'Revolution Primary' THEN 179901
        WHEN school = 'TEAM Academy' THEN 133570965
       END AS schoolid
      ,domain
      ,field
      ,value
FROM KIPP_NJ..[AUTOLOAD$GDOCS_TNTP_insight_survey_data] WITH(NOLOCK)