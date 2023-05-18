DECLARE @execution_id INT
SET @execution_id=(SELECT MAX(execution_id) AS D FROM [SSISDB].[catalog].[executions])


WAITFOR DELAY '00:00:10'

SELECT 
	e.execution_id
	,e.folder_name
	,e.environment_name
	,e.project_name
	,e.package_name
	,exc.executable_name
	,exs.execution_duration
	,exs.start_time
	,exs.end_time
	,CASE exs.execution_result 
		WHEN 0 THEN 'success'
		WHEN 1 THEN 'failure'
		WHEN 2 THEN 'completion'
		WHEN 3 THEN 'cancelled'
		ELSE 'unknown' 
	END AS execution_result
FROM ssisdb.internal.executions e
INNER JOIN ssisdb.internal.executable_statistics exs
	ON e.execution_id = exs.execution_id
INNER JOIN ssisdb.internal.executables exc
	ON exs.executable_id = exc.executable_id
WHERE 
	e.execution_id = @execution_id
ORDER BY 
	exs.start_time