#!/bin/bash
#
# FileMaker Backup Retention to AWS S3 
# written by adimicoli@hotmail.com - Sept. 2017
#
###################################################### 
# Set Life cicle in AWS S3 as follow:                #
# Weekly pool -  After 365 days from object creation #
# Monthly pool - After 365 days from object creation #
# Yearly pool - Never delete                         #
######################################################
# Set Cronjob as follow:                             #
# 00 00 * * 6 /Users/user/fm-cbb-reteintion.sh   #
# More info here                                     #
######################################################

# Backup plans name, change if needed
WEEKLYBACKUPPLAN="FileMaker 15 Live Nightly Weekly Retention"
MONTHLYBACKUPPLAN="FileMaker 15 Live Nightly Monthly Retention"
YEARLYBACKUPPLAN="FileMaker 15 Live Nightly Yearly Retention"

# Backups store path, change if needed
BACKUPSTORE="/Volumes/Backups/Nightly Backup/"

# variables not to be changed
CBBPATH="/Applications/CloudBerry Backup.app/Contents/MacOS/cbb"
TODAY=$(date +"%d")
LATEST=$(date -v-1d "+%Y-%m-%d")
DAY=$(date +%u)
LASTSAT=$(ncal | grep Sa | awk '{print $NF}')

# tmp to store downloaded files
TMPSTORE=/Volumes/Backups/Retention/
mkdir -p $TMPSTORE
chmod 777 $TMPSTORE

# clean tmp store
rm -r $TMPSTORE*

# copy LATEST backup to tempstore
### find "${BACKUPSTORE}" -name "*$LATEST*" -exec echo {} \; -exec cp -r {} $TMPSTORE \;
cp -r "$(find "${BACKUPSTORE}" -name "*$LATEST*" | head -1)" $TMPSTORE

#### Only Testing ####
# read -p "Press enter to continue 2"
# ls -la $TMPSTORE

# read -p "Press enter to continue 3"
# "${CBBPATH}" plan -r "${BACKUPPLAN}" ### only testing
#### Only Testing ####

if [ $DAY == 6 ]; then
     "${CBBPATH}" plan -r "${WEEKLYBACKUPPLAN}"
    if [ $TODAY == $LASTSAT ]; then
        "${CBBPATH}" plan -r "${MONTHLYBACKUPPLAN}"
    	"${CBBPATH}" plan -r "${YEARLYBACKUPPLAN}"
    fi
fi

### TODO
### curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
### unzip awscli-bundle.zip
### sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
### aws configure
