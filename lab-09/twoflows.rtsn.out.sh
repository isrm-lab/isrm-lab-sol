CS  - puterea la marginea CS
bps - debit 
x   - distanta in metri
udp - trimis, primit de agenti
mac - trimise de mac
COL - coliziuni la date 
    - coliziuni non-date (ACK, RTS)

AD=412m BD=223m  P(200m)=8.91e-10W=-60dBm P(223m)=5.76e-10W=-62dBm
       CS         x   bps    UDP  UDP mac COL  
250m 3.65262e-10 100 243904  1709 103 995  892 0  coliziuni BD=223m
300m 1.76149e-10 100 267584  1713 113 1023 910 0  coliziuni BD=223m
400m 5.57346e-11 100 265216  1709 112 1002 890 0  coliziuni BD=223m
500m 1.55924e-11 100 1783104 1734 753  753   0 0  A,D in CS


AD=447m BD=282m
250m 3.65262e-10 200 1752320 1727 740 1203 463 0  coliziuni doar de ACK (mic, scapa mai des)[1], inechitate [2]
300m 1.76149e-10 200 291264  1722 123 1014 891 0  coliziuni BD<300m, similar cu x=100m 
400m 5.57346e-11 200 298368  1715 126 1005 879 0  coliziuni BD<400m, similar cu x=100m  
500m 1.55924e-11 200 1757056 1743 742  742   0 0  A,D in CS 


AD=500m BD=360m P(360)=8.49e-11W=-71dBm
250m 3.65262e-10 300 3495168 1703 1476 1476 0 0   captura BD > 355.7
300m 1.76149e-10 300 3490432 1736 1474 1474 0 0   captura BD > 355.7
400m 5.57346e-11 300 1749952 1707  739 1179 440 0 coliziuni ACK 300 < 355.7, capturi date 360>355.7  
500m 1.55924e-11 300 1754688 1713  741  741 0 0   A, D in CS => terminal expus [3]


[1] 
# găsește prima coliziune: timpul t, pachetul pi
read t pi <<< $(cat twoflows-1channel.tr | grep COL | head -n1 | awk '{print $3, $47}')
# printează evenimenlele care duc la coliziune
cat twoflows-1channel.tr | grep MAC |   awk -v t=$t -v pi=$pi '$47==pi{p=1}  (p==1)&& ($3 <= t) {print $0}'
# se observă ACK de la cealaltă conversație chiar înainte de COLiziune

[2] rulați de mai multe ori, comparați throughput la cele două fluxuri 

[3] cercul de CS mare de 500m nu permite conversațiile simultane A->B și C->D care ar funcționa cu un CS mai mic (250m sau 300m)

