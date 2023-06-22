
USE NORTHWIND --CHANGE DATABASE
DECLARE @dates TABLE (FullDate DATE)
DECLARE @FromDate DATETIME = '2011-03-21' --1390/01/01
DECLARE @ToDate DATETIME = '2032-03-19' --1410/12/29

--------------------------------------
--CREATE DIMDATE TABLE
--------------------------------------
DROP TABLE IF EXISTS dbo.DimDate
CREATE TABLE dbo.DimDate
(
	[DateKey] INT NOT NULL,
	[FullDateAlternateKey] DATE NULL,
	[GregorianDayNumberOfWeek] TINYINT NULL,
	[GregorianDayNameOfWeek] NVARCHAR(10) NULL,
	[GregorianDayNumberOfMonth] TINYINT NULL,
	[GregorianDayNumberOfYear] SMALLINT NULL,
	[GregorianWeekNumberOfYear] TINYINT NULL,
	[GregorianMonthName] NVARCHAR(10) NULL,
	[GregorianMonthNumberOfYear] TINYINT NULL,
	[GregorianYear] SMALLINT NULL,
	[PersianDateKey] INT NOT NULL,
	[PersianDate] NCHAR(10) NULL,
	[PersianDayNumberOfWeek] TINYINT NULL,
	[PersianDayNameOfWeek] NVARCHAR(12) NULL,
	[PersianDayNumberOfMonth] TINYINT NULL,
	[PersianDayNumberOfYear] SMALLINT NULL,
	[PersianWeekNumberOfMonth] INT NULL,
	[PersianWeekNumberOfMonthLabel] NVARCHAR(30) NULL,
	[PersianWeekNumberOfYear] INT NULL,
	[PersianWeekNumberOfYearLabel] NVARCHAR(30) NULL,
	[PersianMonthName] NVARCHAR(8) NULL,
	[PersianMonthNumberOfYear] TINYINT NULL,
	[PersianYearMonth] INT NULL,
	[PersianYearName] NVARCHAR(6) NULL,
	[PersianYear] SMALLINT NULL,
	[PersianSeasonName] NVARCHAR(8) NULL,
	[PersianSeasonNumberOfYear] TINYINT NULL,
	[PersianYearSeasonId] SMALLINT  NULL,
	[PersianYearMonthId] SMALLINT NULL,
	[PersianYearWeekId] SMALLINT NULL,
	[PersianDayId] SMALLINT NULL,
	[PersianHalfYearName] NVARCHAR(15) NULL,
	[PersianHalfNumberOfYear] TINYINT NULL,
	[PersianYearCurrentPast] NVARCHAR(12) NULL,
	[PersianMonthCurrentPast] NVARCHAR(25) NULL,
	[PersianSeasonCurrentPast] NVARCHAR(25) NULL,
	[PersianWeekCurrentPast] NVARCHAR(12) NULL
) ON [PRIMARY]

--------------------------------------
--INSERT NULL RECORD
--------------------------------------
INSERT INTO dbo.DimDate
(
	DateKey,
	FullDateAlternateKey,
	GregorianDayNumberOfWeek,
	GregorianDayNameOfWeek,
	GregorianDayNumberOfMonth,
	GregorianDayNumberOfYear,
	GregorianWeekNumberOfYear,
	GregorianMonthName,
	GregorianMonthNumberOfYear,
	GregorianYear,
	PersianDateKey,
	PersianDate,
	PersianDayNumberOfWeek,
	PersianDayNameOfWeek,
	PersianDayNumberOfMonth,
	PersianDayNumberOfYear,
	PersianMonthName,
	PersianMonthNumberOfYear,
	PersianSeasonName,
	PersianSeasonNumberOfYear,
	PersianYearName,
	PersianYear,
	PersianYearSeasonId,
	PersianYearMonth,
	PersianYearMonthId,
	PersianDayId,
	PersianHalfYearName,
	PersianHalfNumberOfYear,
	PersianWeekNumberOfMonth,
	PersianWeekNumberOfYear,
	PersianYearWeekId,
	PersianWeekNumberOfMonthLabel,
	PersianWeekNumberOfYearLabel
)
VALUES(
	-1,	--DateKey
	NULL, --FullDateAlternateKey
	NULL, --GregorianDayNumberOfWeek
	NULL, --GregorianDayNameOfWeek
	NULL, --GregorianDayNumberOfMonth
	NULL, --GregorianDayNumberOfYear
	NULL, --GregorianWeekNumberOfYear
	NULL, --GregorianMonthName
	NULL, --GregorianMonthNumberOfYear
	NULL, --GregorianYear
	-1, --PersianDateKey
	N'نامشخص', --PersianDate
	NULL, --PersianDayNumberOfWeek
	N'نامشخص', --PersianDayNameOfWeek
	NULL, --PersianDayNumberOfMonth
	NULL, --PersianDayNumberOfYear
	N'نامشخص', --PersianMonthName
	NULL, --PersianMonthNumberOfYear
	N'نامشخص', --PersianSeasonName
	NULL, --PersianSeasonNumberOfYear
	N'نامشخص', --PersianYearName
	NULL, --PersianYear
	0, --PersianYearSeasonId
	NULL, --PersianYearMonth
	0, --PersianYearMonthId
	0, --PersianDayId
	N'نامشخص', --PersianHalfYearName
	NULL, --PersianHalfNumberOfYear
	NULL, --PersianWeekNumberOfMonth
	NULL, --PersianWeekNumberOfYear
	NULL, --PersianYearWeekId
	N'نامشخص', --PersianWeekNumberOfMonthLabel
	N'نامشخص' --PersianWeekNumberOfYearLabel
)

