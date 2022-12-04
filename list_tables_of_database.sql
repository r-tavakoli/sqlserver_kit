--LIST TABLES OF A DATABASE

USE test
GO

SELECT 
	schema_name(t.schema_id) as schema_name,
	t.name as table_name,
	t.create_date,
	t.modify_date
FROM
	sys.tables AS t
ORDER BY 
	schema_name,
	table_name