USE KIPP_NJ
GO

CREATE PROCEDURE sp_QA$grant_permissions AS
GRANT SELECT ON LIT$FP_test_events_long#identifiers#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_tracker#NCA#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_detail#NCA#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$quick_lookup#NCA#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_tracker#Rise_static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_tracker#TEAM_static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_tracker#NCA#static TO db_data_tool_reader
GRANT SELECT ON STUDENTS TO db_data_tool_reader
GRANT SELECT ON CUSTOM_STUDENTS TO db_data_tool_reader
GRANT SELECT ON ES_DAILY$daily_tracking_long#static TO db_data_tool_reader