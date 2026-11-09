global _start
section .text
_start:
    mov rax, 0      ; sum
    mov rcx, 1      ; counter

sum_loop:
    add rax, rcx
    inc rcx
    cmp rcx, 10
    jle sum_loop

    mov rdi, rax
    mov rax, 60
    syscall
