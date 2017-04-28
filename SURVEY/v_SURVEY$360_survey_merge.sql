USE KIPP_NJ
GO

ALTER VIEW SURVEY$360_survey_merge AS

WITH responses_deduped AS (
  SELECT *
  FROM
      (
       SELECT associateid AS responder_associate_id      
             ,kippemail AS responder_email
             ,department AS recipient_department
             ,surveyassigment AS recipient_name
             ,CASE
               WHEN assignmentrelationship = 'Manager. He/she manages me.' THEN 'MGR'
               WHEN assignmentrelationship = 'Self. I am rating myself.' THEN 'SELF'
               WHEN assignmentrelationship = 'Direct Report. I manage him/her.' THEN 'DR'
               WHEN assignmentrelationship = 'Peer. I work with him/her' THEN 'PEER'
              END AS assignmentrelationship
             ,CONVERT(DATETIME,timesubmitted) AS timestamp
             ,ROW_NUMBER() OVER(
                PARTITION BY kippemail, surveyassigment
                  ORDER BY CONVERT(DATETIME,timesubmitted) DESC, BINI_ID DESC) AS rn_mostrecent
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
       FROM KIPP_NJ..AUTOLOAD$GDOCS_PM_360_surveygizmo WITH(NOLOCK)
      ) sub
  WHERE rn_mostrecent = 1
 )

,responses_unpivot AS (
  SELECT recipient_name        
        ,assignmentrelationship              
        ,UPPER(question_code) AS question_code
        ,UPPER(KIPP_NJ.dbo.fn_StripCharacters(question_code,'0-9')) AS competency_code
        ,CASE
          WHEN response = 'Always' THEN 5
          WHEN response = 'Almost Always' THEN 4
          WHEN response = 'Frequently' THEN 3
          WHEN response = 'Sometimes' THEN 2
          WHEN response = 'Rarely' THEN 1
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

  UNION ALL

  /* R9 AVG */
  SELECT DISTINCT 
         recipient_name     
        ,competency_code      
        ,question_code        
        ,'R9' AS assignmentrelationship
        ,AVG(response_value) OVER(PARTITION BY competency_code, question_code) AS avg_response_value
  FROM responses_unpivot r
  UNION ALL
  SELECT DISTINCT
         recipient_name     
        ,competency_code      
        ,competency_code AS question_code        
        ,'R9' AS assignmentrelationship
        ,AVG(response_value) OVER(PARTITION BY competency_code) AS avg_response_value
  FROM responses_unpivot r
 )

