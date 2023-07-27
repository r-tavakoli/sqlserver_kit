
USE db_source

--CREATE DUMMY DB
--CREATE DATABASE [db_destination]
-- ON  PRIMARY 
--( NAME = N'rtn_CopyDBClvRate', FILENAME = N'F:\tavakoli\cube\rtn_CopyDBClvRate.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
-- LOG ON 
--( NAME = N'rtn_CopyDBClvRate_log', FILENAME = N'F:\tavakoli\cube\rtn_CopyDBClvRate_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )

--VARIABLES
DECLARE @insert_script NVARCHAR(MAX), @table_name NVARCHAR(100)
DECLARE @db_name NVARCHAR(100) = 'db_destination' 

--DEFINE CURSTOR TO GET SCRIPTS OF EACH TABLE
DECLARE script_cursor CURSOR  
    FOR 
		--SCRIPTS OF EACH TABLE
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


