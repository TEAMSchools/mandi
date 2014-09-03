USE KIPP_NJ
GO

ALTER VIEW PS$bus_info AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT id AS studentid      
        ,ps_customfields.getcf(''Students'',id,''Bus_Info_AM'') AS Bus_Info_AM
        ,ps_customfields.getcf(''Students'',id,''Bus_Info_PM'') AS Bus_Info_PM        
        ,ps_customfields.getcf(''Students'',id,''Bus_Info_Fridays'') AS Bus_Info_Fridays
        ,ps_customfields.getcf(''Students'',id,''Bus_Info_BGC_Closed'') AS Bus_Info_BGC_Closed
        ,ps_customfields.getcf(''Students'',id,''Bus_Notes'') AS Bus_Notes        
        ,ps_customfields.getcf(''Students'',id,''geocode'') AS geocode        
  FROM students
  WHERE schoolid IN (73254, 73255, 73256, 73257, 179901)    
')