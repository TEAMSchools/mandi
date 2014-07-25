USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_PS$STUDENTS_refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$STUDENTS|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$STUDENTS|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#PS$STUDENTS|refresh]
  FROM OPENQUERY(PS_TEAM, '
    SELECT dcid
          ,id
          ,lastfirst
          ,first_name
          ,middle_name
          ,last_name
          ,student_number
          ,enroll_status
          ,grade_level
          ,schoolid

          ,gender
          ,dob
          ,lunchstatus
          ,ethnicity
						    ,fedethnicity
          ,fedracedecline
          ,ssn

          ,entrydate
          ,exitdate
          ,entrycode
          ,exitcode
          ,enrollmentid

          ,fteid
      
          ,districtofresidence
          ,enrollmenttype
          ,enrollmentcode
          ,membershipshare
          ,fee_exemption_status
          ,tuitionpayer
          ,enrollment_transfer_date_pend
						    ,withdrawal_reason_code
     
          ,team
          ,house
          ,building
          ,track

          ,campusid
          ,enrollment_schoolid

						    ,state_studentnumber
						    ,state_excludefromreporting
          ,state_enrollflag

						    ,districtentrydate
						    ,districtentrygradelevel
          ,schoolentrydate
          ,schoolentrygradelevel

          ,gradreqsetid								
          ,gpentryyear

          ,graduated_schoolname
          ,graduated_schoolid
          ,graduated_rank

          ,summerschoolid
          ,summerschoolnote

          ,phone_id
          ,lunch_id

          ,web_id
          ,web_password
          ,allowwebaccess
          ,student_web_id
          ,student_web_password
          ,student_allowwebaccess

          ,photoflag

          ,street
          ,city
          ,state
          ,zip
          
						    ,mailing_city
          ,mailing_street
          ,mailing_state
          ,mailing_zip	
    							
          ,geocode
          ,mailing_geocode

          ,mother
          ,father
          ,home_phone

          ,cumulative_gpa
          ,simple_gpa
          ,cumulative_pct
          ,simple_pct
          ,customrank_gpa

          ,lastmeal
          ,pl_language
						    ,person_id
          ,ldapenabled
           
          ,home_room
          ,classof
          ,family_ident
          ,next_school
          ,exclude_fr_rank
          ,teachergroupid


          ,bus_route
          ,bus_stop

						    ,locker_number
						    ,locker_combination

          ,balance1
          ,balance2
          ,balance3
          ,balance4
          
          ,doctor_name
          ,doctor_phone

          ,emerg_contact_1
          ,emerg_contact_2
          ,emerg_phone_1
          ,emerg_phone_2

          ,sched_yearofgraduation
          ,sched_nextyearhouse
          ,sched_nextyearbuilding
          ,sched_nextyearteam
          ,sched_nextyearhomeroom
          ,sched_nextyeargrade
          ,sched_scheduled
          ,sched_lockstudentschedule
          ,sched_priority
          ,sched_loadlock

          ,studentpers_guid
          ,studentpict_guid
          ,studentschlenrl_guid
         
          ,guardian_studentcont_guid
          ,father_studentcont_guid
          ,mother_studentcont_guid
    FROM students
  ');
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [LIT$FP_test_events_long#identifiers] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..STUDENTS');

  --STEP 5: disable all nonclustered indexes on table
  SELECT @sql = @sql + 
   'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
  FROM 
   sys.indexes
  JOIN 
   sys.objects 
   ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
   AND sys.objects.type_desc = 'USER_TABLE'
   AND sys.objects.name = 'STUDENTS';

 EXEC (@sql);

 -- step 6: insert into final destination
 INSERT INTO [dbo].[STUDENTS]
 SELECT *
 FROM [#PS$STUDENTS|refresh];

 -- Step 4: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'STUDENTS';

 EXEC (@sql);
  
END