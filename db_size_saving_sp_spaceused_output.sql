
--SAVING THE OUTPUT OF SP_SPACEUSED IN TEMP VARIABLE
USE test
GO

DECLARE @db_size_table TABLE (
	database_name nvarchar(100),
	database_size nvarchar(100),
	unallocated nvarchar(100),
	reserved nvarchar(100),
	data nvarchar(100),
	index_size nvarchar(100),
	unused nvarchar(100)
)

DECLARE @sql varchar(200)
SET @sql = 'EXEC sp_spaceused @oneresultset = 1'


INSERT INTO @db_size_table
EXEC(@sql)

SELECT *, GETDATE() AS CalculatedOn FROM @db_size_table