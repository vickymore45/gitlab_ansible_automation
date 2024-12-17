#!/bin/bash

# parse command-line arguments
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -u|--mysql-user)
            MYSQL_USER="$2"
            shift # past argument
            shift # past value
            ;;
        -p|--mysql-pass)
            MYSQL_PASS="$2"
            shift # past argument
            shift # past value
            ;;
        -d|--mysql-db)
            MYSQL_DB="$2"
            shift # past argument
            shift # past value
            ;;
        -h|--remote-host)
            REMOTE_HOST="$2"
            shift # past argument
            shift # past value
            ;;
        *)  # unknown option
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

MYSQL_DB="tmp_"${MYSQL_DB//-}
echo $MYSQL_DB

# check if required arguments are provided
if [[ -z "$MYSQL_USER" ]] || [[ -z "$MYSQL_PASS" ]] || [[ -z "$MYSQL_DB" ]] || [[ -z "$REMOTE_HOST" ]]; then
    echo "Usage: $0 -u <mysql_user> -p <mysql_pass> -d <mysql_db> -h <remote_host>"
    exit 1
fi

# define other variables
BACKUP_NAME="$MYSQL_DB-$(date +%Y%m%d_%H%M%S).sql.gz"
LOCAL_BACKUP_DIR="/tmp"
REMOTE_BACKUP_DIR="/tmp/."
REMOTE_USER="user"

# create backup file
mysqldump -h<db-host> -u $MYSQL_USER -p$MYSQL_PASS --single-transaction $MYSQL_DB | gzip > $LOCAL_BACKUP_DIR/$BACKUP_NAME

# transfer backup file to remote server
scp $LOCAL_BACKUP_DIR/$BACKUP_NAME $REMOTE_USER@$REMOTE_HOST:$REMOTE_BACKUP_DIR

# create database if it doesn't exist
#ssh $REMOTE_HOST "mysql -u $MYSQL_USER -p$MYSQL_PASS -e 'CREATE DATABASE IF NOT EXISTS $MYSQL_DB'"

# import backup file on remote server
#ssh $REMOTE_HOST "gunzip -c $REMOTE_BACKUP_DIR/$BACKUP_NAME | mysql -u $MYSQL_USER -p$MYSQL_PASS $MYSQL_DB"

# delete local backup file
rm $LOCAL_BACKUP_DIR/$BACKUP_NAME
