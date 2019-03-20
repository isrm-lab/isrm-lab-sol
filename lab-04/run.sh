#!/bin/bash

#
# acest script creează 2 fișiere de date: thr și pdr cu date în funcție de distanță (coloana 1)
# thr conține pentru fiecare distanță debitul/throughput în Mbps obținut pentru tries=1,4,10 de TCP și UDP
# pdr conține pentru fiecare distanță numărul de pachete primite/trimise de MAC, și unice primite/trimise de MAC.
#     fiecare grup de 4 numere este repetat pentru tries=1,4,10
#
# după rularea acestui script se rulează 'gnuplot shadow2.plot.txt' pentru a obține toate graficele
#

d=50
echo "# dist UDP0 TCP0 UDP4 TCP4 UDP10 TCP10" > thr
echo "# dist (macrecv macsent unqsent unqrecv)0 (...)4 (...)10" > pdr
while [ $d -le 250 ]; do
    echo "$d "
    echo -n "$d " >> thr
    echo -n "$d " >> pdr
    tries=0
    for tries in 1 4 10; do
	ns ./shadow2.tcl -tries $tries -dist $d | grep Throughput | awk '{udp=$3; getline; printf("%5.3f %5.3f ", udp/1e6, $3/1e6);}' >> thr
	macsent=$(cat shadow2.tr  | grep MAC | grep '^s' | grep cbr | awk '$3 <= 25.0' |   wc -l)
	macrecv=$(cat shadow2.tr  | grep MAC | grep '^r' | grep cbr | awk '$3 <= 25.0' |   wc -l)
	unqsent=$(cat shadow2.tr  | grep MAC | grep '^s' | grep cbr | awk '$3 <= 25.0 {print $47}' | uniq -c| wc -l)
	unqrecv=$(cat shadow2.tr  | grep MAC | grep '^r' | grep cbr | awk '$3 <= 25.0 {print $47}' | uniq -c| wc -l)
	echo -n "$macrecv $macsent $unqsent $unqrecv " >> pdr
	tries=$(($tries+1))
    done
    echo "" >> thr
    echo "" >> pdr
    d=$(($d+10))
done
