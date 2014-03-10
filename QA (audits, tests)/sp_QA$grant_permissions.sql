USE KIPP_NJ
GO

ALTER PROCEDURE sp_QA$grant_permissions AS

--DB objects
GRANT SELECT ON REPORTING$dates TO db_data_tool_reader
GRANT SELECT ON UTIL$reporting_weeks_days TO db_data_tool_reader

--Lit
GRANT SELECT ON LIT$FP_test_events_long#identifiers#static TO db_data_tool_reader
GRANT SELECT ON reporting$reading_log TO db_data_tool_reader
GRANT SELECT ON reporting$reading_log#NCA TO db_data_tool_reader

--Progress trackers
GRANT SELECT ON REPORTING$progress_tracker#NCA#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_detail#NCA#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_tracker#Rise_static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_tracker#TEAM_static TO db_data_tool_reader
GRANT SELECT ON REPORTING$progress_tracker#NCA#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$quick_lookup#NCA#static TO db_data_tool_reader

--PS sync
GRANT SELECT ON STUDENTS TO db_data_tool_reader
GRANT SELECT ON CUSTOM_STUDENTS TO db_data_tool_reader
GRANT SELECT ON DISC$log#static TO db_data_tool_reader
GRANT SELECT ON SCHOOLS TO db_data_tool_reader
GRANT SELECT ON TEACHERS TO db_data_tool_reader
GRANT SELECT ON CC TO db_data_tool_reader
GRANT SELECT ON SECTIONS TO db_data_tool_reader

--MAP
GRANT SELECT ON MAP$cohort_performance_targets TO db_data_tool_reader
GRANT SELECT ON MAP$rutgers_ready_student_goals TO db_data_tool_reader 
GRANT SELECT ON MAP$comprehensive#identifiers TO db_data_tool_reader 
GRANT SELECT ON MAP$best_baseline#static TO db_data_tool_reader
GRANT SELECT ON REPORTING$MAP_tracker#static TO db_data_tool_reader

--Gradebook
GRANT SELECT ON GRADES$DETAIL#MS TO db_data_tool_reader
GRANT SELECT ON GPA$detail#Rise TO db_data_tool_reader
GRANT SELECT ON GRADES$elements TO db_data_tool_reader

--ES Reporting
GRANT SELECT ON REPORTING$intervention_results_by_standard TO db_data_tool_reader
GRANT SELECT ON ES_DAILY$daily_tracking_long#static TO db_data_tool_reader

--Testing
GRANT SELECT ON NAVIANCE$ID_key TO db_data_tool_reader
GRANT SELECT ON NAVIANCE$act_scores TO db_data_tool_reader
GRANT SELECT ON NAVIANCE$SAT_scores TO db_data_tool_reader
GRANT SELECT ON NAVIANCE$PSAT_scores TO db_data_tool_reader
GRANT SELECT ON HSPA$scaled_scores_roster TO db_data_tool_reader
GRANT SELECT ON NAVIANCE$EXPLORE_scores TO db_data_tool_reader
GRANT SELECT ON NAVIANCE$SAT_II_scores TO db_data_tool_reader

--DB functions
GRANT EXECUTE ON fn_Global_Term_Id TO db_data_tool_reader
GRANT EXECUTE ON GROUP_CONCAT_D TO db_data_tool_reader
GRANT EXECUTE ON GROUP_CONCAT TO db_data_tool_reader