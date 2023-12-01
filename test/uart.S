.section .text
.global _start
_start:
    lui x1, 0x10010 # rw: 32'h10010000 status: 32'h10010005
    addi t1, x0, 1 # 計算用の1
TX1:
    addi t2, x0, 0x46 #txデータ1
    lw s0, 5(x1) #statusの読み出し
    srl s0, s0, 6 # busyフラグを抽出
    beq s0, t1, TX1 # busyフラグが立っていたら送信を待つ
    sb t2, 0(x1) # busyフラグが立っていなかったらUARTにデータを送信

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    


RX1:
    lw s0, 5(x1) # statusの読み出し
    and s0, s0, t1 # read_readyフラグを抽出
    beq s0, x0, RX1 # read_readyフラグが立っていなかったら受信を待つ
    lw s1, 0(x1) # UARTからデータを受信

TX2:
    addi t2, x0, 0x37 #txデータ2
    lw s0, 5(x1) # statusの読み出し
    srl s0, s0, 6 # busyフラグを抽出
    beq s0, t1, TX2 # busyフラグが立っていたら送信を待つ
    sb t2, 0(x1)

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    
RX2:
    lw s0, 5(x1) # statusの読み出し
    and s0, s0, t1 # read_readyフラグを抽出
    beq s0, x0, RX2 # read_readyフラグが立っていなかったら受信を待つ
    lw s1, 0(x1) # UARTからデータを受信

.end:
    beq x0, x0, .end
