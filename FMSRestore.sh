#!/bin/bash
#
# FileMaker Backups Restore for Testing Server 
# written by adimicoli@hotmail.com - Jan. 2018
# NOTE: this must be set on a cron job under root account.
#
FMADMIN=/Volumes/Macintosh\ HD/Library/FileMaker\ Server/Database\ Server/bin/fmsadmin
FMSUSER=user
FMSPASSWORD=xxxxxxxxxxxxxxx
BACKUPFOLDER="/Volumes/Backups/Nightly\ Backup"
LATESTFOLDER="Nightly\ Backup_"$(date -v-1d "+%Y-%m-%d")"_2000"
BACKUPPATH="/Volumes/Backups/Nightly Backup"
LATESTPATH="Nightly Backup_"$(date -v-1d "+%Y-%m-%d")"_2000"
DATABASEPATH=/Volumes/Macintosh\ HD/Library/FileMaker\ Server/Data/Databases/
LOG=FMSRestore.log
RECIPIENT="adimicoli@hotmail.com"

# Send Logs function
function sendLog {
    mail -s "FileMaker Testing Server Restore" $RECIPIENT < $LOG
}

# Clean up old backups and logs
rm -rf "$BACKUPPATH"/*
echo > $LOG

# Close all databases
 "$FMADMIN" close -y -u $FMSUSER -p $FMSPASSWORD
if [ $? -eq 0 ] ; then
    echo "Databases have been closed correctely" | tee -a $LOG
else
    echo "Databases closing failed, Please investigate!!!" | tee -a $LOG
    sendLog && exit
fi

# Remove databases
"$FMADMIN" remove -y -u $FMSUSER -p $FMSPASSWORD
if [ $? -eq 0 ] ; then
    echo "Databases have been removed correctely" | tee -a $LOG
else
    echo "Databases removing failed, Please investigate!!!" | tee -a $LOG
#    sendLog && exit
fi

if [ "$1" == "--fromS3" ]; then
BACKUPFOLDER="/Users/user/anyFolder/Restore\ FileMaker\ 15\ Live"
fi

# Import databases from FM Live server
scp -r user@192.168.1.XX:"$BACKUPFOLDER/$LATESTFOLDER" "$BACKUPPATH"/"$LATESTPATH"
if [ $? -eq 0 ] ; then
    echo "Databases have been imported correctely" | tee -a $LOG
else
    echo "Databases importing failed, Please investigate!!!" | tee -a $LOG
    sendLog && exit
fi

# Copy databases from backup forder to FM folder and set right permissions
cp -rv "$BACKUPPATH"/"$LATESTPATH"/Databases/ "$DATABASEPATH"
if [ $? -eq 0 ] ; then
    echo "Databases have been copied correctely" | tee -a $LOG
else
    echo "Databases copying failed, Please investigate!!!" | tee -a $LOG
    sendLog && exit
fi
chown -R fmserver "$DATABASEPATH"

# Open databases
"$FMADMIN" open -y -u $FMSUSER -p $FMSPASSWORD
if [ $? -eq 0 ] ; then
   echo "Databases have been opened correctely" | tee -a $LOG
else
    echo "Databases opening failed, Please investigate!!!" | tee -a $LOG
    sendLog && exit
fi

# Send logs 
sendLog
