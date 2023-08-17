

--https://learn.microsoft.com/en-us/sql/integration-services/system-views/catalog-operations-ssisdb-database?view=sql-server-2017
--https://learn.microsoft.com/en-us/sql/integration-services/system-views/catalog-executions-ssisdb-database?view=sql-server-2017

------------------------------------------
--package execution stats (time and status)
------------------------------------------
SELECT E.execution_id,
       E.folder_name,
       E.project_name,
       E.package_name,
       E.environment_folder_name, 
       E.environment_name, 
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
       O.start_time, 
       O.end_time
FROM 
    internal.executions AS E
INNER JOIN 
    internal.operations AS O 
ON 
    E.execution_id = O.operation_id;