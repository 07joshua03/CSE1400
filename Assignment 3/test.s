.text

.include "helloWorld.s"

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value             movb    movw    movl    movq                        *
# ****************************************1******2*******4*******8

.global main

main:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $0, %rax
    movq    $0, %rbx
    movq    $0, %rcx
    movq    $0, %rdx


    movq    $MESSAGE, %rdi

    movb    (%rdi), %al
    movb    1(%rdi), %bl
    movl    2(%rdi), %ecx
    movw    6(%rdi), %dx


    movq    %rbp, %rsp
    popq    %rbp
    ret

