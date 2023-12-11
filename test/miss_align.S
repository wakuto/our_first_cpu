.section .text
.global _start
_start:
    lui t0, 0x90000
    lui t1, 0x12345
    addi t1, t1, 0x678

    sw t1, 1(t0)
    sw t1, 5(t0)

    lw s0, 0(t0)
    lw s1, 4(t0)
    lw s2, 8(t0)

    sw t1, 0(t0)
    sw t1, 4(t0)

    lw s0, 0(t0)
    lw s1, 4(t0)

.end:
    beq x0, x0, .end
