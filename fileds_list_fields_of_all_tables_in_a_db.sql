USE test
GO

SELECT 
	--@@SERVERNAME,
	--DB_NAME(),
	T.name AS TableName,
	C.name AS FiledName,
	TY.name AS DataType,
	--I.is_primary_key AS PK,
	--I.name,
	ISNULL(I.is_primary_key, 0) AS PK,
	CASE 
		WHEN I.index_id IS NOT NULL AND I.is_primary_key=0 THEN 1 
		ELSE 0 
	END AS FK
FROM 
	sys.tables AS T --TABLE
INNER JOIN 
	sys.columns AS C --COLUMN
ON 
	T.object_id = C.object_id
INNER JOIN
	sys.types AS TY --DATATYPE
ON
	TY.system_type_id = C.system_type_id
LEFT OUTER JOIN 
	sys.index_columns AS IC --MAP TABLE
ON 
	IC.object_id = C.object_id AND IC.index_id = C.column_id
LEFT OUTER JOIN 
	sys.indexes AS I --INDEX
ON 
	IC.object_id = I.object_id AND IC.index_id = I.index_id
--WHERE
--	T.name='article'
ORDER BY
	T.name,
	C.name

