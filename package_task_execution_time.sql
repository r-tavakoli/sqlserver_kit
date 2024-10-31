--https://learn.microsoft.com/en-us/sql/integration-services/system-views/catalog-operations-ssisdb-database?view=sql-server-2017
--https://learn.microsoft.com/en-us/sql/integration-services/system-views/catalog-executions-ssisdb-database?view=sql-server-2017

------------------------------------------
--package execution's stats (time and status)
------------------------------------------
--SELECT E.execution_id,
--       E.folder_name,
--       E.project_name,
--       E.package_name,
--       E.environment_folder_name, 
--       E.environment_name, 
--       CASE O.[status]
--           WHEN 1 THEN 'Created'
--           WHEN 2 THEN 'Running'
--           WHEN 3 THEN 'Canceled'
--           WHEN 4 THEN 'Failed'
--           WHEN 5 THEN 'Pending'
--           WHEN 6 THEN 'Ended Unexpectly'
--           WHEN 7 THEN 'Succeeded'
--           WHEN 8 THEN 'Stopping'
--           WHEN 9 THEN 'Completed'
--       END AS [Status],
--       O.start_time, 
--       O.end_time
--FROM 
--    SSISDB.internal.executions AS E
--INNER JOIN 
--    SSISDB.internal.operations AS O 
--ON 
--    E.execution_id = O.operation_id
--WHERE
--	project_name='SN_ETL'
--	AND package_name='Sales_Incremental_Main_OrderCarts.dtsx'

GO
------------------------------------------
--package execution's stats (time and status)
------------------------------------------

DECLARE @project_name NVARCHAR(MAX) = 'SN_ETL'
DECLARE @package_name NVARCHAR(MAX) = 'Sales_Incremental_Main' --Sales_Incremental_Main_OrderCarts, Sales_Incremental_Main
--DECLARE @task_name NVARCHAR(MAX) = 'Cart Shippment  In memory' --Cart Shippment  In memory, Cart Incremental In memory
--DECLARE @task_name NVARCHAR(MAX) = 'Cart Incremental In memory' --Cart Shippment  In memory, Cart Incremental In memory
DECLARE @task_name NVARCHAR(MAX) = 'Sales_sp_FillFactCustomers'
--DECLARE @task_name NVARCHAR(MAX) = NULL
DECLARE @top_n_executions INT = 20

--get ids based on inputs to filter in next level
DROP TABLE IF EXISTS #execution_ids
SELECT execution_id, ROW_NUMBER() OVER(ORDER BY execution_id DESC) AS rn
INTO #execution_ids
FROM [SSISDB].[catalog].[executions] 
WHERE project_name = @project_name AND package_name = @package_name + '.dtsx'

--main data
DROP TABLE IF EXISTS #execution_time_cte
SELECT
	e.execution_id,
	es.executable_id,
	e.project_name,
	e.package_name,
	CASE O.[status]
		WHEN 1 THEN 'Created'
		WHEN 2 THEN 'Running'
		WHEN 3 THEN 'Canceled'
		WHEN 4 THEN 'Failed'
		WHEN 5 THEN 'Pending'
		WHEN 6 THEN 'Ended Unexpectly' 
		WHEN 7 THEN 'Succeeded'
		WHEN 8 THEN 'Stopping'
		WHEN 9 THEN 'Completed'
	END AS [Status],
	es.execution_path,
	REPLACE(REVERSE(LEFT(REVERSE(es.execution_path), CHARINDEX('\', REVERSE(es.execution_path)))), '\', '') AS task_name,
	REVERSE(LEFT(REVERSE(es.execution_path), CHARINDEX('\', REVERSE(es.execution_path), CHARINDEX('\', REVERSE(es.execution_path)) + 1)))  AS task_name_run_by_another_package,
	CASE
		WHEN REVERSE(LEFT(REVERSE(es.execution_path), CHARINDEX('\', REVERSE(es.execution_path), CHARINDEX('\', REVERSE(es.execution_path)) + 1))) LIKE '%package%'
		THEN 1
	ELSE 0
	END AS is_run_by_another_package,	
	es.start_time,
	es.end_time,
	CAST(es.execution_duration / 60000 AS VARCHAR) + ':' + CAST(CAST(((es.execution_duration / 60000.0) % 1) * 60 AS INT) AS VARCHAR) AS execution_duration_minute_second,
	CAST(es.execution_duration / 3600000 AS VARCHAR) AS execution_duration_hour
INTO #execution_time_cte
FROM 
	[SSISDB].[catalog].[executions] AS e
INNER JOIN
	[SSISDB].[catalog].[executable_statistics] AS es
ON 
	e.execution_id=es.execution_id
INNER JOIN 
    [SSISDB].[internal].[operations] AS o
ON 
    e.execution_id = o.operation_id
INNER JOIN
	(SELECT * FROM #execution_ids WHERE rn<=@top_n_executions) AS eid --first 20 latest executions
ON
	e.execution_id=eid.execution_id

--result
SELECT *
FROM #execution_time_cte
WHERE 
	task_name LIKE (CASE WHEN @task_name IS NOT NULL THEN '%' + @task_name + '%' ELSE '%' END)
ORDER BY start_time desc
