USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lit_tracker#ES AS

SELECT Academic_Year
      ,Test_Round
      ,sch.ABBREVIATION AS School
      ,CASE WHEN rs.grade_level = 0 THEN 'K' ELSE CONVERT(VARCHAR,rs.grade_level) END AS Gr
      ,s.Team
      ,s.LASTFIRST AS Name
      ,cs.SPEDLEP
      ,rs.read_lvl AS Reading_Level
      ,ROUND(CONVERT(FLOAT,GLEQ),1) AS GLEQ
      ,rs.status      
      ,CONVERT(VARCHAR,Test_Date, 101) AS Test_Date
      ,instruct_lvl AS Instructional_Level
      ,indep_lvl AS Independent_Level
      ,long.domain
      ,long.label
      ,long.score
      ,long.is_prof
      ,dna.dna_reason AS Reasons_for_DNA
      ,Color
      ,Genre
      ,FP_KeyLever
      ,FP_WPMrate      
      ,goal_lvl AS Round_Goal
      ,CASE WHEN met_goal = 1 THEN 'Yes' ELSE 'No' END AS Met_Goal
      ,CASE WHEN achv_curr_round = 1 THEN 'x' ELSE NULL END AS Round_Achieved
      ,CASE WHEN dna_round = 1 THEN 'x' ELSE NULL END AS Round_DNA
FROM LIT$test_events#identifiers rs WITH(NOLOCK)
LEFT OUTER JOIN LIT$dna_reasons dna WITH(NOLOCK)
  ON rs.unique_id = dna.unique_id
 AND rs.studentid = dna.studentid 
LEFT OUTER JOIN LIT$readingscores_long long WITH(NOLOCK)
  ON rs.unique_id = long.unique_id 
 AND rs.studentid = long.studentid 
JOIN SCHOOLS sch WITH(NOLOCK)
  ON rs.schoolid = sch.SCHOOL_NUMBER 
JOIN students s WITH(NOLOCK)
  ON rs.studentid = s.id
JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON rs.studentid = cs.studentid
WHERE rs.academic_year = 2014
  AND rs.schoolid IN (73254,73255,73256,73257,179901)