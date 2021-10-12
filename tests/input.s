.text

hi:     .asciz "Please input a number: "
input:  .asciz "%ld"
output: .asciz "\nThe number put in is: %ld\n\n"

.global main

main:
    pushq    %rbp           
    movq     %rsp, %rbp

    call     docoolstuff

    movq     %rbp, %rsp  
    popq     %rbp

    ret

docoolstuff:
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

    movq    $0, %rax
    movq    $output, %rdi  
    call    printf


    movq     %rbp, %rsp
    popq     %rbp
    ret
