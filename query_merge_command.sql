
--SOURCE TABLE
DROP TABLE IF EXISTS SourceProducts
CREATE TABLE SourceProducts(
    ProductID		INT,
    ProductName		VARCHAR(50),
    Price			DECIMAL(9,2),
	VersionNumber   ROWVERSION
)
GO

INSERT INTO SourceProducts(ProductID,ProductName, Price) 
VALUES
	(1,'Table',100),
	(2,'Desk',80),
	(3,'Chair',50),
	(4,'Computer',300)
GO

--TARGET TABLE
DROP TABLE IF EXISTS TargetProducts
CREATE TABLE TargetProducts(
    ProductID		INT,
    ProductName		VARCHAR(50),
    Price			DECIMAL(9,2),
	VersionNumber   BINARY(8) --NOTICE!
)
GO

----------------------
--MERGE COMMAND
----------------------
MERGE TargetProducts AS Target
USING SourceProducts AS Source
ON 
	Source.ProductID = Target.ProductID
 
-- For Inserts
WHEN NOT MATCHED BY Target THEN
    INSERT (ProductID, ProductName, Price, VersionNumber) 
    VALUES (Source.ProductID, Source.ProductName, Source.Price, SOURCE.VersionNumber)
    
-- For Updates
WHEN MATCHED AND SOURCE.VersionNumber <> Target.VersionNumber THEN 
	UPDATE
	SET
		Target.ProductName = Source.ProductName,
		Target.Price = Source.Price,
		Target.VersionNumber = SOURCE.VersionNumber 
    
-- For Deletes
WHEN NOT MATCHED BY Source THEN
    DELETE
        
-- CHECKING THE ACTIONS BY MERGE STATEMENT
OUTPUT $action, 
	DELETED.ProductID AS TargetProductID,
	DELETED.ProductName AS TargetProductName, 
	DELETED.Price AS TargetPrice, 
	INSERTED.ProductID AS SourceProductID, 
	INSERTED.ProductName AS SourceProductName, 
	INSERTED.Price AS SourcePrice;

----------------------
--INSERTING THE RESULTS OF THE MERGE STATEMENT INTO ANOTHER TABLE
----------------------

--LOG TABLE
DROP TABLE IF EXISTS LogProducts
CREATE TABLE LogProducts(
	ActionType VARCHAR(20),
    OldProductID INT,
    OldProductName VARCHAR(50),
    OldTargetPrice DECIMAL(9,2),
    NewProductID INT,
    NewProductName VARCHAR(50),
    NewPrice DECIMAL(9,2),
	ModifiedOn DATETIME2
)
GO


--TEST UDPATE, INSERT AND DELETE
INSERT INTO SourceProducts (ProductID, ProductName, Price) VALUES (5, 'Monitor', 100)
UPDATE SourceProducts SET Price = 50 WHERE ProductID=2
DELETE FROM SourceProducts WHERE ProductID=3

--MERGE COMMAND
INSERT INTO LogProducts
SELECT 
	Action,
    OldProductID,
    OldProductName,
    OldTargetPrice,
    NewProductID,
    NewProductName,
    NewPrice,
	GETDATE()
FROM (
	MERGE TargetProducts AS Target
	USING SourceProducts AS Source
	ON 
		Source.ProductID = Target.ProductID
 
	-- For Inserts
	WHEN NOT MATCHED BY Target THEN
		INSERT (ProductID, ProductName, Price, VersionNumber) 
		VALUES (Source.ProductID, Source.ProductName, Source.Price, SOURCE.VersionNumber)
    
	-- For Updates
	WHEN MATCHED AND SOURCE.VersionNumber <> Target.VersionNumber THEN 
		UPDATE
		SET
			Target.ProductName = Source.ProductName,
			Target.Price = Source.Price,
			Target.VersionNumber = SOURCE.VersionNumber 
    
	-- For Deletes
	WHEN NOT MATCHED BY Source THEN
		DELETE
        
	-- CHECKING THE ACTIONS BY MERGE STATEMENT
	--DU ==> DELETED OR UPDATED VALUES
	--I  ==> INSETED VALUES
	OUTPUT $action, 
		DELETED.ProductID AS duProductID, 
		DELETED.ProductName AS duProductName, 
		DELETED.Price AS duTargetPrice, 
		INSERTED.ProductID AS iSourceProductID, 
		INSERTED.ProductName AS iSourceProductName, 
		INSERTED.Price AS iSourcePrice
) AS CHANGES (Action, OldProductID, OldProductName, OldTargetPrice, NewProductID, NewProductName, NewPrice)
WHERE Action IN ('UPDATE', 'DELETE');