USE StagingTEST
GO

CREATE PROCEDURE sales.sp_participation_process_tabular
AS

DECLARE @tabular_server_name NVARCHAR(MAX) = 'BITABULAR.test.com'
DECLARE @tabular_server_port_number NVARCHAR(MAX) = '2384'
DECLARE @tabular_model_name NVARCHAR(MAX) = 'campaign_participation_Test'
DECLARE @connection NVARCHAR(MAX) = (SELECT configurationsetting FROM [StagingTEST].[etl].[ETLConfiguration] WHERE [configurationname] = 'TabularConnectionString')
DECLARE @tabular_table_name NVARCHAR(MAX) = 'fact_participation_promotion_supply_category_history'
DECLARE @source_server_name NVARCHAR(MAX) = 'biwarehousing'
DECLARE @source_database_name NVARCHAR(MAX) = 'dwTEST'
DECLARE @source_schema_name NVARCHAR(MAX) = 'sales'
DECLARE @source_table_name NVARCHAR(MAX) = 'vw_fact_participation_promotion_supply_category_history' --table or view
DECLARE @partitoin_column_name NVARCHAR(MAX) = 'campaign_id'
DECLARE @dmv_script NVARCHAR(MAX)
DECLARE @partition_name NVARCHAR(MAX)
DECLARE @from_value NVARCHAR(MAX)
DECLARE @to_value NVARCHAR(MAX)
DECLARE @xmla NVARCHAR(MAX)
DECLARE @cmd NVARCHAR(MAX)

--campaigns which have no partition
DROP TABLE IF EXISTS #partitions_to_create
SELECT DISTINCT campaign_id
INTO #partitions_to_create
FROM [DWTEST].[sales].[dim_participation_promotion]
WHERE last_process_date_time IS NULL

-----------------------------------------
--command to create partition
-----------------------------------------
IF EXISTS(SELECT * FROM #partitions_to_create)
BEGIN --begin if
	DECLARE cursor_xmla_script CURSOR LOCAL READ_ONLY FORWARD_ONLY FOR 
	SELECT 		
		'cmp_' + CAST(campaign_id AS NVARCHAR(MAX)) AS partition_name,
		campaign_id AS from_value,
		(campaign_id + 1) AS to_value
	FROM #partitions_to_create 
	ORDER BY campaign_id

	OPEN cursor_xmla_script FETCH NEXT FROM cursor_xmla_script 
	INTO @partition_name, @from_value, @to_value

	WHILE @@FETCH_STATUS = 0  
	BEGIN  --start loop of cursor
		SET @xmla = '{
				"createOrReplace": {
				"object": {
					"database": "' + @tabular_model_name + '",
					"table": "' + @tabular_table_name + '",
					"partition": "' + @partition_name + '"
				},
				"partition": {
					"name": "' + @partition_name + '",
					"source": {
					"type": "m",
					"expression": [
						"let\r",
						"    Source = #\"SQL/' + @source_server_name + ';' + @source_database_name + '\",\r",
						"    source_step = Source{[Schema=\"' + @source_schema_name + '\",Item=\"' + @source_table_name + '\"]}[Data],\r",
						"    #\"Filtered Rows\" = Table.SelectRows(source_step, each [' + @partitoin_column_name + '] >= ' + @from_value + ' and [' + @partitoin_column_name + '] < ' + @to_value + '  )\r",
						"in\r",
						"    #\"Filtered Rows\""
					]
					}
				}
				}
			}'

		--check if partition's name already exists or not
		--sample: SELECT a.* FROM OpenRowset('MSOLAP',';Data Source=BITABULAR.TEST.COM:2384;Initial Catalog=campaign_participation_Test;User Id=test\biservice;Password=123;','SELECT [Name] FROM $System.TMSCHEMA_PARTITIONS WHERE [Name]=''Partition'' ') as a
		SET @dmv_script = N'SELECT d.* FROM OpenRowset(''MSOLAP'','';Data Source=' + @tabular_server_name + ':' + @tabular_server_port_number + ';Initial Catalog=' + @tabular_model_name + N';' + @connection + N''',''SELECT [Name] FROM $System.TMSCHEMA_PARTITIONS where [Name] =''''' + @partition_name + ''''' '') as d'
		DECLARE @partitions TABLE ([partition_name] NVARCHAR(MAX))
		INSERT INTO @partitions ([partition_name])
		EXEC [sys].[sp_executesql] @dmv_script

		IF NOT EXISTS(SELECT * FROM @partitions WHERE [partition_name]=@partition_name) --if already exists, don't execute
		BEGIN --begin if of partition_name
			SET @cmd = 'EXEC (''' + @xmla + ''') AT ' +  QUOTENAME(@tabular_server_name) 
			EXEC sp_executesql @cmd 
			PRINT 'partition: ' + QUOTENAME(@partition_name) + ', database: ' + QUOTENAME(@tabular_model_name) + ', table: ' + QUOTENAME(@tabular_table_name) + ' created'
			--PRINT @cmd
		END --end if of partition_name

		--next row
		FETCH NEXT FROM cursor_xmla_script 
		INTO @partition_name, @from_value, @to_value
	END  --end loop of cursor

	CLOSE cursor_xmla_script  
	DEALLOCATE cursor_xmla_script

END --end if

-----------------------------------------
--processing the partitions
-----------------------------------------
DROP TABLE IF EXISTS #partitions_to_process
SELECT DISTINCT campaign_id
INTO #partitions_to_process
FROM [DWTEST].[sales].[dim_participation_promotion]
WHERE last_process_date_time IS NULL OR (DATEDIFF(DAY, DATEADD(DAY, 1, end_date), CAST(GETDATE() AS DATE)) <= 0)


IF EXISTS(SELECT * FROM #partitions_to_process)
BEGIN --begin if
	DECLARE cursor_xmla_process_script CURSOR LOCAL READ_ONLY FORWARD_ONLY FOR 
	SELECT 'cmp_' + CAST(campaign_id AS NVARCHAR(MAX)) AS partition_name
	FROM #partitions_to_process 
	ORDER BY campaign_id

	OPEN cursor_xmla_process_script FETCH NEXT FROM cursor_xmla_process_script 
	INTO @partition_name

	WHILE @@FETCH_STATUS = 0  
	BEGIN  --start loop of cursor

		SET @xmla = '
		{
		  "refresh": {
			"type": "full",
			"objects": [
			  {
				"database": "' + @tabular_model_name + '",
				"table": "' + @tabular_table_name + '",
				"partition": "' + @partition_name + '"
			  }
			]
		  }
		}'
		SET @cmd = 'EXEC (''' + @xmla + ''') AT ' +  QUOTENAME(@tabular_server_name) 
		EXEC sp_executesql @cmd 
		PRINT 'partition: ' + QUOTENAME(@partition_name) + ', database: ' + QUOTENAME(@tabular_model_name) + ', table: ' + QUOTENAME(@tabular_table_name) + ' processed'
		--PRINT @cmd

		--next row
		FETCH NEXT FROM cursor_xmla_process_script 
		INTO @partition_name

	END  --end loop of cursor

	CLOSE cursor_xmla_process_script  
	DEALLOCATE cursor_xmla_process_script
END --end if

-----------------------------------------
--updating last_update_process field
-----------------------------------------
UPDATE [DWTEST].[sales].[dim_participation_promotion]
SET last_process_date_time = GETDATE()
WHERE last_process_date_time IS NULL OR (DATEDIFF(DAY, DATEADD(DAY, 1, end_date), CAST(GETDATE() AS DATE)) <= 0)

