USE KIPP_NJ
GO

ALTER VIEW MAP$CDF#identifiers AS

SELECT co.schoolid
      ,co.studentid
      ,co.lastfirst
      ,co.grade_level
      ,co.cohort
      ,co.year_in_network
      ,co.abbreviation AS year_abbreviation
      ,sub.*
      ,norms_2008.student_percentile AS percentile_2008_norms
      ,norms_2011.student_percentile AS percentile_2011_norms
      ,norms_2015.student_percentile AS percentile_2015_norms
      ,CASE
        /* MATH ACT model */
        WHEN sub.measurementscale = 'Mathematics'
             THEN ROUND(-28.193 -- intercept
                          + (0.307 * sub.testritscore)
                          + ((-4.256 * co.grade_level) + (0.183 * (co.grade_level * co.grade_level)))
                          + CASE
                             WHEN sub.term = 'Fall' THEN 0
                             WHEN sub.term = 'Winter' THEN -1.173 -- half of Spring
                             WHEN sub.term = 'Spring' THEN -2.346
                             ELSE NULL
                            END,0)
        /* READING ACT model */
        WHEN sub.measurementscale = 'Reading'
             THEN ROUND(-52.748 -- intercept
                          + (0.417 * sub.testritscore)
                          + ((-3.433 * co.grade_level) + (0.132 * (co.grade_level * co.grade_level)))
                          + CASE
                             WHEN sub.term = 'Fall' THEN 0
                             WHEN sub.term = 'Winter' THEN -0.829 -- half of Spring
                             WHEN sub.term = 'Spring' THEN -1.655
                             ELSE NULL
                            END, 0)
        ELSE NULL
       END AS proj_ACT_subj_score
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.student_number, sub.measurementscale
           ORDER BY sub.academic_year ASC, sub.term_numeric ASC, sub.rn ASC, sub.teststartdate DESC, sub.teststarttime DESC) AS rn_base
      ,ROW_NUMBER() OVER( 
         PARTITION BY sub.student_number, sub.measurementscale
           ORDER BY sub.academic_year DESC, sub.term_numeric DESC, sub.rn ASC, sub.teststartdate DESC, sub.teststarttime DESC) AS rn_curr
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.student_number, sub.measurementscale, sub.academic_year
           ORDER BY sub.term_numeric ASC, sub.rn ASC, sub.teststartdate DESC, sub.teststarttime DESC) AS rn_base_yr
      ,ROW_NUMBER() OVER( 
         PARTITION BY sub.student_number, sub.measurementscale, sub.academic_year
           ORDER BY sub.term_numeric DESC, sub.rn ASC, sub.teststartdate DESC, sub.teststarttime DESC) AS rn_curr_yr
      ,ROW_NUMBER() OVER( 
         PARTITION BY sub.student_number, sub.measurementscale
           ORDER BY sub.academic_year ASC, sub.term_numeric ASC, sub.rn ASC, sub.teststartdate ASC, sub.teststarttime ASC) AS rn_asc
