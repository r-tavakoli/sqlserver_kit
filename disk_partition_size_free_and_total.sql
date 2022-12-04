
--SIZE OF FREE AND TOTAL SPACE SIZE OF EACH VOLUME IN (MB, GB)
SELECT 
	volume_mount_point, 
	total_bytes/1048576 AS Size_in_MB, 
	available_bytes/1048576 AS Free_in_MB,
	total_bytes/1048576/1024 AS Size_in_GB, 
	available_bytes/1048576/1024 AS Free_in_GB,
	(available_bytes/1048576*1.0)/(total_bytes/1048576*1.0) * 100 AS FreePercentage
FROM 
	sys.master_files AS f 
CROSS APPLY 
  sys.dm_os_volume_stats(f.database_id, f.file_id)
GROUP BY 
	volume_mount_point, total_bytes/1048576, 
	available_bytes/1048576 
ORDER BY 
	volume_mount_point

