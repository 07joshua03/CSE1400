.text

.include "final.s"

.global main

character: .asciz "%c"

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the addqress of the message to read                *
#   return: no return value                                  *
# ************************************************************

#rdx holds the character
#rcx holds the index
#rbx holds the amount

main:

	pushq	%rbp 				#push the base pointer (and align the stack)
	movq	%rsp, %rbp			#copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi		#first parameter: addqress of the message
	call	decode				#call decode

	movq 	%rbp, %rsp 
	popq	%rbp				#restore base pointer location 

	movq	$0, %rdi			#load program exit code
	call	exit				#exit the program

decode: 
	
	#prologue
	pushq	%rbp 				#push the base pointer (and align the stack)
	movq	%rsp, %rbp			#copy stack pointer value to base pointer

	call 	firstcycle
	call 	decodeloop

	#epilogue
	movq	%rbp, %rsp			#clear local variables from stack
	popq	%rbp				#restore base pointer location

	ret  

decodeloop_start:
	#prologue
	pushq 	%rbp				#push the base pointer
	movq 	%rsp, %rbp			#copy stack pointer value to base pointer
	jmp		decodeloop

decodeloop:
	pushq 	%rdi 
	movq 	%rcx, %rsi  

	call 	readamount

	popq 	%rdi 
	pushq	%rdi
	movq 	%rcx, %rsi 

	call  	readcharacter

	popq  	%rdi
	pushq 	%rdi		

	call  	printloop

	popq  	%rdi
	pushq 	%rdi  
	movq 	%rcx, %rsi

	call 	readnextindex

	popq 	%rdi

	cmpq 	$0, %rcx
	je  	end 

	
	jmp 	decodeloop
	ret 

end: 
	#epilogue
	movq %rbp, %rsp 		#clear local variables from stack
	popq %rbp				#restore base pointer locatio

	ret 

readcharacter:
	pushq	%rbp
	movq	%rsp, %rbp

	movq 	$8, %rax
	mulq	%rsi
	addq 	%rax, %rdi  
	movzb	(%rdi), %rdx

	movq	%rbp, %rsp
	popq	%rbp
	ret

readamount:
	pushq	%rbp
	movq	%rsp, %rbp

	movq 	$8, %rax
	mulq	%rsi 
	addq 	%rax, %rdi 
	addq 	$1, %rdi  
	movzb	(%rdi), %rbx

	movq	%rbp, %rsp
	popq	%rbp
	ret

readnextindex: 
	pushq	%rbp
	movq	%rsp, %rbp

	movq 	$8, %rax
	mulq	%rsi 
	addq 	%rax, %rdi  
	addq 	$2, %rdi 
	movzb	(%rdi), %rcx

	movq	%rbp, %rsp
	popq	%rbp
	ret
	
printloop:

	cmpq 	$0, %rbx
	je 		printloopend

	decq 	%rbx

	pushq 	%rdx 
	pushq	%rcx

	movq	%rdx, %rsi 			#copy letter to rsi
	movq	$0, %rax 			#no vector registers in use for printf
	movq	$character, %rdi 	#load string into rdi
	call    printf				#call printf to print

	popq	%rcx
	popq 	%rdx

	jmp 	printloop

printloopend: 

	ret 

firstcycle:

	#prologue
	pushq 	%rbp				#push the base pointer
	movq 	%rsp, %rbp			#copy stack pointer value to base pointer

	pushq 	%rdi 
	movq 	$0, %rsi  

	call 	readamount

	popq 	%rdi 
	pushq	%rdi
	movq 	$0, %rsi 

	call  	readcharacter

	popq  	%rdi
	pushq 	%rdi		

	call  	printloop

	popq  	%rdi
	pushq 	%rdi 
	movq	$0, %rsi 

	call 	readnextindex

	popq 	%rdi

	#epilogue
	movq %rbp, %rsp 		#clear local variables from stack
	popq %rbp				#restore base pointer locatio

	ret
