#!/bin/sh
#set -x
cd /home; 
for a in *; 
	do echo ;
	echo "Doing" $a "'s mail";
	maildirmake /home/$a/Maildir
	~simon/bin/perfect-convert.pl /home/$a/Maildir < /var/spool/mail/$a
	cd /home/$a/mail;
	pwd
	for directories in *; do
		#echo "doing " /$directories "directory";
		echo "creating" $directories " in ~/Maildir"
		maildirmake /home/$a/Maildir/.$directories
		#echo "Injecting messages";
		~simon/bin/perfect-convert.pl /home/$a/Maildir/.$directories < /home/$a/mail/$directories
	done;
done
