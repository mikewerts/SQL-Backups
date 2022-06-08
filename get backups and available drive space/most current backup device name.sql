use msdb

select a.server_name, a.database_name, --a.name, 
(cast([software_major_version] as nvarchar) + '.' + cast([software_minor_version] as nvarchar) 
 + '.' + cast([software_build_version] as nvarchar)) as 'Version Number',

a.[backup_finish_date] as 'Most Recent Backup', --(cast(convert(decimal, (a.backup_size/1024)) as numeric(8,4))),
convert(decimal, (a.backup_size/(POWER(1024,2)))) as 'Backup MB',
-- a.recovery_model, 
case when b.device_type = 2 then 'Disk'
when b.device_type = 5 then 'Tape'
when b.device_type = 7 then 'Virtual device'
when b.device_type = 105 then 'permanent backup device'
else
NULL
end as 'Backup Type'
,
case when b.physical_device_name like '%{%}%' then 'Unknown Virtual Device'
when (b.device_type = 2 and b.physical_device_name not like '\\%') 
then 'Local Disk'
when (b.physical_device_name like '%SQL' or b.physical_device_name like '%\\me-datadomain01\%')  then 'Avamar'
else 'other'
end as 'Device Backup Type'
,

b.physical_device_name
--@Drive1,
--@MB_free1,
--@Drive2,
--@MB_free2,
--@Drive3,
--@MB_free3,
--@Drive4,
--@MB_free4

from msdb.dbo.backupset a join msdb.dbo.backupmediafamily b
  on a.media_set_id = b.media_set_id
--where (a.[database_name] not in ('master','msdb','model'))
--group by 
-- a.server_name, a.database_name, [software_major_version], [software_minor_version], [software_build_version], a.backup_size, b.physical_device_name
 
 join
 (
 select 

database_name, max([backup_finish_date]) as 'Most_Recent_Full_Backup'
FROM [dbo].[backupset]
where --recovery_model = 'FULL' and 
Type = 'D'
group by database_name
 ) as a1

 on a1.database_name = a.database_name

join
 (
  select max([backup_set_id]) as [backup_set_id], database_name from msdb.dbo.backupset
 group by database_name 
 ) as a2
 on a2.backup_set_id = a.backup_set_id
 
 where (a.[database_name] not in ('master','msdb','model'))
  and b.family_sequence_number = 1

 -- order by @@servername
  order by a.server_name