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
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************

#rdx holds the character
#rcx holds the index
#r8 holds the amount

main:

	#prologue
	pushq 	%rbp				#push the base pointer
	movq 	%rsp, %rbp			#copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi		#first parameter: address of the message
	call	decode				#call decode

	#epilogue
	movq	%rbp, %rsp			#clear local variables from stack
	popq	%rbp				#restore base pointer location

	movq	$0, %rdi			#load program exit code
	call	exit				#exit the program

decode: 
	
	#prologue
	pushq 	%rbp				#push the base pointer
	movq 	%rsp, %rbp			#copy stack pointer value to base pointer

	call 	firstcycle 			#call the first cycle
	call 	decodeloopstart		#call the start of the loop

	#epilogue
	movq	%rbp, %rsp			#clear local variables from stack
	popq	%rbp				#restore base pointer location

	ret  						#return to main

firstcycle:

	#prologue
	pushq 	%rbp				#push the base pointer
	movq 	%rsp, %rbp			#copy stack pointer value to base pointer

	pushq 	%rdi 				#push rdi to make sure it will hold the same address after calling the subroutine  
	movq 	$0, %rsi  			#move 0 into rsi so that rsi holds the right index

	call 	readamount 			#call the subroutine readamount

	popq 	%rdi 				#pop rdi to make sure it holds the same address as before calling the subroutine
	movq 	%rax, %r8 			#move the return, that's in rax, into r8 so that r8 holds the amount
	pushq	%rdi 				#push rdi to make sure it will hold the same address after calling the subroutine  
	movq 	$0, %rsi  			#move 0 into rsi so that rsi holds the right index

	call  	readcharacter 		#call the subroutine readcharacter

	popq  	%rdi  				#pop rdi to make sure it holds the same address as before calling the subroutine
	movq 	%rax, %rdx 			#move the return, that's in rax, into rdx so that rdx holds the character
	pushq 	%rdi  				#push rdi to make sure it will hold the same address after calling the subroutine  
	movq 	%r8, %rsi 			#move the amount into rsi

	call  	printloopstart 		#call the subroutine printloopstart

	popq  	%rdi 				#pop rdi to make sure it holds the same address as before calling the subroutine
	pushq 	%rdi  				#push rdi to make sure it will hold the same address after calling the subroutine  
	movq	$0, %rsi  			#move 0 into rsi so that rsi holds the right index

	call 	readnextindex		#call the subroutine readnextindex

	popq 	%rdi  		 		#pop rdi to make sure it holds the same address as before calling the subroutine		
	movq 	%rax, %rcx 			#move the return, that's in rax, into rcx so that rcx holds the index for the next loop

	#epilogue
	movq %rbp, %rsp 			#clear local variables from stack
	popq %rbp					#restore base pointer location

	ret 						#return to decode

decodeloopstart:

	#prologue
	pushq 	%rbp				#push the base pointer
	movq 	%rsp, %rbp			#copy stack pointer value to base pointer

	jmp 	decodeloop 			#jump to decodeloop

decodeloop:

	pushq 	%rdi  				#push rdi to make sure it will hold the same address after calling the subroutine  
	movq 	%rcx, %rsi  		#move rcx into rsi so that rsi holds the right index

	call 	readamount 			#call subroutine readamount

	popq 	%rdi  				#pop rdi to make sure it holds the same address as before calling the subroutine
	movq 	%rax, %r8 			#move the return, that's in rax, into r8 so that r8 holds the amount
	pushq	%rdi 				#push rdi to make sure it will hold the same address after calling the subroutine  
	movq 	%rcx, %rsi 			#move rcx into rsi so that rsi holds the right index

	call  	readcharacter 		#call subroutine readcharacter

	popq  	%rdi 				#pop rdi to make sure it holds the same address as before calling the subroutine
	movq 	%rax, %rdx  		#move the return, that's in rax, into rdx so that rdx holds the character
	pushq 	%rdi 				#push rdi to make sure it will hold the same address after calling the subroutine  
	movq 	%r8, %rsi 			#move the amount into rsi

	call  	printloopstart 		#call the subroutine printloopstart

	popq  	%rdi 				#pop rdi to make sure it holds the same address as before calling the subroutine
	pushq 	%rdi 				#push rdi to make sure it will hold the same address after calling the subroutine  
	movq 	%rcx, %rsi 			#move rcx into rsi so that rsi holds the right index

	call 	readnextindex 		#call the subroutine readnextindex

	popq 	%rdi 				#pop rdi to make sure it holds the same address as before calling the subroutine
	movq 	%rax, %rcx 			#move the return, that's in rax, into rcx so that rcx holds the index for the next loop

	cmp 	$0, %rcx 			#check whether the next index is 0
	je  	decodeloopend		#if the next index is 0, end the loop by jumping to decodeloopend

	jmp 	decodeloop			#if the next index is not 8, repeat the loop
	