--------------------------------------
--DETERMINE DATE RANGE
--------------------------------------
WHILE @FromDate <= @ToDate
    BEGIN 
        INSERT INTO @dates (FullDate)
        SELECT @FromDate

        SET @FromDate = DATEADD(dd, 1, @FromDate)
    END 
--------------------------------------
--FILL DIMDATE TABLE
--------------------------------------

INSERT INTO dbo.DimDate
( 
	DateKey ,
	FullDateAlternateKey,
	GregorianDayNumberOfWeek,
	GregorianDayNameOfWeek,
	GregorianDayNumberOfMonth,
	GregorianDayNumberOfYear,
	GregorianWeekNumberOfYear,
	GregorianMonthName,
	GregorianMonthNumberOfYear,
	GregorianYear,
	PersianDateKey,
	PersianDate,
	PersianDayNumberOfWeek,
	PersianDayNameOfWeek,
	PersianDayNumberOfMonth,
	PersianDayNumberOfYear,
	PersianMonthName,
	PersianMonthNumberOfYear,
	PersianSeasonName,
	PersianSeasonNumberOfYear,
	PersianYearName,
	PersianYear,
	PersianYearSeasonId,
	PersianYearMonth,
	PersianYearMonthId,
	PersianDayId,
	PersianHalfYearName,
	PersianHalfNumberOfYear
)
SELECT  
	CONVERT(INT, CONVERT(VARCHAR, d.FullDate, 112)) AS DateKey,
	d.FullDate AS FullDateAlternateKey,
	DATEPART(dw, d.FullDate) AS GregorianDayNumberOfWeek,
	DATENAME(WEEKDAY, d.FullDate) AS GregorianDayNameOfWeek ,
	DATEPART(d, d.FullDate) AS GregorianDayNumberOfMonth,
	DATEPART(dy, d.FullDate) AS GregorianDayNumberOfYear,
	DATEPART(wk, d.FUllDate) AS GregorianWeekNumberOfYear,
	DATENAME(MONTH, d.FullDate) AS GregorianMonthName,
	MONTH(d.FullDate) AS GregorianMonthNumberOfYear,
	YEAR(d.FullDate) AS GregorianYear,
	FORMAT(d.FullDate, 'yyyyMMdd', 'FA-IR') * 1 AS PersianDateKey,
	FORMAT(d.FullDate, 'yyyy/MM/dd', 'FA-IR') AS PersianDate,
	(DATEPART(dw, d.FullDate) % 7) + 1 AS PersianDayNumberOfWeek,
	CASE
		WHEN DATEPART(dw, d.FullDate)=1 THEN N'یک شنبه'
		WHEN DATEPART(dw, d.FullDate)=2 THEN N'دو شنبه'
		WHEN DATEPART(dw, d.FullDate)=3 THEN N'سه شنبه'
		WHEN DATEPART(dw, d.FullDate)=4 THEN N'چهار شنبه'
		WHEN DATEPART(dw, d.FullDate)=5 THEN N'پنج شنبه'
		WHEN DATEPART(dw, d.FullDate)=6 THEN N'جمعه'
		WHEN DATEPART(dw, d.FullDate)=7 THEN N'شنبه'
	END AS PersianDayNameOfWeek,
	FORMAT(d.FullDate, 'dd', 'FA-IR') * 1 AS PersianDayNumberOfMonth,
	ROW_NUMBER()OVER(PARTITION BY FORMAT(d.FullDate, 'yyyy', 'FA-IR') * 1 ORDER BY d.FullDate) AS PersianDayNumberOfYear,
	CASE
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1=1  THEN N'فروردین'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1=2  THEN N'اردیبهشت'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1=3  THEN N'خرداد'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1=4  THEN N'تیر'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1=5  THEN N'مرداد'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1=6  THEN N'شهریور'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1=7  THEN N'مهر'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1=8  THEN N'آبان'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1=9  THEN N'آذر'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1=10 THEN N'دی'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1=11 THEN N'بهمن'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1=12 THEN N'اسفند'
	END AS PersianMonthName,
	FORMAT(d.FullDate, 'MM', 'FA-IR') * 1 AS PersianMonthNumberOfYear,
	CASE
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=3   THEN N'بهار'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=6   THEN N'تابستان'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=9   THEN N'پاییز'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=12  THEN N'زمستان'
	END AS PersianSeasonName,
	CASE
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=3   THEN 1
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=6   THEN 2
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=9   THEN 3
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=12  THEN 4
	END AS PersianSeasonNumberOfYear,
	FORMAT(d.FullDate, 'yyyy', 'FA-IR') AS PersianYearName,
	FORMAT(d.FullDate, 'yyyy', 'FA-IR') * 1 AS PersianYear,
	DENSE_RANK()OVER(
		ORDER BY
			CASE
				WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=3   THEN FORMAT(d.FullDate, 'yyyy01', 'FA-IR') * 1
				WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=6   THEN FORMAT(d.FullDate, 'yyyy02', 'FA-IR') * 1
				WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=9   THEN FORMAT(d.FullDate, 'yyyy03', 'FA-IR') * 1
				WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=12  THEN FORMAT(d.FullDate, 'yyyy04', 'FA-IR') * 1
			END
	) AS PersianYearSeasonId,
	FORMAT(d.FullDate, 'yyyyMM', 'FA-IR') * 1 AS PersianYearMonth,
	DENSE_RANK()OVER(ORDER BY FORMAT(d.FullDate, 'yyyyMM', 'FA-IR') * 1) AS PersianYearMonthId,
	DENSE_RANK()OVER(ORDER BY FORMAT(d.FullDate, 'yyyyMMdd', 'FA-IR')) AS PersianDayId,
	CASE
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=6    THEN N'نیمه اول سال'
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=12   THEN N'نیمه دوم سال'
	END AS PersianHalfYearName,
	CASE
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=6    THEN 1
		WHEN FORMAT(d.FullDate, 'MM', 'FA-IR') * 1<=12   THEN 2
	END AS PersianHalfNumberOfYear
