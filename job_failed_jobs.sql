SELECT  j.[name],  
        s.step_name,  
        h.step_id,  
        h.step_name,  
        h.run_date,  
        h.run_time,
		STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(h.run_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 'run_time (HH:MM:SS)  ',
		run_duration,
		STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CAST(h.run_duration as varchar(8)), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':') 'run_duration (DD:HH:MM:SS)  ',
        h.sql_severity,  
        h.message,   
        h.server  
FROM    msdb.dbo.sysjobhistory h  
        INNER JOIN msdb.dbo.sysjobs j  
            ON h.job_id = j.job_id  
        INNER JOIN msdb.dbo.sysjobsteps s  
            ON j.job_id = s.job_id 
                AND h.step_id = s.step_id  
WHERE    h.run_status = 0 -- Failure  


