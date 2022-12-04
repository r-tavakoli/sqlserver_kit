
--LIST TABLES WHICH ARE FRAGMENTED
--BASED ON MICROSOFT'S RECOMMENDATION FOR REBUILDING
    --->  avg_fragmentation_in_percent > 30 %
    --->  page_count > 1000

USE test
GO

SELECT
	OBJECT_NAME(ips.OBJECT_ID) AS TableName,
	i.NAME AS IndexName,
	CONVERT(decimal(4,2),avg_fragmentation_in_percent) AS avg_fragmentation_in_percent,
	page_count,
	index_type_desc,
	CASE
		WHEN TYPE=0 THEN 'Heap'
		WHEN TYPE=1 THEN 'Clustered'
		WHEN TYPE=2 THEN 'Nonclustered'
		WHEN TYPE=3 THEN 'XML'
		WHEN TYPE=4 THEN 'Spatial'
		WHEN TYPE=5 THEN 'Clustered columnstore index'
		WHEN TYPE=6 THEN 'Nonclustered columnstore index' 
		WHEN TYPE=7 THEN 'Nonclustered hash index'
		ELSE 'Unknown'
	END AS IndexType
FROM 
sys.dm_db_index_physical_stats(DB_ID(N'test'), NULL, NULL, NULL, 'SAMPLED') AS ips
INNER JOIN sys.indexes AS i 
ON 
	 (ips.object_id = i.object_id)
 AND (ips.index_id = i.index_id)
WHERE
	avg_fragmentation_in_percent>30.0
	AND
	page_count>1000
ORDER BY
	avg_fragmentation_in_percent DESC,
	page_count DESC