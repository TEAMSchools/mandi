USE KIPP_NJ
GO

ALTER PROCEDURE sp_MAP$CDF#MERGE AS

BEGIN

  WITH autoload_clean AS (
    SELECT CONVERT(varchar(255),TermName) AS TermName
          ,CONVERT(varchar(255),StudentID) AS StudentID
          ,CONVERT(varchar(255),SchoolName) AS SchoolName
          ,CONVERT(varchar(255),MeasurementScale) AS MeasurementScale
          ,CONVERT(varchar(255),Discipline) AS Discipline
          ,CONVERT(varchar(255),GrowthMeasureYN) AS GrowthMeasureYN
          ,CONVERT(varchar(30),NormsReferenceData) AS NormsReferenceData
          ,CONVERT(varchar(30),WISelectedAYFall) AS WISelectedAYFall
          ,CONVERT(varchar(30),WISelectedAYWinter) AS WISelectedAYWinter
          ,CONVERT(varchar(30),WISelectedAYSpring) AS WISelectedAYSpring
          ,CONVERT(varchar(30),WIPreviousAYFall) AS WIPreviousAYFall
          ,CONVERT(varchar(30),WIPreviousAYWinter) AS WIPreviousAYWinter
          ,CONVERT(varchar(30),WIPreviousAYSpring) AS WIPreviousAYSpring
          ,CONVERT(varchar(255),TestType) AS TestType
          ,CONVERT(varchar(255),TestName) AS TestName
          ,CONVERT(varchar(255),TestID) AS TestID
          ,CONVERT(date,TestStartDate) AS TestStartDate
          ,CONVERT(varchar(255),TestDurationMinutes) AS TestDurationMinutes
          ,CONVERT(varchar(255),TestRITScore) AS TestRITScore
          ,CONVERT(varchar(255),TestStandardError) AS TestStandardError
          ,CONVERT(varchar(255),TestPercentile) AS TestPercentile
          ,CONVERT(varchar(30),FallToFallProjectedGrowth) AS FallToFallProjectedGrowth
          ,CONVERT(varchar(30),FallToFallObservedGrowth) AS FallToFallObservedGrowth
          ,CONVERT(varchar(30),FallToFallObservedGrowthSE) AS FallToFallObservedGrowthSE
          ,CONVERT(varchar(30),FallToFallMetProjectedGrowth) AS FallToFallMetProjectedGrowth
          ,CONVERT(varchar(30),FallToFallConditionalGrowthIndex) AS FallToFallConditionalGrowthIndex
          ,CONVERT(varchar(30),FallToFallConditionalGrowthPercentile) AS FallToFallConditionalGrowthPercentile
          ,CONVERT(varchar(30),FallToWinterProjectedGrowth) AS FallToWinterProjectedGrowth
          ,CONVERT(varchar(30),FallToWinterObservedGrowth) AS FallToWinterObservedGrowth
          ,CONVERT(varchar(30),FallToWinterObservedGrowthSE) AS FallToWinterObservedGrowthSE
          ,CONVERT(varchar(30),FallToWinterMetProjectedGrowth) AS FallToWinterMetProjectedGrowth
          ,CONVERT(varchar(30),FallToWinterConditionalGrowthIndex) AS FallToWinterConditionalGrowthIndex
          ,CONVERT(varchar(30),FallToWinterConditionalGrowthPercentile) AS FallToWinterConditionalGrowthPercentile
          ,CONVERT(varchar(30),FallToSpringProjectedGrowth) AS FallToSpringProjectedGrowth
          ,CONVERT(varchar(30),FallToSpringObservedGrowth) AS FallToSpringObservedGrowth
          ,CONVERT(varchar(30),FallToSpringObservedGrowthSE) AS FallToSpringObservedGrowthSE
          ,CONVERT(varchar(30),FallToSpringMetProjectedGrowth) AS FallToSpringMetProjectedGrowth
          ,CONVERT(varchar(30),FallToSpringConditionalGrowthIndex) AS FallToSpringConditionalGrowthIndex
          ,CONVERT(varchar(30),FallToSpringConditionalGrowthPercentile) AS FallToSpringConditionalGrowthPercentile
          ,CONVERT(varchar(30),WinterToWinterProjectedGrowth) AS WinterToWinterProjectedGrowth
          ,CONVERT(varchar(30),WinterToWinterObservedGrowth) AS WinterToWinterObservedGrowth
          ,CONVERT(varchar(30),WinterToWinterObservedGrowthSE) AS WinterToWinterObservedGrowthSE
          ,CONVERT(varchar(30),WinterToWinterMetProjectedGrowth) AS WinterToWinterMetProjectedGrowth
          ,CONVERT(varchar(30),WinterToWinterConditionalGrowthIndex) AS WinterToWinterConditionalGrowthIndex
          ,CONVERT(varchar(30),WinterToWinterConditionalGrowthPercentile) AS WinterToWinterConditionalGrowthPercentile
          ,CONVERT(varchar(30),WinterToSpringProjectedGrowth) AS WinterToSpringProjectedGrowth
          ,CONVERT(varchar(30),WinterToSpringObservedGrowth) AS WinterToSpringObservedGrowth
          ,CONVERT(varchar(30),WinterToSpringObservedGrowthSE) AS WinterToSpringObservedGrowthSE
          ,CONVERT(varchar(30),WinterToSpringMetProjectedGrowth) AS WinterToSpringMetProjectedGrowth
          ,CONVERT(varchar(30),WinterToSpringConditionalGrowthIndex) AS WinterToSpringConditionalGrowthIndex
          ,CONVERT(varchar(30),WinterToSpringConditionalGrowthPercentile) AS WinterToSpringConditionalGrowthPercentile
          ,CONVERT(varchar(30),SpringToSpringProjectedGrowth) AS SpringToSpringProjectedGrowth
          ,CONVERT(varchar(30),SpringToSpringObservedGrowth) AS SpringToSpringObservedGrowth
          ,CONVERT(varchar(30),SpringToSpringObservedGrowthSE) AS SpringToSpringObservedGrowthSE
          ,CONVERT(varchar(30),SpringToSpringMetProjectedGrowth) AS SpringToSpringMetProjectedGrowth
          ,CONVERT(varchar(30),SpringToSpringConditionalGrowthIndex) AS SpringToSpringConditionalGrowthIndex
          ,CONVERT(varchar(30),SpringToSpringConditionalGrowthPercentile) AS SpringToSpringConditionalGrowthPercentile
          ,CONVERT(varchar(255),RITtoReadingScore) AS RITtoReadingScore
          ,CONVERT(varchar(255),RITtoReadingMin) AS RITtoReadingMin
          ,CONVERT(varchar(255),RITtoReadingMax) AS RITtoReadingMax
          ,CONVERT(varchar(255),Goal1Name) AS Goal1Name
          ,CONVERT(varchar(255),Goal1RitScore) AS Goal1RitScore
          ,CONVERT(varchar(255),Goal1StdErr) AS Goal1StdErr
          ,CONVERT(varchar(255),Goal1Range) AS Goal1Range
          ,CONVERT(varchar(255),Goal1Adjective) AS Goal1Adjective
          ,CONVERT(varchar(255),Goal2Name) AS Goal2Name
          ,CONVERT(varchar(255),Goal2RitScore) AS Goal2RitScore
          ,CONVERT(varchar(255),Goal2StdErr) AS Goal2StdErr
          ,CONVERT(varchar(255),Goal2Range) AS Goal2Range
          ,CONVERT(varchar(255),Goal2Adjective) AS Goal2Adjective
          ,CONVERT(varchar(255),Goal3Name) AS Goal3Name
          ,CONVERT(varchar(255),Goal3RitScore) AS Goal3RitScore
          ,CONVERT(varchar(255),Goal3StdErr) AS Goal3StdErr
          ,CONVERT(varchar(255),Goal3Range) AS Goal3Range
          ,CONVERT(varchar(255),Goal3Adjective) AS Goal3Adjective
          ,CONVERT(varchar(255),Goal4Name) AS Goal4Name
          ,CONVERT(varchar(255),Goal4RitScore) AS Goal4RitScore
          ,CONVERT(varchar(255),Goal4StdErr) AS Goal4StdErr
          ,CONVERT(varchar(255),Goal4Range) AS Goal4Range
          ,CONVERT(varchar(255),Goal4Adjective) AS Goal4Adjective
          ,CONVERT(varchar(255),Goal5Name) AS Goal5Name
          ,CONVERT(varchar(255),Goal5RitScore) AS Goal5RitScore
          ,CONVERT(varchar(255),Goal5StdErr) AS Goal5StdErr
          ,CONVERT(varchar(255),Goal5Range) AS Goal5Range
          ,CONVERT(varchar(255),Goal5Adjective) AS Goal5Adjective
          ,CONVERT(varchar(255),Goal6Name) AS Goal6Name
          ,CONVERT(varchar(255),Goal6RitScore) AS Goal6RitScore
          ,CONVERT(varchar(255),Goal6StdErr) AS Goal6StdErr
          ,CONVERT(varchar(255),Goal6Range) AS Goal6Range
          ,CONVERT(varchar(255),Goal6Adjective) AS Goal6Adjective
          ,CONVERT(varchar(255),Goal7Name) AS Goal7Name
          ,CONVERT(varchar(255),Goal7RitScore) AS Goal7RitScore
          ,CONVERT(varchar(255),Goal7StdErr) AS Goal7StdErr
          ,CONVERT(varchar(255),Goal7Range) AS Goal7Range
          ,CONVERT(varchar(255),Goal7Adjective) AS Goal7Adjective
          ,CONVERT(varchar(255),Goal8Name) AS Goal8Name
          ,CONVERT(varchar(255),Goal8RitScore) AS Goal8RitScore
          ,CONVERT(varchar(255),Goal8StdErr) AS Goal8StdErr
          ,CONVERT(varchar(255),Goal8Range) AS Goal8Range
          ,CONVERT(varchar(255),Goal8Adjective) AS Goal8Adjective
          ,CONVERT(varchar(255),TestStartTime) AS TestStartTime
          ,CONVERT(varchar(255),PercentCorrect) AS PercentCorrect
          ,CONVERT(varchar(30),ProjectedProficiencyStudy1) AS ProjectedProficiencyStudy1
          ,CONVERT(varchar(30),ProjectedProficiencyLevel1) AS ProjectedProficiencyLevel1
          ,CONVERT(varchar(30),ProjectedProficiencyStudy2) AS ProjectedProficiencyStudy2
          ,CONVERT(varchar(30),ProjectedProficiencyLevel2) AS ProjectedProficiencyLevel2
          ,CONVERT(varchar(30),ProjectedProficiencyStudy3) AS ProjectedProficiencyStudy3
          ,CONVERT(varchar(30),ProjectedProficiencyLevel3) AS ProjectedProficiencyLevel3
    FROM [KIPP_NJ].[dbo].[AUTOLOAD$NWEA_AssessmentResult] WITH(NOLOCK)
   )

  MERGE KIPP_NJ..MAP$CDF AS TARGET
    USING autoload_clean AS SOURCE
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