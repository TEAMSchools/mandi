USE KIPP_NJ
GO

ALTER VIEW PM$social_support_long#Rise AS

SELECT CASE
        WHEN DATEPART(MONTH,[Timestamp]) IN (9,10) THEN 'BOY'
        ELSE NULL
       END AS survey_round      
      ,[Please enter your name] AS evaluator
      ,[What is your role?] AS evaluator_role      
      ,LEFT([Who are you completing the survey for?], CHARINDEX('(',[Who are you completing the survey for?])-1) AS person_evaluated
      ,REVERSE(SUBSTRING(REVERSE([Who are you completing the survey for?]), 2, CHARINDEX('(',REVERSE([Who are you completing the survey for?]))-2)) AS role_evaluated      
      ,LEFT(strand, CHARINDEX(' (', strand) - 1) AS strand
      ,SUBSTRING(strand, CHARINDEX('(', strand) + 1, 1) AS sub_heading
      ,strand AS raw_strand
      ,RIGHT(response, 1) AS response
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PM_Responses] WITH(NOLOCK)

UNPIVOT(
  response
  FOR strand IN ([Beliefs (A#_All children can and will learn# (GROWTH MINDSET))]
                ,[Beliefs (B#_Accountability starts and ends with me# (THE MIRROR)]
                ,[Beliefs (C#_Differences among people exist and are a source of s]
                ,[Character (A#_Gets stuck and does not stay there# (GRIT))]
                ,[Character (B#_Finds passion, joy, and adventure in the work# (ZE]
                ,[Character (C#_Values relationships and builds them intentionally]
                ,[Character (D#_Makes decisions with studentsâ€™ best interests in]
                ,[Character (E#_Keeps commitments made to: students, families, and]
                ,[Character (F#_Takes time to show gratitude# (GRATITUDE))]
                ,[Character (G#_Expresses and maintains optimism about the future ]
                ,[Self-Awareness & Self-Adjustment (A# Doesnâ€™t settle or sit# Gr]
                ,[Self-Awareness & Self-Adjustment (B# Calibrates emotions even wh]
                ,[Self-Awareness & Self-Adjustment (C# Adjusts tone and actions as]
                ,[Self-Awareness & Self-Adjustment (D# Manages time, energy, and a]
                ,[Building Relationships (A# Treats colleagues, students, and fami]
                ,[Building Relationships (B# Intentionally seeks to know others an]
                ,[Building Relationships (C# Engages in genuine conversations with]
                ,[Building Relationships (D# Notices and intentionally takes advan]
                ,[Building Relationships (E# Anticipates and identifies problems i]
                ,[Communication (A# Actively listens to others, with appropriate e]
                ,[Communication (B# Communicates with genuine warmth; maintains ri]
                ,[Communication (C# Responds to students and adults with positive ]
                ,[Communication (D# Avoids sarcasm#)]
                ,[Communication (E# Writes clearly and concisely, with appropriate]
                ,[Communication (F# Communicates praise, feedback, and concerns di]
                ,[Professionalism (A#_Honors our chosen profession and that our st]
                ,[Professionalism (B#_Embrace that part of being an excellent memb]
                ,[Professionalism (C#_Presents self as being prepared, punctual, p]
                ,[Continuous Learning (A# Seeks feedback and data early and often ]
                ,[Continuous Learning (B# Researches, observes, experiments, share])
 ) u