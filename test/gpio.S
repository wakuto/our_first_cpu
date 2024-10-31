.equ GPIO_ADDRESS_IN, 0xA0000000
.equ GPIO_ADDRESS_OUT, 0xA0000100
    .global _start

_start:
    li      t1, 0x87654321                # 書き込む値をt1にロード
    li      t0, GPIO_ADDRESS_OUT          # GPIOのOUTPUTアドレスをt0にロード
    sw      t1, 0(t0)                     # GPIOのOUTPUTアドレスにt1をストア
    lw      s0, 0(t0)                     # GPIOのOUTPUTアドレスから値を読み取りs0にロード
    li      t0, GPIO_ADDRESS_IN           # GPIOのINPUTアドレスをt0にロード
    sw      t1, 0(t0)                     # GPIOのINPUTアドレスにt1をストア
.end:
    beq x0, x0, .end