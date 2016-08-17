USE KIPP_NJ
GO

ALTER VIEW PS$course_enrollments AS

SELECT co.STUDENTID
      ,co.student_number            
      ,co.SCHOOLID
      ,co.grade_level 
      ,co.year AS academic_year

      ,cc.id AS ccid
      ,ABS(cc.TERMID) AS termid      
      
      ,cou.CREDITTYPE            
      ,cou.COURSE_NAME            
      ,cc.COURSE_NUMBER      
      ,ABS(cc.SECTIONID) AS sectionid      
      ,cc.SECTION_NUMBER      
      ,cc.period            
      ,CONVERT(DATE,cc.DATEENROLLED) AS dateenrolled
      ,CONVERT(DATE,cc.DATELEFT) AS dateleft
      ,CONVERT(DATE,cc.LASTGRADEUPDATE) AS lastgradeupdate
      ,sec.DCID AS sectionsDCID

      ,t.TEACHERNUMBER
      ,t.lastfirst AS teacher_name      
      ,NULL AS teacher_coach
      ,NULL AS TNTP_effectiveness      

      ,cou.CREDIT_HOURS      
      ,cou.GRADESCALEID
      ,cou.EXCLUDEFROMGPA
      ,cou.EXCLUDEFROMSTOREDGRADES  
      
      ,NULL AS tier
      ,NULL AS tier_numeric
      ,NULL AS behavior_tier
      ,NULL AS behavior_tier_numeric                  
      ,CASE WHEN cc.termid < 0 THEN 1 ELSE 0 END AS drop_flags
      ,SUM(CASE WHEN cc.termid < 0 THEN 1 ELSE 0 END) OVER(PARTITION BY co.studentid, co.year, cou.course_number) 
        / COUNT(cc.termid) OVER(PARTITION BY co.studentid, co.year, cou.course_number) AS course_enr_status
      
      ,CASE
        WHEN co.grade_level BETWEEN 5 AND 8 AND cou.CREDITTYPE = 'ENG' THEN 'Text Study'
        WHEN co.grade_level BETWEEN 5 AND 8 AND cou.CREDITTYPE = 'MATH' THEN 'Mathematics'
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
      
      ,ROW_NUMBER() OVER(
        PARTITION BY cc.studentid, cou.credittype, cc.academic_year, CASE WHEN cc.termid < 0 THEN 1 ELSE 0 END
            ORDER BY cc.termid DESC, cc.course_number DESC, cc.dateenrolled DESC, cc.dateleft DESC) AS rn_subject    
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
WHERE cc.DATEENROLLED < cc.DATELEFT
  AND cc.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()