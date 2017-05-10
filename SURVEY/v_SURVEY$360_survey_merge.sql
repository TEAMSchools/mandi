USE KIPP_NJ
GO

ALTER VIEW SURVEY$360_survey_merge AS

WITH responses_deduped AS (
  SELECT *
  FROM
      (
       SELECT r.associateid AS responder_associate_id      
             ,r.kippemail AS responder_email
             ,r.department AS recipient_department
             ,r.surveyassigment AS recipient_name                   
             ,CASE
               WHEN r.assignmentrelationship = 'Manager. He/she manages me.' THEN 'MGR'
               WHEN r.assignmentrelationship = 'Self. I am rating myself.' THEN 'SELF'
               WHEN r.assignmentrelationship = 'Direct Report. I manage him/her.' THEN 'DR'
               WHEN r.assignmentrelationship = 'Peer. I work with him/her' THEN 'PEER'
              END AS assignmentrelationship
             ,CONVERT(DATETIME,r.timesubmitted) AS timestamp
             ,ROW_NUMBER() OVER(
                PARTITION BY r.kippemail, r.surveyassigment
                  ORDER BY CONVERT(DATETIME,r.timesubmitted) DESC, r.BINI_ID DESC) AS rn_mostrecent
             ,strengths
             ,growths      
             ,sf1
             ,sf2
             ,ao1
             ,ao2
             ,ao3
             ,ao4
             ,ao5
             ,cl1
             ,cl2
             ,ct1
             ,ct2
             ,ct3
             ,ct4
             ,dm1
             ,dm2
             ,dm3
             ,dm4
             ,pe1
             ,pe2
             ,pe3
             ,pe4
             ,sm1
             ,sm2
             ,sm3
             ,c1
             ,c2
             ,c3
             ,c4
             ,ii1
             ,ii2
             ,ii3
             ,ii4
             ,sa1
             ,sa2
             ,sa3
             ,sa4
             ,cc1
             ,cc2
             ,cc3
             ,mds1
             ,mds2
             ,mds3
             ,mds4
             ,mtl1
             ,mtl2
             ,mtl3
             ,mtl4
             ,mtl5
             ,mpm1
             ,mpm2
             ,mpm3
             ,mpm4
             ,mom1
             ,mom2
             ,mom3
             ,mom4
       FROM KIPP_NJ..AUTOLOAD$GDOCS_PM_360_surveygizmo r WITH(NOLOCK)
      ) sub
  WHERE rn_mostrecent = 1
 )

,responses_unpivot AS (
  SELECT recipient_name        
        ,assignmentrelationship              
        ,UPPER(question_code) AS question_code
        ,UPPER(KIPP_NJ.dbo.fn_StripCharacters(question_code,'0-9')) AS competency_code
        ,CASE
          WHEN response = 'Always' THEN 5.0
          WHEN response = 'Almost Always' THEN 4.0
          WHEN response = 'Frequently' THEN 3.0
          WHEN response = 'Sometimes' THEN 2.0
          WHEN response = 'Rarely' THEN 1.0
         END AS response_value           
  FROM responses_deduped
  UNPIVOT(
    response
    FOR question_code IN (sf1
                         ,sf2
                         ,ao1
                         ,ao2
                         ,ao3
                         ,ao4
                         ,ao5
                         ,cl1
                         ,cl2
                         ,ct1
                         ,ct2
                         ,ct3
                         ,ct4
                         ,dm1
                         ,dm2
                         ,dm3
                         ,dm4
                         ,pe1
                         ,pe2
                         ,pe3
                         ,pe4
                         ,sm1
                         ,sm2
                         ,sm3
                         ,c1
                         ,c2
                         ,c3
                         ,c4
                         ,ii1
                         ,ii2
                         ,ii3
                         ,ii4
                         ,sa1
                         ,sa2
                         ,sa3
                         ,sa4
                         ,cc1
                         ,cc2
                         ,cc3
                         ,mds1
                         ,mds2
                         ,mds3
                         ,mds4
                         ,mtl1
                         ,mtl2
                         ,mtl3
                         ,mtl4
                         ,mtl5
                         ,mpm1
                         ,mpm2
                         ,mpm3
                         ,mpm4
                         ,mom1
                         ,mom2
                         ,mom3
                         ,mom4)
   ) u
 )

,responses_rollup AS (
  /* question avg */
  SELECT recipient_name     
        ,competency_code      
        ,question_code        
        ,assignmentrelationship
        ,AVG(response_value) AS avg_response_value
  FROM responses_unpivot r
  GROUP BY recipient_name
          ,assignmentrelationship
          ,competency_code
          ,question_code

  UNION ALL

  /* competency avg */
  SELECT recipient_name     
        ,competency_code      
        ,competency_code AS question_code        
        ,assignmentrelationship
        ,AVG(response_value) AS avg_response_value
  FROM responses_unpivot r
  GROUP BY recipient_name
          ,assignmentrelationship
          ,competency_code
 )

