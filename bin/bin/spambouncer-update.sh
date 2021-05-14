#!/bin/sh
set -x 
rm /tmp/sb-new.tar
rm /tmp/sb-new.tar.Z
cd /tmp && wget http://www.spambouncer.org/sb-new.tar.Z && cd ~simon/bin/spambouncer && uncompress /tmp/sb-new.tar.Z && tar xfv /tmp/sb-new.tar && chmod -R a+rx ~simon/bin/spambouncer

