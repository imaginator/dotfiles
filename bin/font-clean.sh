 #!/bin/sh
 #
 ## -------- convert upper to lower case ---------
 
 ls * | while read f
  do
    if [ -f $f ]; then
      if [ "$f" != "`echo \"$f\" | tr A-Z a-z`" ]; then
       #Note that 'This' will overwrite 'this'!
       mv -ifv "$f" "`echo \"$f\" | tr A-Z a-z`"
      fi
    fi
  done

 ## eof
