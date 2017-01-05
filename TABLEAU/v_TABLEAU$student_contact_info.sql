USE KIPP_NJ
GO

ALTER VIEW TABLEAU$student_contact_info AS

WITH contacts_unpivot AS (
  SELECT studentid        
        ,FAMILY_IDENT
        ,LEFT(field, CHARINDEX('_',field) - 1) AS person
        ,RIGHT(field, LEN(field) - CHARINDEX('_',field)) AS type
        ,value      
  FROM
      (
       SELECT s.ID AS STUDENTID
             ,s.FAMILY_IDENT
             ,CONVERT(VARCHAR(MAX),CONCAT(LTRIM(RTRIM(s.STREET)), ', ', LTRIM(RTRIM(s.CITY)), ' ', LTRIM(RTRIM(s.ZIP)))) AS HOME_NAME           
             ,CONVERT(VARCHAR(MAX),con.HOME_PHONE) AS HOME_HOME
             ,CONVERT(VARCHAR(MAX),blob.GUARDIANEMAIL) AS HOME_EMAIL
             ,CONVERT(VARCHAR(MAX),con.MOTHER) AS PARENT1_NAME
             ,CASE WHEN CONCAT(con.mother_home, con.mother_cell, con.mother_day) != '' THEN CONVERT(VARCHAR(MAX),'Mother') END AS PARENT1_RELATION
             ,CONVERT(VARCHAR(MAX),con.MOTHER_HOME) AS PARENT1_HOME
             ,CONVERT(VARCHAR(MAX),con.MOTHER_CELL) AS PARENT1_CELL
             ,CONVERT(VARCHAR(MAX),con.MOTHER_DAY) AS PARENT1_DAY           
             ,CONVERT(VARCHAR(MAX),cs.MOTHER_REGISTERED_TO_VOTE) AS PARENT1_REGISTEREDTOVOTE
             ,CONVERT(VARCHAR(MAX),blob.GUARDIANEMAIL) AS PARENT1_EMAIL
             ,CONVERT(VARCHAR(MAX),con.FATHER) AS PARENT2_NAME             
             ,CASE WHEN CONCAT(con.FATHER_HOME, con.FATHER_CELL, con.FATHER_DAY) != '' THEN CONVERT(VARCHAR(MAX),'Father') END AS PARENT2_RELATION
             ,CONVERT(VARCHAR(MAX),con.FATHER_HOME) AS PARENT2_HOME
             ,CONVERT(VARCHAR(MAX),con.FATHER_CELL) AS PARENT2_CELL
             ,CONVERT(VARCHAR(MAX),con.FATHER_DAY) AS PARENT2_DAY
             ,CONVERT(VARCHAR(MAX),cs.FATHER_REGISTERED_TO_VOTE) AS PARENT2_REGISTEREDTOVOTE
             ,CONVERT(VARCHAR(MAX),blob.GUARDIANEMAIL) AS PARENT2_EMAIL
             ,CONVERT(VARCHAR(MAX),con.DOCTOR_NAME) AS DOCTOR_NAME
             ,CASE WHEN CONCAT(con.DOCTOR_NAME, con.DOCTOR_PHONE) != '' THEN CONVERT(VARCHAR(MAX),'Doctor') END AS DOCTOR_RELATION
             ,CONVERT(VARCHAR(MAX),con.DOCTOR_PHONE) AS DOCTOR_CELL
             ,CONVERT(VARCHAR(MAX),con.EMERG_CONTACT_1) AS EMERG1_NAME
             ,CONVERT(VARCHAR(MAX),con.EMERG_1_REL) AS EMERG1_RELATION
             ,CONVERT(VARCHAR(MAX),con.EMERG_PHONE_1) AS EMERG1_CELL
             ,CONVERT(VARCHAR(MAX),con.EMERG_CONTACT_2) AS EMERG2_NAME
             ,CONVERT(VARCHAR(MAX),con.EMERG_2_REL) AS EMERG2_RELATION
             ,CONVERT(VARCHAR(MAX),con.EMERG_PHONE_2) AS EMERG2_CELL
             ,CONVERT(VARCHAR(MAX),con.EMERG_CONTACT_3) AS EMERG3_NAME
             ,CONVERT(VARCHAR(MAX),con.EMERG_3_REL) AS EMERG3_RELATION
             ,CONVERT(VARCHAR(MAX),con.EMERG_3_PHONE) AS EMERG3_CELL
             ,CONVERT(VARCHAR(MAX),con.EMERG_4_NAME) AS EMERG4_NAME
             ,CONVERT(VARCHAR(MAX),con.EMERG_4_REL) AS EMERG4_RELATION
             ,CONVERT(VARCHAR(MAX),con.EMERG_4_PHONE) AS EMERG4_CELL
             ,CONVERT(VARCHAR(MAX),con.EMERG_5_NAME) AS EMERG5_NAME
             ,CONVERT(VARCHAR(MAX),con.EMERG_5_REL) AS EMERG5_RELATION
             ,CONVERT(VARCHAR(MAX),con.EMERG_5_PHONE) AS EMERG5_CELL
             ,CONVERT(VARCHAR(MAX),con.RELEASE_1_NAME) AS RELEASE1_NAME
             ,CONVERT(VARCHAR(MAX),con.RELEASE_1_RELATION) AS RELEASE1_RELATION
             ,CONVERT(VARCHAR(MAX),con.RELEASE_1_PHONE) AS RELEASE1_CELL
             ,CONVERT(VARCHAR(MAX),con.RELEASE_2_NAME) AS RELEASE2_NAME
             ,CONVERT(VARCHAR(MAX),con.RELEASE_2_RELATION) AS RELEASE2_RELATION
             ,CONVERT(VARCHAR(MAX),con.RELEASE_2_PHONE) AS RELEASE2_CELL
             ,CONVERT(VARCHAR(MAX),con.RELEASE_3_NAME) AS RELEASE3_NAME
             ,CONVERT(VARCHAR(MAX),con.RELEASE_3_RELATION) AS RELEASE3_RELATION
             ,CONVERT(VARCHAR(MAX),con.RELEASE_3_PHONE) AS RELEASE3_CELL
             ,CONVERT(VARCHAR(MAX),con.RELEASE_4_NAME) AS RELEASE4_NAME
             ,CONVERT(VARCHAR(MAX),con.RELEASE_4_RELATION) AS RELEASE4_RELATION
             ,CONVERT(VARCHAR(MAX),con.RELEASE_4_PHONE) AS RELEASE4_CELL           
             ,CONVERT(VARCHAR(MAX),con.RELEASE_5_NAME) AS RELEASE5_NAME
             ,CONVERT(VARCHAR(MAX),con.RELEASE_5_RELATION) AS RELEASE5_RELATION
             ,CONVERT(VARCHAR(MAX),con.RELEASE_5_PHONE) AS RELEASE5_CELL
       FROM KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
       LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_custom#static cs WITH(NOLOCK)
         ON s.ID = cs.STUDENTID
       LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_contact#static con WITH(NOLOCK)
         ON s.ID = con.STUDENTID
       LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_BLObs#static blob WITH(NOLOCK)
         ON s.ID = blob.STUDENTID
      ) sub
  UNPIVOT(
    value
    FOR field IN (HOME_NAME
                 ,HOME_HOME
                 ,HOME_EMAIL
                 ,PARENT1_NAME
                 ,PARENT1_RELATION
                 ,PARENT1_HOME
                 ,PARENT1_CELL
                 ,PARENT1_DAY
                 ,PARENT1_REGISTEREDTOVOTE
                 ,PARENT1_EMAIL
                 ,PARENT2_NAME
                 ,PARENT2_RELATION
                 ,PARENT2_HOME
                 ,PARENT2_CELL
                 ,PARENT2_DAY
                 ,PARENT2_REGISTEREDTOVOTE
                 ,PARENT2_EMAIL
                 ,DOCTOR_NAME
                 ,DOCTOR_RELATION
                 ,DOCTOR_CELL
                 ,EMERG1_NAME
                 ,EMERG1_RELATION
                 ,EMERG1_CELL
                 ,EMERG2_NAME
                 ,EMERG2_RELATION
                 ,EMERG2_CELL
                 ,EMERG3_NAME
                 ,EMERG3_RELATION
                 ,EMERG3_CELL
                 ,EMERG4_NAME
                 ,EMERG4_RELATION
                 ,EMERG4_CELL
                 ,EMERG5_NAME
                 ,EMERG5_RELATION
                 ,EMERG5_CELL
                 ,RELEASE1_NAME
                 ,RELEASE1_RELATION
                 ,RELEASE1_CELL
                 ,RELEASE2_NAME
                 ,RELEASE2_RELATION
                 ,RELEASE2_CELL
                 ,RELEASE3_NAME
                 ,RELEASE3_RELATION
                 ,RELEASE3_CELL
                 ,RELEASE4_NAME
                 ,RELEASE4_RELATION
                 ,RELEASE4_CELL
                 ,RELEASE5_NAME
                 ,RELEASE5_RELATION
                 ,RELEASE5_CELL)
   ) u
 )

