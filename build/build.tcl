# Non-project batch build for the Hack computer on Basys3.
#
#   vivado -mode batch -source build/build.tcl -tclargs [ROM_HEX] [ENABLE_ILA]
#
#   ROM_HEX     : $readmemh program image for the instruction ROM
#                 (default: sim/io_test.hex)
#   ENABLE_ILA  : 1 to insert an ILA on the CPU debug taps, 0 to skip (default 1)

set PART      xc7a35tcpg236-1
set TOP       hack_top

set repo      [file normalize [file dirname [info script]]/..]
set outdir    [expr {[info exists ::env(HACK_BUILD_DIR)] ? $::env(HACK_BUILD_DIR) : "/tmp/hack_build_$::env(USER)"}]
file mkdir $outdir

set ROM_HEX    [expr {[llength $argv] > 0 ? [lindex $argv 0] : "$repo/sim/io_test.hex"}]
set ENABLE_ILA [expr {[llength $argv] > 1 ? [lindex $argv 1] : 1}]
set ROM_HEX    [file normalize $ROM_HEX]
puts "INFO: ROM_HEX    = $ROM_HEX"
puts "INFO: ENABLE_ILA = $ENABLE_ILA"

set srcs [list \
    fpga/hack_top.v fpga/vga_controller.v fpga/ps2_keyboard.v \
    Computer.v CPU.v ROM32K.v Memory.v \
    ALU.v Add16.v Halfadder.v Fulladder.v And16.v Or8Way.v Not16.v \
    Mux16.v Mux.v Register.v Bit.v Inc16.v PC.v]

foreach s $srcs { read_verilog $repo/$s }
read_xdc $repo/fpga/basys3.xdc
set_property include_dirs [file dirname $ROM_HEX] [current_fileset]

# ---- synthesis ----
synth_design -top $TOP -part $PART -generic ROM_INIT=$ROM_HEX -flatten_hierarchy none
source $repo/fpga/timing.xdc
write_checkpoint -force $outdir/post_synth.dcp
report_utilization -file $outdir/util_synth.rpt

# ---- ILA insertion on the synth netlist (before opt_design, so the debug
#      taps keep a load and opt_design generates/cleans the debug hub) ----
if {$ENABLE_ILA} {
    if {[catch {
        set clknet [get_nets clk_IBUF_BUFG]
        create_debug_core u_ila_0 ila
        foreach {prop val} {C_DATA_DEPTH 4096 C_TRIGIN_EN false C_TRIGOUT_EN false \
                            C_INPUT_PIPE_STAGES 0 ALL_PROBE_SAME_MU true} {
            catch { set_property $prop $val [get_debug_cores u_ila_0] }
        }
        connect_debug_port u_ila_0/clk $clknet
        proc add_probe {core idx nets} {
            if {$idx == 0} { set p ${core}/probe0 } else {
                create_debug_port $core probe
                set p ${core}/probe$idx
            }
            set_property PORT_WIDTH [llength $nets] [get_debug_ports $p]
            connect_debug_port $p $nets
        }
        add_probe u_ila_0 0 [get_nets -hier dbg_pc*]
        add_probe u_ila_0 1 [get_nets -hier dbg_instr*]
        add_probe u_ila_0 2 [get_nets -hier dbg_writeM*]
        add_probe u_ila_0 3 [get_nets -hier dbg_addressM*]
        add_probe u_ila_0 4 [get_nets -hier dbg_outM*]
        add_probe u_ila_0 5 [get_nets -hier dbg_key*]
        puts "INFO: ILA cores created."
    } emsg]} {
        puts "WARNING: ILA insertion failed ($emsg); continuing without ILA."
        set ENABLE_ILA 0
        catch { delete_debug_core [get_debug_cores -quiet u_ila_0] }
    }
}

# ---- optimize (generates + connects the debug hub when ILA present) ----
opt_design

# relax the ILA sampling paths: the probed CPU signals only change on cpu_en,
# so the ILA capture (though clocked every cycle) is effectively multicycle.
if {$ENABLE_ILA} {
    set ila_cells [get_cells -hierarchical -filter {NAME =~ "*u_ila_0*" && IS_SEQUENTIAL}]
    if {[llength $ila_cells] > 0} {
        catch { set_multicycle_path -setup 4 -to $ila_cells }
        catch { set_multicycle_path -hold  3 -to $ila_cells }
    }
}

# ---- implementation ----
place_design
phys_opt_design
route_design

report_timing_summary -file $outdir/timing.rpt
report_utilization    -file $outdir/util_impl.rpt
write_checkpoint -force $outdir/post_route.dcp

# ---- bitstream ----
write_bitstream -force $outdir/hack_top.bit
if {$ENABLE_ILA} { catch { write_debug_probes -force $outdir/hack_top.ltx } }

set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
puts "==================================================="
puts "BUILD DONE. Worst setup slack (WNS) = $wns ns"
if {$wns >= 0} { puts "TIMING: MET" } else { puts "TIMING: VIOLATED" }
puts "Outputs in: $outdir"
puts "==================================================="
