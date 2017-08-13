#!/bin/bash
# this will be run every week by crontab
logfile="/esgda/postgres_backup/pgsql_backup.log"
backup_dir="/esgda/postgres_backup"
touch $logfile
databases=`psql -h localhost -U postgres -q -c "\l" | sed -n 4,/\eof/p | grep -v rows\) | grep -v template | awk {'if($1!="|" || S1!="") print $1'}`

echo "Starting backup of databases " >> $logfile
for i in $databases; do
        dateinfo=`date '+%Y-%m-%d %H:%M:%S'`
        timeslot=`date '+%Y%m%d%H%M'`
        #/usr/bin/vacuumdb -z -h localhost -U postgres $i >/dev/null 2>&1
        /usr/bin/pg_dump -U postgres -F c -b $i -h localhost -f $backup_dir/$i-database-$timeslot.sql
        tar -czf $backup_dir/$i-database-$timeslot.tar $backup_dir/$i-database-$timeslot.sql
        rm $backup_dir/$i-database-$timeslot.sql
        echo "Backup and Vacuum complete on $dateinfo for database: $i " >> $logfile
done
echo "Done backup of databases " >> $logfile

#tail -15 $logfile | mailx dxi@qti.qualcomm.com
