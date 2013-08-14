USE KIPP_NJ
GO

ALTER VIEW AR$test_event_detail AS

--CTE to enable manipulation of this guy w/o ugly self join
WITH ar_detail AS
    --Rise
    (SELECT arsp.[iUserID] AS student_number
          ,rluser.[vchPreviousIDNum]
          ,arsp.[iQuizNumber]
          ,arsp.[vchContentTitle]
          ,arsp.[vchAuthor] 
          ,arsp.[iWordCount]
          ,arsp.[chFictionNonFiction] 
          ,arsp.[vchInterestLevel] 
          ,arsp.[dBookLevel] 
          ,arsp.[iQuestionsPresented] 
          ,arsp.[iQuestionsCorrect] 
          ,arsp.[dAlternateBookLevel_1] 
          ,arsp.[iAlternateBookLevel_2] 
          ,arsp.[dPointsPossible] 
          ,arsp.[dPointsEarned] 
          ,arsp.[dPassingPercentage] 
          ,arsp.[dPercentCorrect] 
          ,arsp.[tiPassed] 
          ,arsp.[chTWI] 
          ,arsp.[tiBookRating] 
          ,arsp.[dtTaken] 
    FROM [RM9-DSCHEDULER\SQLEXPRESS].[RL_RISE].[dbo].[ar_StudentPractice] arsp
    LEFT OUTER JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_RISE].[dbo].[rl_User]  rluser
      ON arsp.iUserID = rluser.iUserID
    WHERE arsp.[iContentTypeID] = 31

    UNION ALL

    --SPARK
    SELECT arsp.[iUserID]
          ,rluser.[vchPreviousIDNum]
          ,arsp.[iQuizNumber]
          ,arsp.[vchContentTitle]
          ,arsp.[vchAuthor] 
          ,arsp.[iWordCount]
          ,arsp.[chFictionNonFiction] 
          ,arsp.[vchInterestLevel] 
          ,arsp.[dBookLevel] 
          ,arsp.[iQuestionsPresented] 
          ,arsp.[iQuestionsCorrect] 
          ,arsp.[dAlternateBookLevel_1] 
          ,arsp.[iAlternateBookLevel_2] 
          ,arsp.[dPointsPossible] 
          ,arsp.[dPointsEarned] 
          ,arsp.[dPassingPercentage] 
          ,arsp.[dPercentCorrect] 
          ,arsp.[tiPassed] 
          ,arsp.[chTWI] 
          ,arsp.[tiBookRating] 
          ,arsp.[dtTaken] 
    FROM [RM9-DSCHEDULER\SQLEXPRESS].[RL_SPARK].[dbo].[ar_StudentPractice] arsp
    LEFT OUTER JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_SPARK].[dbo].[rl_User]  rluser
      ON arsp.iUserID = rluser.iUserID
    WHERE arsp.[iContentTypeID] = 31

    UNION ALL

    --TEAM
    SELECT arsp.[iUserID]
          ,rluser.[vchPreviousIDNum]
          ,arsp.[iQuizNumber]
          ,arsp.[vchContentTitle]
          ,arsp.[vchAuthor] 
          ,arsp.[iWordCount]
          ,arsp.[chFictionNonFiction] 
          ,arsp.[vchInterestLevel] 
          ,arsp.[dBookLevel] 
          ,arsp.[iQuestionsPresented] 
          ,arsp.[iQuestionsCorrect] 
          ,arsp.[dAlternateBookLevel_1] 
          ,arsp.[iAlternateBookLevel_2] 
          ,arsp.[dPointsPossible] 
          ,arsp.[dPointsEarned] 
          ,arsp.[dPassingPercentage] 
          ,arsp.[dPercentCorrect] 
          ,arsp.[tiPassed] 
          ,arsp.[chTWI] 
          ,arsp.[tiBookRating] 
          ,arsp.[dtTaken] 
    FROM [RM9-DSCHEDULER\SQLEXPRESS].[RL_TEAM].[dbo].[ar_StudentPractice] arsp
    LEFT OUTER JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_TEAM].[dbo].[rl_User]  rluser
      ON arsp.iUserID = rluser.iUserID
    WHERE arsp.[iContentTypeID] = 31

    UNION ALL

    --NCA
    SELECT arsp.[iUserID]
          ,rluser.[vchPreviousIDNum]
          ,arsp.[iQuizNumber]
          ,arsp.[vchContentTitle]
          ,arsp.[vchAuthor] 
          ,arsp.[iWordCount]
          ,arsp.[chFictionNonFiction] 
          ,arsp.[vchInterestLevel] 
          ,arsp.[dBookLevel] 
          ,arsp.[iQuestionsPresented] 
          ,arsp.[iQuestionsCorrect] 
          ,arsp.[dAlternateBookLevel_1] 
          ,arsp.[iAlternateBookLevel_2] 
          ,arsp.[dPointsPossible] 
          ,arsp.[dPointsEarned] 
          ,arsp.[dPassingPercentage] 
          ,arsp.[dPercentCorrect] 
          ,arsp.[tiPassed] 
          ,arsp.[chTWI] 
          ,arsp.[tiBookRating] 
          ,arsp.[dtTaken] 
    FROM [RM9-DSCHEDULER\SQLEXPRESS].[RL_NCA].[dbo].[ar_StudentPractice] arsp
    LEFT OUTER JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_NCA].[dbo].[rl_User]  rluser
      ON arsp.iUserID = rluser.iUserID
    WHERE arsp.[iContentTypeID] = 31
    )

SELECT ar_base.*
FROM ar_detail ar_base
--self join, same book, in the future
JOIN ar_detail ar_future
  ON ar_base.vchPreviousIDNum = ar_future.vchPreviousIDNum
 AND ar_base.iQuizNumber = ar_future.iQuizNumber
 AND (ar_future.dtTaken > ar_base.dtTaken)
