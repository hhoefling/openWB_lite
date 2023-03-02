#!/bin/bash
# aus modules/speicher_rctxx/info.sh  modules/bezug_rctxx/speicher_info.sh machen
B=${0/speicher_/bezug_}
B=${B/info.sh/speicher_info.sh}
$B

