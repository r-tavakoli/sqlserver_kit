
--HOW TO SEND FORMATTED EMAIL FROM SQL SERVER

--STEPS TO CONFIGURE EMAIL ON SQL SERVER:
/*
	1. ENABEL DB EMAIL IF IS DISABLED
	2. CREATE PROFILE
	3. CREATE ACCOUNT
	4. ADD ACCOUNT TO PROFILE
*/

--ENABLE DATABASE EMAIL IF IT IS NOT SHOWING UP IN SSMS OR GETTING ERROR
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO

--CREATE A DATABASE MAIL PROFILE  
EXECUTE msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'test',  
    @description = 'This profile is for testing...!' ;  
GO

--GRANT ACCESS TO THE PROFILE TO THE DBMAILUSERS ROLE  
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp  
    @profile_name = 'test',  
    @principal_name = 'public',  
    @is_default = 1 ;
GO

--CREATE A DATABASE MAIL ACCOUNT  
EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'Gmail',  
    @description = 'Mail account for sending outgoing email',  
    @email_address = 'avaga.user@gmail.com', --The e-mail address to send the message from
    @display_name = 'BI Department',  
    @mailserver_name = 'smtp.gmail.com',
    @port = 465,
    @enable_ssl = 1,
    @username = 'avaga.user@gmail.com',
    @password = 'Ava@123456';  
GO

--ADD THE ACCOUNT TO THE PROFILE  
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'test',  
    @account_name = 'Gmail',  
    @sequence_number =1 ;  
GO

--ROLLBACK THE ABOVE PROCEDURES IF STH WENT WRONG (USE IF YOU COUNTERED ERROR)
EXECUTE msdb.dbo.sysmail_delete_profileaccount_sp @profile_name = 'test'
EXECUTE msdb.dbo.sysmail_delete_principalprofile_sp @profile_name = 'test'
EXECUTE msdb.dbo.sysmail_delete_account_sp @account_name = 'Gmail'
EXECUTE msdb.dbo.sysmail_delete_profile_sp @profile_name = 'test'

--CHECK PROFILES AND ACCOUNTS WHICH HAVE BEEN CREATED
SELECT 
	*
FROM msdb.dbo.sysmail_profile p 
JOIN msdb.dbo.sysmail_profileaccount pa ON p.profile_id = pa.profile_id 
JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id 
JOIN msdb.dbo.sysmail_server s ON a.account_id = s.account_id

--CONFIGURE GMAIL FOR SENDING EMAIL
--1. Go to Gmail account settings , and click on security tab (https://myaccount.google.com/)
--2. Add 2 step verification (if you don't have)
--3. Click on "App Password"
--4. Select application device or add new one (Select 'Other' when it askes you to select an app you want to connect to, then enter in whatever name you want to give the app and generate anew password.)
--5. You will get new password to use in your app


--TEST
DECLARE @body VARCHAR(MAX)
SET @body = 'this is a test email has created on' + (FORMAT(GETDATE(), 'yyyy/MM/dd HH:mm'))

EXEC msdb.dbo.sp_send_dbmail
     @profile_name = 'test',
     @recipients = 'rahtav68@gmail.com',
     @body = @body,
     @subject = 'BI Report';
GO

SELECT items.subject ,
       items.recipients ,
       items.copy_recipients ,
       items.blind_copy_recipients ,
       items.last_mod_date ,
       l.description
FROM  
	msdb.dbo.sysmail_faileditems AS items
LEFT OUTER JOIN 
	msdb.dbo.sysmail_event_log AS l 
ON 
	items.mailitem_id = l.mailitem_id


--https://www.sqlshack.com/format-dbmail-with-html-and-css/