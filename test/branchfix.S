.section .text
.global _start
_start:
    addi t0, x0, 1
    beq t0, t0, BNE_TEST
    addi x1, x0, 1
    addi x1, x0, 2
    addi x1, x0, 3

BNE_TEST:
    addi x1, x0, 4
    # 1!=0
    bne t0, x0, BLT_TEST
    addi x1, x0, 5
    addi x1, x0, 6
    addi x1, x0, 7

BLT_TEST:
    addi x1, x0, 8
    addi t2, x0, -1
    # -1<1
    blt t2, t0, BLTU_TEST
    addi x1, x0, 9
    addi x1, x0, 10
    addi x1, x0, 11
    addi x1, x0, 12
    addi x1, x0, 13
    addi x1, x0, 14


BLTU_TEST:
    addi x1, x0, 15
    # 1<デカい数
    bltu t0, t2, BGE_TEST
    addi x1, x0, 16
    addi x1, x0, 17
    addi x1, x0, 18
    addi x1, x0, 19
    addi x1, x0, 20
    addi x1, x0, 21

BGE_TEST:
    addi x1, x0, 22
    addi t3, x0, -1
    # -1>=-1
    bge t2, t3, BGEU_TEST
    addi x1, x0, 23
    addi x1, x0, 24
    addi x1, x0, 25
    addi x1, x0, 26
    addi x1, x0, 27
    addi x1, x0, 28

BGEU_TEST:
    addi x1, x0, 29
    # デカい数>=1
    bgeu t2, t0, .end
    addi x1, x0, 29
    addi x1, x0, 30
    addi x1, x0, 31
    addi x1, x0, 32
    addi x1, x0, 33
    addi x1, x0, 34
    addi x1, x0, 35

.end:
    beq x0, x0, .end
