#!/bin/bash
# Compile + run an xsim simulation for the Hack computer.
# Usage: run_sim.sh <top_tb_module> <verilog_file> [more verilog files...]
# Runs out of $REPO/work so build artifacts stay out of git.
set -e
REPO="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${HACK_WORK:-/tmp/hack_work_$USER}"
mkdir -p "$WORK"

VIV_SETTINGS=/proj/gsd/vivado/2025.2/Vivado/settings64.sh
# shellcheck disable=SC1090
source "$VIV_SETTINGS"

TOP="$1"; shift

# Resolve all source files to absolute paths (relative to $REPO) before cd.
SRCS=()
for f in "$@"; do
  if [[ "$f" = /* ]]; then SRCS+=("$f"); else SRCS+=("$REPO/$f"); fi
done

cd "$WORK"

echo ">>> xvlog compiling: ${SRCS[*]}"
xvlog --nolog -sv "${SRCS[@]}"
echo ">>> xelab $TOP"
xelab --nolog -debug typical "$TOP" -s "${TOP}_sim"
echo ">>> xsim run"
cat > "${TOP}_run.tcl" <<TCL
run all
quit
TCL
xsim --nolog "${TOP}_sim" -tclbatch "${TOP}_run.tcl" $XSIM_ARGS
