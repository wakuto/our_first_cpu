.section .text
.global _start
_start:
    lw x6, 3(x0)
    lw x7, 4(x0)
    or x8, x6, x7
    sw x8, 32(x0)
    beq x0, x0, _start
