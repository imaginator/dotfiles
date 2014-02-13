#!/bin/sh
#must have imagemagick installed for the import command to work
export DISPLAY=127.0.0.1:0.0
import -window root /tmp/screen-from-`echo $HOSTNAME`.jpeg        
mogrify -geometry 320x180 /tmp/screen-from-`echo $HOSTNAME`.jpeg
chmod a+rx /tmp/screen-from-`echo $HOSTNAME`.jpeg
scp -a /tmp/screen-from-`echo $HOSTNAME`.jpeg simon@zeus.imaginator.com:public_html/images
rm /tmp/screen-from-`echo $HOSTNAME`.jpeg


