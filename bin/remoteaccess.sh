while true
	echo "simon@bunker's password"
	read password
	do
	ssh -g -R 5000:localhost:22 bunker.imaginator.com < $password ;
	done