FROM
    (
     SELECT CONVERT(INT,SUBSTRING(TermName, CHARINDEX('-', TermName) - 4, 4)) AS academic_year
           ,CASE
             WHEN TermName LIKE 'Fall%' THEN CONVERT(INT,SUBSTRING(TermName, CHARINDEX('-', TermName) - 4, 4))
             ELSE CONVERT(INT,SUBSTRING(TermName, CHARINDEX('-', TermName) + 1, 4))
            END AS test_year                      
           ,LEFT(TermName, CHARINDEX(' ', TermName) - 1) AS term
           ,CASE
             WHEN LEFT(TermName, CHARINDEX(' ', TermName) - 1) = 'Fall'   THEN 1 
             WHEN LEFT(TermName, CHARINDEX(' ', TermName) - 1) = 'Winter' THEN 2
             WHEN LEFT(TermName, CHARINDEX(' ', TermName) - 1) = 'Spring' THEN 3
             ELSE NULL
            END term_numeric
           ,TermName
           ,StudentID AS student_number
           ,SchoolName
           ,CASE WHEN MeasurementScale LIKE 'Language%' THEN 'Language Usage' ELSE MeasurementScale END AS measurementscale
           ,Discipline
           ,CASE 
             WHEN GrowthMeasureYN = 'TRUE' THEN 1
             WHEN GrowthMeasureYN = 'FALSE' THEN 0
             ELSE GrowthMeasureYN
            END AS GrowthMeasureYN
           ,CONVERT(INT,NormsReferenceData) AS NormsReferenceData
           ,CONVERT(FLOAT,WISelectedAYFall) AS WISelectedAYFall
           ,CONVERT(FLOAT,WISelectedAYWinter) AS WISelectedAYWinter
           ,CONVERT(FLOAT,WISelectedAYSpring) AS WISelectedAYSpring
           ,CONVERT(FLOAT,WIPreviousAYFall) AS WIPreviousAYFall
           ,CONVERT(FLOAT,WIPreviousAYWinter) AS WIPreviousAYWinter
           ,CONVERT(FLOAT,WIPreviousAYSpring) AS WIPreviousAYSpring
           ,TestType
           ,TestName
           ,TestID
           ,CONVERT(DATE,TestStartDate) AS TestStartDate
           ,CONVERT(TIME,TestStartTime) AS TestStartTime
           ,CONVERT(FLOAT,TestDurationMinutes) AS TestDurationMinutes
           ,CONVERT(FLOAT,TestRITScore) AS TestRITScore
           ,CONVERT(FLOAT,TestStandardError) AS TestStandardError
           ,CONVERT(FLOAT,TestPercentile) AS TestPercentile
           ,CONVERT(FLOAT,PercentCorrect) AS PercentCorrect
           ,CONVERT(FLOAT,FallToFallProjectedGrowth) AS FallToFallProjectedGrowth
           ,CONVERT(FLOAT,FallToFallObservedGrowth) AS FallToFallObservedGrowth
           ,CONVERT(FLOAT,FallToFallObservedGrowthSE) AS FallToFallObservedGrowthSE
           ,FallToFallMetProjectedGrowth
           ,CONVERT(FLOAT,FallToFallConditionalGrowthIndex) AS FallToFallConditionalGrowthIndex
           ,CONVERT(FLOAT,FallToFallConditionalGrowthPercentile) AS FallToFallConditionalGrowthPercentile
           ,CONVERT(FLOAT,FallToWinterProjectedGrowth) AS FallToWinterProjectedGrowth
           ,CONVERT(FLOAT,FallToWinterObservedGrowth) AS FallToWinterObservedGrowth
           ,CONVERT(FLOAT,FallToWinterObservedGrowthSE) AS FallToWinterObservedGrowthSE
           ,FallToWinterMetProjectedGrowth
           ,CONVERT(FLOAT,FallToWinterConditionalGrowthIndex) AS FallToWinterConditionalGrowthIndex
           ,CONVERT(FLOAT,FallToWinterConditionalGrowthPercentile) AS FallToWinterConditionalGrowthPercentile
           ,CONVERT(FLOAT,FallToSpringProjectedGrowth) AS FallToSpringProjectedGrowth
           ,CONVERT(FLOAT,FallToSpringObservedGrowth) AS FallToSpringObservedGrowth
           ,CONVERT(FLOAT,FallToSpringObservedGrowthSE) AS FallToSpringObservedGrowthSE
           ,FallToSpringMetProjectedGrowth
           ,CONVERT(FLOAT,FallToSpringConditionalGrowthIndex) AS FallToSpringConditionalGrowthIndex
           ,CONVERT(FLOAT,FallToSpringConditionalGrowthPercentile) AS FallToSpringConditionalGrowthPercentile
           ,CONVERT(FLOAT,WinterToWinterProjectedGrowth) AS WinterToWinterProjectedGrowth
           ,CONVERT(FLOAT,WinterToWinterObservedGrowth) AS WinterToWinterObservedGrowth
           ,CONVERT(FLOAT,WinterToWinterObservedGrowthSE) AS WinterToWinterObservedGrowthSE
           ,WinterToWinterMetProjectedGrowth
           ,CONVERT(FLOAT,WinterToWinterConditionalGrowthIndex) AS WinterToWinterConditionalGrowthIndex
           ,CONVERT(FLOAT,WinterToWinterConditionalGrowthPercentile) AS WinterToWinterConditionalGrowthPercentile
           ,CONVERT(FLOAT,WinterToSpringProjectedGrowth) AS WinterToSpringProjectedGrowth
           ,CONVERT(FLOAT,WinterToSpringObservedGrowth) AS WinterToSpringObservedGrowth
           ,CONVERT(FLOAT,WinterToSpringObservedGrowthSE) AS WinterToSpringObservedGrowthSE
           ,WinterToSpringMetProjectedGrowth
           ,CONVERT(FLOAT,WinterToSpringConditionalGrowthIndex) AS WinterToSpringConditionalGrowthIndex
           ,CONVERT(FLOAT,WinterToSpringConditionalGrowthPercentile) AS WinterToSpringConditionalGrowthPercentile
           ,CONVERT(FLOAT,SpringToSpringProjectedGrowth) AS SpringToSpringProjectedGrowth
           ,CONVERT(FLOAT,SpringToSpringObservedGrowth) AS SpringToSpringObservedGrowth
           ,CONVERT(FLOAT,SpringToSpringObservedGrowthSE) AS SpringToSpringObservedGrowthSE
           ,SpringToSpringMetProjectedGrowth
           ,CONVERT(FLOAT,SpringToSpringConditionalGrowthIndex) AS SpringToSpringConditionalGrowthIndex
           ,CONVERT(FLOAT,SpringToSpringConditionalGrowthPercentile) AS SpringToSpringConditionalGrowthPercentile
           ,RITtoReadingScore
           ,RITtoReadingMin
           ,RITtoReadingMax
           ,Goal1Name
           ,CONVERT(FLOAT,Goal1RitScore) AS Goal1RitScore
           ,CONVERT(FLOAT,Goal1StdErr) AS Goal1StdErr
           ,Goal1Range
           ,Goal1Adjective
           ,Goal2Name
           ,CONVERT(FLOAT,Goal2RitScore) AS Goal2RitScore
           ,CONVERT(FLOAT,Goal2StdErr) AS Goal2StdErr
           ,Goal2Range
           ,Goal2Adjective
           ,Goal3Name
           ,CONVERT(FLOAT,Goal3RitScore) AS Goal3RitScore
           ,CONVERT(FLOAT,Goal3StdErr) AS Goal3StdErr
           ,Goal3Range
           ,Goal3Adjective
           ,Goal4Name
           ,CONVERT(FLOAT,Goal4RitScore) AS Goal4RitScore
           ,CONVERT(FLOAT,Goal4StdErr) AS Goal4StdErr
           ,Goal4Range
           ,Goal4Adjective
           ,Goal5Name
           ,CONVERT(FLOAT,Goal5RitScore) AS Goal5RitScore
           ,CONVERT(FLOAT,Goal5StdErr) AS Goal5StdErr
           ,Goal5Range
           ,Goal5Adjective
           ,Goal6Name
           ,CONVERT(FLOAT,Goal6RitScore) AS Goal6RitScore
           ,CONVERT(FLOAT,Goal6StdErr) AS Goal6StdErr
           ,Goal6Range
           ,Goal6Adjective
           ,Goal7Name
           ,CONVERT(FLOAT,Goal7RitScore) AS Goal7RitScore
           ,CONVERT(FLOAT,Goal7StdErr) AS Goal7StdErr
           ,Goal7Range
           ,Goal7Adjective
           ,Goal8Name
           ,CONVERT(FLOAT,Goal8RitScore) AS Goal8RitScore
           ,CONVERT(FLOAT,Goal8StdErr) AS Goal8StdErr
           ,Goal8Range
           ,Goal8Adjective                      
           ,ProjectedProficiencyStudy1
           ,ProjectedProficiencyLevel1
           ,ProjectedProficiencyStudy2
           ,ProjectedProficiencyLevel2
           ,ProjectedProficiencyStudy3
           ,ProjectedProficiencyLevel3                      
           ,ROW_NUMBER() OVER(
              PARTITION BY StudentID, TermName, MeasurementScale
                ORDER BY CASE 
                          WHEN GrowthMeasureYN = 'TRUE' THEN 1
                          WHEN GrowthMeasureYN = 'FALSE' THEN 0
                          ELSE GrowthMeasureYN
                         END DESC
                        ,CONVERT(DATE,TestStartDate) DESC
                        ,CONVERT(FLOAT,TestStandardError) ASC) AS rn
     FROM KIPP_NJ..MAP$CDF WITH (NOLOCK)                
     WHERE (TestID IS NULL OR (TestID NOT IN (SELECT TestID FROM KIPP_NJ..MAP$exclusion_audit#static WITH(NOLOCK) WHERE is_excluded = 1)))
    ) sub
LEFT OUTER JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
  ON sub.student_number = co.student_number
 AND sub.academic_year = co.year
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_MAP_norms_table norms_2008 WITH(NOLOCK)
  ON co.grade_level = norms_2008.grade_level
 AND sub.measurementscale = norms_2008.measurementscale
 AND sub.testritscore = norms_2008.testritscore
 AND sub.term = norms_2008.term
 AND norms_2008.norms_year = 2008
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_MAP_norms_table norms_2011 WITH(NOLOCK)
  ON co.grade_level = norms_2011.grade_level
 AND sub.measurementscale = norms_2011.measurementscale
 AND sub.testritscore = norms_2011.testritscore
 AND sub.term = norms_2011.term
 AND norms_2011.norms_year = 2011
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_MAP_norms_table norms_2015 WITH(NOLOCK)
  ON co.grade_level = norms_2015.grade_level
 AND sub.measurementscale = norms_2015.measurementscale
 AND sub.testritscore = norms_2015.testritscore
 AND sub.term = norms_2015.term
 AND norms_2015.norms_year = 2015