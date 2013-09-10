USE KIPP_NJ
GO

ALTER VIEW LIT$tracker_sharepoint_style_wide#THRIVE14 AS
SELECT [Student Number]
      ,[Grade Level]
      ,[TEAM]
      ,step_rounds.Term_Name
      ,[Test Type]
      ,[Step Level]
      ,[STATUS]
      ,[Independent Level]
      ,[Instructional Level]
      ,[Pre _ Name]
      ,[Pre _ Ph. Aw.-Rhyme]
      ,[Pre - 1 _ Concepts about Print]
      ,[Pre - 2 _ LID Name]
      ,[Pre - 3 _ LID Sound]
      ,[STEP 1 _ PA-1st]
      ,[STEP 1 _ Reading Record]
      ,[STEP 1 - 3 _ Dev. Spell]
      ,[STEP 2_Reading Record: Bk1 Acc]
      ,[STEP 2_Reading Record: Bk2 Acc]
      ,[STEP 2 - 3 _ PA - seg]
      ,[STEP 2 - 3 _ Comprehension]
      ,[STEP 3 - 12 _ Acurracy]
      ,[STEP 4 - 12 _ Fluency]
      ,[STEP 4 - 5 _ Comprehension]
      ,[STEP 4 - 5 _ Dev. Spell]
      ,[STEP 4 - 12 _ Rate]
      ,[STEP 6 - 7 _ Comprehension]
      ,[STEP 6 - 7 _ Dev. Spell]
      ,[STEP 8  _ Comprehension]
      ,[STEP 8 - 12 _ Retell]
      ,[STEP 8 - 10 _ Dev. Spell]
      ,[STEP 9 - 12 _ Comprehension]
      ,[STEP 11 - 12 _ Dev. Spell]
      ,[FP_L-Z_Rate]
      ,[FP_L-Z_Fluency]
      ,[FP_L-Z_Accuracy]
      ,[FP_L-Z_Comprehension]
FROM LIT$tracker_sharepoint_style_wide#static
JOIN LIT$step_rounds step_rounds
  ON [Step Round] >= step_rounds.Start_Date
 AND [Step Round] <= step_rounds.End_Date
WHERE [Step Round] >= '2013-08-01'
  AND [Step Round] <= '2014-06-30'
  AND schoolid = 73255