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
--STEP 3: REPORT
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