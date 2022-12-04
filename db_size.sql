
--SIZE OF ALL DATABASES (DATA FILES AND LOG FILES) IN PIVOT FORMAT
SELECT
    DB_NAME(db.database_id) AS DatabaseName,
    (CAST(mfrows.RowSize AS FLOAT)*8)/1024 AS RowSizeMB,
    (CAST(mflog.LogSize AS FLOAT)*8)/1024 AS LogSizeMB,
    (CAST(mfrows.RowSize + mflog.LogSize AS FLOAT)*8)/1024 AS TotalSizeMB
FROM sys.databases AS db
    LEFT JOIN (
        SELECT database_id, SUM(size) RowSize
    FROM sys.master_files
    WHERE type = 0
    GROUP BY database_id, type) AS mfrows
    ON 
        mfrows.database_id = db.database_id
    LEFT JOIN (
        SELECT database_id, SUM(size) LogSize
    FROM sys.master_files
    WHERE type = 1
    GROUP BY database_id, type) AS mflog
    ON 
        mflog.database_id = db.database_id
ORDER BY
    DB_NAME(db.database_id)


GO

--SIZE OF ALL DATABASES (DATA FILES AND LOG FILES) IN TABLE FORMAT
SELECT
    D.name,
    F.Type_Desc AS FileType,
    F.physical_name AS PhysicalFile,
    F.state_desc AS OnlineStatus,
    CAST(F.size AS bigint) * 8*1024 AS SizeInBytes,
    CAST((F.size*8.0)/1024 AS decimal(18,3)) AS SizeInMB,
    CAST((F.size*8.0)/1024/1024 AS decimal(18,3)) AS SizeInGB
FROM
    sys.master_files AS F
    INNER JOIN
    sys.databases AS D
    ON 
    D.database_id = F.database_id
ORDER BY 
    D.name


--GET SIZE OF ALL DATABASES (SIZE IN KILOBYTES)
EXEC sp_databases;


--GET SIZE OF A SPECIFIC DATABASE WITH SP_HELPDB
EXEC sp_helpdb N'test';

--GET SIZE OF A SPECIFIC DATABASE WITH SP_SPACEDUSED
USE test;
EXEC sp_spaceused;

--GET SIZE OF A SPECIFIC DATABASE WITH DMV
USE test;
SELECT
    name,
    size * 8/1024 'Size (MB)',
    max_size
FROM sys.database_files;

