for n in $(seq 2 1 20); do 
	echo -n "$n "; 
	ns  infra.tcl -run_tcp 1 -nn $n  -packetSize 1460 -sendingRate 7M | grep Through | tr '\.' ' ' | awk '$3=="up"{su+=$4} $3=="dn"{sd+=$4} END{print su, sd}'; 
done | tee col.1.out

