.text
main:
    li t1, 100
    li t2, 200

    add t0, t1, x0
    add t1, t2, x0
    add t2, t0, x0

    li a0, 10
    ecall