/*
--when were all the databases last backed up, and what is their recovery state?

with FULLBUs 
as (
    select d.name, max(b.backup_finish_date) as 'Last FULL Backup'
    from sys.databases d
        join msdb.dbo.backupset b
            on d.name = b.database_name
    where b.type = 'D'
    group by d.name
),

-- last LOG backup for FULL and BULK_LOGGED databases
LOGBUs
as (
    select d.name, max(b.backup_finish_date) as 'Last LOG Backup'
    from sys.databases d
        join msdb.dbo.backupset b
            on d.name = b.database_name
    where d.recovery_model_desc <> 'SIMPLE'
        and b.type = 'L'
    group by d.name
)

-- general overview of databases, recovery model, and what is filling the log, last FULL, last LOG
select d.name, d.state_desc, d.recovery_model_desc, d.log_reuse_wait_desc, f.[Last FULL Backup], l.[Last LOG Backup]
from sys.databases d
    left outer join FULLBUs f
        on d.name = f.name
    left outer join LOGBUs l
        on d.name = l.name
where d.name not in ('model', 'TempDB')
order by d.name

*/