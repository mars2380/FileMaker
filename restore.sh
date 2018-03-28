#!/bin/bash
#
# FileMaker Backups Restore for Testing Server
# written by adimicoli@hotmail.com - Feb. 2018
# NOTE gen root SSH key on FM Live server
# NOTE set root account SSH key on FM Live Backup server
# NOTE Install this script on Filemaker Server Live.

BACKUPPATH="/Users/user/anyFolder/Restore FileMaker 15 Live"
CBBPATH="/Applications/CloudBerry Backup.app/Contents/MacOS/cbb"
RESTOREBACKUPPLAN="Restore FileMaker Live Daily"
PLANID=$(find /opt/local/CloudBerry\ Backup/plans/ -type f -mtime -1 | awk -F'[}{]' '{print $2}')

# script must be run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   echo "Run 'sudo su -' "
   exit
fi

# Clean up old backups and logs
rm -r "$BACKUPPATH"/*
### echo > $LOG

# Run Restore backups plan
"${CBBPATH}" plan -r "${RESTOREBACKUPPLAN}"
if [ $? != 0 ] ; then
   echo "Restore Databases Plan Failed. Please investigate!!!"
fi

# Check restore process if running
while [ ! -z "$(ps aux | grep -v grep | grep $PLANID)" ]; do 

sleep 10
echo "Restore running"

done

# Run restore database on Backup server
echo Script running on FileMaker testing Server
ssh -t root@192.168.1.XX "sudo bash /Users/user/FMSRestore.sh --fromS3"
