.text
.globl _start
_start:
    li t1, 10
    li t2, 20

    bge t1, t2, t1_is_bigger

    mv t3, t2
    j  do_exit

t1_is_bigger:
    mv t3, t1

do_exit:
    li a0, 10          # ecall規約(Venus拡張): a0=サービス番号, exit=10
    ecall
