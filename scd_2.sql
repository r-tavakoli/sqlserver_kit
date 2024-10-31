

---------------------
--part 1
---------------------

--creating tables (source, target and log)
drop table if exists #rtn_source
create table #rtn_source
(
	id int,
	_name varchar(50),
	created_on datetime default(getdate()),
	modified_on datetime
)

drop table if exists #logs
create table #logs
(
	last_modified_on datetime
)

drop table if exists #rtn_target
create table #rtn_target
(
	id int,
	_name varchar(50),
	created_on datetime,
	modified_on datetime,
	started_on datetime,
	ended_on datetime,
	is_active bit
)

--insert new records
insert into #rtn_source(id, _name, modified_on)
values
(1, 'test_1', getdate()),
(2, 'test_2', getdate())

--affecting new rows on target table (merge)
insert into #rtn_target (id, _name, created_on, modified_on, started_on, ended_on, is_active)
select id, _name, created_on, modified_on, started_on, ended_on, 0 
from
	(
		merge #rtn_target as trg
		using #rtn_source as src
		on 
			src.id = trg.id
 
		-- For Inserts
		when not matched by target then
			insert (id, _name, created_on, modified_on, started_on, ended_on, is_active) 
			values (src.id, src._name, src.created_on, src.modified_on, getdate(), null, 1)
    
		-- For Updates
		when matched and trg.ended_on is null then
			update
			set 
				trg._name = src._name,
				trg.modified_on = src.modified_on,
				trg.ended_on = null,
				trg.is_active = 1

		--For Outputs
		output 
			$action as _action,
			deleted.* --previous record which will not be active anymore
	) as sc
where sc._action = 'update'

--check data
select * from #rtn_source
select * from #rtn_target

---------------------
--part 2
---------------------
--update source
update #rtn_source
set _name='test_udated_1', modified_on=getdate()
where id=2

--affecting new rows on target table (merge)
insert into #rtn_target (id, _name, created_on, modified_on, started_on, ended_on, is_active)
select id, _name, created_on, modified_on, started_on, getdate(), 0 
from
	(
		merge #rtn_target as trg
		using #rtn_source as src
		on 
			src.id = trg.id
 
		-- For Inserts
		when not matched by target then
			insert (id, _name, created_on, modified_on, started_on, ended_on, is_active) 
			values (src.id, src._name, src.created_on, src.modified_on, getdate(), null, 1)
    
		-- For Updates
		when matched and trg.ended_on is null then
			update
			set 
				trg._name = src._name,
				trg.modified_on = src.modified_on,
				trg.ended_on = null,
				trg.is_active = 1

		--For Outputs
		output 
			$action as _action,
			deleted.* --previous record which will not be active anymore
	) as sc
where sc._action = 'update'

--check data
select * from #rtn_source
select * from #rtn_target