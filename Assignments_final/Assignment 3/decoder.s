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

	# your code goes here
	
	pushq	%rdi
	call	cycle			#Print the first char (and the correct amount of times)
	popq	%rdi			#Pop the base address into %rsi
	call 	nextcycle

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret




#Takes 1 argument, %rdi, which contains the char address of the MESSAGE
#Does not return anything
#The small loop which prints the first character 
#And then gets called by nextcycle to print new chars
cycle:
	pushq	%rbp
	movq	%rsp, %rbp

	movzb	(%rdi), %rsi	#The character that needs to be written
	movzb	1(%rdi), %rcx	#How many times character needs to be written

	cmpq	$0, %rcx
	jle		nextcycle

	pushq	%rdi
	call	printchar
	popq	%rdi

	movq	%rbp, %rsp
	popq	%rbp

	ret


#Main loop
#Takes 2 arguments:
#%rdi, which is the current char address
#%rsi, which is the base MESSAGE address
#Returns 1 argument, %rdi, which holds the new char address
#If the index of the curr char is 0 it ends the program, otherwise it loads the new
#char address and calls cycle to print it
#Ensure that the base address is at the top of the stack when called
nextcycle:
	pushq	%rbp
	movq	%rsp, %rbp

nextcycle_loop:
	movl	2(%rdi), %ecx	#Move next index to %rcx
	cmpq	$0, %rcx		#If next index==0 
	je		end				#end program

	pushq	%rsi			#Push base address to the stack

	movq	%rsi, %rax		#Move base MESSAGE address to %rax
	call 	nextindex		#Adds 8*%rcx bytes to MESSAGE address to go to next char address
	movq	%rax, %rdi


	call 	cycle			#After new address is put into %rdi go to cycle, which returns %rdi(char address)

	popq	%rsi			#Pop the base address into %rsi
	jmp		nextcycle_loop


end:
	movq	%rbp, %rsp
	popq	%rbp
	ret						#return to decode function


#Takes 2 arguments, 
#%rax, the base MESSAGE address, 
#and %rcx, which is the amount of quads it needs to move the base address
#Returns the new address for the next char in %rax
nextindex:
	addq	$8, %rax		#Add 8 to base address(%rax)
	loop	nextindex		#Loop %rcx times
	ret

#Printchar function
#Takes 2 arguments
#%rcx, which is the amount of times char needs to be printed
#and %rsi, which is the char
#Returns nothing
printchar:
	pushq	%rcx
	pushq	%rsi

	movq	$0, %rax
	movq	$char, %rdi

	call 	printf
	movq	$0, %rax

	popq	%rsi
	popq	%rcx

	loop	printchar
	ret
