.section .text
.global _start
_start:
    lui x1, 0x10010
    addi t1, x0, 10
    sb t1, 0(x1)

    # lui t2, 0x198
    sb t2, 100(x1)

.end:
    beq x0, x0, .end
