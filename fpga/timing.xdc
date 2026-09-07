## Multicycle timing exceptions for the Hack computer.
##
## The Hack CPU state registers (A, D, PC) and the data-memory block RAMs are
## clock-enabled by `cpu_en`, which is asserted only 1 of every 16 clocks.  The
## instruction ROM / data-memory outputs also only change one clock after a
## cpu_en step and are then stable for the remaining ~15 clocks.  The compute
## cloud between them (instruction decode + ripple-carry ALU + PC logic) is thus
## a multicycle path: it has ~15 clocks to settle but is only ever captured on a
## cpu_en step.  A setup budget of 4 clocks is far more than the path needs while
## remaining safely below the true 16-clock window.

set cpu_regs  [get_cells -hierarchical -filter {IS_SEQUENTIAL && NAME =~ "*/cpu/*out_reg*"}]
set mem_brams [get_cells -hierarchical -filter {NAME =~ "*/mem/*" && REF_NAME =~ "RAMB*"}]

if {[llength $cpu_regs] > 0} {
    set_multicycle_path -setup 4 -to $cpu_regs
    set_multicycle_path -hold  3 -to $cpu_regs
}
if {[llength $mem_brams] > 0} {
    set_multicycle_path -setup 4 -to $mem_brams
    set_multicycle_path -hold  3 -to $mem_brams
}
