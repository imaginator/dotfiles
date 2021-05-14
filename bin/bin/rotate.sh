#!/bin/sh
jpegtran -rot -outfile /tmp/newimage.jpg "$1" "$2" 
cp /tmp/newimage.jpg "$2"
chmod a+rx "$2"

