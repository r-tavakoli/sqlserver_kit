--GET DATA OF PROCESSES BY sp_who2
CREATE TABLE #sp_who2 (
	SPID INT,
	Status VARCHAR(255),
    Login VARCHAR(255),
	HostName VARCHAR(255),
    BlkBy VARCHAR(255),
	DBName  VARCHAR(255),
    Command VARCHAR(255),CPUTime INT,
    DiskIO INT,
	LastBatch VARCHAR(255),
    ProgramName VARCHAR(255),
	SPID2 INT,
    REQUESTID INT
)

INSERT INTO #sp_who2 EXEC sp_who2
SELECT * FROM #sp_who2 WHERE DBName <> 'master' ORDER BY DBName
DROP TABLE #sp_who2


--GET DATA OF PROCESSES BY sp_who2
SELECT
	p.spid,
	p.status,
	p.loginame,
	p.hostname,
	p.blocked,
	SUBSTRING(DB_NAME(p.dbid),1, 100) AS dbname,
	p.cmd,
	p.cpu,
	p.physical_io,
	p.last_batch,
	p.program_name,
	p.request_id
FROM 
	master.dbo.sysprocesses AS p
WHERE
	SUBSTRING(DB_NAME(dbid),1, 10) <> 'master'
	--and spid IN (SELECT blocked FROM master.dbo.sysprocesses)	--blocked processes
ORDER BY 
	DBName

--KILL PROCESS BY ADDING SPID TO BELOW COMMAND
--KILL SPID
