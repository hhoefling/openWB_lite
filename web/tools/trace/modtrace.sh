#!/bin/bash
input=$(echo $1) 
temp="${input#*ip=}"
ip="${temp%%&*}"
temp="${input#*start=}"
start="${temp%%&*}"
temp="${input#*len=}"
len="${temp%%&*}"
temp="${input#*fun=}"
fun="${temp%%&*}"
temp="${input#*id=}"
id="${temp%%&*}"
temp="${input#*dtyp=}"
dtyp="${temp%%&*}"

echo "<br/> parmeters parsed ip [$ip] ";
echo "<br/> start [$start] ";
echo "<br/> len [$len] ";
echo "<br/> id [$id] ";
echo "<br/> dtyp [$dtyp] ";
echo "<br/> fun [$fun] ";
echo "<br/> sudo python /var/www/html/openWB/web/tools/trace/trace.py $ip $start $len $id $dtyp $fun ";
sudo python /var/www/html/openWB/web/tools/trace/trace.py $ip $start $len $id $dtyp $fun 
