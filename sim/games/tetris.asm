// ============================================================================
// tetris.asm - falling-blocks game for the Hack computer on Basys3.
//
// A 16x16 block falls from the top of the 512x256 screen one row per tick.
// LEFT (130) / RIGHT (132) steer it between the 32 word-columns.  When it can
// fall no further it locks in place, the column's stack height grows, and a new
// block spawns at the top-centre.  If the spawn column is full the board resets.
//
// Board model:
//   32 columns (word-columns 0..31), each up to 16 blocks tall (block-rows 0..15,
//   row 15 = bottom).  height[c] (RAM 100+c) = number of locked blocks in col c.
//   The lowest free block-row of column c is  15 - height[c].
//   base = SCREEN + by*512 + bx  is the top-left screen word of the block
//   (a block-row is 16 px tall == 16*32 == 512 screen words).
// ============================================================================

(START)
// ---------- clear the whole screen (8192 words) ----------
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

// ---------- clear height[0..31] (RAM 100..131) ----------
    @100
    D=A
    @addr
    M=D
    @32
    D=A
    @cnt
    M=D
(HCLR)
    @addr
    A=M
    M=0
    @addr
    M=M+1
    @cnt
    MD=M-1
    @HCLR
    D;JGT

// ============================ spawn a new block ============================
(SPAWN)
    // game over if column 16 is full -> restart the whole board
    @116                 // &height[16]
    D=M
    @16
    D=D-A
    @SPAWN_OK
    D;JLT                // height[16] < 16 -> ok
    @START
    0;JMP
(SPAWN_OK)
    @16
    D=A
    @bx
    M=D                  // bx = 16
    @0
    D=A
    @by
    M=D                  // by = 0
    @SCREEN
    D=A
    @16
    D=D+A
    @base
    M=D                  // base = SCREEN + 16  (by=0, bx=16)
    // draw the new block
    @DRAW
    D=A
    @after_move
    M=D
    @CALL_DRAW
    0;JMP

// ============================ main tick loop ============================
(LOOP)
    @KBD
    D=M
    @keyv
    M=D

    // ---- LEFT (130) ----
    @keyv
    D=M
    @130
    D=D-A
    @CHK_RIGHT
    D;JNE
    @bx
    D=M
    @FALLNOW
    D;JEQ                // bx==0 -> can't move, just fall
    // tcol = bx-1 ; require 15 - height[tcol] - by >= 0
    @bx
    D=M
    @1
    D=D-A
    @tcol
    M=D
    @tcol
    D=M
    @100
    A=D+A
    D=M                  // D = height[tcol]
    @15
    D=A-D                // 15 - height
    @by
    D=D-M                // 15 - height - by
    @FALLNOW
    D;JLT                // blocked -> fall instead
    @DO_LEFT
    D=A
    @after_move
    M=D
    @CALL_ERASE
    0;JMP
(CHK_RIGHT)
    // ---- RIGHT (132) ----
    @keyv
    D=M
    @132
    D=D-A
    @FALLNOW
    D;JNE
    @bx
    D=M
    @31
    D=D-A
    @FALLNOW
    D;JEQ                // bx==31 -> fall
    // tcol = bx+1 ; require 15 - height[tcol] - by >= 0
    @bx
    D=M
    @1
    D=D+A
    @tcol
    M=D
    @tcol
    D=M
    @100
    A=D+A
    D=M
    @15
    D=A-D
    @by
    D=D-M
    @FALLNOW
    D;JLT
    @DO_RIGHT
    D=A
    @after_move
    M=D
    @CALL_ERASE
    0;JMP

// ---- fall one row, or lock and respawn ----
(FALLNOW)
    @bx
    D=M
    @100
    A=D+A
    D=M                  // D = height[bx]
    @15
    D=A-D                // landing row = 15 - height[bx]
    @landing
    M=D
    @by
    D=M
    @landing
    D=M-D                // landing - by
    @LAND
    D;JLE                // by >= landing -> lock
    // fall: erase, by++, base += 512, draw
    @DO_DOWN
    D=A
    @after_move
    M=D
    @CALL_ERASE
    0;JMP
(LAND)
    @by
    D=M
    @LAND_DO
    D;JGT                // locked above the top row -> normal lock
    @START
    0;JMP                // locked at the very top -> board full -> reset
(LAND_DO)
    @bx
    D=M
    @100
    D=D+A
    @ptr
    M=D
    @ptr
    A=M
    M=M+1                // height[bx]++
    @SPAWN
    0;JMP

// ================= movement handlers (after erasing) =================
(DO_LEFT)
    @bx
    M=M-1
    @base
    M=M-1
    @GO_DRAW
    0;JMP
(DO_RIGHT)
    @bx
    M=M+1
    @base
    M=M+1
    @GO_DRAW
    0;JMP
(DO_DOWN)
    @by
    M=M+1
    @512
    D=A
    @base
    M=M+D
    @GO_DRAW
    0;JMP

(GO_DRAW)
    @DRAW
    D=A
    @after_move
    M=D
    @CALL_DRAW
    0;JMP

// after a draw we always land here: run the tick delay, then loop
(DRAW)
(TICKEND)
    @8000
    D=A
    @dly
    M=D
(DLY)
    @dly
    MD=M-1
    @DLY
    D;JGT
    @LOOP
    0;JMP

// ============================ draw / erase helpers ============================
// CALL_ERASE: fill block at base with 0, then jump to (after_move).
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

// CALL_DRAW: fill block at base with -1, then jump to (after_move).
(CALL_DRAW)
    @1
    D=-A                 // -1
    @fillv
    M=D
    @DRAW_RET
    D=A
    @ret
    M=D
    @FILL
    0;JMP
(DRAW_RET)
    @after_move
    A=M
    0;JMP

// FILL: writes `fillv` to the 16 rows of the block at `base`; returns via `ret`.
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
    M=D
    @32
    D=A
    @faddr
    M=M+D
    @fcnt
    MD=M-1
    @FILLLOOP
    D;JGT
    @ret
    A=M
    0;JMP
