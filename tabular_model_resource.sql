--FOOTPRINT
--Conventional wisdom holds that the xVelocity engine yields roughly 90% compression.
--In practice, the level of compression is more likely to be something closer a range between 60% and 85%. 
--So with a 1TB relational database, you might realistically expect to see a disk footprint between 150 GB and 400 GB.
--Disk footprint of a software application refers to its sizing information 
--when it's in an inactive state, or in other words, when it's not executing 
--but stored on a secondary media or downloaded over a network connection.

DECLARE @DataSize INT = 1000
--GB
SELECT
    @DataSize AS DataSizeGB,
    @DataSize - @DataSize * 0.85 AS MinimumFootprintGB,
    @DataSize - @DataSize * 0.60 AS MaximumFootprintGB
GO

--MEMORY USAGE FORMULA
--71 MB is idle server memory consumption with no data loaded
--When the database is loaded from disk into memory, it will inflate to approximately twice the size of the data files stored on disk
-- The 5.2 operand is used to allow for additional memory for Processing and Disaster Recovery operations
DECLARE @PartitionDataSizeGB INT = 100
--GB
SELECT
    71 + ((@PartitionDataSizeGB * 1024  / 6 ) * 5.2) AS MemoryMB,
    (71 + ((@PartitionDataSizeGB * 1024  / 6 ) * 5.2)) / 1024 AS MemoryGB


--https://learn.microsoft.com/en-us/previous-versions/sql/sql-server-2012/ms174514(v=sql.110)?redirectedfrom=MSDN
--Vertipaq Settings
/* When VertiPaqPagingPolicy is set to 1 or 2, processing is less likely to fail due to memory constraints 
because the server will try to page to disk using the method that you specified.  
Note the property VertiPaqMemoryLimit specifies the level of memory consumption (as a percentage of total memory) 
at which paging starts.  The default is 60.  If memory consumption is less than 60 percent, the server will not page to disk.*/

--VertipaqPagingPolicy
--0 is the default.  No paging is allowed.  If memory is insufficient, processing fails with an out-of-memory error.  All Tabular data is locked in memory
--1 enables paging to disk using the operating system page file (pagefile.sys).  Lock only hash dictionaries in memory, and allow Tabular data to exceed total physical memory
--2 enables paging to disk using memory-mapped files.  Lock only hash dictionaries in memory, and allow Tabular data to exceed total physical memory