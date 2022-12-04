----------------------------------------------------
--STEP 1: DOWNLOAD SCRIPTS
----------------------------------------------------
--https://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html


----------------------------------------------------
--STEP 2: JOB AND RUN SP (IndexOptimize)
----------------------------------------------------
USE master
GO

EXECUTE dbo.IndexOptimize 
@Databases = 'test',
--@indexes = 'test.dbo.table_name', --ALL_INDEXES --test.dbo.table_name.index_id
--@MinNumberOfPages=2000,
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@SortInTempdb = 'Y',
@MaxDOP = 0,
@LogToTable = 'Y'

----------------------------------------------------
--STEP 3-a: REPORT COMMAND LOG
----------------------------------------------------
SELECT 
	CL.ID,
	CL.ObjectName,
	CL.IndexName,
CASE 
	WHEN IndexType = 1 THEN 'CLUSTERED' 
	WHEN IndexType = 2 THEN 'NONCLUSTERED' 
	WHEN IndexType = 3 THEN 'XML' 
	WHEN IndexType = 4 THEN 'SPATIAL' 
END AS IndexType,
	CONVERT(DATE,CL.StartTime,111) AS StartTime,
	DATEDIFF(S,CL.StartTime,CL.EndTime) AS DurationSecond,
	CL.ExtendedInfo.value('(ExtendedInfo/Fragmentation)[1]', 'varchar(100)') AS FragmentatioPercentage,
	CL.ExtendedInfo.value('(ExtendedInfo/PageCount)[1]', 'varchar(100)') AS PageCount,
	CASE 
		WHEN CL.COMMAND LIKE '%REORGANIZE%' THEN 'REORGANIZE' 
		WHEN CL.COMMAND LIKE '%REBUILD%' THEN 'REBUILD' 
	END AS CommandType
FROM 
	[master].[dbo].[CommandLog] AS CL


----------------------------------------------------
--STEP 3-b: SAVE RESULT BEFORE AND AFTER REBUILD
----------------------------------------------------


--CREATE TABLE TO SAVE OUTPUT
USE test
GO

CREATE TABLE RebuildLog (
    [OBJECT_ID] int,
    [index_id] int,
    [ObjectName] nvarchar(128),
    [IndexName] nvarchar(128),
    [partition_number] int,
    [alloc_unit_type_desc] nvarchar(60),
    [page_count_before] bigint,
    [avg_fragmentation_in_percent_before] numeric(6,4),
    [page_count_after] bigint,
    [avg_fragmentation_in_percent_after] numeric(6,4),
    [CreatedOn] datetime
)

--INSERT BELOW OUTPUT TO THE "RebuildLog" TABLE
USE test
GO

SELECT 
	ips.OBJECT_ID,
	OBJECT_NAME(ips.OBJECT_ID) AS ObjectName,
	i.index_id,
	ips.partition_number,
	ips.alloc_unit_type_desc,
	ips.page_count AS page_count_before,
	CONVERT(decimal(6,4),ips.avg_fragmentation_in_percent) AS avg_fragmentation_in_percent_before,
	GETDATE() AS CreatedOn
FROM 
	sys.dm_db_index_physical_stats(DB_ID(N'test'), NULL, NULL, NULL, 'SAMPLED') ips --DETAILED / SAMPLED
INNER JOIN sys.indexes i 
ON 
		ips.object_id = i.object_id
	AND ips.index_id = i.index_id

--UPDATE TABLE AFTER REBUILD
USE test
GO

UPDATE RebuildLog
SET 
	page_count_after = ips.page_count,
	avg_fragmentation_in_percent_after = CONVERT(decimal(6,4),ips.avg_fragmentation_in_percent)
FROM 
	sys.dm_db_index_physical_stats(DB_ID(N'test'), NULL, NULL, NULL, 'SAMPLED') ips --DETAILED / SAMPLED
INNER JOIN sys.indexes i 
ON 
		ips.object_id = i.object_id
	AND ips.index_id = i.index_id
INNER JOIN
	RebuildLog
ON
		RebuildLog.OBJECT_ID=ips.OBJECT_ID
	AND RebuildLog.index_id=i.index_id
	AND RebuildLog.partition_number=ips.partition_number
	AND CONVERT(DATE,RebuildLog.CreatedOn,111)=CONVERT(DATE,GETDATE(),111)