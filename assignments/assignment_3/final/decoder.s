.text

.include "final.s"

char:	.asciz "%c"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************
main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	movq	%rbp, %rsp
	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program


decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    pushq   %rdi
    call    firstchar
    popq    %rdi
    movq    %rax, %rsi
    call    chars


	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

firstchar:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    movzb	1(%rdi), %rsi	#How many times character needs to be written
    movzb	(%rdi), %rdi	#The character that needs to be written
    call    print

    popq    %rdi
    movq    $0, %rax
    movl	2(%rdi), %eax	#Move next index to %rax
    

    movq    %rbp, %rsp
    popq    %rbp
    ret

print:
    pushq   %rbp
    movq    %rsp, %rbp
    jmp     print_loop

print_loop:
    cmpq    $0, %rsi
    jle     print_end

    pushq   %rdi
    pushq   %rsi
    call    print_char
    popq    %rsi
    popq    %rdi
    decq    %rsi
    jmp     print_loop


print_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret


print_char:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $0, %rax
    movq    %rdi, %rsi
    movq    $char, %rdi

    call    printf

    movq    %rbp, %rsp
    popq    %rbp
    ret

chars:
    pushq   %rbp
    movq    %rsp, %rbp

chars_loop:
    cmpq    $0, %rsi
    jle     chars_end

    pushq   %rdi
    shlq    $3, %rsi
    addq    %rsi, %rdi
    pushq   %rdi
    movzb	1(%rdi), %rsi	#How many times character needs to be written
    movzb	(%rdi), %rdi	#The character that needs to be written
    call    print

    popq    %rdi
    movq    $0, %rsi
    movl	2(%rdi), %esi	#Move next index to %rax
    popq    %rdi

    jmp     chars_loop
    

chars_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret
    