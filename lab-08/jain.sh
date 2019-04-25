out=$0.$$.out 
rlen=3
while [ $rlen -le 20 ]; do 
    #select the throughput obtained by each source
    ns ./cw-fair.tcl -rlen $rlen -cwmin 511 -cwmax 511 | grep "^Throughput-kbps" | awk '{print $2}' > $out 
    #compute the Jain fairness index for all sources
    jain=$(cat $out | awk '{s+=$1; s2+=($1*$1)} END{print s*s/s2/NR}')
    #compute the epsilon fairness index for all sources (worst/best)
    eps=$(cat $out | awk 'BEGIN{min=1e8} {if($1<min)min=$1; if($1>max)max=$1;} END{print min/max;}')
    echo $rlen $jain $eps
    rlen=$(($rlen + 1))
    rm $out ./cw-fair.tr 
done    
