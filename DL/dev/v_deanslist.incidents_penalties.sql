USE gabby
GO

ALTER VIEW deanslist.incidents_penalties AS

SELECT dli.incident_id
      ,dli.penalties AS penalties_json
      ,dlip.StartDate
      ,dlip.SchoolID
      ,dlip.EndDate
      ,dlip.NumPeriods
      ,dlip.PenaltyID
      ,dlip.StudentID
      ,dlip.IncidentID
      ,dlip.SAID
      ,dlip.PenaltyName
      ,dlip.[Print]
      ,dlip.IncidentPenaltyID
      ,dlip.NumDays
FROM [gabby].[deanslist].[incidents] dli
CROSS APPLY OPENJSON(dli.penalties, N'$')
  WITH (
    StartDate DATE N'$.StartDate',
    SchoolID INT N'$.SchoolID',
    EndDate DATE N'$.EndDate',
    NumPeriods FLOAT N'$.NumPeriods',
    PenaltyID BIGINT N'$.PenaltyID',
    StudentID BIGINT N'$.StudentID',
    IncidentID BIGINT N'$.IncidentID',
    SAID BIGINT N'$.SAID',
    PenaltyName VARCHAR(MAX) N'$.PenaltyName',
    [Print] VARCHAR(MAX) N'$.Print',
    IncidentPenaltyID BIGINT N'$.IncidentPenaltyID',
    NumDays FLOAT N'$.NumDays'
   ) AS dlip
WHERE dli.penalties != '[]'