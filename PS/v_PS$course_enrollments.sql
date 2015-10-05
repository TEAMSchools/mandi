USE KIPP_NJ
GO

--ALTER VIEW PS$course_enrollments AS

WITH coaches AS (
  SELECT 2014 AS academic_year
        ,[Teacher Name] AS teacher_name
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
        WHEN cc.course_number IN ('ENG10') THEN 'English 100'
        WHEN cc.course_number IN ('ENG20', 'ENG25') THEN 'English 200'
        WHEN cc.course_number IN ('ENG30', 'ENG35') THEN 'English 300'
        WHEN cc.course_number IN ('ENG40', 'ENG45') THEN 'English 400 / 450'
        WHEN cc.course_number IN ('ENG75', 'ENG78') THEN 'English Foundations'
        WHEN cc.course_number IN ('MATH13') THEN 'Pre-Algebra'
        WHEN cc.course_number IN ('MATH10') THEN 'Algebra'        
        WHEN cc.course_number IN ('MATH20', 'MATH22', 'MATH25', 'MATH73') THEN 'Geometry'        
        WHEN cc.course_number IN ('MATH32', 'MATH35') THEN 'Algebra II'
        WHEN cc.course_number IN ('MATH40') THEN 'Pre Calculus'
        WHEN cc.course_number IN ('MATH33') THEN 'Discrete Math'
        WHEN cc.course_number IN ('MATH45') THEN 'Statistics AP'
        WHEN cc.course_number IN ('SCI10') THEN 'Intro to Engineering'
        WHEN cc.course_number IN ('SCI20', 'SCI25') THEN 'Biology'
        WHEN cc.course_number IN ('SCI30', 'SCI32', 'SCI35') THEN 'Chemistry'
        WHEN cc.course_number IN ('SCI31', 'SCI36') THEN 'Physics'
        WHEN cc.course_number IN ('SCI40') THEN 'Environmental Science'
        WHEN cc.course_number IN ('SCI41') THEN 'Anatomy and Physiology'
        WHEN cc.course_number IN ('SCI43') THEN 'Electronics and Magnetism'
        WHEN cc.course_number IN ('SCI70') THEN 'Lab Skills'        
        WHEN cc.course_number IN ('SCI75') THEN 'Life Science'
        WHEN cc.course_number IN ('HIST10', 'HIST11', 'HIST70') THEN 'Global Studies/ AWH'
        WHEN cc.course_number IN ('HIST20', 'HIST25') THEN 'Modern World History'
        WHEN cc.course_number IN ('HIST71', 'HIST30', 'HIST35') THEN 'US History'
        WHEN cc.course_number IN ('HIST40', 'HIST45') THEN 'Comparative Government'
        WHEN cc.course_number IN ('HIST41') THEN 'Sociology'
        WHEN cc.course_number IN ('FREN10', 'FREN11', 'FREN12', 'FREN20', 'FREN30') THEN 'French'
        WHEN cc.course_number IN ('SPAN10', 'SPAN11', 'SPAN20', 'SPAN30', 'SPAN12', 'SPAN40') THEN 'Spanish'
        WHEN cc.course_number IN ('ARAB20') THEN 'Arabic'
       END AS illuminate_subject
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
FROM KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
JOIN KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
  ON ABS(cc.SECTIONID) = ABS(sec.ID)
JOIN KIPP_NJ..PS$COURSES#static cou WITH(NOLOCK)
  ON cc.COURSE_NUMBER = cou.COURSE_NUMBER
JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
  ON cc.TEACHERID = t.ID
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
 AND co.year = coaches.academic_year
WHERE cc.DATEENROLLED < cc.DATELEFT