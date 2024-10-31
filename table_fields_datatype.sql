WITH q AS (
    
    SELECT
        c.TABLE_SCHEMA,
        c.TABLE_NAME,
        c.ORDINAL_POSITION,
        c.COLUMN_NAME,
        c.DATA_TYPE,
        CASE
            WHEN c.DATA_TYPE IN ( N'binary', N'varbinary'                    ) THEN ( CASE c.CHARACTER_OCTET_LENGTH   WHEN -1 THEN N'(max)' ELSE CONCAT( N'(', c.CHARACTER_OCTET_LENGTH  , N')' ) END )
            WHEN c.DATA_TYPE IN ( N'char', N'varchar', N'nchar', N'nvarchar' ) THEN ( CASE c.CHARACTER_MAXIMUM_LENGTH WHEN -1 THEN N'(max)' ELSE CONCAT( N'(', c.CHARACTER_MAXIMUM_LENGTH, N')' ) END )
            WHEN c.DATA_TYPE IN ( N'datetime2', N'datetimeoffset'            ) THEN CONCAT( N'(', c.DATETIME_PRECISION, N')' )
            WHEN c.DATA_TYPE IN ( N'decimal', N'numeric'                     ) THEN CONCAT( N'(', c.NUMERIC_PRECISION , N',', c.NUMERIC_SCALE, N')' )
        END AS DATA_TYPE_PARAMETER,
        CASE c.IS_NULLABLE
            WHEN N'NO'  THEN N' NOT NULL'
            WHEN N'YES' THEN     N' NULL'
        END AS IS_NULLABLE2
    FROM
        INFORMATION_SCHEMA.COLUMNS AS c
)
SELECT
    q.TABLE_SCHEMA,
    q.TABLE_NAME,
    q.ORDINAL_POSITION,
    q.COLUMN_NAME,
    CONCAT( q.DATA_TYPE, ISNULL( q.DATA_TYPE_PARAMETER, N'' ), q.IS_NULLABLE2 ) AS FULL_DATA_TYPE

FROM
    q
WHERE
    q.TABLE_SCHEMA = 'TEST' AND
    q.TABLE_NAME   = 'orders'  AND 
    q.COLUMN_NAME  IN ('site')
ORDER BY
    q.TABLE_SCHEMA,
    q.TABLE_NAME,
    q.ORDINAL_POSITION;