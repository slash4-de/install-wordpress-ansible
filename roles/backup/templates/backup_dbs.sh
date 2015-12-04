#!/bin/bash

TIMESTAMP=$(date +"%Y-%m-%d")
BACKUP_DEST={{ backup_dbs_dest }}
LOG_FILE=/var/log/backup_dbs.log

echo "Starting Backup procedure at `date`" >> $LOG_FILE
echo "===================================" >> $LOG_FILE

mysqldump --all-databases --single-transaction | gzip -9 > $BACKUP_DEST/bkp_dbs-$TIMESTAMP.sql.gz

if [ $? -ne 0 ]; then
	echo "Backup Failed" >> $LOG_FILE
	echo "=============" >> $LOG_FILE
else
	echo "Backup has been taken succefully" >> $LOG_FILE
	echo "================================" >> $LOG_FILE
fi





