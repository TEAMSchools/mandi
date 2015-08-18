USE [NWEA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
SELECT source.*
INTO map$cdf
FROM #cdf source
WHERE 1=2
*/

ALTER PROCEDURE [dbo].[sp_LoadCDF] AS 

BEGIN

		--0. ensure temp table doesn't exist in use
		IF OBJECT_ID(N'tempdb..#cdf') IS NOT NULL
		BEGIN
			DROP TABLE #cdf
		END
	
	--1. bulk load csv and SELECT INTO temp table
		SELECT sub.*
		INTO #cdf
		FROM
					 (
       SELECT * 
					  FROM OPENROWSET(
							  'MSDASQL'
						  ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
						  ,'select * from c:\data_robot\nwea\AssessmentResults.csv'
       )
					 ) sub;

		--2. upsert on WINSQL01
		WITH new_file AS (
				SELECT *
				FROM #cdf
   )

		MERGE map$cdf target
		USING new_file staging
					ON target.testid = staging.testid
		WHEN MATCHED THEN UPDATE 
   SET  
						target.termname = staging.termname
					,target.studentid = staging.studentid
					,target.schoolname = staging.schoolname
					,target.measurementscale = staging.measurementscale
					,target.discipline = staging.discipline
					,target.growthmeasureyn = staging.growthmeasureyn
					,target.testtype = staging.testtype
					,target.testname = staging.testname
					,target.testid = staging.testid
					,target.teststartdate = staging.teststartdate
					,target.testdurationminutes = staging.testdurationminutes
					,target.testritscore = staging.testritscore
					,target.teststandarderror = staging.teststandarderror
					,target.testpercentile = staging.testpercentile
					,target.typicalfalltofallgrowth = staging.typicalfalltofallgrowth
					,target.typicalspringtospringgrowth = staging.typicalspringtospringgrowth
					,target.typicalfalltospringgrowth = staging.typicalfalltospringgrowth
					,target.typicalfalltowintergrowth = staging.typicalfalltowintergrowth
					,target.rittoreadingscore = staging.rittoreadingscore
					,target.rittoreadingmin = staging.rittoreadingmin
					,target.rittoreadingmax = staging.rittoreadingmax
					,target.goal1name = staging.goal1name
					,target.goal1ritscore = staging.goal1ritscore
					,target.goal1stderr = staging.goal1stderr
					,target.goal1range = staging.goal1range
					,target.goal1adjective = staging.goal1adjective
					,target.goal2name = staging.goal2name
					,target.goal2ritscore = staging.goal2ritscore
					,target.goal2stderr = staging.goal2stderr
					,target.goal2range = staging.goal2range
					,target.goal2adjective = staging.goal2adjective
					,target.goal3name = staging.goal3name
					,target.goal3ritscore = staging.goal3ritscore
					,target.goal3stderr = staging.goal3stderr
					,target.goal3range = staging.goal3range
					,target.goal3adjective = staging.goal3adjective
					,target.goal4name = staging.goal4name
					,target.goal4ritscore = staging.goal4ritscore
					,target.goal4stderr = staging.goal4stderr
					,target.goal4range = staging.goal4range
					,target.goal4adjective = staging.goal4adjective
					,target.goal5name = staging.goal5name
					,target.goal5ritscore = staging.goal5ritscore
					,target.goal5stderr = staging.goal5stderr
					,target.goal5range = staging.goal5range
					,target.goal5adjective = staging.goal5adjective
					,target.goal6name = staging.goal6name
					,target.goal6ritscore = staging.goal6ritscore
					,target.goal6stderr = staging.goal6stderr
					,target.goal6range = staging.goal6range
					,target.goal6adjective = staging.goal6adjective
					,target.goal7name = staging.goal7name
					,target.goal7ritscore = staging.goal7ritscore
					,target.goal7stderr = staging.goal7stderr
					,target.goal7range = staging.goal7range
					,target.goal7adjective = staging.goal7adjective
					,target.goal8name = staging.goal8name
					,target.goal8ritscore = staging.goal8ritscore
					,target.goal8stderr = staging.goal8stderr
					,target.goal8range = staging.goal8range
					,target.goal8adjective = staging.goal8adjective
					,target.teststarttime = staging.teststarttime
					,target.percentcorrect = staging.percentcorrect
					,target.projectedproficiency = staging.projectedproficiency
		WHEN NOT MATCHED BY target THEN INSERT 
         (termname
									,studentid
									,schoolname
									,measurementscale
									,discipline
									,growthmeasureyn
									,testtype
									,testname
									,testid
									,teststartdate
									,testdurationminutes
									,testritscore
									,teststandarderror
									,testpercentile
									,typicalfalltofallgrowth
									,typicalspringtospringgrowth
									,typicalfalltospringgrowth
									,typicalfalltowintergrowth
									,rittoreadingscore
									,rittoreadingmin
									,rittoreadingmax
									,goal1name
									,goal1ritscore
									,goal1stderr
									,goal1range
									,goal1adjective
									,goal2name
									,goal2ritscore
									,goal2stderr
									,goal2range
									,goal2adjective
									,goal3name
									,goal3ritscore
									,goal3stderr
									,goal3range
									,goal3adjective
									,goal4name
									,goal4ritscore
									,goal4stderr
									,goal4range
									,goal4adjective
									,goal5name
									,goal5ritscore
									,goal5stderr
									,goal5range
									,goal5adjective
									,goal6name
									,goal6ritscore
									,goal6stderr
									,goal6range
									,goal6adjective
									,goal7name
									,goal7ritscore
									,goal7stderr
									,goal7range
									,goal7adjective
									,goal8name
									,goal8ritscore
									,goal8stderr
									,goal8range
									,goal8adjective
									,teststarttime
									,percentcorrect
									,projectedproficiency) 
		VALUES (staging.termname
									,staging.studentid
									,staging.schoolname
									,staging.measurementscale
									,staging.discipline
									,staging.growthmeasureyn
									,staging.testtype
									,staging.testname
									,staging.testid
									,staging.teststartdate
									,staging.testdurationminutes
									,staging.testritscore
									,staging.teststandarderror
									,staging.testpercentile
									,staging.typicalfalltofallgrowth
									,staging.typicalspringtospringgrowth
									,staging.typicalfalltospringgrowth
									,staging.typicalfalltowintergrowth
									,staging.rittoreadingscore
									,staging.rittoreadingmin
									,staging.rittoreadingmax
									,staging.goal1name
									,staging.goal1ritscore
									,staging.goal1stderr
									,staging.goal1range
									,staging.goal1adjective
									,staging.goal2name
									,staging.goal2ritscore
									,staging.goal2stderr
									,staging.goal2range
									,staging.goal2adjective
									,staging.goal3name
									,staging.goal3ritscore
									,staging.goal3stderr
									,staging.goal3range
									,staging.goal3adjective
									,staging.goal4name
									,staging.goal4ritscore
									,staging.goal4stderr
									,staging.goal4range
									,staging.goal4adjective
									,staging.goal5name
									,staging.goal5ritscore
									,staging.goal5stderr
									,staging.goal5range
									,staging.goal5adjective
									,staging.goal6name
									,staging.goal6ritscore
									,staging.goal6stderr
									,staging.goal6range
									,staging.goal6adjective
									,staging.goal7name
									,staging.goal7ritscore
									,staging.goal7stderr
									,staging.goal7range
									,staging.goal7adjective
									,staging.goal8name
									,staging.goal8ritscore
									,staging.goal8stderr
									,staging.goal8range
									,staging.goal8adjective
									,staging.teststarttime
									,staging.percentcorrect
									,staging.projectedproficiency);
END
				

GO