,contacts_repivot AS (
  SELECT STUDENTID
        ,FAMILY_IDENT
        ,person
        ,NAME
        ,RELATION
        ,CELL
        ,HOME
        ,DAY
        ,EMAIL
        ,REGISTEREDTOVOTE
  FROM contacts_unpivot
  PIVOT(
    MAX(value)
    FOR type IN ([NAME]
                ,[RELATION]
                ,[CELL]
                ,[HOME]              
                ,[DAY]
                ,[EMAIL]
                ,[REGISTEREDTOVOTE])
   ) p      
 )

,contacts_grouped AS (
  SELECT FAMILY_IDENT
        ,person
        ,NAME
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT CELL, CHAR(10)) AS cell
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT HOME, CHAR(10)) AS home
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT DAY, CHAR(10)) AS day
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT EMAIL, CHAR(10)) AS email
        ,MAX(REGISTEREDTOVOTE) AS REGISTEREDTOVOTE
  FROM contacts_repivot
  WHERE FAMILY_IDENT IS NOT NULL
  GROUP BY FAMILY_IDENT
          ,person
          ,NAME
 )

SELECT co.STUDENT_NUMBER
      ,co.LASTFIRST AS student_name
      ,co.reporting_schoolid AS SCHOOLID
      ,co.school_name
      ,co.GRADE_LEVEL
      ,co.team
      ,co.ENROLL_STATUS
      ,CONCAT(co.STREET, ' - ', co.city, ', ', co.state, ' ', co.zip) AS street_address
      
      ,s.FAMILY_IDENT
      ,CASE 
        WHEN s.FAMILY_IDENT IS NOT NULL THEN MAX(cs.INFOSNAP_OPT_IN) OVER(PARTITION BY s.FAMILY_IDENT)
        ELSE cs.INFOSNAP_OPT_IN
       END AS INFOSNAP_OPT_IN      

      ,c.person AS contact_type
      ,c.NAME AS contact_name
      ,ISNULL(c.RELATION, c.person) AS contact_relation
      
      ,cg.CELL AS contact_cell_phone
      ,cg.HOME AS contact_home_phone
      ,cg.DAY AS contact_day_phone
      ,cg.EMAIL AS contact_email      
      ,cg.REGISTEREDTOVOTE AS contact_registered_to_vote
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON co.studentid = s.ID
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_custom#static cs WITH(NOLOCK)
  ON co.studentid = cs.STUDENTID
LEFT OUTER JOIN contacts_repivot c
  ON co.studentid = c.STUDENTID
LEFT OUTER JOIN contacts_grouped cg
  ON s.FAMILY_IDENT = cg.FAMILY_IDENT
 AND c.person = cg.person
 AND c.NAME = cg.NAME
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1