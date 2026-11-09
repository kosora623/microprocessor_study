global _start
section .text
_start:
    mov rax, 10
    mov rbx, 20
    xchg rax, rbx

    mov rdi, 0
    mov rax, 60
    syscall
