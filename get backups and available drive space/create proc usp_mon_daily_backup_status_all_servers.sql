USE [master]
GO

/****** Object:  StoredProcedure [dbo].[usp_mon_backup_status_of_all_servers_new]    Script Date: 5/12/2017 1:24:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




alter  procedure [dbo].[usp_mon_daily_backup_status_all_servers]
                              as
                              begin
                              declare @sql nvarchar(4000)
                              declare @return_code int
                              declare @last_backup_date datetime
                              declare @server_name sysname

                              
							  
							  declare servers_cursor cursor for
                              select srvname from master.dbo.sysservers
							  where isremote = 0
                              order by srvname

							  
							  delete from Backup_Status_daily


							  open servers_cursor

                              fetch servers_cursor into @server_name


                              while @@fetch_status = 0
                              begin


                                      set @sql = ''

									  set @sql = 'with backup_set as (					
						
									 SELECT server_name = '''+ @server_name +'''
									 , a.database_name
									,convert (varchar, a.[backup_finish_date], 101) as ''finish_date''
									,convert (varchar, a.[backup_finish_date], 108) as ''finish_time''
									,convert(decimal, (a.backup_size/(POWER(1024,2)))) as ''backup_size''
									,b.physical_device_name 

									from ['+ @server_name +'].msdb.dbo.backupset a join ['+ @server_name +'].msdb.dbo.backupmediafamily b
									  on a.media_set_id = b.media_set_id

									  where backup_start_date between convert(varchar, getdate() -1, 112)
									 
									 and convert(varchar, getdate(), 112)
									 and b.device_type = 2 
									 )
	

					insert into Backup_Status_daily
					select ''' + @server_name + ''',  d.name, convert (varchar, getdate(), 101),  backup_set.finish_date, backup_set.finish_time, backup_set.backup_size, backup_set.physical_device_name	
					from   ['+ @server_name +'].master.dbo.sysdatabases d
					left join backup_set on backup_set.database_name = d.name 
					where d.name <> ''tempdb'''

									--set @sql = 'insert into Backup_Status_new
									-- SELECT server_name = '''+ @server_name +'''
									-- , a.database_name 
									--,convert (varchar, a.[backup_finish_date], 101) 
									--,convert (varchar, a.[backup_finish_date], 108) 
									--,convert(decimal, (a.backup_size/(POWER(1024,2)))) 
									--,b.physical_device_name 

									--from ['+ @server_name +'].msdb.dbo.backupset a join ['+ @server_name +'].msdb.dbo.backupmediafamily b
									--  on a.media_set_id = b.media_set_id

									--  where backup_start_date between convert(varchar, getdate() -7, 112)
									-- and convert(varchar, getdate(), 112)
									-- and b.device_type = 2 '
									begin try
                                    exec sp_executesql @sql
									end try
									BEGIN CATCH  
										--print @server_name; 
										print 
										'Error:' 
										+ char(10) 
										+ 'Server ' + @server_name 
										+ char(10)
										+ 'Error Number ' + cast(ERROR_NUMBER() as nvarchar) 
										+ char(10)
										+ 'Error Message ' + ERROR_MESSAGE();	
										--+	'ErrorSeverity ' + cast(ERROR_SEVERITY() as nvarchar)    
										--+	'ErrorState ' + cast(ERROR_STATE() as nvarchar)   
 									--	+	'ErrorProcedure ' + cast(ERROR_PROCEDURE() as nvarchar)   
										--+	'ErrorLine ' + cast(ERROR_LINE() as nvarchar)    
																			 

										--SELECT  
										--@server_name,
											--ERROR_NUMBER() AS ErrorNumber  
											--,ERROR_SEVERITY() AS ErrorSeverity  
											--,ERROR_STATE() AS ErrorState  
											--,ERROR_PROCEDURE() AS ErrorProcedure  
											--,ERROR_LINE() AS ErrorLine  
											--,ERROR_MESSAGE() AS ErrorMessage;  
									END CATCH;  


									 --print @sql

                                      fetch servers_cursor into @server_name

									  --print @server_name

                              end

                              close servers_cursor

                              deallocate servers_cursor

                              end



GO


