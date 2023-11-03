.section .text
.global _start
_start:
    # jalr test code
    addi x4, x0, 32
    jalr x5, x4, 0
    # jal x5,L1
    addi x7, x0, 100
    nop
    nop
    nop
    nop
    nop

L1:
    addi x6, x0, 10
    
.end:
    beq x0, x0, .end