#!/bin/bash
#!/bin/bash
# aus modules/wr_rctxx/main.sh  modules/bezug_rctxx/wr_main.sh machen
B=${0/wr_/bezug_}
B=${B/main.sh/wr_main.sh}
$B