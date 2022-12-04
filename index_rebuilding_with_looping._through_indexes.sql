
--INSERT FRAGMENTED INDEXES (GREATER THAN 30%) INTO A TEMP VARIABLE AND REBUILD THEM
DECLARE @frag_Temp AS Table
(
    ID int identity(1,1),
       [objectid][int] NULL,
       [indexid][int] NULL,
       [partitionnum][int] NULL,
       [frag] [float] NULL
)
DECLARE @Count int
DECLARE @i tinyint=1
DECLARE @schemaname sysname;
DECLARE @objectname sysname;
DECLARE @indexname sysname;
DECLARE @objectid int;
DECLARE @indexid int;
DECLARE @partitionnum bigint;
DECLARE @partitioncount bigint;
DECLARE @SQLCommand as Nvarchar(3000)


INSERT INTO @frag_Temp
SELECT
    object_id AS objectid,
    index_id AS indexid,
    partition_number AS partitionnum,
    avg_fragmentation_in_percent AS frag
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, 'SAMPLED')
--Arguments 1(Database_ID,object_Id,Index_ID,partition,mode
WHERE avg_fragmentation_in_percent >=30.0 AND index_id> 0 AND OBJECT_NAME(OBJECT_ID)='cdr_main';


SELECT @Count=Count(*) FROM @frag_Temp --Get Total Count

--Loop through fragmented indexes
While(@i<=@Count)
    Begin
		--Set indexid, objectid and partitionnum
        SELECT @objectid=objectid, @indexid=indexid, @partitionnum=partitionnum FROM @frag_Temp WHERE ID=@i
        --Get table name and its schema
        SELECT @objectname=o.NAME, @schemaname=c.NAME FROM sys.objects o INNER JOIN  sys.schemas c ON o.schema_ID=c.schema_ID WHERE o.object_id=@objectid
        --Get Index Name
		SELECT @indexname=NAME FROM sys.indexes WHERE index_id=@indexid AND object_id=@objectid
        --Get Partition Count
        SELECT @partitioncount=COUNT(*) FROM sys.partitions WHERE object_id=@objectid AND index_id=@indexid
		--Create ALTER script
        SELECT @SQLCommand= 'Alter Index ' + @indexname + ' ON ' + @schemaname + '.' + @objectname + ' REBUILD'  
			IF(@partitioncount>1) SELECT @SQLCommand=@SQLCommand +  ' PARTITION=' +  convert(Char,@partitionnum);
               --PRINT @SQLCommand
        EXEC(@SQLCommand);
        --Increment Count
        SET @i=@i+1
    End