.section .text
.global _start
_start:
    lui t0,3
    nop
    nop
    nop
    auipc t0,3
.end:
    beq x0, x0, .end
