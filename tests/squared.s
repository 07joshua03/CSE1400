.text

hi:     .asciz "Please input number: "
input:  .asciz "%ld"
output1: .asciz "\nThe square of %ld"
output2: .asciz " is: %ld\n\n"

.global main

main:
    pushq    %rbp           
    movq     %rsp, %rbp

    call     inputfunc

    movq     %rbp, %rsp  
    popq     %rbp

    ret

inputfunc:
    pushq    %rbp
    movq     %rsp, %rbp

    movq     $0, %rax
    movq     $hi, %rdi
    call     printf

    movq    $0, %rax

    subq    $16, %rsp
    movq    $input, %rdi
    leaq    -16(%rbp), %rsi

    call    scanf

    popq    %rsi
    pushq   %rsi


    movq    $0, %rax
    movq    $output1, %rdi  
    call    printf

    popq    %rsi
    movq    %rsi, %rax
    mulq    %rax
    movq    %rax, %rsi

    movq    $0, %rax
    movq    $output2, %rdi
    call    printf


    movq     %rbp, %rsp
    popq     %rbp
    ret
