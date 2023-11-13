.section .text
.global _start
_start:
    addi t0,x0,100
    addi t1,x0,-1001

    sb t1, 0(t0)
    sb x0, 1(t0)
    sb x0, 2(t0)
    sb x0, 3(t0)

    sh t1, 4(t0)
    sh x0, 6(t0)

    sw t1, 8(t0)

    lw s0, 0(t0)
    lw s1, 4(t0)
    lw s2, 8(t0)

.end:
    beq x0, x0, .end
