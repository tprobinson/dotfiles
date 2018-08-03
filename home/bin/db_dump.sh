#!/bin/bash
# shellcheck disable=SC2034
set -e -u

# Set all database details here. Prefixes can be anything as long as they match
PROD_URL=my_db.com
PROD_USER=username
PROD_DB=mydb
STAGE_URL=my_db_stage.com
STAGE_USER=username
STAGE_DB=mydb

# Set these to the prefixes of each database.
FROM=PROD
TO=STAGE

# Whether to backup each of the DBs before dump.
BACKUPS_DIR=backups
BACKUP_FROM=0
BACKUP_TO=1

# Internal variables
FROM_URL=$(eval "echo \$${FROM}_URL")
TO_URL=$(eval "echo \$${TO}_URL")
FROM_SHORTNAME="$(echo $FROM_URL | cut -d'.' -f1)"
TO_SHORTNAME="$(echo $TO_URL | cut -d'.' -f1)"

FROM_USER=$(eval "echo \$${FROM}_USER")
TO_USER=$(eval "echo \$${TO}_USER")

# Get passwords
read -s -p "Password for $FROM_SHORTNAME: " FROM_PASSWORD
echo
read -s -p "Password for $TO_SHORTNAME: " TO_PASSWORD
echo

if [ ! -z "$FROM_PASSWORD" ]; then
  FROM_PASSWORD="-p$FROM_PASSWORD"
fi

if [ ! -z "$TO_PASSWORD" ]; then
  TO_PASSWORD="-p$TO_PASSWORD"
fi


# Take backups
if [ ! -d "$BACKUPS_DIR" ]; then
  mkdir "$BACKUPS_DIR"
fi

if [ $BACKUP_FROM -eq 1 ]; then
  echo "Taking backup of $FROM_SHORTNAME..."
  BKP_NAME="${BACKUPS_DIR}/${FROM_SHORTNAME}-$(date '+%F-%H-%M-%S').sql.gz"
  mysqldump -h $FROM_URL -u $FROM_USER "$FROM_PASSWORD" $FROM_DB |\
    gzip > $BKP_NAME
  echo "Backup is at $BKP_NAME"
fi

if [ $BACKUP_TO -eq 1 ]; then
  echo "Taking backup of $TO_SHORTNAME..."
  BKP_NAME="${BACKUPS_DIR}/${TO_SHORTNAME}-$(date '+%F-%H-%M-%S').sql.gz"
  mysqldump -h $TO_URL -u $TO_USER "$TO_PASSWORD" $TO_DB |\
    gzip > $BKP_NAME
  echo "Backup is at $BKP_NAME"
fi

# Do the actual operation
echo
echo "Dumping $FROM_SHORTNAME into $TO_SHORTNAME..."

mysqldump -h $FROM_URL -u $FROM_USER "$FROM_PASSWORD" $FROM_DB |\
mysql -h $TO_URL -u $TO_USER "$TO_PASSWORD" $TO_DB
