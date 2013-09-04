USE KIPP_NJ
GO

ALTER VIEW LIT$tracker_sharepoint_style_wide AS

SELECT unioned.[Student Number]
	  ,unioned.[Grade Level]
	  ,unioned.[Team]
	  ,step_rounds.Term_Name AS [Step Round]
	  ,unioned.[Test Type]
	  ,unioned.[Step Level]
	  ,unioned.[Status]
	  ,unioned.[Independent Level]
	  ,unioned.[Instructional Level]
	  ,unioned.[Pre _ Name]
	  ,unioned.[Pre _ Ph. Aw.-Rhyme]
	  ,unioned.[Pre - 1 _ Concepts about Print]
	  ,unioned.[Pre - 2 _ LID Name]
	  ,unioned.[Pre - 3 _ LID Sound]
	  ,unioned.[STEP 1 _ PA-1st]
	  ,unioned.[STEP 1 _ Reading Record]
	  ,unioned.[STEP 1 - 3 _ Dev. Spell]
	  ,unioned.[STEP 2_Reading Record: Bk1 Acc]
	  ,unioned.[STEP 2_Reading Record: Bk2 Acc]
	  ,unioned.[STEP 2 - 3 _ PA - seg]
	  ,unioned.[STEP 2 - 3 _ Comprehension]
	  ,unioned.[STEP 3 - 12 _ Acurracy]
	  ,unioned.[STEP 4 - 12 _ Fluency]
	  ,unioned.[STEP 4 - 5 _ Comprehension]
	  ,unioned.[STEP 4 - 5 _ Dev. Spell]
	  ,unioned.[STEP 4 - 12 _ Rate]
	  ,unioned.[STEP 6 - 7 _ Comprehension]
	  ,unioned.[STEP 6 - 7 _ Dev. Spell]
	  ,unioned.[STEP 8  _ Comprehension]
	  ,unioned.[STEP 8 - 12 _ Retell]
	  ,unioned.[STEP 8 - 10 _ Dev. Spell]
	  ,unioned.[STEP 9 - 12 _ Comprehension]
	  ,unioned.[STEP 11 - 12 _ Dev. Spell]
	  ,unioned.[FP_L-Z_Accuracy]
	  ,unioned.[FP_L-Z_Rate]
	  ,unioned.[FP_L-Z_Fluency]
	  ,unioned.[FP_L-Z_Comprehension]
