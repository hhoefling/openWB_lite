#!/bin/bash

if  (( "$1" == "-t" )) ; then
   echo -e "<table class="table"><thead><tr><th>Sekunden</th><th>Anzahl</th></tr></thead>\n"; 
   echo -e "<tbody>" 
   cat /var/log/openWB.log | egrep "Regulation loop needs ([[:digit:]]*)"  -o | cut -d" " -f 4 | sort -n | uniq  -c | sed -r 's/^[ ]*([0-9]+) ([0-9]+).*/<tr><td>\2<\/td><td>\1<\/td><\/tr>/'
  echo -e "</tbody></table>\n" 
else
   echo -e "| Sekunden | Anzahl |\n| ---: | --- |"; 
   cat /var/log/openWB.log | egrep "Regulation loop needs ([[:digit:]]*)"  -o | cut -d" " -f 4 | sort -n | uniq  -c | sed -r 's/^[ ]*([0-9]+) ([0-9]+).*/| \2 | \1 |/'
fi


