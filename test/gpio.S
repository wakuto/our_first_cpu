.equ GPIO_ADDRESS_IN, 0xA0000000
.equ GPIO_ADDRESS_OUT, 0xA0000100
    .global _start

_start:
    li      t1, 0x87654321                # 書き込む値をt1にロード
    li      t0, GPIO_ADDRESS_OUT          
    sw      t1, 0(t0)                     
    lw      s0, 0(t0)         
            
    li      t0, GPIO_ADDRESS_IN
    lw      s1, 0(t0)
.end:
    beq x0, x0, .end