,r9_avgs AS (
  SELECT *
  FROM
      (
       SELECT CONCAT(question_code, '_', assignmentrelationship) AS pivot_field
             ,ROUND(CONVERT(FLOAT,avg_response_value), 1) AS avg_response_value
       FROM
           (
            SELECT question_code        
                  ,'R9' AS assignmentrelationship
                  ,AVG(response_value) AS avg_response_value
            FROM responses_unpivot r
            GROUP BY competency_code
                    ,question_code
            UNION ALL
            SELECT competency_code AS question_code        
                  ,'R9' AS assignmentrelationship
                  ,AVG(response_value) AS avg_response_value
            FROM responses_unpivot r
            GROUP BY competency_code
           ) sub
      ) sub
  PIVOT(
    MAX(avg_response_value)
    FOR pivot_field IN ([AO1_R9]
                       ,[AO2_R9]
                       ,[AO3_R9]
                       ,[AO4_R9]
                       ,[AO5_R9]
                       ,[C1_R9]
                       ,[C2_R9]
                       ,[C3_R9]
                       ,[C4_R9]
                       ,[CC1_R9]
                       ,[CC2_R9]
                       ,[CC3_R9]
                       ,[CL1_R9]
                       ,[CL2_R9]
                       ,[CT1_R9]
                       ,[CT2_R9]
                       ,[CT3_R9]
                       ,[CT4_R9]
                       ,[DM1_R9]
                       ,[DM2_R9]
                       ,[DM3_R9]
                       ,[DM4_R9]
                       ,[II1_R9]
                       ,[II2_R9]
                       ,[II3_R9]
                       ,[II4_R9]
                       ,[MDS1_R9]
                       ,[MDS2_R9]
                       ,[MDS3_R9]
                       ,[MDS4_R9]
                       ,[MOM1_R9]
                       ,[MOM2_R9]
                       ,[MOM3_R9]
                       ,[MOM4_R9]
                       ,[MPM1_R9]
                       ,[MPM2_R9]
                       ,[MPM3_R9]
                       ,[MPM4_R9]
                       ,[MTL1_R9]
                       ,[MTL2_R9]
                       ,[MTL3_R9]
                       ,[MTL4_R9]
                       ,[MTL5_R9]
                       ,[PE1_R9]
                       ,[PE2_R9]
                       ,[PE3_R9]
                       ,[PE4_R9]
                       ,[SA1_R9]
                       ,[SA2_R9]
                       ,[SA3_R9]
                       ,[SA4_R9]
                       ,[SF1_R9]
                       ,[SF2_R9]
                       ,[SM1_R9]
                       ,[SM2_R9]
                       ,[SM3_R9]
                       ,[AO_R9]
                       ,[C_R9]
                       ,[CC_R9]
                       ,[CL_R9]
                       ,[CT_R9]
                       ,[DM_R9]
                       ,[II_R9]
                       ,[MDS_R9]
                       ,[MOM_R9]
                       ,[MPM_R9]
                       ,[MTL_R9]
                       ,[PE_R9]
                       ,[SA_R9]
                       ,[SF_R9]
                       ,[SM_R9])
   ) p
 ) 

