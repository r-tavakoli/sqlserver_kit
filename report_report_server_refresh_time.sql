SELECT 
	C.Name AS ReportName,
	C.Path AS ReportPath,
	TimeStart,
	TimeEnd,
	DATEDIFF(SECOND,TimeStart,TimeEnd) AS [RefreshDuration(s)],
	[Status]
FROM 
	[PBIR_DB].[dbo].[ExecutionLogStorage] AS L
INNER JOIN
	[PBIR_DB].[dbo].[Catalog] AS C
ON
	C.ItemID=L.ReportID
WHERE 
	ReportAction=19 --DataRefresh
ORDER BY
	C.Name,TimeStart DESC