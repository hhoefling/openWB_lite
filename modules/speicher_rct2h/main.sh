#!/bin/bash
# aus modules/speicher_rctxx/main.sh  modules/bezug_rctxx/speicher_main.sh machen
B=${0/speicher_/bezug_}
B=${B/main.sh/speicher_main.sh}
[ ! -r $B  ] && exit 0
$B

