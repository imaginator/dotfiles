#!/bin/sh

trap ':' `seq 30`

stty -cbreak -ignbrk  -brkint  -ignpar -istrip -ixon  -ixoff -isig 

"$@" <&-

stty sane

