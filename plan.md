# Hack Computer on Basys3 — Completion Plan

Goal: finish the Nand2Tetris **Hack** computer in Verilog and run it on a
**Digilent Basys3** board (Artix-7 `xc7a35tcpg236-1`) with a **VGA monitor** and a
**USB/PS-2 keyboard**, ultimately to play **Tetris**.

Toolchain in this environment:
- Vivado **2025.2** (`ts 2025.2`), driven from a **tmux** session `hack`.
- Simulation: Vivado **xsim** (iverilog is unavailable on this kernel).
- Git: pushes go to `github.com/AjayaDahal/HackComputer` (fork == origin, both owned by user)
  using `gh` credentials. Commit at every milestone.

## Starting state (verified)
- Repo is **in sync** with upstream `master` (`1ae424e`): all 24 chip `.v` files and
  10 testbenches are byte-identical.
- `Inc16.v` is an empty stub; `PC.v` is empty. No CPU/Memory/ROM/Computer/IO/top/xdc.
- Latent bugs in **unused** primitives `DMux.v` and `Or16.v` (swapped gate terminals);
  the RAM decode path uses the correct NAND-based `DMux4Way`, so RAM already works.

## Architecture / FPGA integration decisions
- **Single 100 MHz clock domain** (Basys3 `W5`). Two clock-enables:
  - `pix_en` = 1-of-4 (25 MHz) drives the VGA pixel pipeline (640x480@60).
  - `cpu_en` = slow enable (~6 MHz) drives CPU registers + memory writes.
- All memories are BRAM read **every** 100 MHz cycle. Because `pc`/`addressM` are stable
  between `cpu_en` ticks (>=2 fast cycles), synchronous BRAM read latency is fully hidden —
  no negedge tricks, clean single-edge inference.
- Hack memory map: `0..16383` data RAM (`RAM16K`), `16384..24575` Screen (8192 words),
  `24576` Keyboard (read-only).
- **Screen**: dedicated true-dual-port BRAM 8192x16. Port A = CPU (r/w), Port B = VGA (r).
  512x256 monochrome image shown top-left of the 640x480 frame.
- **Keyboard**: PS-2 receiver on Basys3 USB-HID pins; Set-2 scancodes -> Hack key codes
  (letters, digits, space, enter, and arrows 130-133 for Tetris), presented at `24576`.
- **Reset**: center button `btnC`.

## Milestones (commit after each)
- **M0 setup** — env, tmux, gh creds, clone, plan.md, confirm upstream sync. *(in progress)*
- **M1 core chips** — implement `Inc16.v`, `PC.v`; fix `DMux.v`/`Or16.v`; xsim unit checks.
- **M2 CPU** — `CPU.v` (A/D regs, ALU x/y mux, dest/jump decode, PC control); directed
  testbench executes real Hack programs (Add, Max, pointer loops) and checks results.
- **M3 Memory/Computer** — `ROM32K.v` (BRAM, `$readmemh` init), `Memory.v` (RAM+Screen+
  Keyboard decode), `Computer.v`; sim a program that writes Screen and reads Keyboard.
- **M4 FPGA IO** — `vga_controller.v`, `ps2_keyboard.v`, clock-enable gen, `screen_ram.v`.
- **M5 Top + XDC** — `fpga/hack_top.v` wiring everything; `fpga/basys3.xdc`; sim VGA/PS-2.
- **M6 Synth/ILA/bitstream** — non-project `build/build.tcl`: read sources -> synth ->
  insert ILA on `pc`/`instruction`/`outM` -> impl -> `.bit`; check timing/utilization.
- **M7 Tetris** — build Tetris `.hack` via the Nand2Tetris Java toolchain, convert to a
  memory-init file, rebuild the bitstream. Fallback: an interactive on-board demo
  (arrow-key-driven sprite) that exercises the full CPU+VGA+keyboard datapath.

## Layout
```
*.v                 Hack chips (upstream) + new core (Inc16,PC,CPU,ROM32K,Memory,Computer)
fpga/               hack_top.v, vga_controller.v, ps2_keyboard.v, screen_ram.v, basys3.xdc
sim/                testbenches (*_tb.v) + Hack test programs (*.hack)
build/              build.tcl (synth/impl/bitstream), sim.tcl (xsim), helper scripts
tools/              asm/hack -> $readmemh converters, scancode helpers
```

## Status: COMPLETE

All milestones done and pushed. Verified in Vivado xsim and Vivado 2025.2 impl:

| Milestone | Result |
|-----------|--------|
| M0 setup / upstream sync | in sync with upstream `1ae424e`; plan added |
| M1 Inc16/PC + DMux/Or16 fixes | `tb_core` ALL PASS |
| M2 CPU | `tb_cpu` Add=5, Sum1..10=55 ALL PASS |
| M3 Memory/ROM/Computer | `tb_computer` mmap I/O ALL PASS |
| M4/M5 VGA + PS/2 + top + xdc | `tb_vga` (800/96,420000/1600), `tb_top` (key→CPU→screen) ALL PASS |
| M6 synth/ILA/bitstream | timing MET (WNS +1.74 ns no-ILA, +1.30 ns ILA); ~1.3% LUT, 57% BRAM |
| M7 game | `tb_game` (block demo) + `tb_tetris` (falling blocks) ALL PASS; bitstreams built |

Deliverables: `bitstreams/hack_tetris.bit` (falling-blocks game),
`bitstreams/hack_blocks.bit` (+`_ila` debug build). Program with
`build/program.tcl`; controls are the arrow keys, reset = btnC.

The falling-blocks game is a Tetris-style stacker (single 16x16 pieces). A full
tetromino Tetris (7 shapes, rotation, line clearing) can be dropped in as a
larger `.hack` via the same ROM path (see README "Tetris toolchain path").
