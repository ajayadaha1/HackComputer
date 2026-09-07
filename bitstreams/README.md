# Prebuilt bitstreams (Basys3, xc7a35tcpg236-1)

| File | Program | ILA | Timing (WNS) |
|------|---------|-----|--------------|
| `hack_tetris.bit`      | falling-blocks game | no  | +1.74 ns (MET) |
| `hack_blocks.bit`      | movable-block demo  | no  | +1.74 ns (MET) |
| `hack_blocks_ila.bit` (+`.ltx`) | movable-block demo | yes | +1.30 ns (MET) |

Program the board (VGA monitor + USB keyboard connected):

```bash
source /proj/gsd/vivado/2025.2/Vivado/settings64.sh    # or: ts 2025.2
vivado -mode batch -source ../build/program.tcl -tclargs hack_tetris.bit
```

## Controls
- **hack_tetris**: LEFT/RIGHT arrows steer the falling block; it drops one row per
  tick, locks at the bottom, and stacks. Board resets when a stack reaches the top.
- **hack_blocks**: arrow keys move a block freely around the screen.
- **btnC**: reset (restarts the program).

Rebuild any program: `vivado -mode batch -source ../build/build.tcl -tclargs <prog.hex> <0|1>`
(assemble a `.asm` first with `python3 ../tools/asm.py prog.asm -o prog.hex`).
