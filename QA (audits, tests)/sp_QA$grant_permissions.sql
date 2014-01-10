USE KIPP_NJ
GO

ALTER PROCEDURE sp_QA$grant_permissions AS
GRANT SELECT ON LIT$FP_test_events_long#identifiers#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_tracker#NCA#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_detail#NCA#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$quick_lookup#NCA#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_tracker#Rise_static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_tracker#TEAM_static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_tracker#NCA#static TO db_data_tool_reader
GRANT SELECT ON reporting$reading_log TO db_data_tool_reader
GRANT SELECT ON STUDENTS TO db_data_tool_reader
GRANT SELECT ON CUSTOM_STUDENTS TO db_data_tool_reader
GRANT SELECT ON ES_DAILY$daily_tracking_long#static TO db_data_tool_reader
GRANT SELECT ON MAP$rutgers_ready_student_goals TO db_data_tool_reader 
GRANT SELECT ON MAP$comprehensive#identifiers TO db_data_tool_reader 
GRANT SELECT ON MAP$best_baseline#static TO db_data_tool_reader
GRANT SELECT ON DISC$log#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$dates TO db_data_tool_reader
GRANT SELECT ON GPA$detail#Rise TO db_data_tool_reader
GRANT SELECT ON GRADES$elements TO db_data_tool_reader
GRANT EXECUTE ON fn_Global_Term_Id TO db_data_tool_reader