#!/bin/sh

echo "#UDP
#nn 1dn  1up  down  mix  uplink" > 0.out
echo "#TCP 
#nn 1dn  1up  down  mix  uplink" > 1.out


for proto in 0 1; do 
    for nn in $(seq 3 2 21); do
	echo -n "$nn "
	for scr in 1dn.tcl  1up.tcl  down.tcl  mix.tcl  uplink.tcl; do 
	    thr=$(ns $scr -run_tcp $proto -nn $nn -packetSize 1460 -sendingRate 7Mbps| grep Throughput | awk '{s+=$3} END{print s}')
	    echo -n "$thr "
	done
	echo ""
    done >> $proto.out
done


