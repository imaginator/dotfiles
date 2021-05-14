#!/bin/bash

echo -n "$1: "
wget "http://finance.yahoo.com/d/quotes.csv?s=$1&f=sl1d1t1c1ohgv&e=.csv" -q -O - |awk -F, '{printf " Last: %s, Chg: %s(%3d%%), Open: %s, Hi: %s, Low: %s\n", $2, $5, ($5/($2-$5))*100, $6, $7, $8}'

