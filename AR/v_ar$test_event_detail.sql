USE KIPP_NJ
GO

ALTER VIEW AR$test_event_detail AS

SELECT CONVERT(INT,[student_number]) AS student_number
      ,[iStudentPracticeID]
      ,[iUserID]
      ,[iSchoolID]
      ,[iContentID]
      ,[iClassID]
      ,[iContentTypeID]
      ,[iRLID]
      ,[iQuizNumber]
      ,[vchContentLanguage]
      ,[vchContentTitle]
      ,[vchSortTitle]
      ,[vchAuthor]
      ,[vchSeriesShortName]
      ,[vchSeriesTitle]
      ,[chContentVersion]
      ,[chFictionNonFiction]
      ,[vchInterestLevel]
      ,CONVERT(FLOAT,[dBookLevel]) AS [dBookLevel]
      ,CONVERT(FLOAT,[iQuestionsPresented]) AS [iQuestionsPresented]
      ,CONVERT(FLOAT,[iQuestionsCorrect]) AS [iQuestionsCorrect]
      ,CONVERT(FLOAT,[dAlternateBookLevel_1]) AS [dAlternateBookLevel_1]
      ,CONVERT(FLOAT,[dPointsPossible]) AS [dPointsPossible]
      ,CONVERT(FLOAT,[iAlternateBookLevel_2]) AS [iAlternateBookLevel_2]
      ,CONVERT(FLOAT,[dPointsEarned]) AS [dPointsEarned]
      ,CONVERT(FLOAT,[dPassingPercentage]) AS [dPassingPercentage]
      ,[tiPassed]
      ,[chTWI]
      ,CONVERT(FLOAT,[tiBookRating]) AS [tiBookRating]
      ,[tiUsedAudio]
      ,[dtTaken]
      ,[dtTakenOriginal]
      ,[tiTeacherModified]
      ,[tiPracticeDetail]
      ,CONVERT(FLOAT,[iWordCount]) AS [iWordCount]
      ,CONVERT(FLOAT,[dPercentCorrect]) AS [dPercentCorrect]
      ,[vchSecondTryTitle]
      ,[vchSecondTryAuthor]
      ,[chStatus]
      ,[iRetakeCount]
      ,[DeviceType]
      ,[DeviceAppletID]
      ,[sDataOrigination]
      ,[tiCSImportVersion]
      ,[iInsertByID]
      ,[dtInsertDate]
      ,[iEditByID]
      ,[dtEditDate]
      ,[tiRowStatus]
      ,[iTeacherUserID]
      ,[DeviceUniqueID]
      ,[iUserActionID]
      ,KIPP_NJ.dbo.fn_DateToSY([dtTaken]) AS academic_year
