
USE db_source

--CREATE DUMMY DB
CREATE DATABASE [db_destination]


--VARIABLES
DECLARE @insert_script NVARCHAR(MAX), @table_name NVARCHAR(100)
DECLARE @db_name NVARCHAR(100) = 'db_destination' 

--DEFINE CURSTOR TO GET SCRIPTS OF EACH TABLE
DECLARE script_cursor CURSOR  
    FOR 
		--INSERT INTO COMMAND FOR EACH TABLE
		SELECT 
			NAME,
			CASE 
				WHEN name LIKE 'Dim%'
				THEN 'SELECT * INTO ' +  @db_name + '.dbo.' + QUOTENAME(name) + ' FROM dbo.' + QUOTENAME(name) + ';'
				ELSE 'SELECT TOP (100000) * INTO ' +  @db_name + '.dbo.' + QUOTENAME(name) + ' FROM dbo.' + QUOTENAME(name) + ';'
			END AS Script
		FROM sys.tables
		WHERE schema_id = 1

--OPENING CURSOR AND GETING FIRST RECORD
OPEN script_cursor  
FETCH NEXT FROM script_cursor INTO @table_name, @insert_script


--LOOP THROUGH AND EXECUTE EACH COMMAND
WHILE @@FETCH_STATUS = 0  
BEGIN
	
	PRINT @insert_script
	EXEC sp_executesql @insert_script
	FETCH NEXT FROM script_cursor INTO @table_name, @insert_script

END

CLOSE script_cursor;
DEALLOCATE script_cursor;


