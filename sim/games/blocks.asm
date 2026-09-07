// ============================================================================
// blocks.asm  -  Movable block demo for the Hack computer on Basys3.
//
// A 16x16 white block sits on the 512x256 screen.  The arrow keys move it:
//   left (130) / right (132) / up (131) / down (133).
// The block position is kept in word-column bx (0..31) and block-row by (0..15).
// `base` is the screen word address of the block's top-left 16-pixel slice:
//   base = SCREEN + by*512 + bx    (a screen row is 32 words; a 16px-tall block
//   spans 16 rows == 16*32 == 512 words).
// Only redraws on an actual move, so the image never flickers.
// ============================================================================

// ---------- clear the whole 512x256 screen (8192 words) ----------
    @SCREEN
    D=A
    @addr
    M=D
    @8192
    D=A
    @cnt
    M=D
(CLR)
    @addr
    A=M
    M=0
    @addr
    M=M+1
    @cnt
    MD=M-1
    @CLR
    D;JGT

// ---------- init position bx=8, by=4 ----------
    @8
    D=A
    @bx
    M=D
    @4
    D=A
    @by
    M=D
    // base = SCREEN + bx + by*512
    @SCREEN
    D=A
    @bx
    D=D+M
    @base
    M=D
    @by
    D=M
    @byc
    M=D
(INITBY)
    @byc
    D=M
    @INITBYEND
    D;JEQ
    @512
    D=A
    @base
    M=M+D
    @byc
    M=M-1
    @INITBY
    0;JMP
(INITBYEND)

    // draw the initial block: fillv = -1, ret = AFTERINIT
    @1
    D=-A                 // D = -1
    @fillv
    M=D
    @AFTERINIT
    D=A
    @ret
    M=D
    @FILL
    0;JMP
(AFTERINIT)

// ============================ main loop ============================
(LOOP)
    @KBD
    D=M
    @keyv
    M=D

    // ---- LEFT (130): bx>0 ----
    @keyv
    D=M
    @130
    D=D-A
    @NOTLEFT
    D;JNE
    @bx
    D=M
    @NOTLEFT
    D;JEQ                // bx==0 -> ignore
    @DECBX
    D=A
    @after_move
    M=D
    @CALL_ERASE
    0;JMP
(NOTLEFT)

    // ---- RIGHT (132): bx<31 ----
    @keyv
    D=M
    @132
    D=D-A
    @NOTRIGHT
    D;JNE
    @bx
    D=M
    @31
    D=D-A
    @NOTRIGHT
    D;JEQ                // bx==31 -> ignore
    @INCBX
    D=A
    @after_move
    M=D
    @CALL_ERASE
    0;JMP
(NOTRIGHT)

    // ---- UP (131): by>0 ----
    @keyv
    D=M
    @131
    D=D-A
    @NOTUP
    D;JNE
    @by
    D=M
    @NOTUP
    D;JEQ
    @DECBY
    D=A
    @after_move
    M=D
    @CALL_ERASE
    0;JMP
(NOTUP)

    // ---- DOWN (133): by<15 ----
    @keyv
    D=M
    @133
    D=D-A
    @NOTDOWN
    D;JNE
    @by
    D=M
    @15
    D=D-A
    @NOTDOWN
    D;JEQ
    @INCBY
    D=A
    @after_move
    M=D
    @CALL_ERASE
    0;JMP
(NOTDOWN)

    @DELAY
    0;JMP

// ---- CALL_ERASE: erase block at current base, then jump to (after_move) ----
(CALL_ERASE)
    @0
    D=A
    @fillv
    M=D
    @ERASE_RET
    D=A
    @ret
    M=D
    @FILL
    0;JMP
(ERASE_RET)
    @after_move
    A=M
    0;JMP

// ---- movement handlers: update bx/by and base, then redraw, then delay ----
(DECBX)
    @bx
    M=M-1
    @base
    M=M-1
    @REDRAW
    0;JMP
(INCBX)
    @bx
    M=M+1
    @base
    M=M+1
    @REDRAW
    0;JMP
(DECBY)
    @by
    M=M-1
    @512
    D=A
    @base
    M=M-D
    @REDRAW
    0;JMP
(INCBY)
    @by
    M=M+1
    @512
    D=A
    @base
    M=M+D
    @REDRAW
    0;JMP

(REDRAW)
    @1
    D=-A                 // -1
    @fillv
    M=D
    @REDRAW_RET
    D=A
    @ret
    M=D
    @FILL
    0;JMP
(REDRAW_RET)

(DELAY)
    @16000
    D=A
    @dly
    M=D
(DELAYLOOP)
    @dly
    MD=M-1
    @DELAYLOOP
    D;JGT
    @LOOP
    0;JMP

// ============================ FILL subroutine ============================
// Fills the 16 rows of the block at `base` with value `fillv`.
// Returns to the address stored in `ret`.
(FILL)
    @base
    D=M
    @faddr
    M=D
    @16
    D=A
    @fcnt
    M=D
(FILLLOOP)
    @fillv
    D=M
    @faddr
    A=M
    M=D                  // screen[faddr] = fillv
    @32
    D=A
    @faddr
    M=M+D                // next row
    @fcnt
    MD=M-1
    @FILLLOOP
    D;JGT
    @ret
    A=M
    0;JMP
