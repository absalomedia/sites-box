#!/bin/bash
 
USER="root"
PASSWORD="root"
 
databases=`ls -1 backupdbs.*.sql`
 
for db in $databases; do
        echo "Importing $db ..."
        mysql -u $USER -p$PASSWORD < $db
done