#!/bin/bash

function parse_trace () { # $1 = ns2 .tr file 
    sent_agt=$(grep AGT $1 |grep ^s |grep cbr| wc -l)
    sent_mac=$(grep MAC $1 |grep ^s |grep cbr| wc -l)
    recv_agt=$(grep AGT $1 |grep ^r |grep cbr| wc -l)
    recv_mac=$(grep MAC $1 |grep ^r |grep cbr| wc -l)
    col_cbr=$(grep COL $1 |grep ^d |grep cbr| wc -l)
    col_rts=$(grep COL $1 |grep ^d |grep RTS| wc -l)
    echo  "$sent_agt $recv_agt $col_cbr $sent_mac $recv_mac $col_rts"
}


#out=$0.$$.out  
out=cwsim.out  

echo "#sz cw sent_agt recv_agt col_cbr sent_mac recv_mac col_rts" > $out 
for sz in 4 6 7 20 40; do 
    for cw in 3 7 15 31 63 127 255 511 1023 2047 4095; do 
        /opt/ns/bin/ns ./cwsim.tcl -ns $sz -nr $sz -cwmin $cw -cwmax $cw
        stats=$(parse_trace cw.tr)
        echo  "$sz $cw $stats" >> $out
    done
    echo "" >> $out
    echo "" >> $out
    /opt/ns/bin/ns ./cwsim.tcl -ns $sz -nr $sz -cwmin 15 -cwmax 1023  # 802.11b standard 
    stats=$(parse_trace cw.tr)
    echo  "$sz 802.11 $stats" >> $out
    echo "" >> $out
    echo "" >> $out
done
