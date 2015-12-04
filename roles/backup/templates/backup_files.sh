#!/bin/bash

TIMESTAMP=$(date +"%Y-%m-%d")
BACKUP_DEST={{ backup_files_dest }}
BACKUP_LIST="{{ backup_files_list | join(" ") }}"
LOG_FILE=/var/log/backup_files.log

echo "Starting Backup procedure at `date`" >> $LOG_FILE
echo "===================================" >> $LOG_FILE

tar czf $BACKUP_DEST/bkp_files-$TIMESTAMP.tar.gz $BACKUP_LIST >> $LOG_FILE 2>&1

if [ $? -ne 0 ]; then
echo "Backup Failed" >> $LOG_FILE
echo "=============" >> $LOG_FILE
else
echo "Backup has been taken succefully" >> $LOG_FILE
echo "================================" >> $LOG_FILE
fi





