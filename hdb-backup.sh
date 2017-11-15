#!/bin/bash
# Original Author: @Trutane
# Ref: http://stackoverflow.com/q/3669121/138325
# Me: In this script was removed prompts(everything is hardcoded), exclusions added

DB_host="127.0.0.1"
DB_user="dbuser"
DB="dbname"

DB_pass="dbpass"
DIR=`date '+%Y-%m-%d_%H%M%S'`
test -d $DIR || mkdir -p $DIR
Exclude="archive archive15 archive16"

echo "Dumping tables into separate SQL command files for database '$DB' into dir=$DIR"

tbl_count=0

for t in $(mysql -NBA -h $DB_host -u $DB_user -p$DB_pass -D $DB -e 'show tables') 
do 
    if [[ " $Exclude " =~ .*\ $t\ .* ]]; then
        echo "Table: $DB.$t is exclusion"
    else
        echo "DUMPING TABLE: $DB.$t"
        mysqldump -h $DB_host -u $DB_user -p$DB_pass $DB $t | gzip > $DIR/$DB.$t.sql.gz
        tbl_count=$(( tbl_count + 1 ))
    fi
done

echo "$tbl_count tables dumped from database '$DB' into dir=$DIR"
