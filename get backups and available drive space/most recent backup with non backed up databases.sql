


	begin transaction
	
	;with backup_set as (					
						
									 SELECT server_name = 'ME-BEACNSQL1'
									 , a.database_name 
									,convert (varchar, a.[backup_finish_date], 101) as 'finish_date'
									,convert (varchar, a.[backup_finish_date], 108) as 'finish_time'
									,convert(decimal, (a.backup_size/(POWER(1024,2)))) as 'backup_size'
									,b.physical_device_name 

									from [ME-BEACNSQL1].msdb.dbo.backupset a join [ME-BEACNSQL1].msdb.dbo.backupmediafamily b
									  on a.media_set_id = b.media_set_id

									  where backup_start_date between convert(varchar, getdate() -6, 112)
									 
									 and convert(varchar, getdate(), 112)
									 and b.device_type = 2 
									 )
	

	insert into Backup_Status_new 
	select 'ME-BEACNSQL1', d.name,  backup_set.finish_date, backup_set.finish_time, backup_set.backup_size, backup_set.physical_device_name	
	from   [ME-BEACNSQL1].master.dbo.sysdatabases d
	left join backup_set on backup_set.database_name = d.name 
	where d.name <> 'tempdb' 
	
	rollback
	--select * from [ME-BEACNSQL1].master.dbo.sysdatabases
	