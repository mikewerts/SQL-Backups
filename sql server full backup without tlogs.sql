use msdb

select 

[database_name] ,max([backup_finish_date]) as 'Most Recent Full Backup'
FROM [dbo].[backupset]
where recovery_model = 'FULL' and Type = 'D'

and 

[database_name] not in
-- list of full backup databases with active transactional backups
(

SELECT 



b.[database_name] -- , datediff(dd,  b.[Most Recent Full Backup], getdate()) 

from (

select

    [database_name]
	--,(case when [database_name] in ('master','msdb','model') 
	--then 'System'
	--else 'User'
	--end ) as 'Database Type'
	--, Case	When b.Type = 'D' Then 'Full Backup'
	--			When b.Type = 'I' Then 'Differential Backup'
	--			When b.Type = 'L' Then 'Log Backup'
	--			Else 'File or filegroup or partial'
	--		End As [Backup Type]
	--,b.Recovery_Model
	,max([backup_finish_date]) as 'Most Recent Full Backup'
	
	
	
FROM [dbo].[backupset]
where recovery_model = 'FULL' and Type = 'D'
group by database_name) 
b 
-- as bufull

join 
(
select

    [database_name]
	--,(case when [database_name] in ('master','msdb','model') 
	--then 'System'
	--else 'User'
	--end ) as 'Database Type'
	--, Case	When b.Type = 'D' Then 'Full Backup'
	--			When b.Type = 'I' Then 'Differential Backup'
	--			When b.Type = 'L' Then 'Log Backup'
	--			Else 'File or filegroup or partial'
	--		End As [Backup Type]
	--,b.Recovery_Model
	,max([backup_finish_date]) as 'Most Recent Log Backup'
	
	
	
FROM [dbo].[backupset]
where recovery_model = 'FULL' and Type = 'L'
group by database_name

)

b1

on b.[database_name] = b1.[database_name]

where b.[database_name] not in ('master','msdb','model')
and b1.[Most Recent Log Backup] > b.[Most Recent Full Backup]
and datediff(dd, b.[Most Recent Full Backup], getdate()) < 7

)

group by database_name
--(select 
--backupset b1 on b1.database_name = b.database_name

---- only full backups mapped to 
--where b.recovery_model = 'FULL' and b.Type = 'D'

--and  b.[database_name] not in ('master','msdb','model')
-- INNER JOIN msdb.dbo.backupmediafamily ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id  


-- join [dbo].[backupset] b1 on b1.

-- where type in ('D', 'I') 
-- database_name not in ('master','msdb','model')

--group by database_name, recovery_model, type
--order by database_name