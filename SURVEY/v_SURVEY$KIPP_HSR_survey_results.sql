USE KIPP_NJ
GO

USE KIPP_NJ
GO

ALTER VIEW SURVEY$KIPP_HSR_survey_results AS

SELECT LEFT(school_year,4) AS academic_year
      ,role AS survey_type
      ,school       
      ,CASE
        WHEN school = 'Newark Collegiate Academy, a KIPP school' THEN 73253
        WHEN school = 'Seek Academy, a KIPP school' THEN 73256
        WHEN school = 'Rise Academy, a KIPP school' THEN 73252
        WHEN school = 'SPARK Academy, a KIPP school' THEN 73254
        WHEN school = 'TEAM Academy, a KIPP school' THEN 133570965
        WHEN school = 'THRIVE Academy, a KIPP school' THEN 73255
        WHEN school = 'Life Academy at Bragaw, a KIPP school' THEN 73257
        WHEN school = 'Revolution Primary, a KIPP school' THEN 179901
       END AS schoolid
      ,parent_topic AS domain
      ,topic_name AS strand
      ,question_id
      ,survey_question       

      /* school */
      ,n_count
      ,likert_5scale_survey_score AS avg_response
      ,likert_1_ AS pct_likert_1
      ,likert_2_ AS pct_likert_2
      ,likert_3_ AS pct_likert_3
      ,likert_4_ AS pct_likert_4
      ,likert_5_ AS pct_likert_5
      ,pct_positive_response__school_average AS pct_top_box      

      /* region */
      ,n_count__regional      
      ,likert_5scale_survey_score__regional
      ,likert_1___regional
      ,likert_2___regional
      ,likert_3___regional
      ,likert_4___regional
      ,likert_5___regional
      ,pct_positive_response__region_average
      
      /* national */
      ,n_count__national
      ,likert_5scale_survey_score__national
      ,likert_1___national
      ,likert_2___national
      ,likert_3___national
      ,likert_4___national
      ,likert_5___national
      ,pct_positive_response__national_average      

      /* like school? */
      ,n_count__like_school
      ,likert_5scale_survey_score__like_school     
      ,pct_positive_response__like_school_average      
FROM KIPP_NJ..AUTOLOAD$GDOCS_SURVEY_hsr_survey_data WITH(NOLOCK)