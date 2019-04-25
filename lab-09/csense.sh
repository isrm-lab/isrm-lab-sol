#!/bin/sh 

stats ()
{
    fin=$1
    sent_a=$(grep AGT $fin | grep ^s |grep cbr | wc -l)
    recv_a=$(grep AGT $fin | grep ^r |grep cbr | wc -l)
    sent_m=$(grep MAC $fin | grep ^s |grep cbr | wc -l)
    col_cbr=$(grep COL $fin | grep ^d |grep cbr | wc -l )
    col_oth=$(grep COL $fin | grep ^d |grep -v cbr | wc -l )
    echo "$sent_a $recv_a $sent_m $col_cbr $col_oth"
}


echo "#RTS CS dist sent_a recv_a sent_m col_cbr col"
#           250         300        400            550

for dist in 100 200 300 1000; do 
    for cs in 3.65262e-10 1.76149e-10 5.57346e-11 1.55924e-11; do 
	thr=$(/opt/ns/bin/ns ./twoflows.tcl -RTSthresh 10000 -CSthresh $cs -dist $dist -sendingRate 2000Kbps | grep Throughput | awk '{s+=$2}END{print s}')
	echo -n "0 $cs $dist $thr "
	stats ./twoflows-1channel.tr
    done
    echo ""
    echo ""
done > twoflows.rtsn.out


for dist in 100 200 300 1000; do 
    for cs in 3.65262e-10 1.76149e-10 5.57346e-11 1.55924e-11; do 
	thr=$(/opt/ns/bin/ns ./twoflows.tcl -RTSthresh 1 -CSthresh $cs -dist $dist -sendingRate 2000Kbps | grep Throughput | awk '{s+=$2}END{print s}')
	echo -n "1 $cs $dist $thr "
	stats ./twoflows-1channel.tr
    done
    echo ""
    echo ""
done > twoflows.rtsy.out 