,responses_rollup_pivot AS (
  SELECT *
  FROM
      (
       SELECT recipient_name
             ,CONCAT(question_code, '_', assignmentrelationship) AS pivot_field
             ,ROUND(CONVERT(FLOAT,avg_response_value), 1) AS avg_response_value
       FROM responses_rollup
      ) sub
  PIVOT(
    MAX(avg_response_value)
    FOR pivot_field IN ([AO1_DR]
                       ,[AO2_DR]
                       ,[AO3_DR]
                       ,[AO4_DR]
                       ,[AO5_DR]
                       ,[C1_DR]
                       ,[C2_DR]
                       ,[C3_DR]
                       ,[C4_DR]
                       ,[CC1_DR]
                       ,[CC2_DR]
                       ,[CC3_DR]
                       ,[CL1_DR]
                       ,[CL2_DR]
                       ,[CT1_DR]
                       ,[CT2_DR]
                       ,[CT3_DR]
                       ,[CT4_DR]
                       ,[DM1_DR]
                       ,[DM2_DR]
                       ,[DM3_DR]
                       ,[II1_DR]
                       ,[II2_DR]
                       ,[II3_DR]
                       ,[II4_DR]
                       ,[MDS1_DR]
                       ,[MDS2_DR]
                       ,[MDS3_DR]
                       ,[MOM1_DR]
                       ,[MOM2_DR]
                       ,[MOM4_DR]
                       ,[PE1_DR]
                       ,[PE2_DR]
                       ,[PE3_DR]
                       ,[PE4_DR]
                       ,[SA1_DR]
                       ,[SA2_DR]
                       ,[SA3_DR]
                       ,[SA4_DR]
                       ,[SF1_DR]
                       ,[SF2_DR]
                       ,[SM1_DR]
                       ,[SM2_DR]
                       ,[SM3_DR]
                       ,[AO1_PEER]
                       ,[AO2_PEER]
                       ,[AO3_PEER]
                       ,[AO4_PEER]
                       ,[AO5_PEER]
                       ,[C1_PEER]
                       ,[C2_PEER]
                       ,[C3_PEER]
                       ,[C4_PEER]
                       ,[CC1_PEER]
                       ,[CC2_PEER]
                       ,[CC3_PEER]
                       ,[CL1_PEER]
                       ,[CL2_PEER]
                       ,[CT1_PEER]
                       ,[CT2_PEER]
                       ,[CT3_PEER]
                       ,[CT4_PEER]
                       ,[DM1_PEER]
                       ,[DM2_PEER]
                       ,[DM3_PEER]
                       ,[DM4_PEER]
                       ,[II1_PEER]
                       ,[II2_PEER]
                       ,[II3_PEER]
                       ,[II4_PEER]
                       ,[MDS1_PEER]
                       ,[MDS2_PEER]
                       ,[MDS3_PEER]
                       ,[MDS4_PEER]
                       ,[MOM1_PEER]
                       ,[MOM2_PEER]
                       ,[MOM3_PEER]
                       ,[MOM4_PEER]
                       ,[PE1_PEER]
                       ,[PE2_PEER]
                       ,[PE3_PEER]
                       ,[PE4_PEER]
                       ,[SA1_PEER]
                       ,[SA2_PEER]
                       ,[SA3_PEER]
                       ,[SA4_PEER]
                       ,[SF1_PEER]
                       ,[SF2_PEER]
                       ,[SM1_PEER]
                       ,[SM2_PEER]
                       ,[SM3_PEER]
                       ,[AO1_SELF]
                       ,[AO2_SELF]
                       ,[AO3_SELF]
                       ,[AO4_SELF]
                       ,[AO5_SELF]
                       ,[C1_SELF]
                       ,[C2_SELF]
                       ,[C3_SELF]
                       ,[C4_SELF]
                       ,[CC1_SELF]
                       ,[CC2_SELF]
                       ,[CC3_SELF]
                       ,[CL1_SELF]
                       ,[CL2_SELF]
                       ,[CT1_SELF]
                       ,[CT2_SELF]
                       ,[CT3_SELF]
                       ,[CT4_SELF]
                       ,[DM1_SELF]
                       ,[DM2_SELF]
                       ,[DM3_SELF]
                       ,[DM4_SELF]
                       ,[II2_SELF]
                       ,[MDS1_SELF]
                       ,[MDS2_SELF]
                       ,[MDS3_SELF]
                       ,[MOM1_SELF]
                       ,[MOM2_SELF]
                       ,[MOM3_SELF]
                       ,[PE1_SELF]
                       ,[PE2_SELF]
                       ,[PE3_SELF]
                       ,[PE4_SELF]
                       ,[SA1_SELF]
                       ,[SA3_SELF]
                       ,[SA4_SELF]
                       ,[SF1_SELF]
                       ,[SF2_SELF]
                       ,[SM1_SELF]
                       ,[SM2_SELF]
                       ,[SM3_SELF]
                       ,[MPM1_PEER]
                       ,[MPM2_PEER]
                       ,[MPM4_PEER]
                       ,[MTL1_PEER]
                       ,[MTL4_PEER]
                       ,[DM4_DR]
                       ,[MDS4_DR]
                       ,[MOM3_DR]
                       ,[MPM1_DR]
                       ,[MPM3_DR]
                       ,[MPM4_DR]
                       ,[MTL1_DR]
                       ,[MTL2_DR]
                       ,[MTL3_DR]
                       ,[MTL4_DR]
                       ,[MPM3_PEER]
                       ,[MTL2_PEER]
                       ,[MTL3_PEER]
                       ,[MTL5_PEER]
                       ,[MPM2_DR]
                       ,[MTL5_DR]
                       ,[AO1_MGR]
                       ,[AO2_MGR]
                       ,[AO3_MGR]
                       ,[AO4_MGR]
                       ,[AO5_MGR]
                       ,[C1_MGR]
                       ,[C2_MGR]
                       ,[C3_MGR]
                       ,[C4_MGR]
                       ,[CC1_MGR]
                       ,[CC2_MGR]
                       ,[CC3_MGR]
                       ,[CL1_MGR]
                       ,[CL2_MGR]
                       ,[CT1_MGR]
                       ,[CT2_MGR]
                       ,[CT3_MGR]
                       ,[CT4_MGR]
                       ,[DM1_MGR]
                       ,[DM2_MGR]
                       ,[DM3_MGR]
                       ,[DM4_MGR]
                       ,[II1_MGR]
                       ,[II2_MGR]
                       ,[II3_MGR]
                       ,[II4_MGR]
                       ,[MDS1_MGR]
                       ,[MDS2_MGR]
                       ,[MDS3_MGR]
                       ,[MDS4_MGR]
                       ,[MOM1_MGR]
                       ,[MOM2_MGR]
                       ,[MOM3_MGR]
                       ,[MOM4_MGR]
                       ,[MPM1_MGR]
                       ,[MPM2_MGR]
                       ,[MPM3_MGR]
                       ,[MPM4_MGR]
                       ,[MTL1_MGR]
                       ,[MTL2_MGR]
                       ,[MTL3_MGR]
                       ,[MTL4_MGR]
                       ,[MTL5_MGR]
                       ,[PE1_MGR]
                       ,[PE2_MGR]
                       ,[PE3_MGR]
                       ,[PE4_MGR]
                       ,[SA1_MGR]
                       ,[SA2_MGR]
                       ,[SA3_MGR]
                       ,[SA4_MGR]
                       ,[SF1_MGR]
                       ,[SF2_MGR]
                       ,[SM1_MGR]
                       ,[SM2_MGR]
                       ,[SM3_MGR]
                       ,[II1_SELF]
                       ,[II3_SELF]
                       ,[II4_SELF]
                       ,[MDS4_SELF]
                       ,[MOM4_SELF]
                       ,[MPM1_SELF]
                       ,[MPM2_SELF]
                       ,[MPM3_SELF]
                       ,[MPM4_SELF]
                       ,[MTL1_SELF]
                       ,[MTL2_SELF]
                       ,[MTL3_SELF]
                       ,[MTL4_SELF]
                       ,[MTL5_SELF]
                       ,[SA2_SELF]
                       ,[AO_DR]
                       ,[C_DR]
                       ,[CC_DR]
                       ,[CL_DR]
                       ,[CT_DR]
                       ,[DM_DR]
                       ,[II_DR]
                       ,[MDS_DR]
                       ,[MOM_DR]
                       ,[PE_DR]
                       ,[SA_DR]
                       ,[SF_DR]
                       ,[SM_DR]
                       ,[AO_PEER]
                       ,[C_PEER]
                       ,[CC_PEER]
                       ,[CL_PEER]
                       ,[CT_PEER]
                       ,[DM_PEER]
                       ,[II_PEER]
                       ,[MDS_PEER]
                       ,[MOM_PEER]
                       ,[PE_PEER]
                       ,[SA_PEER]
                       ,[SF_PEER]
                       ,[SM_PEER]
                       ,[AO_SELF]
                       ,[C_SELF]
                       ,[CC_SELF]
                       ,[CL_SELF]
                       ,[CT_SELF]
                       ,[DM_SELF]
                       ,[II_SELF]
                       ,[MDS_SELF]
                       ,[MOM_SELF]
                       ,[PE_SELF]
                       ,[SA_SELF]
                       ,[SF_SELF]
                       ,[SM_SELF]
                       ,[MPM_PEER]
                       ,[MTL_PEER]
                       ,[MPM_DR]
                       ,[MTL_DR]
                       ,[AO_MGR]
                       ,[C_MGR]
                       ,[CC_MGR]
                       ,[CL_MGR]
                       ,[CT_MGR]
                       ,[DM_MGR]
                       ,[II_MGR]
                       ,[MDS_MGR]
                       ,[MOM_MGR]
                       ,[MPM_MGR]
                       ,[MTL_MGR]
                       ,[PE_MGR]
                       ,[SA_MGR]
                       ,[SF_MGR]
                       ,[SM_MGR]
                       ,[MPM_SELF]
                       ,[MTL_SELF])
   ) p
 )

,openended_responses AS (
  SELECT recipient_name
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(strengths, CHAR(10) + CHAR(13)) AS strengths_grouped
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(growths, CHAR(10) + CHAR(13)) AS growths_grouped
  FROM responses_deduped
  GROUP BY recipient_name
 )

SELECT r.*      
      ,r9.*
      ,p.department
      ,p.manager_name
      ,oe.strengths_grouped
      ,oe.growths_grouped
FROM responses_rollup_pivot r
CROSS JOIN r9_avgs r9
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PM_survey_roster p WITH(NOLOCK)
   ON r.recipient_name = p.firstlast
JOIN openended_responses oe
  ON r.recipient_name = oe.recipient_name