FROM
    (
     SELECT [student_number]
           ,[iStudentPracticeID]
           ,[iUserID]
           ,[iSchoolID]
           ,[iContentID]
           ,[iClassID]
           ,[iContentTypeID]
           ,[iRLID]
           ,[iQuizNumber]
           ,[vchContentLanguage]
           ,[vchContentTitle]
           ,[vchSortTitle]
           ,[vchAuthor]
           ,[vchSeriesShortName]
           ,[vchSeriesTitle]
           ,[chContentVersion]
           ,[chFictionNonFiction]
           ,[vchInterestLevel]
           ,[dBookLevel]
           ,[iQuestionsPresented]
           ,[iQuestionsCorrect]
           ,[dAlternateBookLevel_1]
           ,[dPointsPossible]
           ,[iAlternateBookLevel_2]
           ,[dPointsEarned]
           ,[dPassingPercentage]
           ,[tiPassed]
           ,[chTWI]
           ,[tiBookRating]
           ,[tiUsedAudio]
           ,[dtTaken]
           ,[dtTakenOriginal]
           ,[tiTeacherModified]
           ,[tiPracticeDetail]
           ,[iWordCount]
           ,[dPercentCorrect]
           ,[vchSecondTryTitle]
           ,[vchSecondTryAuthor]
           ,[chStatus]
           ,[iRetakeCount]
           ,[DeviceType]
           ,[DeviceAppletID]
           ,[sDataOrigination]
           ,[tiCSImportVersion]
           ,[iInsertByID]
           ,[dtInsertDate]
           ,[iEditByID]
           ,[dtEditDate]
           ,[tiRowStatus]
           ,[iTeacherUserID]
           ,[DeviceUniqueID]
           ,[iUserActionID]
           ,CASE
             /* for failing attempts, valid row should be most recent */
             WHEN tiPassed = 0 THEN ROW_NUMBER() OVER(
                                      PARTITION BY student_number, iQuizNumber, tiPassed
                                          ORDER BY iretakecount DESC) 
             /* for passing attempts, valid row should be first */
             WHEN tiPassed = 1 THEN ROW_NUMBER() OVER(
                                      PARTITION BY student_number, iQuizNumber, tiPassed
                                          ORDER BY dtTakenOriginal ASC) 
            END AS rn
     FROM 
         (
          SELECT REPLACE(LEFT(rluser.[vchPreviousIDNum], 5), '-','') AS student_number
                ,CONVERT(INT,arsp.[iStudentPracticeID]) AS [iStudentPracticeID]
                ,CONVERT(INT,arsp.[iUserID]) AS [iUserID]
                ,CONVERT(INT,arsp.[iSchoolID]) AS [iSchoolID]
                ,CONVERT(INT,arsp.[iContentID]) AS [iContentID]
                ,CONVERT(INT,CONVERT(FLOAT,arsp.[iClassID])) AS iClassID
                ,CONVERT(INT,arsp.[iContentTypeID]) AS [iContentTypeID]
                ,arsp.[iRLID]
                ,CONVERT(INT,arsp.[iQuizNumber]) AS [iQuizNumber]
                ,arsp.[vchContentLanguage]
                ,arsp.[vchContentTitle]
                ,arsp.[vchSortTitle]
                ,arsp.[vchAuthor]
                ,arsp.[vchSeriesShortName]
                ,arsp.[vchSeriesTitle]
                ,CONVERT(INT,CONVERT(FLOAT,arsp.[chContentVersion])) AS chContentVersion
                ,arsp.[chFictionNonFiction]
                ,arsp.[vchInterestLevel]
                ,arsp.[dBookLevel]
                ,arsp.[iQuestionsPresented]
                ,arsp.[iQuestionsCorrect]
                ,arsp.[dAlternateBookLevel_1]
                ,arsp.[dPointsPossible]
                ,arsp.[iAlternateBookLevel_2]
                ,arsp.[dPointsEarned]
                ,arsp.[dPassingPercentage]
                ,CONVERT(INT,CONVERT(FLOAT,arsp.[tiPassed])) AS tiPassed
                ,arsp.[chTWI]
                ,arsp.[tiBookRating]
                ,arsp.[tiUsedAudio]        
                ,CONVERT(DATETIME,arsp.[dtTaken]) AS dtTaken
                ,CONVERT(DATETIME,arsp.[dtTakenOriginal]) AS dtTakenOriginal
                ,arsp.[tiTeacherModified]
                ,arsp.[tiPracticeDetail]
                ,arsp.[iWordCount]
                ,arsp.[dPercentCorrect]
                ,arsp.[vchSecondTryTitle]
                ,arsp.[vchSecondTryAuthor]
                ,arsp.[chStatus]
                ,CONVERT(INT,CONVERT(FLOAT,arsp.[iRetakeCount])) AS iRetakeCount
                ,arsp.[DeviceType]
                ,arsp.[DeviceAppletID]
                ,arsp.[sDataOrigination]
                ,arsp.[tiCSImportVersion]
                ,arsp.[iInsertByID]
                ,CONVERT(DATETIME,arsp.[dtInsertDate]) AS dtInsertDate
                ,arsp.[iEditByID]
                ,CONVERT(DATETIME,arsp.[dtEditDate]) AS dtEditDate
                ,arsp.[tiRowStatus]
                ,CONVERT(INT,CONVERT(FLOAT,arsp.[iTeacherUserID])) AS iTeacherUserID
                ,arsp.[DeviceUniqueID]
                ,arsp.[iUserActionID]
                ,1 AS school_progression
          FROM [KIPP_NJ].[dbo].[AUTOLOAD$RENLEARN_KIPP_AR_StudentPractice] arsp WITH(NOLOCK)
          LEFT OUTER JOIN [KIPP_NJ].[dbo].[AUTOLOAD$RENLEARN_KIPP_RL_User]  rluser WITH(NOLOCK)
            ON arsp.iUserID = rluser.iUserID
          WHERE arsp.[iContentTypeID] = 31
            AND arsp.chStatus != 'U'
            AND arsp.tiRowStatus = 1
         ) sub
     WHERE ISNUMERIC(student_number) = 1
    ) sub
WHERE rn = 1