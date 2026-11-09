break _start
run
stepi 2
printf "=== BEFORE xchg (expect rax=10, rbx=20) ===\n"
info registers rax rbx
stepi 1
printf "=== AFTER xchg (expect rax=20, rbx=10) ===\n"
info registers rax rbx
quit
