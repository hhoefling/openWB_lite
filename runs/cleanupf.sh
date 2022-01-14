#!/bin/bash

# not needed
exit 0

#echo "tail $1"
ls $1 -l
echo "$(tail -2000 $1)" > $1