FROM    
	@dates AS d
LEFT OUTER JOIN 
	dbo.DimDate AS pd 
ON 
	d.FullDate = pd.FullDateAlternateKey
WHERE   
	pd.FullDateAlternateKey IS NULL


--------------------------------------
--POPULATE WEEK ID COLUMN
--------------------------------------
DECLARE @RowDate DATE = (SELECT MIN(FullDateAlternateKey) FROM DimDate)
DECLARE @Counter INT = 1
DECLARE @Counter_Week_Id SMALLINT = 1

WHILE (@Counter <= (SELECT COUNT(*) FROM DimDate))
BEGIN
    UPDATE DimDate
	SET PersianYearWeekId = @Counter_Week_Id
	FROM DimDate
	WHERE FullDateAlternateKey = @RowDate

	SET @Counter = @Counter + 1
	IF (SELECT PersianDayNumberOfWeek FROM DimDate WHERE FullDateAlternateKey = @RowDate) = 7
		SET @Counter_Week_Id = @Counter_Week_Id + 1
	SET @RowDate = DATEADD(dd, 1, @RowDate)
END
GO

--------------------------------------
--WEEK NUMBER OF YEAR 
--WEEK NUMBER OF MONTH
--------------------------------------
DROP TABLE IF EXISTS #Temp_Week_Table
SELECT
	FullDateAlternateKey,
	PersianWeekNumberOfYear = DENSE_RANK() OVER(PARTITION BY PersianYear ORDER BY PersianYearWeekId),
	PersianWeekNumberOfMonth = DENSE_RANK() OVER(PARTITION BY PersianYearMonth ORDER BY PersianYearWeekId),
	PersianWeekNumberOfYearLabel = 
	N'هفته ' + CAST(
					DENSE_RANK() 
					OVER(
						PARTITION BY PersianYear 
						ORDER BY PersianYearWeekId
						)
					AS NVARCHAR(2)
					)
			+ N' سال ' + PersianYearName,
	PersianWeekNumberOfMonthLabel = 
	N'هفته ' + CAST(
					DENSE_RANK() 
					OVER(
						PARTITION BY PersianYearMonth 
						ORDER BY PersianYearWeekId
						)
					AS NVARCHAR(2)
					)
				+ N' ' + PersianMonthName + N' ماه سال ' + PersianYearName
