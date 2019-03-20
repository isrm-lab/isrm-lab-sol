# comenzi gnuplot pt graficul Throughput_11b

```bash
gnuplot> Throughput_11b(x) = x*8 /(754 + (70 + x)*8/MCS)
gnuplot> set xrange [0:1500]
gnuplot> set yrange [0:7]
gnuplot> plot MCS=1, Throughput_11b(x) w l t '1Mbps', MCS=2, Throughput_11b(x) w l t '2Mbps', MCS=5.5, Throughput_11b(x) w l t '5.5Mbps', MCS=11 , Throughput_11b(x) w l t '11Mbps'
```

# comenzi gnuplot pt graficul Throughput_11g


```bash
gnuplot> Throughput_11g(x) = x*8 /(732 + (70 + x)*8/MCS)
gnuplot> set xrange [0:1500]
gnuplot> set yrange [0:7]
gnuplot> plot MCS=6, Throughput_11g(x) w l t '6Mbps', MCS=12, Throughput_11g(x) w l t '12Mbps', MCS=24, Throughput_11g(x) w l t '24Mbps', MCS=54 , Throughput_11g(x) w l t '54Mbps'
```

