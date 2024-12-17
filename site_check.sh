#!/bin/bash
set -e

abbr=$1
if [ -z "$1" ]; then
	echo "Enter a valid site name"
	exit 1
fi
DB=$(/usr/bin/sqlite3 $HOME/ctms.db "select dbhost from site where abbr='$abbr'")
if [ -z "$DB" ]; then
    echo "Site does not exist"
    exit 1
fi
if [ "$DB" == "localhost" ]; then
	DB="db"
fi
SERVER=$(/usr/bin/sqlite3 $HOME/ctms.db "select server from site where abbr='$abbr'")
if [ "$SERVER" == "" ]; then
	SERVER="us"
fi

echo $DB $SERVER-dep
