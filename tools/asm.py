#!/usr/bin/env python3
"""
Minimal but complete assembler for the Nand2Tetris Hack platform.

Input : Hack assembly (.asm)   Output: 16-bit machine code
Usage : asm.py in.asm [-o out.hex] [--bin out.hack]

  -o / default : hex file, one 4-digit hex word per line (for Verilog $readmemh)
  --bin        : also write a binary-text .hack (one 16-char '0'/'1' line per word)

Supports A-instructions (@value / @symbol), C-instructions (dest=comp;jump),
label declarations (LABEL), predefined symbols (R0..R15, SP, LCL, ARG, THIS,
THAT, SCREEN, KBD) and auto-allocated variables starting at RAM address 16.
"""
import sys, re, argparse

COMP = {
    "0":"0101010","1":"0111111","-1":"0111010","D":"0001100","A":"0110000",
    "!D":"0001101","!A":"0110001","-D":"0001111","-A":"0110011","D+1":"0011111",
    "A+1":"0110111","D-1":"0001110","A-1":"0110010","D+A":"0000010","D-A":"0010011",
    "A-D":"0000111","D&A":"0000000","D|A":"0010101",
    "M":"1110000","!M":"1110001","-M":"1110011","M+1":"1110111","M-1":"1110010",
    "D+M":"1000010","D-M":"1010011","M-D":"1000111","D&M":"1000000","D|M":"1010101",
    # commutative aliases (assembler convenience)
    "A+D":"0000010","M+D":"1000010","A&D":"0000000","M&D":"1000000",
    "A|D":"0010101","M|D":"1010101","1+D":"0011111","1+A":"0110111","1+M":"1110111",
}
DEST = {None:"000","M":"001","D":"010","MD":"011","A":"100","AM":"101","AD":"110","AMD":"111",
        "DM":"011","MA":"101","DA":"110"}
JUMP = {None:"000","JGT":"001","JEQ":"010","JGE":"011","JLT":"100","JNE":"101","JLE":"110","JMP":"111"}

PREDEF = {"SP":0,"LCL":1,"ARG":2,"THIS":3,"THAT":4,"SCREEN":16384,"KBD":24576}
for i in range(16):
    PREDEF["R%d" % i] = i


def strip(line):
    line = line.split("//", 1)[0]
    return line.strip()


def assemble(text):
    lines = [strip(l) for l in text.splitlines()]
    lines = [l for l in lines if l]

    # pass 1: labels
    symbols = dict(PREDEF)
    addr = 0
    for l in lines:
        if l.startswith("(") and l.endswith(")"):
            symbols[l[1:-1]] = addr
        else:
            addr += 1

    # pass 2: emit
    out = []
    next_var = 16
    for l in lines:
        if l.startswith("(") and l.endswith(")"):
            continue
        if l.startswith("@"):
            sym = l[1:]
            if sym.isdigit():
                val = int(sym)
            elif sym in symbols:
                val = symbols[sym]
            else:
                symbols[sym] = next_var
                val = next_var
                next_var += 1
            if val > 0x7FFF:
                raise ValueError("A-value out of range: %s" % l)
            out.append(format(val, "016b"))
        else:
            m = re.match(r'^(?:([ADM]+)=)?([^;]+)(?:;(\w+))?$', l)
            if not m:
                raise ValueError("bad instruction: %r" % l)
            dest, comp, jump = m.group(1), m.group(2).strip(), m.group(3)
            if comp not in COMP:
                raise ValueError("bad comp %r in %r" % (comp, l))
            if dest not in DEST:
                raise ValueError("bad dest %r in %r" % (dest, l))
            if jump not in JUMP:
                raise ValueError("bad jump %r in %r" % (jump, l))
            out.append("111" + COMP[comp] + DEST[dest] + JUMP[jump])
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input")
    ap.add_argument("-o", "--out", help="hex output (for $readmemh)")
    ap.add_argument("--bin", help="binary-text .hack output")
    args = ap.parse_args()

    with open(args.input) as f:
        words = assemble(f.read())

    hexout = args.out or (args.input.rsplit(".", 1)[0] + ".hex")
    with open(hexout, "w") as f:
        for w in words:
            f.write("%04X\n" % int(w, 2))
    print("wrote %d words -> %s" % (len(words), hexout))

    if args.bin:
        with open(args.bin, "w") as f:
            for w in words:
                f.write(w + "\n")
        print("wrote %d words -> %s" % (len(words), args.bin))


if __name__ == "__main__":
    main()
