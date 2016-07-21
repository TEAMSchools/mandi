USE KIPP_NJ
GO

ALTER VIEW [dbo].[MAP$comprehensive#identifiers] AS

SELECT schoolid
      ,studentid AS ps_studentid
      ,student_number AS studentid
      ,lastfirst
      ,grade_level
      ,cohort
      ,year_in_network AS stu_year_in_network
      ,year_abbreviation
      ,academic_year AS map_year_academic
      ,test_year AS map_year
      ,term AS fallwinterspring
      ,term_numeric AS fallwinterspring_numeric
      ,TermName      
      ,SchoolName
      ,MeasurementScale
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
      ,TestStartDate
      ,TestStartTime
      ,TestDurationMinutes
      ,TestRITScore
      ,TestStandardError
      ,TestPercentile
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
      ,rn
      ,percentile_2008_norms
      ,percentile_2011_norms
      ,proj_ACT_subj_score
      ,rn_base
      ,rn_curr
      ,rn_asc
FROM KIPP_NJ..MAP$CDF#identifiers#static WITH(NOLOCK)