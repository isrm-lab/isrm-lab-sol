#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

#Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#Create links between the nodes
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.7Mb 20ms DropTail

#Set Queue Size of link (n2-n3) to 5
$ns queue-limit $n2 $n3 5

#Give node position (for NAM)
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

#Monitor the queue for link n2-n3 (for NAM)
$ns duplex-link-op $n2 $n3 queuePos 0.5

#Setup a TCP connection
set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n0 $tcp
set sinkt [new Agent/TCPSink]
$ns attach-agent $n3 $sinkt
$ns connect $tcp $sinkt
$tcp set fid_ 1

#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set usink [new Agent/LossMonitor]
$ns attach-agent $n3 $usink
$ns connect $udp $usink
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

#Open a trace file 
set fout [open out.tr w]

#save running byte counters 
set tbytes 0
set ubytes 0

proc record {} {
    global tcp usink fout ubytes tbytes

    set ns [Simulator instance]
    #Set the time after which the procedure should be called again
    set time 0.25
    #How many bytes have been received/acked?
    set tbytes1 [expr [$tcp set ack_]*[$tcp set packetSize_]]
    set ubytes1 [expr [$usink set bytes_]]
    set now [$ns now]
    #Calculate the bandwidth (in MBit/s) and write it to the log
    puts $fout "$now [expr ($tbytes1 - $tbytes)/$time*8/1000000] \
                     [expr ($ubytes1 - $ubytes)/$time*8/1000000]"
    #Reset the bytes_ values on the traffic sinks
    set tbytes $tbytes1
    set ubytes $ubytes1
    #Re-schedule the procedure
    $ns at [expr $now+$time] "record"
}

#Define a 'finish' procedure
proc finish {} {
    global ns nf fout
    $ns flush-trace
    #Close the trace file
    close $fout
    #Call gnuplot to display the results
    exec echo  "plot 'out.tr' using 1:2 t 'TCP' w l, '' using 1:3 t 'UDP' w l" | gnuplot -persist
    exit 0
}

$ns at 0.0 "record"

#Schedule events for the CBR and FTP agents
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 14.0 "$ftp stop"
$ns at 14.5 "$cbr stop"

#Call the finish procedure after 15 seconds of simulation time
$ns at 15.0 "finish"

#Print CBR packet size and interval
puts "CBR packet size = [$cbr set packet_size_]"
puts "CBR interval = [$cbr set interval_]"

#Run the simulation
$ns run

