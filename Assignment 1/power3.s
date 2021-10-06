.text

output1:    .asciz "\nWelcome to the best calculator! Please give a number: "
input:      .asciz "%ld"
output2:    .asciz "\nPlease give a second number: "
output3:    .asciz "\n\nThe solution to %ld^%ld is: %ld\n\n"


.global main

main:

    pushq   %rbp
    movq    %rsp, %rbp

    movq    $output1, %rdi
    call    inout
    movq    %rax, %r12

    movq    $output2, %rdi
    call    inout
    movq    %rax, %rsi

    movq    %r12, %rdi
    call    calc
    
    movq    $0, %rax
    movq    $output3, %rdi
    call    printf
    movq    $0, %rax

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rdi
    call exit


#Takes 1 argument, %rdi, which holds the output text
#Returns number %rax
inout:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $0, %rax
    call    printf

    movq    $0, %rax
    movq    $input, %rdi
    subq    $16, %rsp
    leaq    -16(%rbp), %rsi

    call scanf

    movq    -16(%rbp), %rax
    addq    $16, %rsp

    movq    %rbp, %rsp
    popq    %rbp
    ret

#Takes %rdi and %rsi as base and exponent
#Returns %rsi, %rdx and %rcx as outputs for final
calc:
    pushq   %rbp
    movq    %rsp, %rbp

    cmpq    $0, %rdi
    jle     calc_zero

    movq    $1, %rax
    movq    %rsi, %rcx
    jmp     calc_loop

    
calc_loop:
    cmpq    $0, %rcx
    jle     calc_end

    mulq    %rdi
    decq    %rcx
    jmp    calc_loop

calc_zero:
    movq    $0, %rax
    jmp     calc_end


calc_end:
    movq    %rax, %rcx
    movq    %rax, %r8
    movq    %rsi, %rdx
    movq    %rdi, %rsi
    movq    %rbp, %rsp
    popq    %rbp
    ret
    