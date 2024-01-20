#!/bin/bash
# aus modules/wr_rctxx/info.sh  modules/bezug_rctxx/wr_info.sh machen
B=${0/wr_/bezug_}
B=${B/info.sh/wr_info.sh}
. $B