INTO #Temp_Week_Table
FROM
	DimDate
WHERE
	DateKey != -1

UPDATE DimDate
SET
	DimDate.PersianWeekNumberOfYear = #Temp_Week_Table.PersianWeekNumberOfYear,
	DimDate.PersianWeekNumberOfMonth = #Temp_Week_Table.PersianWeekNumberOfMonth,
	DimDate.PersianWeekNumberOfYearLabel = #Temp_Week_Table.PersianWeekNumberOfYearLabel,
	DimDate.PersianWeekNumberOfMonthLabel = #Temp_Week_Table.PersianWeekNumberOfMonthLabel
FROM
	DimDate
INNER JOIN
	#Temp_Week_Table
ON
	DimDate.FullDateAlternateKey=#Temp_Week_Table.FullDateAlternateKey

--------------------------------------
--CURRENT AND LAST YEAR
--------------------------------------
DROP PROCEDURE IF EXISTS usp_SetPersianCurrentAndPastYearOnDimDate
GO

CREATE PROCEDURE usp_SetPersianCurrentAndPastYearOnDimDate
AS

BEGIN

	--SET COLUMN TO NULL
	UPDATE DimDate
	SET DimDate.PersianYearCurrentPast = NULL
	WHERE DimDate.PersianYearCurrentPast IS NOT NULL

	--CURRENT YEAR
	UPDATE DimDate
	SET DimDate.PersianYearCurrentPast = N'سال جاری'
	WHERE DimDate.PersianYear = FORMAT(GETDATE(), 'yyyy', 'FA-IR') * 1

	--PREVIOUS MONTH
	UPDATE DimDate
	SET DimDate.PersianYearCurrentPast = N'سال گذشته'
	WHERE DimDate.PersianYear = FORMAT(GETDATE(), 'yyyy', 'FA-IR') - 1

END

--EXEC usp_SetPersianCurrentAndPastYearOnDimDate

--------------------------------------
--CURRENT AND LAST SEASON
--------------------------------------
DROP PROCEDURE IF EXISTS usp_SetPersianCurrentAndPastSeasonOnDimDate
GO

CREATE PROCEDURE usp_SetPersianCurrentAndPastSeasonOnDimDate
AS

BEGIN

	--SET COLUMN TO NULL
	UPDATE DimDate
	SET DimDate.PersianSeasonCurrentPast = NULL
	WHERE DimDate.PersianSeasonCurrentPast IS NOT NULL

	--CURRENT SEASON
	UPDATE DimDate
	SET DimDate.PersianSeasonCurrentPast = N'فصل جاری'
	WHERE DimDate.PersianYearSeasonId =
		(
			SELECT MAX(PersianYearSeasonId) * 1
			FROM DimDate
			WHERE PersianYearMonth=FORMAT(GETDATE(), 'yyyyMM', 'FA-IR')
		)

	--PREVIOUS SEASON
	UPDATE DimDate
	SET DimDate.PersianSeasonCurrentPast = N'فصل گذشته'
	WHERE DimDate.PersianYearSeasonId = 
		(
			SELECT MAX(PersianYearSeasonId) - 1 
			FROM DimDate 
			WHERE PersianYearMonth=FORMAT(GETDATE(), 'yyyyMM', 'FA-IR')
		)

	--SAME SEASON LAST YEAR
	UPDATE DimDate
	SET DimDate.PersianSeasonCurrentPast = N'فصل جاری / سال گذشته'
	WHERE DimDate.PersianYearSeasonId =
		(
			SELECT MAX(PersianYearSeasonId) - 4
			FROM DimDate
			WHERE PersianYearMonth=FORMAT(GETDATE(), 'yyyyMM', 'FA-IR')
		)

	--PREVIOUS SEASON LAST YEAR
	UPDATE DimDate
	SET DimDate.PersianSeasonCurrentPast = N'فصل گذشته / سال گذشته'
	WHERE DimDate.PersianYearSeasonId = 
		(
			SELECT MAX(PersianYearSeasonId) - 1 - 4
			FROM DimDate 
			WHERE PersianYearMonth=FORMAT(GETDATE(), 'yyyyMM', 'FA-IR')
		)
