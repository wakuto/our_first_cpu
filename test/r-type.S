.section .text
.global _start
_start:
    addi t0, x0, 2 # t0 = 2
    add t1, t0, t0 # t1 = 2+2 =4
    or  t2, t1, t0 # t2 = 3'b100 | 3'b010 = 3'b110 = 6
    addi s1, t2, -1 # s1 = 6-1=5
    and t3, t0, t2 # t3 = 3'b010 & 3'b110 =3'b010 = 2
    sub t4, t1, s1 # t4 = 4-5=-1
    slt t5, t0, t1 # t5 = 2<4=1
    addi s1, x0, -3 
    slt t6, s1, t4 # t6 = -3<-1=1
    slt t6, t0, s1 # t6 = 2<-3=0

.end:
    beq x0, x0, .end