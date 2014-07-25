USE RutgersReady
GO

ALTER VIEW STUDENT_REPORT$news_feed#format AS
SELECT TOP 10000000 a.studentid
      ,'<div class=\"feed_title\">' +
         CAST(DATEPART(Month, a.date_achieved) AS VARCHAR) + '/' + CAST(DATEPART(Day, a.date_achieved) AS VARCHAR) + ': ' + a.title +
        '</div>' + 
        '<div>' +
           '<img height=\"100\" src=\"' + a.img_path + '\"' +
        '</div>' +
        '<div class=\"feed_description\">' +
           a.description +
        '</div>' AS report_html_string
FROM RutgersReady..STUDENT_REPORT$news_feed_achievements a
ORDER BY a.studentid
        ,a.date_achieved DESC