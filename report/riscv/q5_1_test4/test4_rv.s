.data
mes1: .asciz "TRUE\n"
mes2: .asciz "FALSE\n"

.text
.globl _start
_start:
    li   t1, 20
    li   t2, 10

if_cmp:
    beq  t1, t2, then

else_branch:
    la   a1, mes2
    li   a0, 4          # ecall規約(Venus拡張): a0=サービス番号, print_string=4
    ecall
    j    endif

then:
    la   a1, mes1
    li   a0, 4          # print_string=4
    ecall

endif:
    li   a0, 10         # exit=10
    ecall
