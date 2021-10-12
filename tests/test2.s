.text

string:     .asciz "\33[5m%ld %ld %ld\33[0m\n"

.global main

main:
    push    %rbp
    movq    %rsp, %rbp

    movq    $0, %rax
    movq    $string, %rdi
    movq    $2, %rsi
    movq    $4, %rdx
    movq    $3, %rcx

    call    printf

    movq    $0, %rax

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rdi
    call exit