    .section .data
GPIO_BASE:    .word 0xA0000000    # GPIOベースアドレス
    .section .text
    .global _start

_start:
    # GPIO出力値を書き込む (0x54321 を GPIO に書き込む)
    la      t0, GPIO_BASE
    li      t1, 0x87654321         # 書き込む値をt1にロード
    sw      t1, 0(t0)              # GPIOベースアドレスに書き込む

    # GPIO入力値を読み取る
    lw      t2, 0(t0)              # GPIOの入力値をt2にロード

.end:
    beq x0, x0, .end

