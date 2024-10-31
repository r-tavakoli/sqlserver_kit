
declare @job_name nvarchar(max) = 'PowerETL_ExecuteIncrementalETL_Marketing_Shopping'
declare @job_owner nvarchar(max) = '';

with running_jobs as (
	select
		j.job_id,
		j.name as jobname,
		s.step_id as step_id,
		s.step_name as step_name,
		'in progress' as step_status,
		s.last_run_date as run_date, 
		s.last_run_time as run_time,
		((run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) / 60) as duration_in_minutes,
		j.description,
		s.subsystem,
		s.database_name,
		s.retry_attempts,
		s.retry_interval,
		s.last_run_duration,
		s.last_run_retries,
		s.last_run_date,
		s.last_run_time,
		h.message,
		1 as is_current_step
	from msdb.dbo.sysjobactivity ja 
	left join msdb.dbo.sysjobhistory h on ja.job_history_id = h.instance_id
	join msdb.dbo.sysjobs j on ja.job_id = j.job_id
	join msdb.dbo.sysjobsteps s on ja.job_id = s.job_id and isnull(ja.last_executed_step_id,0)+1 = s.step_id
	where
		ja.session_id in (select top 1 session_id from msdb.dbo.syssessions order by agent_start_date desc)
	and start_execution_date is not null
	and stop_execution_date is null
	and j.name=@job_name
)
select 
	j.job_id,
	j.name as jobname,
	s.step_id as step_id,
	s.step_name as step_name,
	case 
		when h.run_status=0 then 'failed'
		when h.run_status=1 then 'succeeded'
		when h.run_status=2 then 'retry'
		when h.run_status=3 then 'canceled'
		when h.run_status=4 then 'in progress'
	end step_status,
	h.run_date, 
	h.run_time,
	((run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) / 60) as duration_in_minutes,
	j.description,
	s.subsystem,
	s.database_name,
	s.retry_attempts,
	s.retry_interval,
	s.last_run_duration,
	s.last_run_retries,
	s.last_run_date,
	s.last_run_time,
	h.message,
	0 as is_current_step
from	
				msdb.dbo.sysjobs j 
inner join		msdb.dbo.sysjobsteps s		on j.job_id = s.job_id
inner join		msdb.dbo.sysjobhistory h	on s.job_id = h.job_id and s.step_id = h.step_id and h.step_id <> 0
where 
		j.enabled=1
	and j.name=@job_name --PowerETL_ExecuteIncrementalETL_MarketPlace_Seller_Rating
	and j.description like '%' + @job_owner + '%'

union

select 
	*
from running_jobs

order by 
	jobname, 
	run_date desc,
	step_id desc


/*


select * from msdb.dbo.sysjobactivity where job_id='F30A9B22-1103-4A57-8B2A-838F3384ED13'
--select * from msdb.dbo.sysjobhistory where job_id='F30A9B22-1103-4A57-8B2A-838F3384ED13' --and instance_id=15112323
select * from msdb.dbo.sysjobsteps where job_id='F30A9B22-1103-4A57-8B2A-838F3384ED13'

select
    ja.job_id,
    j.name as job_name,
    ja.start_execution_date,      
    isnull(last_executed_step_id,0)+1 as current_executed_step_id,
    js.step_name
from msdb.dbo.sysjobactivity ja 
left join msdb.dbo.sysjobhistory jh on ja.job_history_id = jh.instance_id
join msdb.dbo.sysjobs j on ja.job_id = j.job_id
join msdb.dbo.sysjobsteps js on ja.job_id = js.job_id and isnull(ja.last_executed_step_id,0)+1 = js.step_id
where
  ja.session_id in (
    select top 1 session_id from msdb.dbo.syssessions order by agent_start_date desc
  )
and start_execution_date is not null
and stop_execution_date is null
and j.name='PowerETL_ExecuteIncrementalETL_MarketPlace_Seller_Rating'


select * from msdb.dbo.syssessions --where session_id=25


*/