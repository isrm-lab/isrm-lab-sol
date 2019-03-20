# Rulare exemplu tcl

```bash
student@isrm-vm:~/isrm-lab-sol/lab-01$ tclsh8.5 ex-tcl.tcl 
k < 5, pow = 1.0
k < 5, pow = 1120.0
k < 5, pow = 1254400.0
k < 5, pow = 1404928000.0
k < 5, pow = 1573519360000.0
k >= 5, mod = 0
k >= 5, mod = 4
k >= 5, mod = 0
k >= 5, mod = 0
k >= 5, mod = 4
```

# Rulare exemplu simplu ns:

```bash
student@isrm-vm:~/isrm-lab-sol/lab-01$ ns ns-simple.tcl 
CBR packet size = 1000
CBR interval = 0.0080000000000000002

# sa observam ce trace-uri obtinem:
student@isrm-vm:~/isrm-lab-sol/lab-01$ ls -l
total 3888
-rw-rw-r-- 1 student student     360 Mar 20 20:09 ex-tcl.tcl
-rw-rw-r-- 1 student student    2116 Mar 20 20:12 ns-simple.tcl
-rw-rw-r-- 1 student student    2859 Mar 20 20:25 ns-simple-with-gnuplot.tcl
-rw-rw-r-- 1 student student 2825893 Mar 20 20:25 out.nam
-rw-rw-r-- 1 student student     692 Mar 20 20:25 README.md
-rw-rw-r-- 1 student student 1137885 Mar 20 20:25 simple.tr
```

# Rulare exemplu simplu ns care traseaza si grafic

```bash
student@isrm-vm:~/isrm-lab-sol/lab-01$ ns ./ns-simple-with-gnuplot.tcl 
CBR packet size = 1000
CBR interval = 0.0080000000000000002
student@isrm-vm:~/isrm-lab-sol/lab-01$ ls -l
total 20
-rw-rw-r-- 1 student student  360 Mar 20 20:09 ex-tcl.tcl
-rw-rw-r-- 1 student student 2116 Mar 20 20:12 ns-simple.tcl
-rw-rw-r-- 1 student student 2859 Mar 20 20:25 ns-simple-with-gnuplot.tcl
-rw-rw-r-- 1 student student 2469 Mar 20 20:26 out.tr
-rw-rw-r-- 1 student student 1106 Mar 20 20:26 README.md
```