FROM
	(SELECT CAST([Student Number] AS VARCHAR(100)) AS [Student Number]
		  ,CAST([Grade Level] AS VARCHAR(20)) AS [Grade Level]
		  ,CAST([Team] AS VARCHAR(20)) AS [Team]
		  ,[Step Round]
		  ,CAST([Test Type] AS VARCHAR(20)) AS [Test Type]
		  ,CAST([Step Level] AS VARCHAR(20)) AS [Step Level]
		  ,CAST([status] AS VARCHAR(20)) AS [Status]
		  ,CAST([Independent Level] AS VARCHAR(20)) AS [Independent Level]
		  ,CAST([Instructional Level] AS VARCHAR(20)) AS [Instructional Level]
		  ,CAST([Pre _ Name] AS VARCHAR(20)) AS [Pre _ Name]
		  ,CAST([Pre _ Ph. Aw.-Rhyme] AS VARCHAR(20)) AS [Pre _ Ph. Aw.-Rhyme]
		  ,CAST([Pre - 1 _ Concepts about Print] AS VARCHAR(20)) AS [Pre - 1 _ Concepts about Print]
		  ,CAST([Pre - 2 _ LID Name] AS VARCHAR(20)) AS [Pre - 2 _ LID Name]
		  ,CAST([Pre - 3 _ LID Sound] AS VARCHAR(20)) AS [Pre - 3 _ LID Sound]
		  ,CAST([STEP 1 _ PA-1st] AS VARCHAR(20)) AS [STEP 1 _ PA-1st]
		  ,CAST([STEP 1 _ Reading Record] AS VARCHAR(20)) AS [STEP 1 _ Reading Record]
		  ,CAST([STEP 1 - 3 _ Dev. Spell] AS VARCHAR(20)) AS [STEP 1 - 3 _ Dev. Spell]
		  ,CAST([STEP 2_Reading Record: Bk1 Acc] AS VARCHAR(20)) AS [STEP 2_Reading Record: Bk1 Acc]
		  ,CAST([STEP 2_Reading Record: Bk2 Acc] AS VARCHAR(20)) AS [STEP 2_Reading Record: Bk2 Acc]
		  ,CAST([STEP 2 - 3 _ PA - seg] AS VARCHAR(20)) AS [STEP 2 - 3 _ PA - seg]
		  ,CAST([STEP 2 - 3 _ Comprehension] AS VARCHAR(20)) AS [STEP 2 - 3 _ Comprehension]
		  ,CAST([STEP 3 - 12 _ Acurracy] AS VARCHAR(20)) AS [STEP 3 - 12 _ Acurracy]
		  ,CAST([STEP 4 - 12 _ Fluency] AS VARCHAR(20)) AS [STEP 4 - 12 _ Fluency]
		  ,CAST([STEP 4 - 5 _ Comprehension] AS VARCHAR(20)) AS [STEP 4 - 5 _ Comprehension]
		  ,CAST([STEP 4 - 5 _ Dev. Spell] AS VARCHAR(20)) AS [STEP 4 - 5 _ Dev. Spell]
		  ,CAST([STEP 4 - 12 _ Rate] AS VARCHAR(20)) AS [STEP 4 - 12 _ Rate]
		  ,CAST([STEP 6 - 7 _ Comprehension] AS VARCHAR(20)) AS [STEP 6 - 7 _ Comprehension]
		  ,CAST([STEP 6 - 7 _ Dev. Spell] AS VARCHAR(20)) AS [STEP 6 - 7 _ Dev. Spell]
		  ,CAST([STEP 8  _ Comprehension] AS VARCHAR(20)) AS [STEP 8  _ Comprehension]
		  ,CAST([STEP 8 - 12 _ Retell] AS VARCHAR(20)) AS [STEP 8 - 12 _ Retell]
		  ,CAST([STEP 8 - 10 _ Dev. Spell] AS VARCHAR(20)) AS [STEP 8 - 10 _ Dev. Spell]
		  ,CAST([STEP 9 - 12 _ Comprehension] AS VARCHAR(20)) AS [STEP 9 - 12 _ Comprehension]
		  ,CAST([STEP 11 - 12 _ Dev. Spell] AS VARCHAR(20)) AS [STEP 11 - 12 _ Dev. Spell]
		  ,CAST([FP_L-Z_Accuracy] AS VARCHAR(20)) AS [FP_L-Z_Accuracy]
		  ,CAST([FP_L-Z_Rate] AS VARCHAR(20)) AS [FP_L-Z_Rate]
		  ,CAST([FP_L-Z_Fluency] AS VARCHAR(100)) AS [FP_L-Z_Fluency]
		  ,CAST([FP_L-Z_Comprehension] AS VARCHAR(20)) AS [FP_L-Z_Comprehension]
	  FROM [KIPP_NJ].[dbo].[LIT$STEP_sharepoint_style_wide]
	  
	UNION ALL

	SELECT CAST([Student Number] AS VARCHAR(100)) AS [Student Number]
		  ,CAST([Grade Level] AS VARCHAR(20)) AS [Grade Level]
		  ,CAST([Team] AS VARCHAR(20)) AS [Team]
		  ,[Step Round]
		  ,CAST([Test Type] AS VARCHAR(20)) AS [Test Type]
		  ,CAST([Step Level] AS VARCHAR(20)) AS [Step Level]
		  ,CAST([status] AS VARCHAR(20)) AS [Status]
		  ,CAST([Independent Level] AS VARCHAR(20)) AS [Independent Level]
		  ,CAST([Instructional Level] AS VARCHAR(20)) AS [Instructional Level]
		  ,CAST([Pre _ Name] AS VARCHAR(20)) AS [Pre _ Name]
		  ,CAST([Pre _ Ph. Aw.-Rhyme] AS VARCHAR(20)) AS [Pre _ Ph. Aw.-Rhyme]
		  ,CAST([Pre - 1 _ Concepts about Print] AS VARCHAR(20)) AS [Pre - 1 _ Concepts about Print]
		  ,CAST([Pre - 2 _ LID Name] AS VARCHAR(20)) AS [Pre - 2 _ LID Name]
		  ,CAST([Pre - 3 _ LID Sound] AS VARCHAR(20)) AS [Pre - 3 _ LID Sound]
		  ,CAST([STEP 1 _ PA-1st] AS VARCHAR(20)) AS [STEP 1 _ PA-1st]
		  ,CAST([STEP 1 _ Reading Record] AS VARCHAR(20)) AS [STEP 1 _ Reading Record]
		  ,CAST([STEP 1 - 3 _ Dev. Spell] AS VARCHAR(20)) AS [STEP 1 - 3 _ Dev. Spell]
		  ,CAST([STEP 2_Reading Record: Bk1 Acc] AS VARCHAR(20)) AS [STEP 2_Reading Record: Bk1 Acc]
		  ,CAST([STEP 2_Reading Record: Bk2 Acc] AS VARCHAR(20)) AS [STEP 2_Reading Record: Bk2 Acc]
		  ,CAST([STEP 2 - 3 _ PA - seg] AS VARCHAR(20)) AS [STEP 2 - 3 _ PA - seg]
		  ,CAST([STEP 2 - 3 _ Comprehension] AS VARCHAR(20)) AS [STEP 2 - 3 _ Comprehension]
		  ,CAST([STEP 3 - 12 _ Acurracy] AS VARCHAR(20)) AS [STEP 3 - 12 _ Acurracy]
		  ,CAST([STEP 4 - 12 _ Fluency] AS VARCHAR(20)) AS [STEP 4 - 12 _ Fluency]
		  ,CAST([STEP 4 - 5 _ Comprehension] AS VARCHAR(20)) AS [STEP 4 - 5 _ Comprehension]
		  ,CAST([STEP 4 - 5 _ Dev. Spell] AS VARCHAR(20)) AS [STEP 4 - 5 _ Dev. Spell]
		  ,CAST([STEP 4 - 12 _ Rate] AS VARCHAR(20)) AS [STEP 4 - 12 _ Rate]
		  ,CAST([STEP 6 - 7 _ Comprehension] AS VARCHAR(20)) AS [STEP 6 - 7 _ Comprehension]
		  ,CAST([STEP 6 - 7 _ Dev. Spell] AS VARCHAR(20)) AS [STEP 6 - 7 _ Dev. Spell]
		  ,CAST([STEP 8  _ Comprehension] AS VARCHAR(20)) AS [STEP 8  _ Comprehension]
		  ,CAST([STEP 8 - 12 _ Retell] AS VARCHAR(20)) AS [STEP 8 - 12 _ Retell]
		  ,CAST([STEP 8 - 10 _ Dev. Spell] AS VARCHAR(20)) AS [STEP 8 - 10 _ Dev. Spell]
		  ,CAST([STEP 9 - 12 _ Comprehension] AS VARCHAR(20)) AS [STEP 9 - 12 _ Comprehension]
		  ,CAST([STEP 11 - 12 _ Dev. Spell] AS VARCHAR(20)) AS [STEP 11 - 12 _ Dev. Spell]
		  ,CAST([FP_L-Z_Accuracy] AS VARCHAR(20)) AS [FP_L-Z_Accuracy]
		  ,CAST([FP_L-Z_Rate] AS VARCHAR(20)) AS [FP_L-Z_Rate]
		  ,CAST([FP_L-Z_Fluency] AS VARCHAR(100)) AS [FP_L-Z_Fluency]
		  ,CAST([FP_L-Z_Comprehension] AS VARCHAR(20)) AS [FP_L-Z_Comprehension]
	  FROM [KIPP_NJ].[dbo].[LIT$FP_sharepoint_style_wide]
  ) unioned
JOIN LIT$step_rounds step_rounds
  ON unioned.[Step Round] >= step_rounds.Start_Date
 AND unioned.[Step Round] <= step_rounds.End_Date