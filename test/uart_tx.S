.section .text
.global _start
_start:
    lui x1, 0x10010
    addi t1, x0, 0x46
    sb t1, 0(x1)

    lui t2, 0xf
    sw t2, 256(x1)

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    addi t1, x0, 0x22
    sb t1, 0(x1)

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    addi t1, x0, 0x37
    sb t1, 0(x1)

.end:
    beq x0, x0, .end
