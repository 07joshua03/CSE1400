.data

.include "testdata.s"

.text

.global main

main:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $h, %rax
    movq    $w, %rdi
    movq    $0, %rsi
    movl    $0xFFFFFFFF, %edx
    call    writeword

    movq    %rbp, %rsp
    popq    %rbp
    call    exit

#   Takes 3 arguments
#   %rdi, The base word address w[0]
#   %rsi, The index in which data needs to be written w[X]
#   %edx, The data(32-bit word) which needs to be written
#   Returns nothing but writes w[%rsi]
#   Changes %rax, %rdx and %r8
writeword:
	pushq	%rbp
	movq	%rsp, %rbp

    movq	%rsi, %rax
	movq	$4, %r8
	mulq	%r8
	leaq	(%rax, %rdi), %r8
        movl    $0xFFFFFFFF, %edx
	movl	%edx, (%r8)

	
    movq	%rbp, %rsp
	popq	%rbp
	ret
