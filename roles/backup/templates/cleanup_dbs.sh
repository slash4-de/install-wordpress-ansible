#!/bin/bash

BACKUP_DEST={{ backup_dbs_dest }}
LOG_FILE=/var/log/cleanup_dbs.log

echo "Starting cleanup procedure at `date`" >> $LOG_FILE
echo "====================================" >> $LOG_FILE
find $BACKUP_DEST -mtime +{{ cleanup_dbs }} -exec rm {} \; >> $LOG_FILE

if [ $? -ne 0 ]; then
echo "Cleanup Failed" >> $LOG_FILE
echo "=============" >> $LOG_FILE
else
echo "Cleanup has been done succefully" >> $LOG_FILE
echo "================================" >> $LOG_FILE
fi





