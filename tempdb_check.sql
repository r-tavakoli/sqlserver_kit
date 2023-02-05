-- TEMPDB purpose is to hold temporary objects and have certain action performed in the tempdb such as: 
    -- Global or local temporary tables
    -- Temporary stored procedures 
    -- Table variables
    -- Cursors
    -- Results for spools or sorting
    -- Online index operations
    -- Multiple Active Result Sets (MARS)
    -- AFTER triggers. 
    
-- Tempdb is re-created every time SQL Server is started 
-- Backup and restore operations are not allowed on tempdb

/***********************************/
--  1. file growth increment 

--set file growth increment  to a reasonable size to avoid the tempdb database files from growing by too small a value
-- tempdb file size ==> FILEGROWTH increment
-- 0 to 100 MB      ==>	10 MB
-- 100 to 200 MB    ==>	20 MB
-- 200 MB or more   ==>	10% * file size

USE tempdb

SELECT 
    name AS FileName, 
    size*1.0/128 AS FileSizeinMB,
    CASE max_size 
        WHEN 0 THEN 'Autogrowth is turned off.' 
        WHEN -1 THEN 'Autogrowth is turned on.'
        ELSE 'Log file will continue to grow'
    END AS AutoGrowthState,
    growth AS 'GrowthValue',
    'GrowthIncrement' = 
    CASE
        WHEN growth = 0 THEN 'Size is fixed and will not grow.'
        WHEN growth > 0 AND is_percent_growth = 0 
        THEN 'Growth value is in 8-KB pages.'
        ELSE 'Growth value is a percentage.'
    END
FROM 
    tempdb.sys.database_files;
GO

/***********************************/
-- 2. File number rule

--When you have less (or equal) than 8 CPU cores, you will get as many TempDb data files as you have CPU cores
--If you have more than 8 CPU cores, you will get 8 TempDb data files out of the box

SELECT 
    cpu_count,*
FROM 
    sys.dm_os_sys_info
GO


/***********************************/

