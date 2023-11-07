.section .text
.global _start
_start:
    addi t0,x0,100
    addi t1,x0,-1000
    sb t1, 0(t0)
    sh t1, 1(t0)
    sw t1, 2(t0)

    lw s0, 0(t0)
    lw s1, 1(t0)
    lw s2, 2(t0)

.end:
    beq x0, x0, .end
