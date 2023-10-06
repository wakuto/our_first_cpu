.section .text
.global _start
_start:
    # スタックの初期化
    addi sp, x0, 1023

    addi a0, x0, 10
    call fibonacchi

.end:
    beq x0, x0, .end

# n: a0(x10)
# return: a0(x10)
fibonacchi:
    # if (n == 0) return n;
    addi t0, x0, 0
    beq a0, t0, .return_a0

    # if (n == 1) return n;
    addi t0, x0, 1
    beq a0, t0, .return_a0

    # return fibonacchi(n - 1) + fibonacchi(n - 2);
    # 戻り番地をスタックに保存
    addi sp, sp, -12
    sw ra, 0(sp)

    # s0, s1 をスタックに保存
    sw s0, 4(sp)
    sw s1, 8(sp)

    # n を s0 に保存
    add s0, x0, a0

    # t1 = fibonacchi(n - 1)
    addi a0, s0, -1
    jal ra, fibonacchi
    add s1, x0, a0

    # a0 = t1 + fibonacchi(n-2)
    addi a0, s0, -2
    jal ra, fibonacchi
    add a0, s1, a0

    # スタックの復帰
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 12

.return_a0:
    ret
