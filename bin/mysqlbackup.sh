#!/bin/sh

#
#  Directory we store the dumps in.
#
BACKUP_DIR=~/db-backups

#
#  Make sure output directory exists.
#
if [ ! -d $BACKUP_DIR ]; then
    mkdir -p $BACKUP_DIR
fi

#
#  Rotate backups
#
for j in  6 5 4 3 2 1 0; do
    for i in $BACKUP_DIR/*.gz.$j; do 
	if [ -e $i ]; then
	    mv $i ${i/.$j/}.`expr $j + 1 `;
	fi
    done
done


#
# Create new backups
#
for i in /var/lib/mysql/*/; do
    dbname=`basename $i`
    mysqldump --user=root $dbname |  \
	gzip > $BACKUP_DIR/$dbname.gz.0
done

