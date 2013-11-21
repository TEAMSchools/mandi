USE KIPP_NJ
GO

ALTER VIEW AM$detail AS
SELECT sub.*
      ,am_stuobj.[iLibraryObjectiveID] as ilibraryobjectiveid 
      ,am_stuobj.[tiObjectiveState]    as tiobjectivestate
      ,am_stuobj.[tiMasteredType]      as timasteredtype
      ,am_stuobj.[dtAssignedDate]      as dtassigneddate
      ,am_stuobj.[dtMasteredDate]      as dtmastereddate
      ,am_stuobj.[dtReviewedDate]      as dtrevieweddate
      ,am_stuobj.[dtTestableDate]      as dttestabledate
      ,am_stuobj.[dtWorkingDate]       as dtworkingdate
      ,am_stuobj.[dtInterveneDate]     as dtintervenedate
      ,am_obj.[iLibraryID]             as ilibraryid
      ,am_obj.[chObjectiveCode]        as chobjectivecode
      ,am_obj.[vchDescription]         as vchdescription
      ,am_obj.[siOrder]                as siorder
FROM
     (SELECT s.id AS base_studentid
            ,CAST(s.student_number AS VARCHAR) AS base_student_number
      FROM KIPP_NJ..STUDENTS s
      WHERE s.enroll_status = 0 
      ) sub
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_RISE].[dbo].[rl_User] rluser  
  ON rluser.[vchPreviousIDNum] = sub.base_student_number
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_RISE].[dbo].[am_StudentObjective] am_stuobj
  ON rluser.[iUserID] = am_stuobj.[iUserID]
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_RISE].[dbo].[am_LibraryObjective] am_obj
  ON am_stuobj.[iLibraryObjectiveID] = am_obj.[iLibraryObjectiveID]

UNION ALL

SELECT sub.*
      ,am_stuobj.[iLibraryObjectiveID] as ilibraryobjectiveid 
      ,am_stuobj.[tiObjectiveState]    as tiobjectivestate
      ,am_stuobj.[tiMasteredType]      as timasteredtype
      ,am_stuobj.[dtAssignedDate]      as dtassigneddate
      ,am_stuobj.[dtMasteredDate]      as dtmastereddate
      ,am_stuobj.[dtReviewedDate]      as dtrevieweddate
      ,am_stuobj.[dtTestableDate]      as dttestabledate
      ,am_stuobj.[dtWorkingDate]       as dtworkingdate
      ,am_stuobj.[dtInterveneDate]     as dtintervenedate
      ,am_obj.[iLibraryID]             as ilibraryid
      ,am_obj.[chObjectiveCode]        as chobjectivecode
      ,am_obj.[vchDescription]         as vchdescription
      ,am_obj.[siOrder]                as siorder
FROM
     (SELECT s.id AS base_studentid
            ,CAST(s.student_number AS VARCHAR) AS base_student_number
      FROM KIPP_NJ..STUDENTS s
      WHERE s.enroll_status = 0 
      ) sub
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_TEAM].[dbo].[rl_User] rluser
  ON rluser.[vchPreviousIDNum] = sub.base_student_number
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_TEAM].[dbo].[am_StudentObjective] am_stuobj
  ON rluser.[iUserID] = am_stuobj.[iUserID]
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_TEAM].[dbo].[am_LibraryObjective] am_obj
  ON am_stuobj.[iLibraryObjectiveID] = am_obj.[iLibraryObjectiveID]

UNION ALL

SELECT sub.*
      ,am_stuobj.[iLibraryObjectiveID] as ilibraryobjectiveid 
      ,am_stuobj.[tiObjectiveState]    as tiobjectivestate
      ,am_stuobj.[tiMasteredType]      as timasteredtype
      ,am_stuobj.[dtAssignedDate]      as dtassigneddate
      ,am_stuobj.[dtMasteredDate]      as dtmastereddate
      ,am_stuobj.[dtReviewedDate]      as dtrevieweddate
      ,am_stuobj.[dtTestableDate]      as dttestabledate
      ,am_stuobj.[dtWorkingDate]       as dtworkingdate
      ,am_stuobj.[dtInterveneDate]     as dtintervenedate
      ,am_obj.[iLibraryID]             as ilibraryid
      ,am_obj.[chObjectiveCode]        as chobjectivecode
      ,am_obj.[vchDescription]         as vchdescription
      ,am_obj.[siOrder]                as siorder
FROM
     (SELECT s.id AS base_studentid
            ,CAST(s.student_number AS VARCHAR) AS base_student_number
      FROM KIPP_NJ..STUDENTS s
      WHERE s.enroll_status = 0 
      ) sub
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_NCA].[dbo].[rl_User] rluser
  ON rluser.[vchPreviousIDNum] = sub.base_student_number
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_NCA].[dbo].[am_StudentObjective] am_stuobj
  ON rluser.[iUserID] = am_stuobj.[iUserID]
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_NCA].[dbo].[am_LibraryObjective] am_obj
  ON am_stuobj.[iLibraryObjectiveID] = am_obj.[iLibraryObjectiveID]

UNION ALL

SELECT sub.*
      ,am_stuobj.[iLibraryObjectiveID] as ilibraryobjectiveid 
      ,am_stuobj.[tiObjectiveState]    as tiobjectivestate
      ,am_stuobj.[tiMasteredType]      as timasteredtype
      ,am_stuobj.[dtAssignedDate]      as dtassigneddate
      ,am_stuobj.[dtMasteredDate]      as dtmastereddate
      ,am_stuobj.[dtReviewedDate]      as dtrevieweddate
      ,am_stuobj.[dtTestableDate]      as dttestabledate
      ,am_stuobj.[dtWorkingDate]       as dtworkingdate
      ,am_stuobj.[dtInterveneDate]     as dtintervenedate
      ,am_obj.[iLibraryID]             as ilibraryid
      ,am_obj.[chObjectiveCode]        as chobjectivecode
      ,am_obj.[vchDescription]         as vchdescription
      ,am_obj.[siOrder]                as siorder
FROM
     (SELECT s.id AS base_studentid
            ,CAST(s.student_number AS VARCHAR) AS base_student_number
      FROM KIPP_NJ..STUDENTS s
      WHERE s.enroll_status = 0 
      ) sub
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_SPARK].[dbo].[rl_User] rluser
  ON rluser.[vchPreviousIDNum] = sub.base_student_number
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_SPARK].[dbo].[am_StudentObjective] am_stuobj
  ON rluser.[iUserID] = am_stuobj.[iUserID]
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_SPARK].[dbo].[am_LibraryObjective] am_obj
  ON am_stuobj.[iLibraryObjectiveID] = am_obj.[iLibraryObjectiveID]