END

--EXEC usp_SetPersianCurrentAndPastSeasonOnDimDate

--------------------------------------
--CURRENT AND LAST MONTH
--------------------------------------
DROP PROCEDURE IF EXISTS usp_SetPersianCurrentAndPastMonthOnDimDate
GO

CREATE PROCEDURE usp_SetPersianCurrentAndPastMonthOnDimDate
AS

BEGIN

	--SET COLUMN TO NULL
	UPDATE DimDate
	SET DimDate.PersianMonthCurrentPast = NULL
	WHERE DimDate.PersianMonthCurrentPast IS NOT NULL

	--CURRENT MONTH
	UPDATE DimDate
	SET DimDate.PersianMonthCurrentPast = N'ماه جاری'
	WHERE DimDate.PersianYearMonth = FORMAT(GETDATE(), 'yyyyMM', 'FA-IR') * 1

	--PREVIOUS MONTH
	UPDATE DimDate
	SET DimDate.PersianMonthCurrentPast = N'ماه گذشته'
	WHERE DimDate.PersianYearMonthId = 
		(
			SELECT MAX(PersianYearMonthId) - 1 
			FROM DimDate 
			WHERE PersianYearMonth=FORMAT(GETDATE(), 'yyyyMM', 'FA-IR')
		)

	--PAST TWO MONTHS
	UPDATE DimDate
	SET DimDate.PersianMonthCurrentPast = N'دو ماه گذشته'
	WHERE DimDate.PersianYearMonthId = 
		(
			SELECT MAX(PersianYearMonthId) - 2 
			FROM DimDate 
			WHERE PersianYearMonth=FORMAT(GETDATE(), 'yyyyMM', 'FA-IR')
		)

	--SAME MONTH LAST YEAR
	UPDATE DimDate
	SET DimDate.PersianMonthCurrentPast = N'ماه جاری / سال گذشته'
	WHERE DimDate.PersianYearMonthId =
		(
			SELECT MAX(PersianYearMonthId) - 12
			FROM DimDate
			WHERE PersianYearMonth=FORMAT(GETDATE(), 'yyyyMM', 'FA-IR')
		)

	--PREVIOUS MONTH LAST YEAR
	UPDATE DimDate
	SET DimDate.PersianMonthCurrentPast = N'ماه گذشته / سال گذشته'
	WHERE DimDate.PersianYearMonthId = 
		(
			SELECT MAX(PersianYearMonthId) - 1 - 12
			FROM DimDate 
			WHERE PersianYearMonth=FORMAT(GETDATE(), 'yyyyMM', 'FA-IR')
		)
END

--EXEC usp_SetPersianCurrentAndPastMonthOnDimDate


--------------------------------------
--CURRENT AND LAST WEEK
--------------------------------------
DROP PROCEDURE IF EXISTS usp_SetPersianCurrentAndPastWeekOnDimDate
GO

CREATE PROCEDURE usp_SetPersianCurrentAndPastWeekOnDimDate
AS

BEGIN

	--SET COLUMN TO NULL
	UPDATE DimDate
	SET DimDate.PersianWeekCurrentPast = NULL
	WHERE DimDate.PersianWeekCurrentPast IS NOT NULL

	--CURRENT WEEK
	UPDATE DimDate
	SET DimDate.PersianWeekCurrentPast = N'هفته جاری'
	WHERE DimDate.PersianYearWeekId =
		(
			SELECT PersianYearWeekId
			FROM DimDate
			WHERE PersianDateKey=FORMAT(GETDATE(), 'yyyyMMdd', 'FA-IR') * 1
		)

	--PREVIOUS WEEK
	UPDATE DimDate
	SET DimDate.PersianWeekCurrentPast = N'فصل گذشته'
	WHERE DimDate.PersianYearWeekId = 
		(
			SELECT PersianYearWeekId - 1
			FROM DimDate
			WHERE PersianDateKey=FORMAT(GETDATE(), 'yyyyMMdd', 'FA-IR') * 1
		)
END

--EXEC usp_SetPersianCurrentAndPastWeekOnDimDate
