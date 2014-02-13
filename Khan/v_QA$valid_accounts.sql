USE Khan
GO

CREATE VIEW QA$valid_accounts AS
SELECT s.id
      ,s.lastfirst
      ,s.first_name + ' ' + s.last_name AS full_name
      ,s.schoolid
      ,s.grade_level
      ,d.nickname
      ,replace(convert(varchar,convert(Money, d.points),1),'.00','') AS points
      ,CAST(ROUND((d.total_seconds_watched + 0.0) / 60, 1) AS float) AS min_watched
FROM KIPP_NJ..STUDENTS s
LEFT OUTER JOIN Khan..stu_detail#identifiers d
  ON s.id = d.studentid
WHERE s.enroll_status = 0