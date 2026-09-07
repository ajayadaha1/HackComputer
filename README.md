# Hack Computer on Basys3 (Nand2Tetris)

A complete, synthesizable implementation of the Nand2Tetris **Hack** computer that
runs on a **Digilent Basys3** board (Artix-7 `xc7a35tcpg236-1`) with a **VGA
monitor** and a **USB / PS-2 keyboard**.

The gate-level Hack chips (ALU, RAM, muxes, adders, …) are the original
Nand2Tetris designs; this repo adds the missing pieces to turn them into a real
computer on real hardware:

| Layer | Files |
|-------|-------|
| Core chips (Nand2Tetris) | `ALU.v`, `Add16.v`, `Mux*.v`, `RAM*.v`, `Register.v`, `Bit.v`, … |
| Completed core | `Inc16.v`, `PC.v`, `CPU.v`, `ROM32K.v`, `Memory.v`, `Computer.v` |
| FPGA I/O | `fpga/vga_controller.v`, `fpga/ps2_keyboard.v`, `fpga/hack_top.v` |
| Constraints | `fpga/basys3.xdc`, `fpga/timing.xdc` |
| Build / tools | `build/build.tcl`, `build/run_sim.sh`, `build/program.tcl`, `tools/asm.py` |
| Programs / tests | `sim/*.v`, `sim/games/blocks.asm`, `sim/games/tetris.asm` |

Prebuilt bitstreams (all meet timing at 100 MHz) live in `bitstreams/`:
`hack_tetris.bit` (falling-blocks game), `hack_blocks.bit` (free-move demo) and
`hack_blocks_ila.bit` (+`.ltx`, with an ILA).

## Architecture

Single **100 MHz** clock domain with two clock enables:

* `pix_en` — 1-of-4 (25 MHz) drives the VGA pixel pipeline (640×480 @ 60 Hz).
* `cpu_en` — 1-of-16 (~6.25 MHz) steps the Hack CPU one instruction at a time.

All memories are inferred **block RAM** read every 100 MHz clock. Because
`pc`/`addressM` only change on a `cpu_en` step, the one-cycle BRAM read latency is
fully hidden — no gated clocks, clean single-edge inference. The CPU compute
cloud (decode + ripple-carry ALU + PC) is therefore a **multicycle path**
(`fpga/timing.xdc`), which lets the whole design close timing at 100 MHz.

Hack memory map (data memory):

| Address | Region |
|---------|--------|
| `0x0000–0x3FFF` | data RAM (16K words) |
| `0x4000–0x5FFF` | Screen (8K words, 512×256 monochrome) |
| `0x6000` | Keyboard (read-only) |

The Screen buffer is a true dual-port BRAM: the CPU writes it, the VGA controller
reads it. The keyboard is driven by a PS-2 receiver that translates Set-2
scancodes to Nand2Tetris key codes (letters, digits, space, enter, esc and the
arrow keys 130–133).

## Simulate (Vivado xsim)

```bash
source /proj/gsd/vivado/2025.2/Vivado/settings64.sh    # or: ts 2025.2
# core chips
bash build/run_sim.sh tb_core sim/tb_core.v Inc16.v PC.v Add16.v Halfadder.v \
     Fulladder.v Mux16.v Mux.v Register.v Bit.v
# CPU running real programs
XSIM_ARGS="-testplusarg TEST=sum" bash build/run_sim.sh tb_cpu sim/tb_cpu.v CPU.v \
     ALU.v Add16.v Halfadder.v Fulladder.v And16.v Or8Way.v Not16.v Mux16.v Mux.v \
     Register.v Bit.v Inc16.v PC.v
```

Test benches: `tb_core` (Inc16/PC), `tb_cpu` (Add, Sum), `tb_computer`
(memory-mapped I/O), `tb_vga` (640×480 timing), `tb_ps2`/`tb_top` (keyboard →
CPU → screen), `tb_game` (the block demo on the full Computer). All pass.

## Build a bitstream

```bash
source /proj/gsd/vivado/2025.2/Vivado/settings64.sh
# arg 1: program image (hex);  arg 2: 1=insert ILA, 0=no ILA
vivado -mode batch -source build/build.tcl -tclargs sim/games/blocks.hex 0
# -> $HACK_BUILD_DIR/hack_top.bit   (default /tmp/hack_build_$USER)
```

The design meets timing at 100 MHz (WNS ≈ +1.7 ns) and uses ~1.3 % LUTs and
~57 % block RAM of the xc7a35t. With `ENABLE_ILA=1` an ILA is inserted on the
CPU debug taps (`pc`, `instruction`, `writeM`, `addressM`, `outM`, `keyboard`)
and a `hack_top.ltx` probes file is written.

## Program the board

Connect a VGA monitor and a USB keyboard, then:

```bash
vivado -mode batch -source build/program.tcl                    # loads bitstreams/hack_tetris.bit
vivado -mode batch -source build/program.tcl -tclargs bitstreams/hack_blocks.bit
```

or use the Vivado Hardware Manager: open target, program `hack_top.bit`.

Controls:
* **hack_tetris** — LEFT / RIGHT arrows steer the block; it falls one row per
  tick and locks/stacks at the bottom. The board resets when a stack reaches the
  top (game over).
* **hack_blocks** — arrow keys move a white block freely around the screen.
* **btnC** — reset.

## Writing / loading your own program (and a path to full Tetris)

Author in Hack assembly and assemble to a ROM image:

```bash
python3 tools/asm.py my.asm -o my.hex
vivado -mode batch -source build/build.tcl -tclargs my.hex 0
```

For a full high-level game (e.g. a Jack Tetris) use the Nand2Tetris software
suite (Java): `JackCompiler` (`.jack` → `.vm`) → `VMTranslator` (`.vm` → `.asm`)
→ assemble the resulting `.asm` with `tools/asm.py` (or the course `Assembler`)
to a `.hex`, then rebuild the bitstream with that hex. The instruction ROM is
32K words, matching the full Hack instruction space.
