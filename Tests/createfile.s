.text

.global main

filepath:   .asciz "/home/student/TUDelft/Assembly/tests/newfile.txt"
message:    .asciz "This should work!"

main:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $2, %rax
    movq    $filepath, %rdi
    movq    $0102, %rsi
    movq    $00700, %rdx

    syscall

    movq    %rax, %rdi
    movq    $1, %rax
    movq    $message, %rsi
    movq    $17, %rdx

    syscall

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rdi
    call    exit

