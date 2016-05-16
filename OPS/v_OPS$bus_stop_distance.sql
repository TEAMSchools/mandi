USE KIPP_NJ
GO

ALTER VIEW OPS$bus_stop_distance AS

SELECT student_id
      ,bus_stop_name
      ,distance_to_bus_stop
      ,RANK() OVER(
        PARTITION BY student_id
          ORDER BY distance_to_bus_stop ASC) AS distance_rank
      ,ROW_NUMBER() OVER(
        PARTITION BY student_id
          ORDER BY distance_to_bus_stop ASC) AS distance_rank_unique
FROM OPENROWSET(
  'MSDASQL'
 ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
 ,'SELECT * FROM C:\data_robot\bussing\data\bus_stop_distance.csv'
 )
