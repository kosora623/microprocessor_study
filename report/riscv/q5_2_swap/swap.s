.text
.globl _start
_start:
    li t1, 10
    li t2, 20

    mv t0, t1
    mv t1, t2
    mv t2, t0
    # ここで t1=20, t2=10 になっている

    li a0, 10          # ecall規約(Venus拡張): a0=サービス番号, exit=10
    ecall
