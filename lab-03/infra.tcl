
set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(x)              8000            ;# X dimension of the topography
set val(y)              8000            ;# Y dimension of the topography
set val(ifqlen)         50              ;# max packet in ifq
					;# DSR queue length is defined in
					;# queue/dsr-priqueue.h
set val(adhocRouting)   NOAH

set val(nn)             2	;# how many nodes are simulated

set val(start0)         10.0	;# traffic 0's simulation start time
set val(stop0)		20.0	;# traffic 0's simulation stop time



set val(packetSize)	1460
set val(run_tcp)        0       ;# tcp or udp  
set val(sendingRate)    500Kbps 

global defaultRNG 
$defaultRNG seed [expr abs([clock clicks]) % 0xffff]

proc getopt {argc argv} {
    global val
    lappend optlist dist

    for {set i 0} {$i < $argc} {incr i} {
	set arg [lindex $argv $i]
	if {[string range $arg 0 0] != "-"} continue

	set name [string range $arg 1 end]
	if {! [info exists val($name)]} { 
	    puts "Atenție, variabila val($name) nu există\n";
	    exit 2;
	} else {
	    set val($name) [lindex $argv [expr $i+1]]
	}
    }
}

if { $argc == 0 } {
    puts "argumente:\n\
-run_tcp  1:TCP  0:UDP\n\
-nn <număr de noduri>\n\
-packetSize <S>, MSS\n\
-sendingRate <Număr>\[M|K\]<bps>, doar pt UDP. În loc de 0, folosiți 0.1bps\n"
    exit; 
}

getopt $argc $argv


Phy/WirelessPhy set CPThresh_ 10.0

# Carrier sense threshold
Phy/WirelessPhy set CSThresh_ 1.55924e-11	;# for 550m
#Phy/WirelessPhy set CSThresh_ 3.65262e-10	;# for 250m
#Phy/WirelessPhy set CSThresh_ 1.76149e-10	;# for 300m

# Receive threshold
Phy/WirelessPhy set RXThresh_ 3.65262e-10	;# for 250m
#Phy/WirelessPhy set RXThresh_ 1.76149e-10	;# for 300m

Phy/WirelessPhy set Pt_ 0.281838
Phy/WirelessPhy set freq_ 2.4e+9
Phy/WirelessPhy set L_ 1.0

#
# TwoRayGround's Received Power = 
#     
#    Pt * Gt * Gr * (ht^2 * hr^2)
#   -----------------------------  (== 1.76125e-10, if d == 200m)
#             d^4 * L
#


#
# Define 802.11 basic and data rates
#
if { 0 } { # 802.11b
    Mac/802_11 set CWMin_  31 
    Mac/802_11 set CWMax_  1023
    Mac/802_11 set SlotTime_          0.000020        ;# 20us
    Mac/802_11 set SIFS_              0.000010        ;# 10us
    Mac/802_11 set PreambleLength_    144             ;# 144 bit
    Mac/802_11 set PLCPHeaderLength_  48              ;# 48 bits
    Mac/802_11 set PLCPDataRate_      1.0e6           ;# 1Mbps
    Mac/802_11 set dataRate_          11.0e6          ;# 11Mbps
    Mac/802_11 set basicRate_         1.0e6           ;# 1Mbps
}

if { 0 } { # 802.11a
    Mac/802_11 set CWMin_ 15
    Mac/802_11 set CWMax_ 1023
    Mac/802_11 set SlotTime_          0.000009        ;# 9us
    Mac/802_11 set SIFS_              0.000016        ;# 16us
    Mac/802_11 set PreambleLength_    144             ;# 
    Mac/802_11 set PLCPHeaderLength_  48              ;# 48 bits
    Mac/802_11 set PLCPDataRate_      6.0e6           ;# 6Mbps
    Mac/802_11 set dataRate_          54.0e6          ;# 54Mbps
    Mac/802_11 set basicRate_         6.0e6           ;# 6Mbps 
}

if { 1 } { # 802.11g
    Mac/802_11 set CWMin_ 15
    Mac/802_11 set CWMax_ 1023
    Mac/802_11 set SlotTime_          0.000009        ;# 9us
    Mac/802_11 set SIFS_              0.000016        ;# 16us
    Mac/802_11 set PreambleLength_    16              ;# 16us
    Mac/802_11 set PLCPHeaderLength_  24              ;# 24 bits
    Mac/802_11 set PLCPDataRate_      6.0e6           ;# 6Mbps
    Mac/802_11 set dataRate_          54.0e6          ;# 54Mbps
    Mac/802_11 set basicRate_         6.0e6           ;# 6Mbps 
}

Mac/802_11 set RTSThreshold_		3000	;# no RTS/CTS 
#Mac/802_11 set RTSThreshold_		1	;# RTS/CTS
Mac/802_11 set ShortRetryLimit_ 	7	;# Short Retry Limit 
Mac/802_11 set MaxShortRetryLimit_ 	7	;# Short Retry Limit 
Mac/802_11 set LongRetryLimit_ 		4	;# Long Retry Limit 



set ns_		[new Simulator]


set topo	[new Topography]
$topo load_flatgrid $val(x) $val(y)

# create trace object for ns and nam

set tracefd	[open infra.tr w]
# set namtracefd    [open infra.nam w]
$ns_ use-newtrace
$ns_ trace-all $tracefd

# Create God
# node 0 is AP, nodes 1..n-1 are clients 
set god_ [create-god $val(nn)]


#
# define how node should be created
#
#global node setting
#$ns_ node-config  