decodeloopend: 

	#epilogue
	movq 	%rbp, %rsp 			#clear local variables from stack
	popq 	%rbp				#restore base pointer location
	
	ret 						#return to decode

readcharacter:

	#prologue
	pushq 	%rbp				#push the base pointer
	movq 	%rsp, %rbp			#copy stack pointer value to base pointer

	movq 	$8, %rax 			#move 8 to rax, because the used memory is 8 bytes each time
	mulq	%rsi 				#multiply with rsi, which holds the index
	add 	%rax, %rdi  		#add the value in rax to rdi, so that rdi is pointing to the right memory block
	movzb	(%rdi), %rax 		#move the value that rdi is pointing to into rax and add 0's in front of it so that rax holds 64 bits

	#epilogue
	movq	%rbp, %rsp			#clear local variables from stack
	popq	%rbp				#restore base pointer location

	ret 						#return from the subroutine

readamount:

	#prologue
	pushq 	%rbp				#push the base pointer
	movq 	%rsp, %rbp			#copy stack pointer value to base pointer

	movq 	$8, %rax 			#move 8 to rax, because the used memory is 8 bytes each time
	mulq	%rsi  				#multiply with rsi, which holds the index
	add 	%rax, %rdi 			#add the value in rax to rdi, so that rdi is pointing to the right memory block
	add 	$1, %rdi  			#add 1 to rdi, so that rdi is pointing to the amount
	movzb	(%rdi), %rax 		#move the value that rdi is pointing to into rax and add 0's in front of it so that rax holds 64 bits

	#epilogue
	movq	%rbp, %rsp			#clear local variables from stack
	popq	%rbp				#restore base pointer location

	ret 						#return from the subroutine

readnextindex: 

	#prologue
	pushq 	%rbp				#push the base pointer
	movq 	%rsp, %rbp			#copy stack pointer value to base pointer

	movq 	$8, %rax 			#move 8 to rax, because the used memory is 8 bytes each time
	mulq	%rsi 				#multiply with rsi, which holds the index
	add 	%rax, %rdi   		#add the value in rax to rdi, so that rdi is pointing to the right memory block
	add 	$2, %rdi 			#add 2 to rdi, so that rdi is pointing to the next index
	movl	(%rdi), %eax  		#move the 32 bits that rdi is pointing to into eax to return 

	#epilogue
	movq	%rbp, %rsp			#clear local variables from stack
	popq	%rbp				#restore base pointer location

	ret 						#return from the subroutine
	

printloopstart: 

	#prologue
	pushq 	%rbp				#push the base pointer
	movq 	%rsp, %rbp			#copy stack pointer value to base pointer

	jmp		printloop 			#jump to printloop

printloop:
	
	cmp 	$0, %rsi 			#check whether the amount the character should be printed is 0
	je 		printloopend		#if the amount is 0, end the loop by jumping to printloopend

	decq 	%rsi 				#decrement the amount 

	pushq 	%rcx 				#push rcx to make sure it will hold the index again after calling printf
	pushq 	%rsi 				#push rsi to make sure it will hold the amount again after calling printf

	movq	%rdx, %rsi 			#copy letter to rsi
	movq	$0, %rax 			#no vector registers in use for printf
	movq	$character, %rdi 	#load string into rdi

	call    printf				#call printf to print

	popq 	%rsi  				#pop rsi to make sure it holds the same amount as before calling printf
	popq 	%rcx 				#pop rcx to make sure it holds the same index as before calling printf

	jmp 	printloop 			#repeat the loop

printloopend: 

	#epilogue
	movq	%rbp, %rsp			#clear local variables from stack
	popq	%rbp				#restore base pointer location

	ret 						#return from the subroutine
