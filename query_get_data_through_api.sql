
--TURN ON LOE AUTOMATION PROCEDURES
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE;
GO

--GET DATA
DECLARE @URL NVARCHAR(MAX) = 'https://dummy.restapiexample.com/api/v1/employees';
Declare @Object as Int;
Declare @ResponseText as Varchar(8000);

Exec sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
Exec sp_OAMethod @Object, 'open', NULL, 'get', @URL, 'False';
Exec sp_OAMethod @Object, 'send';
Exec sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

IF((Select @ResponseText) <> '')
BEGIN
     DECLARE @json NVARCHAR(MAX) = (Select @ResponseText)
     SELECT *
     FROM OPENJSON(@json,'$.data')
          WITH (
                 id INT,
                 employee_name NVARCHAR(50),
				 employee_salary INT,
				 employee_age SMALLINT,
				 profile_image NVARCHAR(100)
               );
END
ELSE
BEGIN
     DECLARE @ErroMsg NVARCHAR(30) = 'No data found.';
     Print @ErroMsg;
END
Exec sp_OADestroy @Object

