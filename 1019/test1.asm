.data
mes1: .asciiz "TRUE\n"
mes2: .asciiz "FLASE\n"

.text
main:
    li t0, 20
    li t1, 10
    
else_part:
    la a1, mes2
    li a0, 4
    ecall
    j endif

then_part:
    la a1, mes1
    li a0, 4
    ecall

endif: 
    li a0, 10
    ecall