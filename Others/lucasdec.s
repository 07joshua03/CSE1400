.text

.include "final.s"

character: .asciz "%c"

.global main

# ********************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ********************
main:
	#prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	#epilogue
	movq	%rbp, %rsp
	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	pushq	%rdi
	call    first_char	
		popq %rdi

	movq	%rax, %rsi

	call  	decode_loop	

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

first_char:
	#prologue
	pushq	%rbp
	movq	%rsp, %rbp

	pushq	%rdi
	movzb	(%rdi), %rsi    # character to print
	movzb	1(%rdi), %rdi 	# amount of times to print

	call 	print_char		

	popq	%rdi			#pop the value of the top of the stack into rdi

	movq	$0, %rax		
	movl	2(%rdi), %eax	#move the index into eax

	#epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret


decode_loop:
	#prologue
	pushq	%rbp
	movq	%rsp, %rbp

	movq	%rsi, %rcx		#move the current index into rcx
	jmp		decode_loops

decode_loops:
	cmpq	$0, %rcx		#check if the amount of numbers to be printed is greater than 0
	jle		decode_loop_end	#if so jump to decode_loop_end

	pushq	%rdi 			#
	shlq	$3, %rcx		#shift 3 bits, so multiply by 2^3
	addq	%rcx, %rdi 		#address of char n

	pushq	%rdi
	movzb	(%rdi), %rsi    #character to print
	movzb	1(%rdi), %rdi 	#amount of times to print

	call 	print_char		

	popq	%rdi			#pop the top stack value into rdi

	movq	$0, %rcx		
	movl	2(%rdi), %ecx	#move the index into ecx

	popq	%rdi			#pop the top stack value into rdi

	jmp		decode_loops


decode_loop_end:
	#epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret


print_char:
	#prologue
	pushq	%rbp
	movq	%rsp, %rbp

	jmp 	print_char_loop

print_char_loop:
	cmpq	$0, %rdi			#check if the value in rdi is smaller than or equal to 0
	jle  	print_char_end		#if true, jump to print_char_end

	pushq	%rdi				#push the value of %rdi onto the stack
	pushq	%rsi				#push the value of %rsi onto the stack
	movq	$0, %rax			#no vector registers in use for printf
	movq	$character, %rdi	#move character to print into rdi
	call 	printf				#print said character
	popq	%rsi				
	popq    %rdi
	decq    %rdi				#decrement the value of rdi by 1
	jmp     print_char_loop 	#call print_char_loop again


print_char_end:
	#epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret