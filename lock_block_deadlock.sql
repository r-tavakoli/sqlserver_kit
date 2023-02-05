
--LOCK
SELECT
    resource_type,
    request_mode,
    resource_description
FROM
    sys.dm_tran_locks

/*
==> resource_type = Displays a resource where the locks are being acquired.  
ALLOCATION_UNIT, 
APPLICATION, 
DATABASE, 
EXTENT, 
FILE, 
HOBT, 
METADATA, 
OBJECT, 
PAGE, 
KEY, 
RID 

==> request_mode = displays the lock mode
Exclusive (X)
Shared (S)
Intent exclusive (IX)
Intent shared (IS)
Shared with intent exclusive (SIX)

==> resource_description = displays a short resource description of the column contains the id of the row, page, object, file, etc 
*/

--BLOCK
--OPEN TRANSACTIONS

SELECT spid,blocked,loginame,cmd,text,lastwaittype,physical_io,login_time,
open_tran,status,hostname
FROM SYS.SYSPROCESSES SP
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(SP.[SQL_HANDLE])
AS DEST WHERE OPEN_TRAN >= 1

--DEADLCOK 
--OPEN TRANSACTIONS --SHOULD BE 2

SELECT spid,blocked,loginame,cmd,text,lastwaittype,physical_io,login_time,
open_tran,status,hostname
FROM SYS.SYSPROCESSES SP
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(SP.[SQL_HANDLE])
AS DEST WHERE OPEN_TRAN >= 1


--KILL SPID
SELECT *
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;

KILL 100

