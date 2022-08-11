#!/bin/bash
# aus modules/speicher_rctxx/main.sh  modules/bezug_rctxx/speicher_main.sh machen
B=${0/wr_/bezug_}
B=${B/main.sh/wr_main.sh}
$B

