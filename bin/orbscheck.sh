#!/bin/sh
        for d 
	in `host -t ns relays.orbs.org | cut -f4 -d" " `
	    do		        echo -n $d
			        host -t soa relays.orbs.org $d | grep serial | cut -f1 -d\;
				        done
					
