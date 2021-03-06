SELECT SUBSTRING(data,1,2) AS [Reporting Year Identifier]
      ,SUBSTRING(data,3,25) AS [Last Name]
      ,SUBSTRING(data,28,16) AS [First Name]
      ,SUBSTRING(data,44,1) AS [Middle Initial]
      ,SUBSTRING(data,45,40) AS [Address]
      ,SUBSTRING(data,85,2) AS [Country Code]
      ,SUBSTRING(data,87,1) AS [Gender (Numeric)]
      ,SUBSTRING(data,88,1) AS [Gender (Alpha)]
      ,SUBSTRING(data,89,2) AS [Grade Level]
      ,SUBSTRING(data,91,9) AS [ACT ID]
      ,SUBSTRING(data,100,1) AS [Phone Type]
      ,SUBSTRING(data,101,6) AS [Date of Birth]
      ,SUBSTRING(data,107,10) AS [Phone Number]
      ,SUBSTRING(data,117,25) AS [City]
      ,SUBSTRING(data,142,2) AS [State (Numeric)]
      ,SUBSTRING(data,144,2) AS [State (Alpha)]
      ,SUBSTRING(data,146,9) AS [ZIP Code]
      ,SUBSTRING(data,155,8) AS [Expanded Date of Birth]      
      ,SUBSTRING(data,163,2) AS [Combined English/Writing (EW) Score]
      ,SUBSTRING(data,165,2) AS [Writing Subscore (WR)]      
      ,SUBSTRING(data,171,8) AS [Comments on Essay]      
      ,SUBSTRING(data,192,13) AS [State-Assigned Student ID]      
      ,SUBSTRING(data,205,6) AS [High School Code]
      ,SUBSTRING(data,211,2) AS [High School Grades - English]
      ,SUBSTRING(data,213,2) AS [High School Grades - Mathematics]
      ,SUBSTRING(data,215,2) AS [High School Grades - Social Studies]
      ,SUBSTRING(data,217,2) AS [High School Grades - Natural Sciences]
      ,SUBSTRING(data,220,3) AS [High School Average]
      ,SUBSTRING(data,223,4) AS [Year of HS Graduation]
      ,SUBSTRING(data,227,6) AS [Expanded Test Date]
      ,SUBSTRING(data,233,4) AS [Test Date]
      ,SUBSTRING(data,237,3) AS [State Rank - English]
      ,SUBSTRING(data,240,3) AS [State Rank - Mathematics]
      ,SUBSTRING(data,243,3) AS [State Rank - Reading]
      ,SUBSTRING(data,246,3) AS [State Rank - Science]
      ,SUBSTRING(data,249,1) AS [Test Location]
      ,SUBSTRING(data,250,2) AS [Canadian Province]
      ,SUBSTRING(data,253,7) AS [Canadian Postal Code]
      ,SUBSTRING(data,260,1) AS [Corrected ReportIndicator]
      ,SUBSTRING(data,261,2) AS [Scale Scores - English]
      ,SUBSTRING(data,263,2) AS [Scale Scores - Mathematics]
      ,SUBSTRING(data,265,2) AS [Scale Scores - Reading]
      ,SUBSTRING(data,267,2) AS [Scale Scores - Science]
      ,SUBSTRING(data,269,2) AS [Scale Scores - Composite]
      ,SUBSTRING(data,272,3) AS [Sum of Scale Scores]
      ,SUBSTRING(data,275,3) AS [State Rank]
      ,SUBSTRING(data,281,2) AS [Science & Technology]
      ,SUBSTRING(data,285,2) AS [Arts]
      ,SUBSTRING(data,289,2) AS [Social Service]
      ,SUBSTRING(data,293,2) AS [Administration & Sales]
      ,SUBSTRING(data,297,2) AS [Business Operations]
      ,SUBSTRING(data,301,2) AS [Technical]
      ,SUBSTRING(data,303,6) AS [World-of-Work Map]
      ,SUBSTRING(data,320,2) AS [Scale Subscores – Usage/Mechanics]
      ,SUBSTRING(data,322,2) AS [Scale Subscores – Rhetorical Skills]
      ,SUBSTRING(data,324,2) AS [Scale Subscores – Elementary Algebra]
      ,SUBSTRING(data,326,2) AS [Scale Subscores – Algebra/Coord Geom]
      ,SUBSTRING(data,328,2) AS [Scale Subscores – Plane Geom/Trig]
      ,SUBSTRING(data,330,2) AS [Scale Subscores – Soc Studies/Science]
      ,SUBSTRING(data,332,2) AS [Scale Subscores – Arts/Literature]
      ,SUBSTRING(data,334,3) AS [State Rank (Cumulative %) – STEM]
      ,SUBSTRING(data,337,3) AS [State Rank (Cumulative %) – ELA]
      ,SUBSTRING(data,369,2) AS [Science & Technology]
      ,SUBSTRING(data,371,2) AS [Arts]
      ,SUBSTRING(data,373,2) AS [Social Service]
      ,SUBSTRING(data,375,2) AS [Administration & Sales]
      ,SUBSTRING(data,377,2) AS [Business Operations]
      ,SUBSTRING(data,379,2) AS [Technical]
      ,SUBSTRING(data,381,10) AS [Local ID Number]
      ,SUBSTRING(data,605,1) AS [EOS Release]
      ,SUBSTRING(data,606,2) AS [Religious Affiliation]
      ,SUBSTRING(data,631,30) AS [Courses Taken or Planned]
      ,SUBSTRING(data,661,30) AS [Grades Earned]
      ,SUBSTRING(data,691,10) AS [State-Assigned Student IDNumber (10-characters)]
      ,SUBSTRING(data,701,24) AS [College Choices]
      ,SUBSTRING(data,783,1) AS [Ranks Type]
      ,SUBSTRING(data,791,2) AS [Writing Subject Score]
      ,SUBSTRING(data,793,3) AS [US Rank (Cumulative %) – Writing Subject Score]
      ,SUBSTRING(data,796,2) AS [Writing Domain Scores - Ideas & Analysis]
      ,SUBSTRING(data,798,2) AS [Writing Domain Scores - Development & Support]
      ,SUBSTRING(data,800,2) AS [Writing Domain Scores - Organization]
      ,SUBSTRING(data,802,2) AS [Writing Domain Scores - Language Use & Conventions]
      ,SUBSTRING(data,804,2) AS [Writing Subject Score]
      ,SUBSTRING(data,806,2) AS [ELA Score]
      ,SUBSTRING(data,808,3) AS [US Rank (Cumulative %) – ELA]
      ,SUBSTRING(data,813,2) AS [STEM Score]
      ,SUBSTRING(data,815,3) AS [US Rank (Cumulative %) – STEM]
      ,SUBSTRING(data,820,1) AS [Understanding Complex]
      ,SUBSTRING(data,821,1) AS [Progress Toward Career]
      /*
      ,SUBSTRING(data,822,180) AS [Reporting Categories]
      ,SUBSTRING(data,822,30) AS [English]
      ,SUBSTRING(data,822,10) AS [Production of Writing]
      ,SUBSTRING(data,822,2) AS [Points Earned]
      ,SUBSTRING(data,824,2) AS [Points Possible]
      ,SUBSTRING(data,826,3) AS [% Correct]
      ,SUBSTRING(data,829,3) AS [Readiness Range]
      ,SUBSTRING(data,832,10) AS [Knowledge of Language]
      ,SUBSTRING(data,832,2) AS [Points Earned]
      ,SUBSTRING(data,834,2) AS [Points Possible]
      ,SUBSTRING(data,836,3) AS [% Correct]
      ,SUBSTRING(data,839,3) AS [Readiness Range]
      ,SUBSTRING(data,842,10) AS [Conventions of Standard English]
      ,SUBSTRING(data,842,2) AS [Points Earned]
      ,SUBSTRING(data,844,2) AS [Points Possible]
      ,SUBSTRING(data,846,3) AS [% Correct]
      ,SUBSTRING(data,849,3) AS [Readiness Range]
      ,SUBSTRING(data,852,80) AS [Mathematics]
      ,SUBSTRING(data,852,10) AS [Preparing for Higher Math]
      ,SUBSTRING(data,852,2) AS [Points Earned]
      ,SUBSTRING(data,854,2) AS [Points Possible]
      ,SUBSTRING(data,856,3) AS [% Correct]
      ,SUBSTRING(data,859,3) AS [Readiness Range]
      ,SUBSTRING(data,862,10) AS [Number & Quantity]
      ,SUBSTRING(data,862,2) AS [Points Earned]
      ,SUBSTRING(data,864,2) AS [Points Possible]
      ,SUBSTRING(data,866,3) AS [% Correct]
      ,SUBSTRING(data,869,3) AS [Readiness Range]
      ,SUBSTRING(data,872,10) AS [Algebra]
      ,SUBSTRING(data,872,2) AS [Points Earned]
      ,SUBSTRING(data,874,2) AS [Points Possible]
      ,SUBSTRING(data,876,3) AS [% Correct]
      ,SUBSTRING(data,879,3) AS [Readiness Range]
      ,SUBSTRING(data,882,10) AS [Functions]
      ,SUBSTRING(data,882,2) AS [Points Earned]
      ,SUBSTRING(data,884,2) AS [Points Possible]
      ,SUBSTRING(data,886,3) AS [% Correct]
      ,SUBSTRING(data,889,3) AS [Readiness Range]
      ,SUBSTRING(data,892,10) AS [Geometry]
      ,SUBSTRING(data,892,2) AS [Points Earned]
      ,SUBSTRING(data,894,2) AS [Points Possible]
      ,SUBSTRING(data,896,3) AS [% Correct]
      ,SUBSTRING(data,899,3) AS [Readiness Range]
      ,SUBSTRING(data,902,10) AS [Statistics & Probability]
      ,SUBSTRING(data,902,2) AS [Points Earned]
      ,SUBSTRING(data,904,2) AS [Points Possible]
      ,SUBSTRING(data,906,3) AS [% Correct]
      ,SUBSTRING(data,909,3) AS [Readiness Range]
      ,SUBSTRING(data,912,10) AS [Integrating Essential Skills]
      ,SUBSTRING(data,912,2) AS [Points Earned]
      ,SUBSTRING(data,914,2) AS [Points Possible]
      ,SUBSTRING(data,916,3) AS [% Correct]
      ,SUBSTRING(data,919,3) AS [Readiness Range]
      ,SUBSTRING(data,922,10) AS [Modeling]
      ,SUBSTRING(data,922,2) AS [Points Earned]
      ,SUBSTRING(data,924,2) AS [Points Possible]
      ,SUBSTRING(data,926,3) AS [% Correct]
      ,SUBSTRING(data,929,3) AS [Readiness Range]      
      ,SUBSTRING(data,942,30) AS [Reading]
      ,SUBSTRING(data,942,10) AS [Key Ideas & Details]
      ,SUBSTRING(data,942,2) AS [Points Earned]
      ,SUBSTRING(data,944,2) AS [Points Possible]
      ,SUBSTRING(data,946,3) AS [% Correct]
      ,SUBSTRING(data,949,3) AS [Readiness Range]
      ,SUBSTRING(data,952,10) AS [Craft & Structure]
      ,SUBSTRING(data,952,2) AS [Points Earned]
      ,SUBSTRING(data,954,2) AS [Points Possible]
      ,SUBSTRING(data,956,3) AS [% Correct]
      ,SUBSTRING(data,959,3) AS [Readiness Range]
      ,SUBSTRING(data,962,10) AS [Integration of Knowledge & Ideas]
      ,SUBSTRING(data,962,2) AS [Points Earned]
      ,SUBSTRING(data,964,2) AS [Points Possible]
      ,SUBSTRING(data,966,3) AS [% Correct]
      ,SUBSTRING(data,969,3) AS [Readiness Range]
      ,SUBSTRING(data,972,30) AS [Science]
      ,SUBSTRING(data,972,10) AS [Interpretation of Data]
      ,SUBSTRING(data,972,2) AS [Points Earned]
      ,SUBSTRING(data,974,2) AS [Points Possible]
      ,SUBSTRING(data,976,3) AS [% Correct]
      ,SUBSTRING(data,979,3) AS [Readiness Range]
      ,SUBSTRING(data,982,10) AS [Scientific Investigation]
      ,SUBSTRING(data,982,2) AS [Points Earned]
      ,SUBSTRING(data,984,2) AS [Points Possible]
      ,SUBSTRING(data,986,3) AS [% Correct]
      ,SUBSTRING(data,989,3) AS [Readiness Range]
      ,SUBSTRING(data,992,10) AS [Evaluation of Models, Inferences & Experimental Results]
      ,SUBSTRING(data,992,2) AS [Points Earned]
      ,SUBSTRING(data,994,2) AS [Points Possible]
      ,SUBSTRING(data,996,3) AS [% Correct]
      ,SUBSTRING(data,999,3) AS [Readiness Range]
      ,SUBSTRING(data,1002,45) AS [US Ranks]
      ,SUBSTRING(data,1002,6) AS [US Ranks]
      ,SUBSTRING(data,1008,21) AS [US Ranks]
      ,SUBSTRING(data,1008,3) AS [Usage/Mechanics]
      ,SUBSTRING(data,1011,3) AS [Rhetorical Skills]
      ,SUBSTRING(data,1014,3) AS [Elementary Algebra]
      ,SUBSTRING(data,1017,3) AS [Algebra/Coord Geom]
      ,SUBSTRING(data,1020,3) AS [Plane Geom/Trig]
      ,SUBSTRING(data,1023,3) AS [Soc Studies/Science]
      ,SUBSTRING(data,1026,3) AS [Arts/Literature]
      ,SUBSTRING(data,1029,15) AS [US Ranks]
      ,SUBSTRING(data,1029,3) AS [English]
      ,SUBSTRING(data,1032,3) AS [Mathematics]
      ,SUBSTRING(data,1035,3) AS [Reading]
      ,SUBSTRING(data,1038,3) AS [Science]
      ,SUBSTRING(data,1041,3) AS [Composite]
      ,SUBSTRING(data,1044,3) AS [State Rank]    
      --,SUBSTRING(data,932,10) AS [BLANK]  
      --,SUBSTRING(data,3,160) AS [Student IdentifyingInformation]
      --,SUBSTRING(data,3,42) AS [Student Name]
      --,SUBSTRING(data,163,16) AS [Writing Results– test events before 09/2015]
      --,SUBSTRING(data,167,4) AS [BLANK]
      --,SUBSTRING(data,179,13) AS [BLANK]
      --,SUBSTRING(data,205,22) AS [High School Information]
      --,SUBSTRING(data,211,8) AS [High School Grades]
      --,SUBSTRING(data,219,1) AS [BLANK]
      --,SUBSTRING(data,227,23) AS [ACT Test Information (continued in positions 260-274)]
      --,SUBSTRING(data,237,12) AS [State Ranks]
      --,SUBSTRING(data,250,10) AS [Postal Code/Province]
      --,SUBSTRING(data,252,1) AS [BLANK]
      --,SUBSTRING(data,260,15) AS [ACT Test Information continued]
      --,SUBSTRING(data,261,10) AS [Scale Scores]
      --,SUBSTRING(data,271,1) AS [BLANK]
      --,SUBSTRING(data,278,1) AS [BLANK]
      --,SUBSTRING(data,279,24) AS [Interest InventoryStandard Scores]
      --,SUBSTRING(data,279,2) AS [BLANK]
      --,SUBSTRING(data,283,2) AS [BLANK]
      --,SUBSTRING(data,287,2) AS [BLANK]
      --,SUBSTRING(data,291,2) AS [BLANK]
      --,SUBSTRING(data,295,2) AS [BLANK]
      --,SUBSTRING(data,299,2) AS [BLANK]
      --,SUBSTRING(data,309,11) AS [BLANK]
      --,SUBSTRING(data,320,14) AS [Scale Subscores– test events before 09/2016]
      --,SUBSTRING(data,340,29) AS [BLANK]
      --,SUBSTRING(data,369,12) AS [Interest Inventory –]
      --,SUBSTRING(data,391,10) AS [BLANK]
      --,SUBSTRING(data,401,150) AS [Student ProfileSection (SPS)– items 1-135*]
      --,SUBSTRING(data,551,54) AS [BLANK]
      --,SUBSTRING(data,608,23) AS [BLANK]
      --,SUBSTRING(data,631,60) AS [High School Courses/Grade Information]
      --,SUBSTRING(data,725,58) AS [BLANK]
      --,SUBSTRING(data,784,7) AS [BLANK]
      --,SUBSTRING(data,791,15) AS [Writing Results]
      --,SUBSTRING(data,796,8) AS [Writing Domain Scores]
      --,SUBSTRING(data,806,16) AS [Additional Scores &]
      --,SUBSTRING(data,811,2) AS [BLANK]
      --,SUBSTRING(data,818,2) AS [BLANK]
      --,SUBSTRING(data,1047,4) AS [BLANK]
      */
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_ACT_electronic_student_record_file]