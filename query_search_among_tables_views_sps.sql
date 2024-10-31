
-----------------------
--INPUT PARAMETER
-----------------------

DECLARE @_schema_name VARCHAR(200) = 'DIGIPAY'
DECLARE @obj_name VARCHAR(200) = ''


-----------------------
--TABLES
-----------------------
DROP TABLE IF EXISTS #rtn_t
CREATE TABLE #rtn_t(_db_name SYSNAME, _schema_name NVARCHAR(512), _table_name NVARCHAR(512))

DECLARE @sql_table NVARCHAR(MAX);
SET @sql_table = N''

SELECT @sql_table = @sql_table + 
	N'INSERT #rtn_t(_db_name, _schema_name, _table_name) 
	SELECT 
		''' + REPLACE(name, '''','''''') + ''',
		QUOTENAME(s.name),
		QUOTENAME(t.name)
	FROM 
		' + QUOTENAME(name) + '.sys.tables AS t
	INNER JOIN 
		' + QUOTENAME(name) + '.sys.schemas AS s
	ON 
		t.[schema_id] = s.[schema_id]
	WHERE 
		t.is_ms_shipped = 0;
'
FROM sys.databases
WHERE [state] = 0 and name in ('DWDigikala', 'DWSNDigiKala', 'Staging', 'StagingDigikala', 'ODSDigikala');

EXEC sp_executesql @sql_table;

SELECT 
	_db_name, 
	_schema_name, 
	_table_name,
	'[' + _db_name + '].' + _schema_name + '.' + _table_name AS full_obj_name  
FROM #rtn_t 
WHERE _table_name LIKE '%' + @obj_name + '%' AND _schema_name LIKE '%' + @_schema_name + '%'
ORDER BY _db_name, _schema_name, _table_name;

-----------------------
--VIEWS
-----------------------
DROP TABLE IF EXISTS #rtn_v
CREATE TABLE #rtn_v(_db_name SYSNAME, _schema_name NVARCHAR(512), _view_name NVARCHAR(512))

DECLARE @sql_view NVARCHAR(MAX);
SET @sql_view = N''

SELECT @sql_view = @sql_view + 
	N'INSERT #rtn_v(_db_name, _schema_name, _view_name) 
	SELECT 
		''' + REPLACE(name, '''','''''') + ''',
		QUOTENAME(s.name),
		QUOTENAME(v.name)
	FROM 
		' + QUOTENAME(name) + '.sys.views AS v
	INNER JOIN 
		' + QUOTENAME(name) + '.sys.schemas AS s
	ON 
		v.[schema_id] = s.[schema_id]
	WHERE 
		v.is_ms_shipped = 0;
'
FROM sys.databases
WHERE [state] = 0 and name in ('DWDigikala', 'DWSNDigiKala', 'Staging', 'StagingDigikala', 'ODSDigikala');

EXEC sp_executesql @sql_view;

SELECT 
	_db_name, 
	_schema_name, 
	_view_name,
	'[' + _db_name + '].' + _schema_name + '.' + _view_name AS full_obj_name  
FROM #rtn_v
WHERE _view_name LIKE '%' + @obj_name + '%' AND _schema_name LIKE '%' + @_schema_name + '%' 
ORDER BY _db_name, _schema_name, _view_name ;

-----------------------
--SPs
-----------------------
DROP TABLE IF EXISTS #rtn_sp
CREATE TABLE #rtn_sp(_db_name SYSNAME, _schema_name NVARCHAR(512), _sp_name NVARCHAR(512))

DECLARE @sql_sp NVARCHAR(MAX)
SET @sql_sp = N''

SELECT @sql_sp = @sql_sp + 
	N'INSERT #rtn_sp(_db_name, _schema_name, _sp_name) 
	SELECT 
		''' + REPLACE(name, '''','''''') + ''',
		QUOTENAME(s.name),
		QUOTENAME(sp.name)
	FROM 
		' + QUOTENAME(name) + '.sys.procedures AS sp
	INNER JOIN 
		' + QUOTENAME(name) + '.sys.schemas AS s
	ON 
		sp.[schema_id] = s.[schema_id]
	WHERE 
		sp.is_ms_shipped = 0;
'
FROM sys.databases
WHERE [state] = 0 and name in ('DWDigikala', 'DWSNDigiKala', 'Staging', 'StagingDigikala', 'ODSDigikala');

EXEC sp_executesql @sql_sp;

SELECT 
	_db_name, 
	_schema_name, 
	_sp_name,
	'[' + _db_name + '].' + _schema_name + '.' + _sp_name AS full_obj_name  
FROM #rtn_sp
WHERE _sp_name LIKE '%' + @obj_name + '%'  AND _schema_name LIKE '%' + @_schema_name + '%'
ORDER BY _db_name, _schema_name, _sp_name ;

-----------------------
--DROP TEMP TABLES
-----------------------
DROP TABLE IF EXISTS #rtn_t
DROP TABLE IF EXISTS #rtn_v
DROP TABLE IF EXISTS #rtn_sp