,responses_rollup_pivot AS (
  SELECT *
  FROM
      (
       SELECT recipient_name
             ,CONCAT(question_code, '_', assignmentrelationship) AS pivot_field
             ,avg_response_value
       FROM responses_rollup
      ) sub
  PIVOT(
    MAX(avg_response_value)
    FOR pivot_field IN ([AO_DR]
                       ,[AO_MGR]
                       ,[AO_PEER]
                       ,[AO_R9]
                       ,[AO_SELF]
                       ,[AO1_DR]
                       ,[AO1_MGR]
                       ,[AO1_PEER]
                       ,[AO1_R9]
                       ,[AO1_SELF]
                       ,[AO2_DR]
                       ,[AO2_MGR]
                       ,[AO2_PEER]
                       ,[AO2_R9]
                       ,[AO2_SELF]
                       ,[AO3_DR]
                       ,[AO3_MGR]
                       ,[AO3_PEER]
                       ,[AO3_R9]
                       ,[AO3_SELF]
                       ,[AO4_DR]
                       ,[AO4_MGR]
                       ,[AO4_PEER]
                       ,[AO4_R9]
                       ,[AO4_SELF]
                       ,[AO5_DR]
                       ,[AO5_MGR]
                       ,[AO5_PEER]
                       ,[AO5_R9]
                       ,[AO5_SELF]
                       ,[C_DR]
                       ,[C_MGR]
                       ,[C_PEER]
                       ,[C_R9]
                       ,[C_SELF]
                       ,[C1_DR]
                       ,[C1_MGR]
                       ,[C1_PEER]
                       ,[C1_R9]
                       ,[C1_SELF]
                       ,[C2_DR]
                       ,[C2_MGR]
                       ,[C2_PEER]
                       ,[C2_R9]
                       ,[C2_SELF]
                       ,[C3_DR]
                       ,[C3_MGR]
                       ,[C3_PEER]
                       ,[C3_R9]
                       ,[C3_SELF]
                       ,[C4_DR]
                       ,[C4_MGR]
                       ,[C4_PEER]
                       ,[C4_R9]
                       ,[C4_SELF]
                       ,[CC_DR]
                       ,[CC_MGR]
                       ,[CC_PEER]
                       ,[CC_R9]
                       ,[CC_SELF]
                       ,[CC1_DR]
                       ,[CC1_MGR]
                       ,[CC1_PEER]
                       ,[CC1_R9]
                       ,[CC1_SELF]
                       ,[CC2_DR]
                       ,[CC2_MGR]
                       ,[CC2_PEER]
                       ,[CC2_R9]
                       ,[CC2_SELF]
                       ,[CC3_DR]
                       ,[CC3_MGR]
                       ,[CC3_PEER]
                       ,[CC3_R9]
                       ,[CC3_SELF]
                       ,[CL_DR]
                       ,[CL_MGR]
                       ,[CL_PEER]
                       ,[CL_R9]
                       ,[CL_SELF]
                       ,[CL1_DR]
                       ,[CL1_MGR]
                       ,[CL1_PEER]
                       ,[CL1_R9]
                       ,[CL1_SELF]
                       ,[CL2_DR]
                       ,[CL2_MGR]
                       ,[CL2_PEER]
                       ,[CL2_R9]
                       ,[CL2_SELF]
                       ,[CT_DR]
                       ,[CT_MGR]
                       ,[CT_PEER]
                       ,[CT_R9]
                       ,[CT_SELF]
                       ,[CT1_DR]
                       ,[CT1_MGR]
                       ,[CT1_PEER]
                       ,[CT1_R9]
                       ,[CT1_SELF]
                       ,[CT2_DR]
                       ,[CT2_MGR]
                       ,[CT2_PEER]
                       ,[CT2_R9]
                       ,[CT2_SELF]
                       ,[CT3_DR]
                       ,[CT3_MGR]
                       ,[CT3_PEER]
                       ,[CT3_R9]
                       ,[CT3_SELF]
                       ,[CT4_DR]
                       ,[CT4_MGR]
                       ,[CT4_PEER]
                       ,[CT4_R9]
                       ,[CT4_SELF]
                       ,[DM_DR]
                       ,[DM_MGR]
                       ,[DM_PEER]
                       ,[DM_R9]
                       ,[DM_SELF]
                       ,[DM1_DR]
                       ,[DM1_MGR]
                       ,[DM1_PEER]
                       ,[DM1_R9]
                       ,[DM1_SELF]
                       ,[DM2_DR]
                       ,[DM2_MGR]
                       ,[DM2_PEER]
                       ,[DM2_R9]
                       ,[DM2_SELF]
                       ,[DM3_DR]
                       ,[DM3_MGR]
                       ,[DM3_PEER]
                       ,[DM3_R9]
                       ,[DM3_SELF]
                       ,[DM4_DR]
                       ,[DM4_MGR]
                       ,[DM4_PEER]
                       ,[DM4_R9]
                       ,[DM4_SELF]
                       ,[II_DR]
                       ,[II_MGR]
                       ,[II_PEER]
                       ,[II_R9]
                       ,[II_SELF]
                       ,[II1_DR]
                       ,[II1_MGR]
                       ,[II1_PEER]
                       ,[II1_R9]
                       ,[II1_SELF]
                       ,[II2_DR]
                       ,[II2_MGR]
                       ,[II2_PEER]
                       ,[II2_R9]
                       ,[II2_SELF]
                       ,[II3_DR]
                       ,[II3_MGR]
                       ,[II3_PEER]
                       ,[II3_R9]
                       ,[II3_SELF]
                       ,[II4_DR]
                       ,[II4_MGR]
                       ,[II4_PEER]
                       ,[II4_R9]
                       ,[II4_SELF]
                       ,[MDS_DR]
                       ,[MDS_MGR]
                       ,[MDS_PEER]
                       ,[MDS_R9]
                       ,[MDS_SELF]
                       ,[MDS1_DR]
                       ,[MDS1_MGR]
                       ,[MDS1_PEER]
                       ,[MDS1_R9]
                       ,[MDS1_SELF]
                       ,[MDS2_DR]
                       ,[MDS2_MGR]
                       ,[MDS2_PEER]
                       ,[MDS2_R9]
                       ,[MDS2_SELF]
                       ,[MDS3_DR]
                       ,[MDS3_MGR]
                       ,[MDS3_PEER]
                       ,[MDS3_R9]
                       ,[MDS3_SELF]
                       ,[MDS4_DR]
                       ,[MDS4_MGR]
                       ,[MDS4_PEER]
                       ,[MDS4_R9]
                       ,[MDS4_SELF]
                       ,[MOM_MGR]
                       ,[MOM_PEER]
                       ,[MOM_R9]
                       ,[MOM_SELF]
                       ,[MOM1_MGR]
                       ,[MOM1_PEER]
                       ,[MOM1_R9]
                       ,[MOM1_SELF]
                       ,[MOM2_MGR]
                       ,[MOM2_PEER]
                       ,[MOM2_R9]
                       ,[MOM2_SELF]
                       ,[MOM3_MGR]
                       ,[MOM3_PEER]
                       ,[MOM3_R9]
                       ,[MOM3_SELF]
                       ,[MOM4_MGR]
                       ,[MOM4_PEER]
                       ,[MOM4_R9]
                       ,[MOM4_SELF]
                       ,[MPM_MGR]
                       ,[MPM_PEER]
                       ,[MPM_R9]
                       ,[MPM_SELF]
                       ,[MPM1_MGR]
                       ,[MPM1_PEER]
                       ,[MPM1_R9]
                       ,[MPM1_SELF]
                       ,[MPM2_MGR]
                       ,[MPM2_PEER]
                       ,[MPM2_R9]
                       ,[MPM2_SELF]
                       ,[MPM3_MGR]
                       ,[MPM3_PEER]
                       ,[MPM3_R9]
                       ,[MPM3_SELF]
                       ,[MPM4_MGR]
                       ,[MPM4_PEER]
                       ,[MPM4_R9]
                       ,[MPM4_SELF]
                       ,[MTL_MGR]
                       ,[MTL_PEER]
                       ,[MTL_R9]
                       ,[MTL_SELF]
                       ,[MTL1_MGR]
                       ,[MTL1_PEER]
                       ,[MTL1_R9]
                       ,[MTL1_SELF]
                       ,[MTL2_MGR]
                       ,[MTL2_PEER]
                       ,[MTL2_R9]
                       ,[MTL2_SELF]
                       ,[MTL3_MGR]
                       ,[MTL3_PEER]
                       ,[MTL3_R9]
                       ,[MTL3_SELF]
                       ,[MTL4_MGR]
                       ,[MTL4_PEER]
                       ,[MTL4_R9]
                       ,[MTL4_SELF]
                       ,[MTL5_MGR]
                       ,[MTL5_PEER]
                       ,[MTL5_R9]
                       ,[MTL5_SELF]
                       ,[PE_DR]
                       ,[PE_MGR]
                       ,[PE_PEER]
                       ,[PE_R9]
                       ,[PE_SELF]
                       ,[PE1_DR]
                       ,[PE1_MGR]
                       ,[PE1_PEER]
                       ,[PE1_R9]
                       ,[PE1_SELF]
                       ,[PE2_DR]
                       ,[PE2_MGR]
                       ,[PE2_PEER]
                       ,[PE2_R9]
                       ,[PE2_SELF]
                       ,[PE3_DR]
                       ,[PE3_MGR]
                       ,[PE3_PEER]
                       ,[PE3_R9]
                       ,[PE3_SELF]
                       ,[PE4_DR]
                       ,[PE4_MGR]
                       ,[PE4_PEER]
                       ,[PE4_R9]
                       ,[PE4_SELF]
                       ,[SA_DR]
                       ,[SA_MGR]
                       ,[SA_PEER]
                       ,[SA_R9]
                       ,[SA_SELF]
                       ,[SA1_DR]
                       ,[SA1_MGR]
                       ,[SA1_PEER]
                       ,[SA1_R9]
                       ,[SA1_SELF]
                       ,[SA2_DR]
                       ,[SA2_MGR]
                       ,[SA2_PEER]
                       ,[SA2_R9]
                       ,[SA2_SELF]
                       ,[SA3_DR]
                       ,[SA3_MGR]
                       ,[SA3_PEER]
                       ,[SA3_R9]
                       ,[SA3_SELF]
                       ,[SA4_DR]
                       ,[SA4_MGR]
                       ,[SA4_PEER]
                       ,[SA4_R9]
                       ,[SA4_SELF]
                       ,[SF_DR]
                       ,[SF_MGR]
                       ,[SF_PEER]
                       ,[SF_R9]
                       ,[SF_SELF]
                       ,[SF1_DR]
                       ,[SF1_MGR]
                       ,[SF1_PEER]
                       ,[SF1_R9]
                       ,[SF1_SELF]
                       ,[SF2_DR]
                       ,[SF2_MGR]
                       ,[SF2_PEER]
                       ,[SF2_R9]
                       ,[SF2_SELF]
                       ,[SM_DR]
                       ,[SM_MGR]
                       ,[SM_PEER]
                       ,[SM_R9]
                       ,[SM_SELF]
                       ,[SM1_DR]
                       ,[SM1_MGR]
                       ,[SM1_PEER]
                       ,[SM1_R9]
                       ,[SM1_SELF]
                       ,[SM2_DR]
                       ,[SM2_MGR]
                       ,[SM2_PEER]
                       ,[SM2_R9]
                       ,[SM2_SELF]
                       ,[SM3_DR]
                       ,[SM3_MGR]
                       ,[SM3_PEER]
                       ,[SM3_R9]
                       ,[SM3_SELF])
   ) p
 )

,openended_responses AS (
  SELECT recipient_name
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(strengths, CHAR(10)) AS strengths_grouped
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(growths, CHAR(10)) AS growths_grouped
  FROM responses_deduped
  GROUP BY recipient_name
 )

SELECT r.*
      ,oe.strengths_grouped
      ,oe.growths_grouped
FROM responses_rollup_pivot r
JOIN openended_responses oe
  ON r.recipient_name = oe.recipient_name