# Purpose is to sudy uplink fairness 
# -rlen 3 means 1 AP and 2 stations sending uplink traffic 


# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             25                          ;# default number of mobilenodes
set val(rp)             NOAH                       ;# routing protocol
set val(x)		150.0			   ;
set val(y)		150.0			   ;
set val(simtime)	2.0			   ; #sim time
set val(rlen)		5			   ;
set val(cwmin)		7			   ;
set val(cwmax)		1023			   ;
# ======================================================================
# Main Program
# ======================================================================
global defaultRNG 
$defaultRNG seed [expr abs([clock clicks] % 0xfff)]



if { $argc != 6 } {
        puts "Wrong no. of cmdline args."
	puts "Usage: ns cw-fair.tcl -rlen <n> -cwmin <n> -cwmax <n>"
        exit 0
}


proc getopt {argc argv} {
        global val
        lappend optlist rlen cwmin cwmax
 
        for {set i 0} {$i < $argc} {incr i} {
                set arg [lindex $argv $i]
                if {[string range $arg 0 0] != "-"} continue
                set name [string range $arg 1 end]
                set val($name) [lindex $argv [expr $i+1]]
        }

	set val(nn) [expr $val(rlen) ]	
#        puts "cw   $val(cw)"
#       exit 0 
}

#################################################
# dump_udp
#################################################
proc dump_udp { null start stop flowid } {
    
    global val printf
    
    puts "loss-monitor-flow $flowid"
    puts "nlost_ [$null set nlost_]"
    puts "npkts_ [$null set npkts_]"
#    puts "bytes_ [$null set bytes_]"
#    puts "lastPktTime_ [$null set lastPktTime_]"
#    puts "expected_ [$null set expected_]"
    
    set sending_time [expr $stop-$start]
    
#    puts "sending time : $sending_time\n"
    puts [format "Throughput-kbps  %6.1f\n" [expr [$null set bytes_]*8/$sending_time/1000]]
}

 

getopt $argc $argv
#
# Initialize Global Variables
#
set ns_		[new Simulator]
set tracefd     [open cw-fair.tr w]
$ns_ trace-all $tracefd

#set namtrace [open cwsim.nam w]           ;# for nam tracing
#$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
$ns_ use-newtrace

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#

set god_ [ create-god $val(nn) ]


Mac/802_11 set RTSThreshold_		3000	;# no RTS/CTS 
#Mac/802_11 set RTSThreshold_		1	;# RTS/CTS

$val(mac) set basicRate_ 1.0e6 
$val(mac) set dataRate_  2.0e6
 
$val(mac) set CWMin_ $val(cwmin)
$val(mac) set CWMax_ $val(cwmax)

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 

# configure node


        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace OFF \
			 -macTrace ON \
			 -movementTrace OFF



for {set i 0} {$i < $val(nn) } {incr i} {
    set node_($i) [$ns_ node]	
    $node_($i) random-motion 0		;# disable random motion
}



#    AP        or around, in circle 
# N N N N N          
# <- 150 ->

set gridspace [expr 150.0 / ($val(rlen)-1)]
set pi 3.14156592
	
$node_(0) set X_ 0.0 
$node_(0) set Y_ 0.0 
$node_(0) set Z_ 0.0

for {set i 1} {$i < $val(rlen) } {incr i} {
    $node_($i) set X_ [expr  20 * cos($i * 2 * $pi / ($val(rlen) - 1))]]
    $node_($i) set Y_ [expr  20 * sin($i * 2 * $pi / ($val(rlen) - 1))]]
#    $node_($i) set X_ [expr  -75.0 + [ expr $i * $gridspace]]
#    $node_($i) set Y_ 75.0 
    $node_($i) set Z_ 0.0
}



# Define node initial position in nam

for {set i 1} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 20
    
    set udp_($i) [new Agent/UDP]
    $ns_ attach-agent $node_($i) $udp_($i)
    
    set cbr_($i) [new Application/Traffic/CBR]
    $cbr_($i) set packetSize_ 1512
    $udp_($i) set packetSize_ 1512 
    $cbr_($i) set interval_ [expr 1.0/40] 
    $cbr_($i) set random_ 0.348 
    $cbr_($i) set maxpkts_ 10000000
    $cbr_($i) attach-agent $udp_($i)
    
    set null_($i) [new Agent/LossMonitor]
    $ns_ attach-agent $node_(0) $null_($i)
    # Tell nodes when the simulation ends
    $ns_ at [expr 0.0 * $i] "$cbr_($i) start"
    $ns_ at $val(simtime) "$node_($i) reset";
}

#$cbr_(1) set interval_ [expr 1.0/70] 
#$cbr_(2) set interval_ [expr 1.0/64] 


# set up flows uplink + downlink 

# rutare 

for {set i 1} {$i < $val(nn) } {incr i} {
#    set dst [expr [expr $i + $val(rlen)] % $val(nn)] 
    set cmd "[$node_($i) set ragent_] routing 1  0 0"
    eval $cmd
    $ns_ connect $udp_($i) $null_($i)
}


$ns_ at $val(simtime) "stop"
$ns_ at $val(simtime).01 "$ns_ halt"

proc stop {} {
    global val null_ sending_time printf
    set total 0 
    for {set i 1} {$i < $val(nn) } {incr i} {
	dump_udp $null_($i) 0.0 $val(simtime) $i
	set total [expr [$null_($i) set bytes_] + $total]
    }
    puts [format "TotalThroughputkbps %6.1f\n" [expr $total*8/$val(simtime)/1000]]
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

$ns_ run

