USE KIPP_NJ
GO

ALTER PROCEDURE sp_MAP$CDF#MERGE AS

BEGIN

  MERGE KIPP_NJ..MAP$CDF AS TARGET
    USING KIPP_NJ..[AUTOLOAD$NWEA_AssessmentResult] AS SOURCE
       ON TARGET.TestID = SOURCE.TestID
      WHEN MATCHED THEN
       UPDATE
        SET TARGET.TermName = SOURCE.TermName
           ,TARGET.StudentID = SOURCE.StudentID
           ,TARGET.SchoolName = SOURCE.SchoolName
           ,TARGET.MeasurementScale = SOURCE.MeasurementScale
           ,TARGET.Discipline = SOURCE.Discipline
           ,TARGET.GrowthMeasureYN = SOURCE.GrowthMeasureYN
           ,TARGET.NormsReferenceData = SOURCE.NormsReferenceData
           ,TARGET.WISelectedAYFall = SOURCE.WISelectedAYFall
           ,TARGET.WISelectedAYWinter = SOURCE.WISelectedAYWinter
           ,TARGET.WISelectedAYSpring = SOURCE.WISelectedAYSpring
           ,TARGET.WIPreviousAYFall = SOURCE.WIPreviousAYFall
           ,TARGET.WIPreviousAYWinter = SOURCE.WIPreviousAYWinter
           ,TARGET.WIPreviousAYSpring = SOURCE.WIPreviousAYSpring
           ,TARGET.TestType = SOURCE.TestType
           ,TARGET.TestName = SOURCE.TestName           
           ,TARGET.TestStartDate = SOURCE.TestStartDate
           ,TARGET.TestDurationMinutes = SOURCE.TestDurationMinutes
           ,TARGET.TestRITScore = SOURCE.TestRITScore
           ,TARGET.TestStandardError = SOURCE.TestStandardError
           ,TARGET.TestPercentile = SOURCE.TestPercentile
           ,TARGET.FallToFallProjectedGrowth = SOURCE.FallToFallProjectedGrowth
           ,TARGET.FallToFallObservedGrowth = SOURCE.FallToFallObservedGrowth
           ,TARGET.FallToFallObservedGrowthSE = SOURCE.FallToFallObservedGrowthSE
           ,TARGET.FallToFallMetProjectedGrowth = SOURCE.FallToFallMetProjectedGrowth
           ,TARGET.FallToFallConditionalGrowthIndex = SOURCE.FallToFallConditionalGrowthIndex
           ,TARGET.FallToFallConditionalGrowthPercentile = SOURCE.FallToFallConditionalGrowthPercentile
           ,TARGET.FallToWinterProjectedGrowth = SOURCE.FallToWinterProjectedGrowth
           ,TARGET.FallToWinterObservedGrowth = SOURCE.FallToWinterObservedGrowth
           ,TARGET.FallToWinterObservedGrowthSE = SOURCE.FallToWinterObservedGrowthSE
           ,TARGET.FallToWinterMetProjectedGrowth = SOURCE.FallToWinterMetProjectedGrowth
           ,TARGET.FallToWinterConditionalGrowthIndex = SOURCE.FallToWinterConditionalGrowthIndex
           ,TARGET.FallToWinterConditionalGrowthPercentile = SOURCE.FallToWinterConditionalGrowthPercentile
           ,TARGET.FallToSpringProjectedGrowth = SOURCE.FallToSpringProjectedGrowth
           ,TARGET.FallToSpringObservedGrowth = SOURCE.FallToSpringObservedGrowth
           ,TARGET.FallToSpringObservedGrowthSE = SOURCE.FallToSpringObservedGrowthSE
           ,TARGET.FallToSpringMetProjectedGrowth = SOURCE.FallToSpringMetProjectedGrowth
           ,TARGET.FallToSpringConditionalGrowthIndex = SOURCE.FallToSpringConditionalGrowthIndex
           ,TARGET.FallToSpringConditionalGrowthPercentile = SOURCE.FallToSpringConditionalGrowthPercentile
           ,TARGET.WinterToWinterProjectedGrowth = SOURCE.WinterToWinterProjectedGrowth
           ,TARGET.WinterToWinterObservedGrowth = SOURCE.WinterToWinterObservedGrowth
           ,TARGET.WinterToWinterObservedGrowthSE = SOURCE.WinterToWinterObservedGrowthSE
           ,TARGET.WinterToWinterMetProjectedGrowth = SOURCE.WinterToWinterMetProjectedGrowth
           ,TARGET.WinterToWinterConditionalGrowthIndex = SOURCE.WinterToWinterConditionalGrowthIndex
           ,TARGET.WinterToWinterConditionalGrowthPercentile = SOURCE.WinterToWinterConditionalGrowthPercentile
           ,TARGET.WinterToSpringProjectedGrowth = SOURCE.WinterToSpringProjectedGrowth
           ,TARGET.WinterToSpringObservedGrowth = SOURCE.WinterToSpringObservedGrowth
           ,TARGET.WinterToSpringObservedGrowthSE = SOURCE.WinterToSpringObservedGrowthSE
           ,TARGET.WinterToSpringMetProjectedGrowth = SOURCE.WinterToSpringMetProjectedGrowth
           ,TARGET.WinterToSpringConditionalGrowthIndex = SOURCE.WinterToSpringConditionalGrowthIndex
           ,TARGET.WinterToSpringConditionalGrowthPercentile = SOURCE.WinterToSpringConditionalGrowthPercentile
           ,TARGET.SpringToSpringProjectedGrowth = SOURCE.SpringToSpringProjectedGrowth
           ,TARGET.SpringToSpringObservedGrowth = SOURCE.SpringToSpringObservedGrowth
           ,TARGET.SpringToSpringObservedGrowthSE = SOURCE.SpringToSpringObservedGrowthSE
           ,TARGET.SpringToSpringMetProjectedGrowth = SOURCE.SpringToSpringMetProjectedGrowth
           ,TARGET.SpringToSpringConditionalGrowthIndex = SOURCE.SpringToSpringConditionalGrowthIndex
           ,TARGET.SpringToSpringConditionalGrowthPercentile = SOURCE.SpringToSpringConditionalGrowthPercentile
           ,TARGET.RITtoReadingScore = SOURCE.RITtoReadingScore
           ,TARGET.RITtoReadingMin = SOURCE.RITtoReadingMin
           ,TARGET.RITtoReadingMax = SOURCE.RITtoReadingMax
           ,TARGET.Goal1Name = SOURCE.Goal1Name
           ,TARGET.Goal1RitScore = SOURCE.Goal1RitScore
           ,TARGET.Goal1StdErr = SOURCE.Goal1StdErr
           ,TARGET.Goal1Range = SOURCE.Goal1Range
           ,TARGET.Goal1Adjective = SOURCE.Goal1Adjective
           ,TARGET.Goal2Name = SOURCE.Goal2Name
           ,TARGET.Goal2RitScore = SOURCE.Goal2RitScore
           ,TARGET.Goal2StdErr = SOURCE.Goal2StdErr
           ,TARGET.Goal2Range = SOURCE.Goal2Range
           ,TARGET.Goal2Adjective = SOURCE.Goal2Adjective
           ,TARGET.Goal3Name = SOURCE.Goal3Name
           ,TARGET.Goal3RitScore = SOURCE.Goal3RitScore
           ,TARGET.Goal3StdErr = SOURCE.Goal3StdErr
           ,TARGET.Goal3Range = SOURCE.Goal3Range
           ,TARGET.Goal3Adjective = SOURCE.Goal3Adjective
           ,TARGET.Goal4Name = SOURCE.Goal4Name
           ,TARGET.Goal4RitScore = SOURCE.Goal4RitScore
           ,TARGET.Goal4StdErr = SOURCE.Goal4StdErr
           ,TARGET.Goal4Range = SOURCE.Goal4Range
           ,TARGET.Goal4Adjective = SOURCE.Goal4Adjective
           ,TARGET.Goal5Name = SOURCE.Goal5Name
           ,TARGET.Goal5RitScore = SOURCE.Goal5RitScore
           ,TARGET.Goal5StdErr = SOURCE.Goal5StdErr
           ,TARGET.Goal5Range = SOURCE.Goal5Range
           ,TARGET.Goal5Adjective = SOURCE.Goal5Adjective
           ,TARGET.Goal6Name = SOURCE.Goal6Name
           ,TARGET.Goal6RitScore = SOURCE.Goal6RitScore
           ,TARGET.Goal6StdErr = SOURCE.Goal6StdErr
           ,TARGET.Goal6Range = SOURCE.Goal6Range
           ,TARGET.Goal6Adjective = SOURCE.Goal6Adjective
           ,TARGET.Goal7Name = SOURCE.Goal7Name
           ,TARGET.Goal7RitScore = SOURCE.Goal7RitScore
           ,TARGET.Goal7StdErr = SOURCE.Goal7StdErr
           ,TARGET.Goal7Range = SOURCE.Goal7Range
           ,TARGET.Goal7Adjective = SOURCE.Goal7Adjective
           ,TARGET.Goal8Name = SOURCE.Goal8Name
           ,TARGET.Goal8RitScore = SOURCE.Goal8RitScore
           ,TARGET.Goal8StdErr = SOURCE.Goal8StdErr
           ,TARGET.Goal8Range = SOURCE.Goal8Range
           ,TARGET.Goal8Adjective = SOURCE.Goal8Adjective
           ,TARGET.TestStartTime = SOURCE.TestStartTime
           ,TARGET.PercentCorrect = SOURCE.PercentCorrect
           ,TARGET.ProjectedProficiencyStudy1 = SOURCE.ProjectedProficiencyStudy1
           ,TARGET.ProjectedProficiencyLevel1 = SOURCE.ProjectedProficiencyLevel1
           ,TARGET.ProjectedProficiencyStudy2 = SOURCE.ProjectedProficiencyStudy2
           ,TARGET.ProjectedProficiencyLevel2 = SOURCE.ProjectedProficiencyLevel2
           ,TARGET.ProjectedProficiencyStudy3 = SOURCE.ProjectedProficiencyStudy3
           ,TARGET.ProjectedProficiencyLevel3 = SOURCE.ProjectedProficiencyLevel3
      WHEN NOT MATCHED THEN
       INSERT
        (TermName
        ,StudentID
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
        ,TestDurationMinutes
        ,TestRITScore
        ,TestStandardError
        ,TestPercentile
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
        ,TestStartTime
        ,PercentCorrect
        ,ProjectedProficiencyStudy1
        ,ProjectedProficiencyLevel1
        ,ProjectedProficiencyStudy2
        ,ProjectedProficiencyLevel2
        ,ProjectedProficiencyStudy3
        ,ProjectedProficiencyLevel3)
       VALUES
        (SOURCE.TermName
        ,SOURCE.StudentID
        ,SOURCE.SchoolName
        ,SOURCE.MeasurementScale
        ,SOURCE.Discipline
        ,SOURCE.GrowthMeasureYN
        ,SOURCE.NormsReferenceData
        ,SOURCE.WISelectedAYFall
        ,SOURCE.WISelectedAYWinter
        ,SOURCE.WISelectedAYSpring
        ,SOURCE.WIPreviousAYFall
        ,SOURCE.WIPreviousAYWinter
        ,SOURCE.WIPreviousAYSpring
        ,SOURCE.TestType
        ,SOURCE.TestName
        ,SOURCE.TestID
        ,SOURCE.TestStartDate
        ,SOURCE.TestDurationMinutes
        ,SOURCE.TestRITScore
        ,SOURCE.TestStandardError
        ,SOURCE.TestPercentile
        ,SOURCE.FallToFallProjectedGrowth
        ,SOURCE.FallToFallObservedGrowth
        ,SOURCE.FallToFallObservedGrowthSE
        ,SOURCE.FallToFallMetProjectedGrowth
        ,SOURCE.FallToFallConditionalGrowthIndex
        ,SOURCE.FallToFallConditionalGrowthPercentile
        ,SOURCE.FallToWinterProjectedGrowth
        ,SOURCE.FallToWinterObservedGrowth
        ,SOURCE.FallToWinterObservedGrowthSE
        ,SOURCE.FallToWinterMetProjectedGrowth
        ,SOURCE.FallToWinterConditionalGrowthIndex
        ,SOURCE.FallToWinterConditionalGrowthPercentile
        ,SOURCE.FallToSpringProjectedGrowth
        ,SOURCE.FallToSpringObservedGrowth
        ,SOURCE.FallToSpringObservedGrowthSE
        ,SOURCE.FallToSpringMetProjectedGrowth
        ,SOURCE.FallToSpringConditionalGrowthIndex
        ,SOURCE.FallToSpringConditionalGrowthPercentile
        ,SOURCE.WinterToWinterProjectedGrowth
        ,SOURCE.WinterToWinterObservedGrowth
        ,SOURCE.WinterToWinterObservedGrowthSE
        ,SOURCE.WinterToWinterMetProjectedGrowth
        ,SOURCE.WinterToWinterConditionalGrowthIndex
        ,SOURCE.WinterToWinterConditionalGrowthPercentile
        ,SOURCE.WinterToSpringProjectedGrowth
        ,SOURCE.WinterToSpringObservedGrowth
        ,SOURCE.WinterToSpringObservedGrowthSE
        ,SOURCE.WinterToSpringMetProjectedGrowth
        ,SOURCE.WinterToSpringConditionalGrowthIndex
        ,SOURCE.WinterToSpringConditionalGrowthPercentile
        ,SOURCE.SpringToSpringProjectedGrowth
        ,SOURCE.SpringToSpringObservedGrowth
        ,SOURCE.SpringToSpringObservedGrowthSE
        ,SOURCE.SpringToSpringMetProjectedGrowth
        ,SOURCE.SpringToSpringConditionalGrowthIndex
        ,SOURCE.SpringToSpringConditionalGrowthPercentile
        ,SOURCE.RITtoReadingScore
        ,SOURCE.RITtoReadingMin
        ,SOURCE.RITtoReadingMax
        ,SOURCE.Goal1Name
        ,SOURCE.Goal1RitScore
        ,SOURCE.Goal1StdErr
        ,SOURCE.Goal1Range
        ,SOURCE.Goal1Adjective
        ,SOURCE.Goal2Name
        ,SOURCE.Goal2RitScore
        ,SOURCE.Goal2StdErr
        ,SOURCE.Goal2Range
        ,SOURCE.Goal2Adjective
        ,SOURCE.Goal3Name
        ,SOURCE.Goal3RitScore
        ,SOURCE.Goal3StdErr
        ,SOURCE.Goal3Range
        ,SOURCE.Goal3Adjective
        ,SOURCE.Goal4Name
        ,SOURCE.Goal4RitScore
        ,SOURCE.Goal4StdErr
        ,SOURCE.Goal4Range
        ,SOURCE.Goal4Adjective
        ,SOURCE.Goal5Name
        ,SOURCE.Goal5RitScore
        ,SOURCE.Goal5StdErr
        ,SOURCE.Goal5Range
        ,SOURCE.Goal5Adjective
        ,SOURCE.Goal6Name
        ,SOURCE.Goal6RitScore
        ,SOURCE.Goal6StdErr
        ,SOURCE.Goal6Range
        ,SOURCE.Goal6Adjective
        ,SOURCE.Goal7Name
        ,SOURCE.Goal7RitScore
        ,SOURCE.Goal7StdErr
        ,SOURCE.Goal7Range
        ,SOURCE.Goal7Adjective
        ,SOURCE.Goal8Name
        ,SOURCE.Goal8RitScore
        ,SOURCE.Goal8StdErr
        ,SOURCE.Goal8Range
        ,SOURCE.Goal8Adjective
        ,SOURCE.TestStartTime
        ,SOURCE.PercentCorrect
        ,SOURCE.ProjectedProficiencyStudy1
        ,SOURCE.ProjectedProficiencyLevel1
        ,SOURCE.ProjectedProficiencyStudy2
        ,SOURCE.ProjectedProficiencyLevel2
        ,SOURCE.ProjectedProficiencyStudy3
        ,SOURCE.ProjectedProficiencyLevel3);

END

GO