.section .text
.global _start
_start:
    #s0 = -3
    addi s0, x0, -3

    #s1 = -3 < 1 = 1
    slti s1, s0, 1

    #s2 = デカい数 < 1 = 0 
    sltiu s2, s0, 1

    #s3 = 1101 | 1011 = 1111 = -1
    ori  s3, s0, -5

    #s4 = 1101 & 1110 = 1100 = -4
    andi s4, s0, -2

    #s5 = 1100 << 2 = 110000 = -16
    slli s5, s4, 2

    #s6 = 1....1000 >> 3 = 001...10
    srli s6, s5, 3

    #s7 = 1...10000 >>> 3 = 1...10 = -2
    srai s7, s5, 3

    #s8 = 1101 ^ 1011 = 0110 = 6
    xori s8, s0, -5

.end:
    beq x0, x0, .end
