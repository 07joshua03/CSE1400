.text

.include "final.s"

char:           .asciz "%c"
colorchar:      .asciz "\33[38;5;%ldm\33[48;5;%ldm"
specialchar:    .asciz "\33[%ldm"
resetchar:          .asciz "\33[m"

specialchars:         #                     (first code per ansi norm, then code per manual)
    .word   0x0000    #normal               (special case)
    .word   0x1925    #stop blinknig
    .word   0x012A    #bold
    .word   0x0242    #faint
    .word   0x0869    #conceal
    .word   0x1C99    #reveal
    .word   0x06B6    #blink


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

    call    reset


	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

reset:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $resetchar, %rdi
    movq    $0, %rax

    call    printf

    movq    %rbp, %rsp
    popq    %rbp
    ret

firstchar:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    movzb	1(%rdi), %rsi	#How many times character needs to be written
    movq    $0, %rdx
    movb    6(%rdi), %dl      
    movb    7(%rdi), %dh
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

    pushq   %rdi
    pushq   %rsi
    cmpb    %dl, %dh
    je      print_special
    jmp     print_color

print_color:
    movq    $colorchar, %rdi
    movzb   %dl, %rsi
    movb   %dh, %dl
    movzb   %dl, %rdx
    movq    $0, %rax

    call    printf

    jmp     print_

print_special:
    movq    $specialchars, %rsi

print_special_loop:
    cmpb    %dl, (%rsi)
    je      print_special_end

    addq    $2, %rsi
    jmp     print_special_loop

print_special_end:
    incq    %rsi
   movzb     (%rsi), %rsi
   movq     $specialchar, %rdi
   movq     $0, %rax
   call     printf

   jmp      print_


print_:
    popq    %rsi
    popq    %rdi
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
    movq    $8, %rax
    mulq    %rsi
    addq    %rax, %rdi
    pushq   %rdi
    movzb	1(%rdi), %rsi	#How many times character needs to be written
    movq    $0, %rdx
    movb    6(%rdi), %dl      
    movb    7(%rdi), %dh
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
    
