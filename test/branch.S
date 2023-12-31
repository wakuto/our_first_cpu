.section .text
.global _start
_start:
    addi t0, x0, 1
    beq t0, t0, BNE_TEST
    nop
    nop
    nop

BNE_TEST:
    # 1!=0
    bne t0, x0, BLT_TEST 
    nop
    nop
    nop

BLT_TEST:
    addi t2, x0, -1
    # -1<1
    blt t2, t0, BLTU_TEST
    nop
    nop
    nop
    nop
    nop
    nop


BLTU_TEST:
    # 1<デカい数
    bltu t0, t2, BGE_TEST
    nop
    nop
    nop
    nop
    nop
    nop

BGE_TEST:
    addi t3, x0, -1
    # -1>=-1
    bge t2, t3, BGEU_TEST
    nop
    nop
    nop
    nop
    nop
    nop

BGEU_TEST:
    # デカい数>=1
    bgeu t2, t0, .end
    nop
    nop
    nop
    nop
    nop
    nop

.end:
    beq x0, x0, .end
