.text

welcome:   .asciz "Welcome! Please put in a number: "
input:     .asciz "%ld"
input2:     .asciz "%ld"
exponent:  .asciz "\nPlease give an exponent: "
output:    .asciz "\n\nThe solution is: %ld\n"


.global main

main:
    pushq   %rbp
    movq    %rsp, %rbp
    
    #Printing First message
    movq    $0, %rax
    movq    $welcome, %rdi

    call    printf

    #Scanning for number
    movq    $0, %rax

    subq    $16, %rsp
    movq    $input, %rdi
    leaq    -16(%rbp), %rsi

    call    scanf
    movq    %rsi, %r13


    #Printing exponent text
    movq    $0, %rax
    movq    $exponent, %rdi
    call    printf


    #Scanning for exponent
    movq    $0, %rax

    subq    $16, %rsp
    movq    $input, %rdi
    leaq    -16(%rbp), %rsi

    call    scanf


    #Calculating number
    movq    %rsi, %rdi  #counting number
    movq    %r13, %rsi  #base number
    movq    $1, %rax  #sol mumber
    
    call    calc

    #Printing solution

calc:
    cmp     $0, %rdi
    je      end

    mulq    %rsi
    subq    $1, %rdi

    jmp     calc

end:
    movq    %rax, %rsi
    movq    $0, %rax
    movq    $output, %rdi
    call    printf
    movq    $0, %rax

    movq    %rbp, %rsp
    popq    %rbp
    ret
    