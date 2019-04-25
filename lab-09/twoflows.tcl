# VARIABLE PART

set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             4                          ;# number of mobilenodes
set val(rp)             NOAH                     ;# routing protocol
set val(x)      100
set val(y)      200
set val(start0) 0 
set val(start1) 0 
set val(stop) 5.0


if { $argc != 8} {
        puts "Wrong no. of cmdline args."
        puts "Usage: ns twoflows.tcl -RTSthresh <RTS_Threshold> -CSthresh <carrier-sense threshold> -dist <x> -sendingRate <rate>"
        exit 0
}


proc getopt {argc argv} {
        global val
        lappend optlist RTSthresh CSthresh dist sendingRate
 
        for {set i 0} {$i < $argc} {incr i} {
                set arg [lindex $argv $i]
                if {[string range $arg 0 0] != "-"} continue
 
                set name [string range $arg 1 end]
                set val($name) [lindex $argv [expr $i+1]]
	        puts "            set val($name) [lindex $argv [expr $i+1]]"
        }
}
getopt $argc $argv


Mac/802_11 set basicRate_	1Mb	;# basic sending rate
Mac/802_11 set dataRate_	2Mb	;# sending rate for data and control

#Mac/802_11 set RTSThreshold_		3000	;# no RTS/CTS 
#Mac/802_11 set RTSThreshold_		1	;# RTS/CTS
Mac/802_11 set RTSThreshold_		$val(RTSthresh)
Mac/802_11 set ShortRetryLimit_ 	7	;# Short Retry Limit 
Mac/802_11 set MaxShortRetryLimit_ 	7	;# Short Retry Limit 
Mac/802_11 set LongRetryLimit_ 		4	;# Long Retry Limit 
#Mac/802_11 set IsVariable_CWMax_	0	;# Variable Contention Window
						;# 0: False, 1: True
#Mac/802_11 set Variable_CWMax_		1023	;# Maximum Contention Window
#Mac/802_11 set CONThreshold_		0.5	;# Contention Threshold 
#Mac/802_11 set Shift_CWMax_		2	;# 


# Carrier sense threshold # all numbers for Pt=24dBm

#Phy/WirelessPhy set CSThresh_ 8.91754e-10	;# for 200m ~ -60.5 dBm 
#Phy/WirelessPhy set CSThresh_ 3.65262e-10	;# for 250m ~ -64.4 dBm 
#Phy/WirelessPhy set CSThresh_ 1.76149e-10	;# for 300m ~ -67.5 dBm
#Phy/WirelessPhy set CSThresh_ 5.57346e-11	;# for 400m ~ -72.5 dBm 
#Phy/WirelessPhy set CSThresh_ 1.55924e-11	;# for 550m ~ -78.1 dBm
Phy/WirelessPhy set CSThresh_ $val(CSthresh)

Phy/WirelessPhy set RXThresh_  3.65262e-10	;# for 250m, ns2 default

Phy/WirelessPhy set CPThresh_  10.0             ;# ns2 default  


# Transmit power (W)
#Phy/WirelessPhy set Pt_ 0.400              ;# 26 dBm
Phy/WirelessPhy set Pt_ 0.281838            ;# 24 dBm # ns-2 default
#Phy/WirelessPhy set Pt_ 0.031622777        ;# 15 dBm
#Phy/WirelessPhy set Pt_ 0.010              ;# 10 dBm
#Phy/WirelessPhy set Pt_ 0.005              ;# 7 dBm
#Phy/WirelessPhy set freq_ 2.4e+9           ; atenție, TwoRayGround folosește Friis sub 4*pi*hr*ht/lambda ~ 235m!  




# TRACE PART
set filename       twoflows-1channel
set ns_     [new Simulator]
set tracefd     [open $filename.tr w]
$ns_ use-newtrace
$ns_ trace-all $tracefd

set namtrace [open $filename.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

global defaultRNG 
$defaultRNG seed [expr abs([clock clicks] % 0xffff )]


set chan_0_ [new $val(chan)]
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]
set chan_3_ [new $val(chan)]
set chan_4_ [new $val(chan)]
set chan_5_ [new $val(chan)]
set chan_6_ [new $val(chan)]
set chan_7_ [new $val(chan)]
set chan_8_ [new $val(chan)]
set chan_9_ [new $val(chan)]
set chan_10_ [new $val(chan)]
set chan_11_ [new $val(chan)]

# NODE CONFIG PART

