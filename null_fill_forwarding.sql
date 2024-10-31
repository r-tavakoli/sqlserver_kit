USE DB_Temporary
GO

drop table IF EXISTS #rtn_t1

CREATE TABLE #rtn_t1
(
	[Date] date NOT NULL
	,[Name] varchar(20) NOT NULL
	,qty int NULL
	,[Location] INT NULL
);
INSERT INTO #rtn_t1
VALUES ('20220101','Apple',2, 1)
	,('20220101','Apple',NULL,2)
	,('20220102','Apple',5,3)
	,('20220102','Apple',NULL,4)
	,('20220102','Apple',10,5)
	,('20220102','Apple',NULL,6)
	,('20220102','Kiwi',NULL,7)
	,('20220102','Kiwi',10,8)
	,('20220103','Kiwi',NULL,9)
	;

select * from #rtn_t1 ORDER BY DATE;


SELECT 
	*,
    MAX(QTY) OVER (PARTITION BY GROUPED ORDER BY [Location])
FROM
    (
        SELECT
            *,
            COUNT(QTY) OVER (PARTITION BY [NAME] ORDER BY [Location]) as GROUPED
        FROM
            #rtn_t1
    ) as grouped
ORDER BY Location

