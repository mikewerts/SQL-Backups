declare @num_backups int
set  @num_backups =   @@rowcount;
with c as(




SELECT 
									 database_name
									-- database_guid
									-- ,backup_set_id
									 ,	convert (varchar, MAX (a.[backup_finish_date]), 101) as 'backup_date'
									,convert (varchar, MAX (a.[backup_finish_date]), 108) as 'backup_time'
									--,convert(decimal, (a.backup_size)/(POWER(1024,2))) as 'backup_size_MB'
									from msdb.dbo.backupset a 
										join msdb.dbo.backupmediafamily b
									  on a.media_set_id = b.media_set_id
									   --where b.device_type = 2 
									group by database_name --, backup_set_id --, a.backup_size


 
)




select  top(@num_backups) @@servername, a.DATABASE_NAME, c.backup_date, c.backup_time, b.physical_device_name,
convert(decimal, (a.backup_size)/(POWER(1024,2))) as 'backup_size_MB' 
from msdb.dbo.backupset a join c on c.database_name = a.database_name
join msdb.dbo.backupmediafamily b
									  on a.media_set_id = b.media_set_id
									  -- where b.device_type = 2 

order by backup_start_date desc

print @num_backups;


--select d.database_name, c.backup_date, c.backup_time,
--									convert(decimal, ((d.backup_size)/(POWER(1024,2)))) as 'backup_size_MB'

--									from [ME-BEACNSQL1].msdb.dbo.backupset d



--select * from [ME-BEACNSQL1].msdb.dbo.backupset a  

/*


									select distinct d.database_name, c.backup_date, c.backup_time,
									convert(decimal, ((d.backup_size)/(POWER(1024,2)))) as 'backup_size_MB'

									from [ME-BEACNSQL1].msdb.dbo.backupset d
									--join c on d.database_guid = c.database_guid
									join [ME-BEACNSQL1].msdb.dbo.backupmediafamily a
									  on d.media_set_id = a.media_set_id
									  cross apply
									  (select database_guid
									 ,	convert (varchar, MAX (a.[backup_finish_date]), 101) as 'backup_date'
									,convert (varchar, MAX (a.[backup_finish_date]), 108) as 'backup_time'
									
									from [ME-BEACNSQL1].msdb.dbo.backupset a 
										join [ME-BEACNSQL1].msdb.dbo.backupmediafamily b
									  on a.media_set_id = b.media_set_id
									   where b.device_type = 2 
									   and a.database_guid = d.database_guid
									group by a.database_guid

									  ) as c
									  where a.device_type = 2

*/


									--,convert(decimal, (MAX (a.backup_size)/(POWER(1024,2)))) 
									--from [ME-BEACNSQL1].msdb.dbo.backupset a 
									 
									
									--cross apply
									--(select 
									--,MAX(b.physical_device_name)

									--from [ME-BEACNSQL1].msdb.dbo.backupset a 
									
									--join [ME-BEACNSQL1].msdb.dbo.backupmediafamily b
									--  on a.media_set_id = b.media_set_id
									--   where b.device_type = 2
									--   group by a.database_name --, a.backup_size
									
									 
									  
									 -- where backup_start_date between convert(varchar, getdate() -7, 112)
									 --and convert(varchar, getdate(), 112)
									 

									 --from  backupset a

									 --select * from [ME-BEACNSQL1].msdb.sys.databases
									 --select * from [ME-BEACNSQL1].msdb.dbo.backupset