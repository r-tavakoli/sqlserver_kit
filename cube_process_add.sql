
USE AdventureWorksDW2019
GO

------------------------------------------
--TEST DATA
------------------------------------------
DROP TABLE IF EXISTS[dbo].[test_table]
CREATE TABLE [dbo].[test_table](
	Id BIGINT IDENTITY(1, 1),
	[Title] [varchar](10) NOT NULL,
	[Qty] [int] NOT NULL
) ON [PRIMARY]

INSERT INTO test_table(Title, Qty) VALUES
('A', 100),
('B', 200),
('C', 300),
('D', 400),
('E', 500)


------------------------------------------
--CREATE TABLE CubeSettings
------------------------------------------

DROP TABLE IF EXISTS CubeSettings
CREATE TABLE CubeSettings 
(
	Id INT IDENTITY(1, 1),
	FactName VARCHAR(100),
	LastProcessedRow BIGINT, --BINARY(8),
	CreatedOn DATETIME DEFAULT SYSDATETIME(),
	ModifiedOn DATETIME
)


------------------------------------------
--MAXIMUM ID USING MDX
------------------------------------------
--SELECT NON EMPTY { [Measures].[MaximumID] } ON COLUMNS FROM [Adventure Works DW2019]

------------------------------------------
--FILL CubeSettings TABLE
------------------------------------------

MERGE CubeSettings AS target
USING (VALUES ('test_table', 5, GETDATE())) AS source (FactName, UpsertValue, ModifiedOn)
ON target.FactName = source.FactName
WHEN MATCHED THEN 
	UPDATE 
	SET 
		target.LastProcessedRow = source.UpsertValue, --PARAMETER
		target.ModifiedOn = source.ModifiedOn

WHEN NOT MATCHED  THEN 
	INSERT (FactName, LastProcessedRow, ModifiedOn)
	VALUES(source.FactName, source.UpsertValue, source.ModifiedOn); --PARAMETER

SELECT * FROM CubeSettings

------------------------------------------
--PROCESS ADD QUERY
------------------------------------------
SELECT * 
FROM test_table
WHERE Id>(SELECT LastProcessedRow FROM CubeSettings WHERE FactName='test_table')


------------------------------------------
--ADD DATA TO TEST TABLE
------------------------------------------
INSERT INTO test_table(Title, Qty) VALUES
('DF', 1000),
('EF', 2000)