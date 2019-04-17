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
set val(sc)		"./scenario"		   ;# scenario file
set val(x)		150.0			   ;
set val(y)		150.0			   ;
set val(simtime)	25.0			   ; #sim time
set val(ns)		2			   ;
set val(nr)		2			   ;
set val(cwmin)		7			   ;
set val(cwmax)		1023			   ;
# ======================================================================
# Main Program
# ======================================================================



if { $argc != 8 } {
        puts "Wrong no. of cmdline args."
	puts "Usage: ns cw.tcl -ns <n> -nr <n> -cwmin <n> -cwmax <n>"
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

	set val(nn) [expr $val(ns) + $val(nr)]	
}


 

getopt $argc $argv

#
set ns_		[new Simulator]
set tracefd     [open cw.tr w]
$ns_ trace-all $tracefd
$ns_ use-newtrace

set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
set god_ [ create-god $val(nn) ]

Mac/802_11 set RTSThreshold_		3000	;# no RTS/CTS 
#Mac/802_11 set RTSThreshold_		1	;# RTS/CTS

$val(mac) set basicRate_ 1.0e6 
$val(mac) set dataRate_  2.0e6
 
$val(mac) set CWMin_ $val(cwmin)
$val(mac) set CWMax_ $val(cwmax)

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

# rutare 
for {set i 0} {$i < $val(ns) } {incr i} {
    set dst [expr $val(ns) + $i % $val(nr)] 
    set cmd "[$node_($i) set ragent_] routing 1  $dst $dst"
    eval $cmd
}


#
# Provide initial (X,Y, Z=0) co-ordinates for mobilenodes
#

for {set i 0} {$i < $val(ns) } {incr i} {
    $node_($i) set X_ [expr  0.0 + [ expr $i * 10 / $val(ns)]]
    $node_($i) set Y_ 0.0 
    $node_($i) set Z_ 0.0
}
	
for {set i 0} {$i < $val(nr) } {incr i} {
    set a [expr $i + $val(ns)]
    $node_($a) set X_ [expr  0.0 + [ expr $i * 10 / $val(nr)]]
    $node_($a) set Y_ 10.0 
    $node_($a) set Z_ 0.0
}


for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ initial_node_pos $node_($i) 20
}

for {set i 0} {$i < $val(ns)} {incr i} {
    set udp_($i) [new Agent/UDP]
    $ns_ attach-agent $node_($i) $udp_($i)
    set cbr_($i) [new Application/Traffic/CBR]
    $cbr_($i) set packetSize_ 1460
    $udp_($i) set packetSize_ 1460 
    $cbr_($i) set interval_ 0.05 
    $cbr_($i) set random_ 0.348 
    $cbr_($i) set maxpkts_ 1000000
    $cbr_($i) attach-agent $udp_($i)
    set dst [expr $val(ns) + $i % $val(nr)] 
    set null_($dst) [new Agent/Null]
    $ns_ attach-agent $node_($dst) $null_($dst)
}

# end of simulation 
for {set i 0} {$i < $val(ns) } {incr i} {
    set dst [expr $val(ns) + $i % $val(nr)] 
    $ns_ connect $udp_($i) $null_($dst)
    $ns_ at [expr 0.01 * $i] "$cbr_($i) start"
    $ns_ at $val(simtime) "$node_($i) reset";
}
$ns_ at $val(simtime) "stop"
$ns_ at $val(simtime).01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run