$ns_ node-config -adhocRouting $val(rp) \
     -llType $val(ll) \
	 -macType $val(mac) \
	 -ifqType $val(ifq) \
	 -ifqLen $val(ifqlen) \
	 -antType $val(ant) \
	 -propType $val(prop) \
	 -phyType $val(netif) \
	 -topoInstance $topo \
	 -agentTrace ON \
	 -routerTrace OFF \
	 -macTrace ON \
	 -movementTrace OFF

$ns_ node-config -channel $chan_6_\
	 -channel2 $chan_1_\
	 -channel3 $chan_11_\
	 -channel4 $chan_4_\
	 -channel5 $chan_5_\

set node_(0) [$ns_ node]
$node_(0) random-motion 0

set node_(1) [$ns_ node]
$node_(1) random-motion 0

set node_(2) [$ns_ node]
$node_(2) random-motion 0

set node_(3) [$ns_ node]
$node_(3) random-motion 0


# rutare în șir
if 0 { 
    for {set i 0} {$i < $val(nn) } {incr i} {
	set cmd "[$node_($i) set ragent_] routing $val(nn)"
	for {set to 0} {$to < $val(nn) } {incr to} {
	    if {$to < $i} {
		set hop [expr $i - 1]
	    } elseif {$to > $i} {
		set hop [expr $i + 1]
	    } else {
                set hop $i
	    }
	    set cmd "$cmd $to $hop 0"
	}
	puts "exec: $cmd"
	#eval $cmd
    }
}

# Adăugarea rutelor: size   dst next card  dst next card ...
   
set cmd "[$node_(0) set ragent_] routing 2  1 1   20 1"
eval $cmd
set cmd "[$node_(2) set ragent_] routing 2  3 3   20 3"
eval $cmd


$node_(0) set X_ 0
$node_(0) set Y_ 0
$node_(0) set Z_ 0.0

$node_(1) set X_ 200
$node_(1) set Y_ 0 
$node_(1) set Z_ 0.0

$node_(2) set X_ 400
$node_(2) set Y_ $val(dist)
$node_(2) set Z_ 0.0

$node_(3) set X_ 200
$node_(3) set Y_ $val(dist)
$node_(3) set Z_ 0.0



for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ initial_node_pos $node_($i) 10
}



# Traffic
proc attach-cbr-traffic { node sink seed size rate } {
    global ns_
    set source [new Agent/UDP]
    $source set class_ 2
    $ns_ attach-agent $node $source
    set traffic [new Application/Traffic/CBR]
    $traffic set packetSize_ $size
    $source set packetSize_ $size
    $traffic set random_ 1
    #$traffic set interval_ $interval
    $traffic set rate_ $rate
    $traffic attach-agent $source
    $ns_ connect $source $sink
    return $traffic
}


#################################################
# dump_udp
#################################################
proc dump_udp { null start stop flowid } {
  
    global val
  
    puts "loss-monitor for flow $flowid"
    puts "nlost_ [$null set nlost_]"
    puts "npkts_ [$null set npkts_]"
    puts "bytes_ [$null set bytes_]"
    puts "lastPktTime_ [$null set lastPktTime_]"
    puts "expected_ [$null set expected_]"
  
    set sending_time [expr $stop-$start]
    set bytes [$null set bytes_]
    set npkts [$null set npkts_]
    puts "sending time : $sending_time\n"
    puts "Throughput: [expr ($bytes - 20*$npkts)*8/$sending_time] bps\n"  ;# IP header = 20 bytes
}


set null0 [new Agent/LossMonitor]
$ns_ attach-agent $node_(1) $null0
set cbr0 [attach-cbr-traffic $node_(0) $null0 [clock clicks]  1460  $val(sendingRate)]
$ns_ at $val(start0) "$cbr0 start"
$ns_ at $val(stop) "$cbr0 stop"

set null1 [new Agent/LossMonitor]
$ns_ attach-agent $node_(3) $null1
set cbr1 [attach-cbr-traffic $node_(2) $null1 [clock clicks] 1460  $val(sendingRate)]
$ns_ at $val(start1) "$cbr1 start"
$ns_ at $val(stop) "$cbr1 stop"


for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at [expr $val(stop) + 0.1]  "$node_($i) reset";
}

# dump flow 0
$ns_ at [expr $val(stop) + 0.2 ] "dump_udp $null0 $val(start0) $val(stop) 0"
$ns_ at [expr $val(stop) + 0.3 ] "dump_udp $null1 $val(start1) $val(stop) 1"


puts "Starting Simulation..."


$ns_ run 
