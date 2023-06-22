
USE [AdventureWorksDW2019]
GO

---------------------------------------------
--CREATE DDL LOG TABLE FOR DATABASE
---------------------------------------------
DROP TABLE IF EXISTS LogDDLDatabase
CREATE TABLE [dbo].[LogDDLDatabase](
	[DatabaseLogID] [int] IDENTITY(1,1) NOT NULL,
	[PostTime] [datetime] NOT NULL,
	[DatabaseUser] [nvarchar](100) NOT NULL,
	[SystemUser] sysname NOT NULL,
	[Event] [sysname] NOT NULL,
	[Schema] [sysname] NULL,
	[Object] [sysname] NULL,
	[TSQL] [nvarchar](max) NOT NULL,
	[XmlEvent] [xml] NOT NULL,
) ON [PRIMARY]
GO


---------------------------------------------
--CREATE TRIGGER TO SAVE DDL COMMANDS
---------------------------------------------
CREATE TRIGGER [rtn_ddlDatabaseTriggerLog] ON DATABASE 
FOR DDL_DATABASE_LEVEL_EVENTS AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @data XML;
    DECLARE @schema sysname;
    DECLARE @object sysname;
    DECLARE @eventType sysname;

    SET @data = EVENTDATA();
    SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'sysname');
    SET @schema = @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname');
    SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname') 

    IF @object IS NOT NULL
        PRINT '  ' + @eventType + ' - ' + @schema + '.' + @object;
    ELSE
        PRINT '  ' + @eventType + ' - ' + @schema;

    IF @eventType IS NULL
        PRINT CONVERT(nvarchar(max), @data);

    INSERT [dbo].[LogDDLDatabase] 
        (
        [PostTime], 
        [DatabaseUser],
		[SystemUser],
        [Event], 
        [Schema], 
        [Object], 
        [TSQL], 
        [XmlEvent]
        ) 
    VALUES 
        (
        GETDATE(), 
        ORIGINAL_LOGIN(),
		CONVERT(sysname, CURRENT_USER),
        @eventType, 
        CONVERT(sysname, @schema), 
        CONVERT(sysname, @object), 
        @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)'), 
        @data
        );
END;
GO


---------------------------------------------
--ENABLE TRIGGER ON DATABASE
---------------------------------------------
ENABLE TRIGGER [rtn_ddlDatabaseTriggerLog] ON DATABASE
GO
