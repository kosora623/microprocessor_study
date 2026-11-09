global _start
section .text
_start:
    mov rax, 10
    mov rbx, 20

    cmp rax, rbx
    jge rax_is_bigger

    mov rdi, rbx
    jmp do_exit

rax_is_bigger:
    mov rdi, rax

do_exit:
    mov rax, 60
    syscall
