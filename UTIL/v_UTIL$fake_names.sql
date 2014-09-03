CREATE VIEW UTIL$fake_names AS
SELECT *
FROM OPENROWSET(
  'MSDASQL'
 ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
 ,'select * from C:\data_robot\logistical\fake_names.csv')