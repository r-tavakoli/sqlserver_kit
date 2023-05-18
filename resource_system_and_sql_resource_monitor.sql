
USE test
GO


--SQL MEMORY
SELECT
	physical_memory_in_use_kb/1024 AS Phy_Memory_usedby_Sqlserver_MB,
	locked_page_allocations_kb/1024 AS Locked_pages_used_Sqlserver_MB,
	virtual_address_space_committed_kb/1024 AS Total_Memory_UsedBySQLServer_MB,
	process_physical_memory_low,
	process_virtual_memory_low
FROM 
	sys. dm_os_process_memory WITH (NOLOCK)

--MEMORY
SELECT 
	total_physical_memory_kb/1024 AS [Physical Memory (MB)], 
	available_physical_memory_kb/1024 AS [Available Memory (MB)], 
	total_page_file_kb/1024 AS [Total Page File (MB)], 
	available_page_file_kb/1024 AS [Available Page File (MB)], 
	system_cache_kb/1024 AS [System Cache (MB)],
	system_memory_state_desc AS [System Memory State]
FROM 
	sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);

--CPU
SELECT TOP 50
    [Avg. MultiCore/CPU time(sec)] = qs.total_worker_time / 1000000 / qs.execution_count,
    [Total MultiCore/CPU time(sec)] = qs.total_worker_time / 1000000,
    [Avg. Elapsed Time(sec)] = qs.total_elapsed_time / 1000000 / qs.execution_count,
    [Total Elapsed Time(sec)] = qs.total_elapsed_time / 1000000,
    qs.execution_count,
    [Avg. I/O] = (total_logical_reads + total_logical_writes) / qs.execution_count,
    [Total I/O] = total_logical_reads + total_logical_writes,
    Query = SUBSTRING(qt.[text], (qs.statement_start_offset / 2) + 1,
        (
            (
                CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(qt.[text])
                    ELSE qs.statement_end_offset
                END - qs.statement_start_offset
            ) / 2
        ) + 1
    ),
    Batch = qt.[text],
    [DB] = DB_NAME(qt.[dbid]),
    qs.last_execution_time,
    qp.query_plan
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
where qs.execution_count > 5    --more than 5 occurences
ORDER BY [Total MultiCore/CPU time(sec)] DESC


--PLE
-- Page Life Expectancy (PLE) value for each NUMA node in current instance
-- PLE is a good measurement of internal memory pressure
-- Higher PLE is better. Watch the trend over time, not the absolute value
SELECT 
	@@SERVERNAME AS [Server Name], 
	RTRIM([object_name]) AS [Object Name], 
	instance_name, 
	cntr_value AS [Page Life Expectancy]
FROM 
	sys.dm_os_performance_counters
WHERE 
		[object_name] LIKE N'%Buffer Node%' -- Handles named instances
	AND counter_name = N'Page life expectancy'


--QUERY STATS
SELECT DatabaseID, isnull(DB_Name(DatabaseID),case DatabaseID when 32767 then 'Internal ResourceDB' else CONVERT(varchar(255),DatabaseID)end) AS [DatabaseName], 
    SUM(total_worker_time) AS [CPU Time Ms],
    SUM(total_logical_reads)  AS [Logical Reads],
    SUM(total_logical_writes)  AS [Logical Writes],
    SUM(total_logical_reads+total_logical_writes)  AS [Logical IO],
    SUM(total_physical_reads)  AS [Physical Reads],
    SUM(total_elapsed_time)  AS [Duration MicroSec],
    SUM(total_clr_time)  AS [CLR Time MicroSec],
    SUM(total_rows)  AS [Rows Returned],
    SUM(execution_count)  AS [Execution Count],
    count(*) 'Plan Count'

FROM sys.dm_exec_query_stats AS qs
CROSS APPLY (
                SELECT CONVERT(int, value) AS [DatabaseID] 
                FROM sys.dm_exec_plan_attributes(qs.plan_handle)
                WHERE attribute = N'dbid') AS F_DB
GROUP BY DatabaseID
