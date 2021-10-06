.text

.include "final.s"

bgfgchar:	.asciz "\33[38;5;%ldm\33[48;5;%ldm%c"
specialchar:    .asciz "\33[%ldm"

specialchars:
    .byte   0x00    #normal
    .byte   0x25    #stop blinknig
    .byte   0x2A    #bold
    .byte   0x42    #faint
    .byte   0x69    #conceal
    .byte   0x99    #reveal
    .byte   0xB6    #blink

ansicodes:
    .byte   0x00
    .byte   0x19
    .byte   0x01
    .byte   0x02
    .byte   0x08
    .byte   0x1C
    .byte   0x06

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
	popq	%rsi			#Pop the base address into %rsi
	movq	%rsi, %rdi		#Copy the base address to the current char address
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
	movzb	(%rdi), %r8 	#The character that needs to be written
	movzb	1(%rdi), %rcx	#How many times character needs to be written
    movzb	6(%rdi), %r12	#The bg color
    movzb	7(%rdi), %r13	#The fg color

    pushq	%rdi

	cmpq	$0, %rcx
	jl		endcycle

    cmpq    %r12, %r13
    je      special 
    jmp     nonspecial

special:
    call    specialprint
    movq    %r14, %rsi
    movq    %r15, %rdx
    jmp     cycle2


nonspecial:
    movq    %r12, %rsi
    movq    %r13, %rdx
    movq    %rsi, %r14
    movq    %rdx, %r15
    

cycle2:
	call	printchar
	popq	%rdi


endcycle:
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
	movl	2(%rdi), %ecx	#Move next index to %rcx
	cmpq	$0, %rcx		#If next index==0 
	je		end				#end program

	pushq	%rsi			#Push base address to the stack

	movq	%rsi, %rax		#Move base MESSAGE address to %rax
	call 	nextindex		#Adds 8*%rcx bytes to MESSAGE address to go to next char address
	movq	%rax, %rdi


	call 	cycle			#After new address is put into %rdi go to cycle, which returns %rdi(char address)

	popq	%rsi			#Pop the base address into %rsi
	jmp		nextcycle


end:
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
#Takes 4 arguments
#%rcx, which is the amount of times char needs to be printed
#and %rsi, which is the bg color ansi code
#and %rdx, which is the fg color ansi code
#and %r8, which is the char ascii code
#Returns nothing
printchar:
	pushq	%rcx
	pushq	%rsi
    pushq   %rdx
    pushq   %r8

	movq	$0, %rax
	movq	$bgfgchar, %rdi
    movq    %r8, %rcx

	call 	printf

    popq    %r8
    popq    %rdx
	popq	%rsi
	popq	%rcx

	loop	printchar
	ret


#Takes 1 argument
#%rsi, which includes the specialty ansi code
specialprint:
    pushq   %rbx
    pushq   %rcx
    pushq   %r8


    movq    $0, %rbx
    movq    $specialchars, %rax
    movq    $ansicodes, %rbx
    call    getspecialansi

    movq    $0, %rax
    movq    $specialchar, %rdi
    call    printf
    
    popq    %r8
    popq    %rcx
    popq    %rbx

    ret

getspecialansi:
    movzb   (%rax), %rdi
    cmpq    %r12, %rdi
    je      getspecialansiend

    addq    $1, %rax
    addq    $1, %rbx
    jmp     getspecialansi

getspecialansiend:
    movzb    (%rbx), %rsi
    ret

