    .section .data
GPIO_ADDRESS_IN:    .word 0xA0000000
GPIO_ADDRESS_OUT:   .word 0xA0000100
    .section .text
    .global _start

_start:
    # GPIO出力値を書き込む (0x87654321 を GPIO に書き込む)
    la      t0, GPIO_ADDRESS_OUT          # GPIOのOUTPUTアドレスをt0にロード
    li      t1, 0x87654321                # 書き込む値をt1にロード
    sw      t1, 0(t0)                     # GPIOのOUTPUTに値を書き込む

    # GPIO入力値を読み取る
    la      t0, GPIO_ADDRESS_IN           # GPIOのINPUTアドレスをt0にロード
    sw      t1, 0(t0)                     # GPIOのINPUTに値を書き込む
    lw      s0, 0(t0)                     # GPIOのINPUTから値を読み取りs0にロード

.end:
    beq x0, x0, .end