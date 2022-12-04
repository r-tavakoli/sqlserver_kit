
--LIST ALL TABLES WITH SIZE AND ROW COUNT
USE test
GO

SELECT
    s.Name AS SchemaName,
    t.NAME AS TableName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB,
    ( SUM(a.total_pages) * 8 ) / 1024.0 AS TotalSpaceMB,
    (( SUM(a.total_pages) * 8 ) / 1024.0)/1024.0 AS TotalSpaceGB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB,
    ( SUM(a.used_pages) * 8 ) / 1024.0 AS UsedSpaceMB,
    (( SUM(a.used_pages) * 8 ) / 1024.0) /1024.0 AS UsedSpaceGB,
    ( SUM(a.total_pages) - SUM(a.used_pages) ) * 8 AS UnusedSpaceKB,
    ( ( SUM(a.total_pages) - SUM(a.used_pages) ) * 8 ) / 1024.0 AS UnusedSpaceMB,
    (( ( SUM(a.total_pages) - SUM(a.used_pages) ) * 8 ) / 1024.0)/1024.0 AS UnusedSpaceGB
--,GROUPING(t.Name)
FROM sys.tables t
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
    INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID
        AND i.index_id = p.index_id
    INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE   t.NAME NOT LIKE 'dt%'
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255
GROUP BY 
	s.Name,
    t.Name,
    p.Rows
--WITH ROLLUP
ORDER BY 
	s.Name,
    t.Name


--GET SIZE OF A TABLE WITH SP_SPACEDUSED
USE test;
EXEC sp_spaceused N'dbo.task';   