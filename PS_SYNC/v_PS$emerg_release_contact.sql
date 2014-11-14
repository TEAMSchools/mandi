USE KIPP_NJ
GO

ALTER VIEW PS$emerg_release_contact AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT id AS studentid      
        ,Emerg_Contact_1
        ,ps_customfields.getcf(''Students'',id,''Emerg_1_Rel'') AS Emerg_1_Rel
        ,Emerg_Phone_1
        ,Emerg_Contact_2
        ,ps_customfields.getcf(''Students'',id,''Emerg_2_Rel'') AS Emerg_2_Rel
        ,Emerg_Phone_2
        ,ps_customfields.getcf(''Students'',id,''Emerg_Contact_3'') AS Emerg_Contact_3
        ,ps_customfields.getcf(''Students'',id,''Emerg_3_Rel'') AS Emerg_3_Rel
        ,ps_customfields.getcf(''Students'',id,''Emerg_3_Phone'') AS Emerg_3_Phone
        ,ps_customfields.getcf(''Students'',id,''Emerg_4_Name'') AS Emerg_4_Name
        ,ps_customfields.getcf(''Students'',id,''Emerg_4_Rel'') AS Emerg_4_Rel
        ,ps_customfields.getcf(''Students'',id,''Emerg_4_Phone'') AS Emerg_4_Phone
        ,ps_customfields.getcf(''Students'',id,''Emerg_5_Name'') AS Emerg_5_Name
        ,ps_customfields.getcf(''Students'',id,''Emerg_5_Rel'') AS Emerg_5_Rel
        ,ps_customfields.getcf(''Students'',id,''Emerg_5_Phone'') AS Emerg_5_Phone
        ,ps_customfields.getcf(''Students'',id,''Release_1_Name'') AS Release_1_Name
        ,ps_customfields.getcf(''Students'',id,''Release_1_Phone'') AS Release_1_Phone
        ,ps_customfields.getcf(''Students'',id,''Release_1_Relation'') AS Release_1_Relation      
        ,ps_customfields.getcf(''Students'',id,''Release_2_Name'') AS Release_2_Name
        ,ps_customfields.getcf(''Students'',id,''Release_2_Phone'') AS Release_2_Phone
        ,ps_customfields.getcf(''Students'',id,''Release_2_Relation'') AS Release_2_Relation
        ,ps_customfields.getcf(''Students'',id,''Release_3_Name'') AS Release_3_Name
        ,ps_customfields.getcf(''Students'',id,''Release_3_Phone'') AS Release_3_Phone
        ,ps_customfields.getcf(''Students'',id,''Release_3_Relation'') AS Release_3_Relation
        ,ps_customfields.getcf(''Students'',id,''Release_4_Name'') AS Release_4_Name
        ,ps_customfields.getcf(''Students'',id,''Release_4_Phone'') AS Release_4_Phone
        ,ps_customfields.getcf(''Students'',id,''Release_4_Relation'') AS Release_4_Relation
        ,ps_customfields.getcf(''Students'',id,''Release_5_Name'') AS Release_5_Name
        ,ps_customfields.getcf(''Students'',id,''Release_5_Phone'') AS Release_5_Phone
        ,ps_customfields.getcf(''Students'',id,''Release_5_Relation'') AS Release_5_Relation
  FROM students
  WHERE enroll_status = 0
');