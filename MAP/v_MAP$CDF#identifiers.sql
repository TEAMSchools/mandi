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
      ,norms_2008.testpercentile AS percentile_2008_norms
      ,norms_2011.testpercentile AS percentile_2011_norms
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
         PARTITION BY sub.student_number, sub.academic_year, sub.measurementscale
           ORDER BY sub.rn ASC, sub.teststartdate ASC, sub.teststarttime ASC) AS rn_base
      ,ROW_NUMBER() OVER( 
         PARTITION BY sub.student_number, sub.academic_year, sub.measurementscale
           ORDER BY sub.rn ASC, sub.teststartdate DESC, sub.teststarttime DESC) AS rn_curr
      ,ROW_NUMBER() OVER( 
         PARTITION BY sub.student_number, sub.measurementscale
           ORDER BY sub.rn ASC, sub.teststartdate ASC, sub.teststarttime ASC) AS rn_asc
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
           ,REPLACE(MeasurementScale,'Language','Language Usage') AS MeasurementScale
           ,Discipline
           ,GrowthMeasureYN
           ,NormsReferenceData
           ,WISelectedAYFall
           ,WISelectedAYWinter
           ,WISelectedAYSpring
           ,WIPreviousAYFall
           ,WIPreviousAYWinter
           ,WIPreviousAYSpring
           ,TestType
           ,TestName
           ,TestID
           ,CONVERT(DATE,TestStartDate) AS TestStartDate
           ,TestStartTime                      
           ,TestDurationMinutes
           ,CONVERT(FLOAT,TestRITScore) AS TestRITScore
           ,CONVERT(FLOAT,TestStandardError) AS TestStandardError
           ,CONVERT(FLOAT,TestPercentile) AS TestPercentile
           ,PercentCorrect
           ,FallToFallProjectedGrowth
           ,FallToFallObservedGrowth
           ,FallToFallObservedGrowthSE
           ,FallToFallMetProjectedGrowth
           ,FallToFallConditionalGrowthIndex
           ,FallToFallConditionalGrowthPercentile
           ,FallToWinterProjectedGrowth
           ,FallToWinterObservedGrowth
           ,FallToWinterObservedGrowthSE
           ,FallToWinterMetProjectedGrowth
           ,FallToWinterConditionalGrowthIndex
           ,FallToWinterConditionalGrowthPercentile
           ,FallToSpringProjectedGrowth
           ,FallToSpringObservedGrowth
           ,FallToSpringObservedGrowthSE
           ,FallToSpringMetProjectedGrowth
           ,FallToSpringConditionalGrowthIndex
           ,FallToSpringConditionalGrowthPercentile
           ,WinterToWinterProjectedGrowth
           ,WinterToWinterObservedGrowth
           ,WinterToWinterObservedGrowthSE
           ,WinterToWinterMetProjectedGrowth
           ,WinterToWinterConditionalGrowthIndex
           ,WinterToWinterConditionalGrowthPercentile
           ,WinterToSpringProjectedGrowth
           ,WinterToSpringObservedGrowth
           ,WinterToSpringObservedGrowthSE
           ,WinterToSpringMetProjectedGrowth
           ,WinterToSpringConditionalGrowthIndex
           ,WinterToSpringConditionalGrowthPercentile
           ,SpringToSpringProjectedGrowth
           ,SpringToSpringObservedGrowth
           ,SpringToSpringObservedGrowthSE
           ,SpringToSpringMetProjectedGrowth
           ,SpringToSpringConditionalGrowthIndex
           ,SpringToSpringConditionalGrowthPercentile
           ,RITtoReadingScore
           ,RITtoReadingMin
           ,RITtoReadingMax
           ,Goal1Name
           ,Goal1RitScore
           ,Goal1StdErr
           ,Goal1Range
           ,Goal1Adjective
           ,Goal2Name
           ,Goal2RitScore
           ,Goal2StdErr
           ,Goal2Range
           ,Goal2Adjective
           ,Goal3Name
           ,Goal3RitScore
           ,Goal3StdErr
           ,Goal3Range
           ,Goal3Adjective
           ,Goal4Name
           ,Goal4RitScore
           ,Goal4StdErr
           ,Goal4Range
           ,Goal4Adjective
           ,Goal5Name
           ,Goal5RitScore
           ,Goal5StdErr
           ,Goal5Range
           ,Goal5Adjective
           ,Goal6Name
           ,Goal6RitScore
           ,Goal6StdErr
           ,Goal6Range
           ,Goal6Adjective
           ,Goal7Name
           ,Goal7RitScore
           ,Goal7StdErr
           ,Goal7Range
           ,Goal7Adjective
           ,Goal8Name
           ,Goal8RitScore
           ,Goal8StdErr
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
                ORDER BY GrowthMeasureYN DESC
                        ,CONVERT(DATE,TestStartDate) DESC
                        ,CONVERT(FLOAT,TestStandardError) ASC) AS rn
     FROM KIPP_NJ..MAP$CDF WITH (NOLOCK)                
     WHERE StudentID != '11XXX'
       AND (TestID IS NULL OR TestID NOT IN (SELECT TestID FROM KIPP_NJ..MAP$exclusion_audit#static WITH(NOLOCK) WHERE is_excluded = 1))
    ) sub
LEFT OUTER JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
  ON sub.student_number = co.student_number
 AND sub.academic_year = co.year
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..MAP$norms_table norms_2008 WITH(NOLOCK)
  ON co.grade_level = norms_2008.grade_level
 AND sub.measurementscale = norms_2008.measurementscale
 AND sub.testritscore = norms_2008.testritscore
 AND sub.term = norms_2008.term
 AND norms_2008.norms_year = 2008
LEFT OUTER JOIN KIPP_NJ..MAP$norms_table norms_2011 WITH(NOLOCK)
  ON co.grade_level = norms_2011.grade_level
 AND sub.measurementscale = norms_2011.measurementscale
 AND sub.testritscore = norms_2011.testritscore
 AND sub.term = norms_2011.term
 AND norms_2011.norms_year = 2011