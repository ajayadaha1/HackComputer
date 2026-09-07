# Program the Basys3 over JTAG with a Hack computer bitstream.
#
#   vivado -mode batch -source build/program.tcl -tclargs [path/to/hack_top.bit]
#
# Defaults to the preserved bitstream in ./bitstreams/hack_blocks.bit.

set repo [file normalize [file dirname [info script]]/..]
set bit  [expr {[llength $argv] > 0 ? [lindex $argv 0] : "$repo/bitstreams/hack_blocks.bit"}]
set bit  [file normalize $bit]
puts "INFO: programming $bit"

open_hw_manager
connect_hw_server
open_hw_target

set dev [lindex [get_hw_devices] 0]
current_hw_device $dev
refresh_hw_device -update_hw_probes false $dev

set_property PROGRAM.FILE $bit $dev
# if an ILA probes file sits next to the bitstream, load it too
set ltx [file rootname $bit].ltx
if {[file exists $ltx]} { set_property PROBES.FILE $ltx $dev }

program_hw_devices $dev
refresh_hw_device $dev
puts "INFO: done."
