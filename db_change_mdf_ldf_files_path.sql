
--FIND THE CURRENT PATH
SELECT name AS FileLogicalName, physical_name AS FileLocation
FROM sys.master_files 
WHERE database_id = DB_ID(N'db_name') 


--STEP_1: TAKE THE DB OFFLINE
USE master
--ALTER DATABASE Test01 SET OFFLINE WITH ROLLBACK IMMEDIATE
GO

--STEP_3: CHANGE THE PATH
--ALTER DATABASE Test01 MODIFY FILE(NAME='DataFile',FILENAME='D:\Dump\DataFile1.mdf')
--ALTER DATABASE Test01 MODIFY FILE(NAME='LogFile',FILENAME='D:\Dump\LogFile.ldf')
GO

--STEP_3: COPY OR MOVE THE FILES FROM CURRENT PATH TO DESIRED PATH
/*
NOTICE: 
    * MAKE SURE THAT SQL SERVER CAN ACCESS THE SPECIFIED LOCATION
    * RIGHT CLICK A SQL SERVER INSTANCE THAT HOSTS A DATABASE (FROM SQL Server Configuration Manager[SEARCH FOR "CONF"] OR FROM SERVICES)
    * IN PROPERTIES OF FILES GIVE ACCESS TO SQL ENGINE USER (ALSO FOLDER)
*/
GO

--STEP_4: TAKE THE DB ONLINE
--ALTER DATABASE Test01 SET ONLINE
GO