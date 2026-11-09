.text
.globl _start
_start:
    li t0, 0        # sum
    li t1, 1        # counter

sum_loop:
    add  t0, t0, t1
    addi t1, t1, 1
    li   t2, 10
    ble  t1, t2, sum_loop
    # t0 = 55

    mv a1, t0       # print_intに渡す値
    li a0, 1        # ecall規約(Venus拡張): a0=サービス番号, print_int=1
    ecall

    li a0, 10       # exit=10
    ecall
