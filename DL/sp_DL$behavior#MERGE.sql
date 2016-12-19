USE KIPP_NJ
GO

ALTER PROCEDURE sp_DL$behavior#MERGE AS

BEGIN
  
  MERGE KIPP_NJ..DL$behavior AS TARGET
  USING KIPP_NJ..AUTOLOAD$DL_behavior AS SOURCE
     ON TARGET.dlsaid = SOURCE.dlsaid    
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.BINI_ID = SOURCE.BINI_ID
       ,TARGET.[index] = SOURCE.[index]
       ,TARGET.behavior = SOURCE.behavior
       ,TARGET.behaviorcategory = SOURCE.behaviorcategory
       ,TARGET.behaviordate = SOURCE.behaviordate
       ,TARGET.dlorganizationid = SOURCE.dlorganizationid       
       ,TARGET.dlschoolid = SOURCE.dlschoolid
       ,TARGET.dlstudentid = SOURCE.dlstudentid
       ,TARGET.dluserid = SOURCE.dluserid
       ,TARGET.dl_lastupdate = SOURCE.dl_lastupdate
       ,TARGET.pointvalue = SOURCE.pointvalue
       ,TARGET.roster = SOURCE.roster
       ,TARGET.rosterid = SOURCE.rosterid
       ,TARGET.schoolname = SOURCE.schoolname
       ,TARGET.secondarystudentid = SOURCE.secondarystudentid
       ,TARGET.sourceid = SOURCE.sourceid
       ,TARGET.sourceprocedure = SOURCE.sourceprocedure
       ,TARGET.sourcetype = SOURCE.sourcetype
       ,TARGET.stafffirstname = SOURCE.stafffirstname
       ,TARGET.stafflastname = SOURCE.stafflastname
       ,TARGET.staffmiddlename = SOURCE.staffmiddlename
       ,TARGET.staffschoolid = SOURCE.staffschoolid
       ,TARGET.stafftitle = SOURCE.stafftitle
       ,TARGET.studentfirstname = SOURCE.studentfirstname
       ,TARGET.studentlastname = SOURCE.studentlastname
       ,TARGET.studentmiddlename = SOURCE.studentmiddlename
       ,TARGET.studentschoolid = SOURCE.studentschoolid
  WHEN NOT MATCHED BY TARGET THEN
   INSERT
    (BINI_ID
    ,[index]
    ,behavior
    ,behaviorcategory
    ,behaviordate
    ,dlorganizationid
    ,dlsaid
    ,dlschoolid
    ,dlstudentid
    ,dluserid
    ,dl_lastupdate
    ,pointvalue
    ,roster
    ,rosterid
    ,schoolname
    ,secondarystudentid
    ,sourceid
    ,sourceprocedure
    ,sourcetype
    ,stafffirstname
    ,stafflastname
    ,staffmiddlename
    ,staffschoolid
    ,stafftitle
    ,studentfirstname
    ,studentlastname
    ,studentmiddlename
    ,studentschoolid)
   VALUES
    (SOURCE.BINI_ID
    ,SOURCE.[index]
    ,SOURCE.behavior
    ,SOURCE.behaviorcategory
    ,SOURCE.behaviordate
    ,SOURCE.dlorganizationid
    ,SOURCE.dlsaid
    ,SOURCE.dlschoolid
    ,SOURCE.dlstudentid
    ,SOURCE.dluserid
    ,SOURCE.dl_lastupdate
    ,SOURCE.pointvalue
    ,SOURCE.roster
    ,SOURCE.rosterid
    ,SOURCE.schoolname
    ,SOURCE.secondarystudentid
    ,SOURCE.sourceid
    ,SOURCE.sourceprocedure
    ,SOURCE.sourcetype
    ,SOURCE.stafffirstname
    ,SOURCE.stafflastname
    ,SOURCE.staffmiddlename
    ,SOURCE.staffschoolid
    ,SOURCE.stafftitle
    ,SOURCE.studentfirstname
    ,SOURCE.studentlastname
    ,SOURCE.studentmiddlename
    ,SOURCE.studentschoolid)
  --WHEN NOT MATCHED BY SOURCE AND TARGET.CALENDARDATE >= '2016-07-01' THEN /* UPDATE ANUALLY */
  -- DELETE
  OUTPUT $ACTION, deleted.*
  ;

END

GO