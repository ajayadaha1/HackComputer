# Prebuilt bitstreams (Basys3, xc7a35tcpg236-1)

| File | Program | ILA | Timing (WNS) |
|------|---------|-----|--------------|
| `hack_blocks.bit`      | block demo | no  | +1.74 ns (MET) |
| `hack_blocks_ila.bit` (+`.ltx`) | block demo | yes | +1.30 ns (MET) |

Program the board:

```bash
source /proj/gsd/vivado/2025.2/Vivado/settings64.sh   # or: ts 2025.2
vivado -mode batch -source ../build/program.tcl -tclargs hack_blocks.bit
```

Controls: arrow keys move the white block, btnC = reset.
Rebuild for a different program: `vivado -mode batch -source ../build/build.tcl -tclargs <prog.hex> <0|1>`.
