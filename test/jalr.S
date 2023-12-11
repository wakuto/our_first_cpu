.section .text
.global _start
_start:
    # jalr test code
    lui x4, 0x80000
    jalr x5, x4, 32
    addi x9, x0, 100
    jal x10, .end
    nop
    nop
    nop
    nop
    nop

L1:
    addi x6, x0, 10
    add x7, x5, x0
    jalr x8, x5, 0
    
.end:
    beq x0, x0, .end
