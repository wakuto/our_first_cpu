.section .text
.global _start
_start:
    addi t0, x0, -3
    slti t1, t0, -1
    ori  t2, t1, -4
    andi s1, t2, 6
.end:
    beq x0, x0, .end