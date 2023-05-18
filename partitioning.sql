--STEPS:

--1. CREATE FILEGROUPS AND DATA FILES IF NEEDED 
--2. CREATE A PARTITION FUNCTION
--3. CREATE A PARTITION SCHEME
--4. CREATE THE TABLE USING THE PARTITION SCHEME

------------------------------
--STEP 1: CREATE FILEGROUPS AND DATA FILES IF NEEDED 
------------------------------
USE master
GO

CREATE DATABASE partition_test_db
--DIMENSION DATA FILE
ON PRIMARY
	( 
		NAME = Dimension,
		FILENAME = 'F:\test\partition_dbs\Dimension.mdf',
		SIZE = 10MB,
		MAXSIZE = 50MB,
		FILEGROWTH = 5MB 
	),

--FACT DATA FILES PARTITIONED BY SHAMSI YEAR
FILEGROUP FG_1400
	( 
		NAME = Fact_1400,
		FILENAME = 'F:\test\partition_dbs\Fact_1400.ndf',
		SIZE = 10MB,
		MAXSIZE = 50MB,
		FILEGROWTH = 5MB 
	),
FILEGROUP FG_1401
	( 
		NAME = Fact_1401,
		FILENAME = 'F:\test\partition_dbs\Fact_1401.ndf',
		SIZE = 10MB,
		MAXSIZE = 50MB,
		FILEGROWTH = 5MB 
	)

--LOG FILES
LOG ON
	( NAME = partition_test_db_log,
		FILENAME = 'F:\test\partition_dbs\partition_test_db_log.ldf',
		SIZE = 5MB,
		MAXSIZE = 25MB,
		FILEGROWTH = 5MB );
GO


--ADD NEW FILE GROUP AND A NEW DATA FILE TO DB
USE master
GO
ALTER DATABASE partition_test_db ADD FILEGROUP FG_1402;

GO
ALTER DATABASE partition_test_db ADD FILE
	(
		NAME = Fact_1402,
		FILENAME = 'F:\test\partition_dbs\Fact_1402.ndf',
		SIZE = 10MB,
		MAXSIZE = 50MB,
		FILEGROWTH = 5MB 
	)
	TO FILEGROUP FG_1402;
GO


--LIST FILE GROUPS
USE partition_test_db
GO

SELECT
  name
FROM 
	sys.filegroups
WHERE 
	type = 'FG';

--LIST DATA FILES
SELECT 
	name as filename,
	physical_name as file_path
FROM 
	sys.database_files
where 
	type_desc = 'ROWS';


------------------------------
--STEP 2: CREATE A PARTITION FUNCTION
------------------------------
USE partition_test_db
GO

--DROP PARTITION FUNCTION partition_by_shamsi_year_function
--GO

CREATE PARTITION FUNCTION partition_by_shamsi_year_function (int)
AS RANGE LEFT 
FOR VALUES (1400, 1401);

-- year	==> values range		
-- 1400	==> col <= 1400
-- 1401	==> col >  1400 AND col <= 1401
-- 1402	==> col > 1401


------------------------------
--STEP 3: CREATE A PARTITION SCHEME
------------------------------
USE partition_test_db
GO

--DROP PARTITION SCHEME partition_by_shamsi_year_scheme
--GO

CREATE PARTITION SCHEME partition_by_shamsi_year_scheme
AS PARTITION partition_by_shamsi_year_function
TO (FG_1400, FG_1401, FG_1402);


--Filegroup	Partition	Values
--FG_1400	1	col <= 1400
--FG_1401	2	col >  1400 AND col <= 1401
--FG_1402	3	col > 1401


------------------------------
--STEP 4: CREATE THE TABLE USING THE PARTITION SCHEME
------------------------------
USE partition_test_db
GO

--WITHOUT PK
CREATE TABLE my_fact_table (
  id int not null identity(1,1),
  title varchar(10),
  shamsi_year_col int,
) 
ON partition_by_shamsi_year_scheme (shamsi_year_col);

--WITH PK WHICH NEEDS TO MENTION PARITION COLUMN AS PRIMARY KEY
CREATE TABLE my_fact_table_two (
  id int not null identity(1,1),
  title varchar(10),
  shamsi_year_col int,
  PRIMARY KEY (id, shamsi_year_col)
) 
ON partition_by_shamsi_year_scheme (shamsi_year_col);

--PRIMARY FILE GROUP
CREATE TABLE my_dimension_table (
  id int not null identity(1,1),
  title varchar(10)
)
ON [PRIMARY];


------------------------------
--TEST FIRST TABLE
------------------------------
USE partition_test_db
GO 

INSERT INTO my_fact_table (title, shamsi_year_col)
VALUES ('A', 1400),
	   ('A', 1400),
	   ('A', 1401),
	   ('A', 1401),
	   ('A', 1401),
	   ('A', 1402)

SELECT * FROM my_fact_table

------------------------------
--TEST SECOND TABLE
------------------------------
USE partition_test_db
GO 

INSERT INTO my_fact_table_two (title, shamsi_year_col)
VALUES ('A', 1400),
	   ('A', 1400),
	   ('A', 1401),
	   ('A', 1401),
	   ('A', 1401),
	   ('A', 1402)

SELECT * FROM my_fact_table_two

------------------------------
--TEST THIRD TABLE
------------------------------
USE partition_test_db
GO 

INSERT INTO my_dimension_table (title)
VALUES ('A'),
	   ('B'),
	   ('C'),
	   ('D'),
	   ('E'),
	   ('F')

SELECT * FROM my_dimension_table



--NUMBER OF ROWS IN EACH FILE GROUP
SELECT o.name as table_name, rv.value as partition_range, fg.name as file_groupName, p.partition_number, p.rows as number_of_rows
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.objects o ON p.object_id = o.object_id
INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id
INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id
INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number
INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id
ORDER BY o.name, fg.name
