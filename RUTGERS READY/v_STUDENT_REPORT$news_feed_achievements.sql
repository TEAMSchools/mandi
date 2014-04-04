USE RutgersReady
GO

ALTER VIEW STUDENT_REPORT$news_feed_achievements AS
SELECT b.studentid
      ,b.date_earned AS date_achieved
      ,'Khan: ' + m.description AS title
      ,REPLACE(m.safe_extended_description, ' (time limit depends on skill difficulty)', '') + 
         CASE
           WHEN b.context != 'None' THEN ' <i>(' + b.context + ')</i>'
           ELSE ''
         END AS description
      ,m.icon_large AS img_path
FROM Khan..badge_detail#identifiers b
JOIN Khan..badge_metadata m
  ON b.slug = m.slug
WHERE DATEDIFF(day, b.date_earned, GETDATE()) <= 14

--UNION ALL