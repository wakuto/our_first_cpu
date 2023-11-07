.section .text
.global _start
_start:
    addi t0,x0,100
    addi t1,x0,-1000
    sw t1, 0(t0)
    addi t2,x0,-500
    sw t2, 10(t0)

    lb      s0, 0(t0)
    lh      s1, 0(t0)
    lw      s2, 0(t0)
    lbu     s3, 0(t0)
    lhu     s4, 0(t0)

    lw      s5, 10(t0)

.end:
    beq x0, x0, .end
