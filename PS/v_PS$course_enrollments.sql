USE KIPP_NJ
GO

CREATE VIEW PS$course_enrollments AS

WITH coaches AS (
  SELECT [Teacher Name] AS teacher_name
        ,[LastFirst] AS teacher_lastfirst
        ,[Teacher Email] AS email
        ,[Teacher's Coach] AS coach
        ,[School] AS school_name
        ,CASE
          WHEN [School] = 'TEAM' THEN 133570965
          WHEN [School] = 'Rise' THEN 73252
          WHEN [School] = 'NCA' THEN 73253
          WHEN [School] = 'SPARK' THEN 73254
          WHEN [School] = 'THRIVE' THEN 73255
          WHEN [School] = 'Seek' THEN 73256
          WHEN [School] LIKE 'Life%' THEN 73257
          WHEN [School] = 'Revolution' THEN 179901
          ELSE NULL
         END AS schoolid
        ,[Effectiveness Level] AS TNTP_effectiveness
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_TEACH_Roster] WITH(NOLOCK)
 )

SELECT cc.academic_year
      ,ABS(cc.TERMID) AS termid
      ,cc.SCHOOLID
      ,co.grade_level      
      ,cou.CREDITTYPE
      ,CASE 
        WHEN cou.CREDITTYPE IN ('ENG','READ') THEN 'Reading'
        WHEN cou.CREDITTYPE = 'MATH' THEN 'Mathematics'
        WHEN cou.CREDITTYPE = 'RHET' THEN 'Language Usage'
        WHEN cou.CREDITTYPE = 'SCI' THEN 'Science - General Science'
       END AS measurementscale
      ,cc.COURSE_NUMBER
      ,cou.COURSE_NAME            
      ,ABS(cc.SECTIONID) AS sectionid
      ,sec.DCID AS sectionsDCID
      ,cc.SECTION_NUMBER      
      ,CASE WHEN cc.schoolid = 73253 THEN cc.period ELSE NULL END AS period
      ,t.TEACHERNUMBER
      ,t.lastfirst AS teacher_name      
      ,coaches.coach AS teacher_coach
      ,coaches.TNTP_effectiveness
      ,CONVERT(DATE,cc.LASTGRADEUPDATE) AS lastgradeupdate
      ,cc.STUDENTID
      ,co.student_number
      ,CONVERT(DATE,cc.DATEENROLLED) AS dateenrolled
      ,CONVERT(DATE,cc.DATELEFT) AS dateleft
      ,rti.tier
      ,rti.tier_numeric
      ,rti.behavior_tier
      ,rti.behavior_tier_numeric            
      ,cou.CREDIT_HOURS      
      ,cou.GRADESCALEID
      ,cou.EXCLUDEFROMGPA
      ,cou.EXCLUDEFROMSTOREDGRADES  
      ,CASE WHEN cc.termid < 0 THEN 1 ELSE 0 END AS drop_flags
      ,ROW_NUMBER() OVER(
        PARTITION BY cc.studentid, cou.credittype, cc.academic_year
            ORDER BY cc.termid DESC, cc.dateenrolled DESC) AS rn_subject    
FROM KIPP_NJ..CC WITH(NOLOCK)
JOIN KIPP_NJ..SECTIONS sec WITH(NOLOCK)
  ON cc.SECTIONID = sec.ID
JOIN KIPP_NJ..COURSES cou WITH(NOLOCK)
  ON cc.COURSE_NUMBER = cou.COURSE_NUMBER
JOIN KIPP_NJ..TEACHERS t WITH(NOLOCK)
  ON cc.TEACHERID = t.ID
 AND t.status = 1
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON cc.STUDENTID = co.studentid
 AND cc.academic_year = co.year
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..PS$rti_tiers#static rti WITH(NOLOCK)
  ON cc.studentid = rti.studentid
 AND cou.CREDITTYPE = rti.credittype
LEFT OUTER JOIN coaches WITH(NOLOCK)
  ON t.LASTFIRST = coaches.teacher_lastfirst
 AND t.SCHOOLID = coaches.schoolid
WHERE cc.DATEENROLLED < cc.DATELEFT