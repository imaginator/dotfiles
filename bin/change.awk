BEGIN { num=10000; }

/^uid:/ {
            homedir="/home/" $2;
        }

/^cn:/ {
            split($0,tmp,": ");
            name=tmp[2];
       }

/^telephonenumber:/ {
                                                split($0,tmp,": ");
                        tel=tmp[2];
                    }
/^l:/ {
                  split($0,tmp,": ");
          l=tmp[2];
      }

/^objectclass: person/ { 
                                                   print "loginshell: /bin/bash";
                           print "uidnumber: " num++;
                                                   print "gidnumber: 100";
                           print "homedir: " homedir;
                                                   print "gecos: " name ", " l ", " tel;
                           print $0; 
                           print "objectclass: account";
                           print "objectclass: posixaccount";
                           print "objectclass: top";
                           next;
                       }

    { print $0; }

