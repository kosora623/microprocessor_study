.text
main:
    li t1, 45
    li t2, 80

    bge t1, t2, t1_is_greater

    add t3, t2, x0
    j done

t1_is_greater:
    add t3, t1, x0

done:
    li a0, 10
    ecall