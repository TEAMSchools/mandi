USE KIPP_NJ
GO

ALTER PROCEDURE sp_EMAIL$grade_monitoring#NCA
  @teacherid INT
 ,@teachername VARCHAR(100) AS 
BEGIN

DECLARE

  --@teacherid											INT = 2708
  
  --global, entire email
  @email_body										NVARCHAR(MAX)
 ,@email_subject							NVARCHAR(200)
  
 ,@gainer_code									NVARCHAR(50)
 ,@sinker_code									NVARCHAR(50)
 ,@off_track_code						NVARCHAR(50)
  
  --for cleaning up openquery (don't ask)
 ,@teacher_sql									VARCHAR(8000)
 

 --0. ensure temp table not in use
 IF OBJECT_ID(N'tempdb..#nca_teach_codes') IS NOT NULL
 BEGIN
     DROP TABLE #nca_teach_codes
 END
 
 --1. dump everything into a temp table
 SELECT sub.*
 INTO #nca_teach_codes
 FROM
   (SELECT * FROM 
    OPENQUERY(PS_TEAM, 
    'SELECT DISTINCT schoolid
                      ,teacherid
                      ,teacher
                      ,''stu_gainers_det_'' || teacherid || ''.png'' AS gainers_code
                      ,''stu_sinkers_det_'' || teacherid || ''.png'' AS sinkers_code
                      ,''stu_fail_det_'' || teacherid || ''.png'' AS off_track_code
        FROM
              (SELECT cc.termid
                      ,cc.sectionid
                      ,cc.schoolid
                      ,sections.course_number
                      ,teachers.id AS teacherid
                      ,teachers.first_name || '' '' || teachers.last_name AS teacher
                  FROM cc
                  JOIN sections
                  ON cc.sectionid = sections.ID
                  JOIN teachers
                  ON sections.teacher = teachers.id
                  WHERE cc.termid > 0 
                  AND cc.dateenrolled <= TRUNC(SYSDATE)
                  AND TRUNC(SYSDATE) <= cc.dateleft
                  AND cc.schoolid  = 73253)
        ORDER BY schoolid
                ,teacher')
   ) sub
 
 --2. delete everyone who is NOT the target teacher
 SET @teacher_sql =
  'DELETE
   FROM #nca_teach_codes
   WHERE teacherid != ' + CAST(@teacherid AS VARCHAR)
 EXEC(@teacher_sql)
 
 --3. set some codes that will link to images
 SET @gainer_code =
   (SELECT gainers_code
    FROM #nca_teach_codes)
    
  SET @sinker_code =
   (SELECT sinkers_code
    FROM #nca_teach_codes)
    
  SET @off_track_code = 
   (SELECT off_track_code
    FROM #nca_teach_codes)
    
  --4. email body
  SET @email_body = 
   '<html>
   <head>
     <style type="text/css">
      .small_text {
       font-size: 12px;
       font-family: "Helvetica", Verdana, sans-serif;
       margin: 0;
       padding: 0;
     }
      .med_text {
       font-size: 18px;
       font-family: "Helvetica", Verdana, sans-serif;
       margin: 0;
       padding: 0;
     }
     .pretty_big_text {
       font-size: 24px;
       font-family: "Helvetica", Verdana, sans-serif;
       font-weight: bold;
       text-align: center;
       margin: 0;
       padding: 0;
     }
     .big_text {
       font-size: 36px;
       font-family: "Helvetica", Verdana, sans-serif;
       font-weight: bold;
       text-align: center;
       margin: 0;
       padding: 0;
     }
     .big_number {
       font-size: 64pt;
       font-family: "Helvetica", Verdana, sans-serif;
       font-weight: bold;
       text-align: center;
       margin: 0;
       padding: 0;
     }
     </style>
   </head>

   <body> 
     
     <!-- C H A R T S -->
     <table width= "100%"  cellspacing="0" cellpadding="0">
        
        <tr>
          <td>
            <img src = "\\WINSQL01\r_images\' + CAST(@gainer_code AS VARCHAR) + '" width="1330">
          </td>
        </tr>

        <tr>
          <td>
            <img src = "\\WINSQL01\r_images\' + CAST(@sinker_code AS VARCHAR) + '" width="1330">
          </td>
        </tr>
        
        <tr>
          <td>
            <img src = "\\WINSQL01\r_images\' + CAST(@off_track_code AS VARCHAR) + '" width="1330">
          </td>
        </tr>

        
     </table>
   </body>
   </html>
   '
   
   SET @email_subject = 'NCA: ' + @teachername + ' Credit Completion Status'

   --.5 ship it!
   EXEC [msdb].[dbo].sp_send_dbmail 
          @profile_name = 'DataRobot'
         ,@body = @email_body
         ,@body_format ='HTML'
         --,@recipients = 'amartin@teamschools.org;ldesimon@teamschools.org;nmadigan@teamschools.org;vmarigna@teamschools.org;kswearingen@teamschools.org'
         ,@recipients = 'amartin@teamschools.org;ldesimon@teamschools.org'
         ,@subject = @email_subject
END