if { 1 } { 
$ns_ node-config   \
    -adhocRouting $val(adhocRouting) \
    -llType $val(ll) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -ifqLen $val(ifqlen) \
    -antType $val(ant) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -channel [new $val(chan)]\
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace OFF \
    -macTrace ON \
    -movementTrace OFF
} else { 
    $ns_ node-config \
	-adhocRouting $val(adhocRouting) \
	-wiredRouting ON 
}
# Nodul 0 este AP, la (0,0), celelalte noduri sunt în zona (-100m..100m) pe axa X
#
    for {set i 0} {$i < $val(nn)} {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0		;# disable random motion
	$node_($i) set X_ [expr $i*pow(-1, $i)*100.0/$val(nn)]
	$node_($i) set Y_ 0.0
	$node_($i) set Z_ 0.0
    }


if { 1 } { # NOAH static routes 
    # setup static routing for line of nodes
    set rt_down "[$node_(0) set ragent_] routing [expr $val(nn) -1 ] "
    for {set i 1} {$i < $val(nn) } {incr i} {
	set rt_down "$rt_down $i $i "
	set rt_up "[$node_($i) set ragent_] routing [expr $val(nn) -1 ]  0 0"
	for {set j 1} {$j < $val(nn) } {incr j} {
	    if { $i != $j} { 
		set rt_up "$rt_up $j 0"
	    }
	}
	eval $rt_up
#	puts "ROUTE $rt_up"
    }
    eval $rt_down
#    puts "ROUTE $rt_down"
} else { # wired links
    for {set i 1} {$i < $val(nn)} {incr i} {
	$ns_ duplex-link $node_([expr $i -1]) $node_($i) 2Mb 10ms DropTail
    }
}


set lastnode $node_([expr $val(nn) - 1]) 

#############################################
# udp or tcp 
#############################################
proc attach-cbr-traffic { src_n dst_n pktsize rate start_t  stop_t flow_id} {
    global ns_ node_
    set source [new Agent/UDP]
    set null [new Agent/LossMonitor]
    $source set class_ 2
    $ns_ attach-agent $node_($src_n) $source
    $ns_ attach-agent $node_($dst_n) $null
    set cbr [new Application/Traffic/CBR]
    $cbr set packetSize_ $pktsize
    $source set packetSize_ $pktsize
    $cbr set random_ 1
    #$traffic set interval_ $interval
    $cbr set rate_ $rate
    $cbr attach-agent $source
    $ns_ connect $source $null
    $ns_ at $start_t "$cbr start"
    $ns_ at $stop_t "$cbr stop"
    $ns_ at [expr  $stop_t + 0.1] "dump_udp $null $start_t $stop_t $flow_id"
}

proc attach-tcp-traffic { src_n dst_n packetSize start_t  stop_t flow_id} {
    global val ns_ node_ tracefd

    set tcp [new Agent/TCP/Newreno]
    $tcp set class_ 2
    $tcp set packetSize_ $packetSize
    $tcp set ssthresh_ 300
    $tcp set window_ 2000
    #puts "sstresh = [$tcp set ssthresh_ ]\n"
    #$tcp set overhead_ 0.025

    $tcp attach $tracefd 
    $tcp trace cwnd_
    $tcp trace ack_
    $tcp trace rtt_
    
    set sink [new Agent/TCPSink]
    $ns_ attach-agent $node_($src_n) $tcp
    $ns_ attach-agent $node_($dst_n) $sink
    $ns_ connect $tcp $sink
    #$sink set packetSize_ -72 
    
    set ftp [new Application/FTP]
    $ftp attach-agent $tcp
    $ns_ at $start_t "$ftp start" 
    $ns_ at $stop_t "$ftp stop" 
    $ns_ at [expr $stop_t + 0.2] "dump_tcp $tcp $start_t $stop_t $flow_id"
}


#################################################
# dump_udp
#################################################
proc dump_tcp { src start stop flowid } {
    global val ns_
    puts "\nloss-monitor for flow $flowid"
    set sending_time [expr $stop-$start]
    puts "sending time: $sending_time lastack: [$src set ack_] srtt: [$src set srtt_]"
    puts "datab: [$src set ndatabytes_]  retr: [$src set nrexmitbytes_]"
    puts "Throughput $flowid [expr [$src set ack_]*[$src set packetSize_]*8/$sending_time]"
}

proc dump_udp { null start stop flowid } {
    global val
    
    puts "\nloss-monitor for flow $flowid"
    puts "nlost_ [$null set nlost_]"
    puts "npkts_ [$null set npkts_]"
    puts "bytes_ [$null set bytes_]"
    puts "lastPktTime_ [$null set lastPktTime_]"
    puts "expected_ [$null set expected_]"
    
    set sending_time [expr $stop-$start]
    
    puts "sending time : $sending_time"
    puts "Throughput $flowid [expr ([$null set bytes_]*8 - [$null set npkts_]*20*8)/$sending_time]\n"
}



#################################################################################

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ initial_node_pos $node_($i) 20
}

# Start downlink flows AP -> clients
#
if { $val(run_tcp) == 1 } {
    for {set i 1} {$i < $val(nn)} {incr i} {
	 attach-tcp-traffic 0 $i $val(packetSize) $val(start0) $val(stop0) $i
	puts "attached 0->$i"
    }
} else {
    for {set i 1} {$i < $val(nn)} {incr i} {
	attach-cbr-traffic 0 $i $val(packetSize) $val(sendingRate) $val(start0) $val(stop0) $i
    }
}


# Tell nodes when the simulation ends
#

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ at [expr $val(stop0) + 1.0] "$node_($i) reset";
}
$ns_ at [expr $val(stop0) + 10.0] "exit 0"; #FIXME 

puts "Starting Simulation..."
$ns_ run 

