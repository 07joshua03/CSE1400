.text

MESSAGE:
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000

WORD:
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000


.global main

main:
	pushq	%rbp
	movq	%rsp, %rbp

	movq	$MESSAGE, %rdi
	movq	$WORD, %rsi
	call 	sha1_chunk

	movq	%rbp, %rsp
	popq	%rbp
	call exit

#Take 2 arguments
#%rdi, The address of h0
#%rsi, The address of the first 4-byte word
#Returns nothing bu modifies the addresses h0 till h4
sha1_chunk:
	pushq	%rbp
	movq	%rsp, %rbp


	#Message scheudle: extend the sixteen 32-bit words into eighty 32-bit wordss
	call	messageschedule_start



	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	call	mainloop_start
	popq	%rbx
	popq	%rsi
	popq	%rdi



	movq	%rbp, %rsp
	popq	%rbp
	ret
	
####################################################################################
####################################################################################
#--------------------------------Message schedule----------------------------------#
####################################################################################
####################################################################################


messageschedule_start:
	pushq	%rbp
	movq	%rsp, %rbp

	pushq	%rdi
	pushq	%rsi
	pushq	%rbx

	movq	$16, %rcx
	jmp		messageschedule_loop


messageschedule_end:

	popq	%rbx
	popq	%rsi
	popq	%rdi
	movq	%rbp, %rsp
	popq	%rbp
	ret

messageschedule_loop:
	cmpq	$80, %rcx
	jge		messageschedule_end

	pushq	%rdi		#Base word address
	movq	%rcx, %rsi	#counter between 16 - 79
	movq	$3, %rdx	#Offset a where w[%rcx - %rdx]
	call 	readword	#Returns word data in %eax
	popq	%rdi
	movl	%eax, %ebx

	pushq	%rdi		#Base word address
	movq	%rcx, %rsi	#counter between 16 - 79
	movq	$8, %rdx	#Offset a where w[%rcx - %rdx]
	call 	readword	#Returns word data in %eax
	popq	%rdi
	xorl	%eax, %ebx	#XOR instruction, stored in %ebx

	pushq	%rdi		#Base word address
	movq	%rcx, %rsi	#counter between 16 - 79
	movq	$14, %rdx	#Offset a where w[%rcx - %rdx]
	call 	readword	#Returns word data in %eax
	popq	%rdi
	xorl	%eax, %ebx	#XOR instruction, stored in %ebx

	pushq	%rdi		#Base word address
	movq	%rcx, %rsi	#counter between 16 - 79
	movq	$16, %rdx	#Offset a where w[%rcx - %rdx]
	call 	readword	#Returns word data in %eax
	popq	%rdi
	xorl	%eax, %ebx	#XOR instruction, stored in %ebx

	rcll	$1, %ebx	#Rotate %ebx left once
	movq	%rcx, %rsi
	movq	$0, %rdx
	movl	%ebx, %edx 
	pushq	%rdi
	call	writeword
	popq	%rdi
	
	incq	%rcx
	jmp		messageschedule_loop


#Takes 3 arguments
#%rdi, The base word address w[0]
#%rsi, The index of w w[X-b]
#%rdx, The offset of w w[a-X]
#Returns the data inside w[a-b] at %eax
readword:
	pushq	%rbp
	movq	%rsp, %rbp

	pushq	%rcx
	movq	%rsi, %rax
	subq	%rdx, %rax
	movq	$4, %rcx
	mulq	%rcx
	
	leaq	(%rax, %rdi), %rdi
	movq	$0, %rax
	movl	(%rdi), %eax
	popq	%rcx

	movq	%rbp, %rsp
	popq	%rbp
	ret
	
#Takes 3 arguments
#%rdi, The base word address w[0]
#%rsi, The index in which data needs to be written w[X]
#%edx, The data(32-bit word) which needs to be written
#Returns nothing but write w[%rsi]
writeword:
	movq	%rsi, %rax
	movq	$4, %r8
	mulq	%r8
	leaq	(%rax, %rdi), %rdi
	movl	%edx, (%rdi)
	ret


####################################################################################
####################################################################################
#----------------------------------Main loop---------------------------------------#
####################################################################################
####################################################################################

mainloop_start:
	pushq	%rbp
	movq	%rsp, %rbp

	#Write h0 till h4 to the stack
	pushq	(%rdi)		#A
	pushq	4(%rdi)		#B
	pushq	8(%rdi)		#C
	pushq	12(%rdi)	#D
	pushq	16(%rdi)	#E
	pushq	%rdi

	movq	%rbp, %rdi

	movq	$0, %rcx
	jmp		mainloop_loop


mainloop_loop:
	cmpq	$80, %rcx
	jge		mainloop_end

	pushq	%rdi
	pushq	%rcx
	call	options
	popq	%rcx
	popq	%rdi

	incq	%rcx
	jmp		mainloop_loop


mainloop_end:
	popq	%rdi



	// leaq	4(%rdi), %rax
	// movl	$0, %edi
	// movl	%edi, (%rax)
	movl	(%rdi), %eax	#The data of h0
	movl	(%rbp), %edx	#The data of A
	leaq	(%rdi), %rcx	#The location of h0
	addl	%edx, %eax
	movl	%eax, (%rcx)

	movl	4(%rdi), %eax	#The data of h0
	movl	-8(%rbp), %edx	#The data of A
	leaq	4(%rdi), %rcx	#The location of h0
	addl	%edx, %eax
	 movl	%eax, (%rcx)

	movl	8(%rdi), %eax	#The data of h0
	movl	-16(%rbp), %edx	#The data of A
	leaq	8(%rdi), %rcx	#The location of h0
	addl	%edx, %eax
	movl	%eax, (%rcx)

	movl	12(%rdi), %eax	#The data of h0
	movl	-24(%rbp), %edx	#The data of A
	leaq	12(%rdi), %rcx	#The location of h0
	addl	%edx, %eax
	movl	%eax, (%rcx)

	movl	16(%rdi), %eax	#The data of h0
	movl	-32(%rbp), %edx	#The data of A
	leaq	16(%rdi), %rcx	#The location of h0
	addl	%edx, %eax
	movl	%eax, (%rcx)



	movq	%rbp, %rsp
	popq	%rbp
	ret


####################################################################################
####################################################################################
#------------------------------------Options---------------------------------------#
####################################################################################
####################################################################################


options:
	pushq	%rsi


	cmpq	$19, %rcx
	jle		option_1
	cmpq	$39, %rcx
	jle		option_2
	cmpq	$59, %rcx
	jle		option_3
	cmpq	$79, %rcx
	jle		option_4



#	F - %eax
#	K - %edx
#	Takes %rdi, which has the pointer to A, -8(%rdi) -> B,  etc
option_1:
	#LEFT PART OF EQUATION %EDX
	movl	-8(%rdi), %edx	# B
	movl	-16(%rdi), %eax	# C
	andl	%eax, %edx		#B AND C

	#RIGHT PART OF EQUATION %eax
	movl	-8(%rdi), %eax	# B
	notl	%eax			# NOT B
	movl	-24(%rdi), %ebx	# D
	andl	%ebx, %eax		# (NOT B) AND D

	orl		%edx, %eax		#F in eax

	
	movl	$0x5A827999, %edx

	jmp		option_end


option_2:

	#LEFT PART OF EQUATION %EDX
	movl	-8(%rdi), %ebx	# B
	movl	-16(%rdi), %eax	# C
	xorl	%eax, %ebx		#B XOR C

	#RIGHT PART OF EQUATION %eax
	movl	-24(%rdi), %eax	# D

	xorl	%ebx, %eax		#B xor C xor D -> F

	
	movl	$0x6ED9EBA1, %edx

	jmp		option_end


option_3:
	#LEFT PART OF EQUATION %EDX
	movl	-8(%rdi), %ebx	# B
	movl	-16(%rdi), %eax	# C
	andl	%eax, %ebx		#B AND C

	#RIGHT PART OF EQUATION %eax
	movl	-8(%rdi), %eax	# B
	movl	-24(%rdi), %edx	# D
	andl	%edx, %eax		# B AND D

	orl		%ebx, %eax		#(B and C) or (B and D)

	movl	-16(%rdi), %ebx	# C
	movl	-24(%rdi), %edx	# D
	andl	%ebx, %edx		# C AND D

	orl		%edx, %eax		#(B and C) or (B and D) or (C and D) -> F
	
	movl	$0x8F1BBCDC, %edx


	jmp		option_end


option_4:
	#LEFT PART OF EQUATION %EDX
	movl	-8(%rdi), %edx	# B
	movl	-16(%rdi), %eax	# C
	xorl	%eax, %edx		#B XOR C

	#RIGHT PART OF EQUATION %eax
	movl	-24(%rdi), %eax	# D

	xorl	%edx, %eax		#B xor C xor D -> F

	
	movl	$0xCA62C1D6, %edx

	jmp		option_end


#Takes 3 args,
#	%rdi, which is the base address of A
#	%eax, which holds F
#	%edx, which holds K
option_end:

	popq	%rsi

	pushq	%rdi
	movq	%rdi, %r8

	movq	$0, %rdi
	movl	%eax, %edi		#	%EDI HOLDS F	AND %EDX HOLDS K	AND %R8 HOLDS BASE ADDRESS 

	#Registers Free: %eax, $ecx
	movl	(%r8), %eax		#GET A
	rcll	$5, %eax		#(A LEFTROTATE 5)
	addl	%edi, %eax		#	(A LEFTROTATE 5) + F
	movl	-32(%r8), %edi	#	E
	addl	%edi, %eax		#	(A LEFTROTATE 5) + F + E
	addl	%edx, %eax		#(A LEFTROTATE 5) + F + E + K
	movl	%eax, %ebx


	#%RDI IS SET TO ADDRESS OF w[0]
	movq	%rsi, %rdi
	movq	%rcx, %rsi
	movq	$0, %rdx
	call 	readword

	addl	%ebx, %eax 	#(A LEFTROTATE 5) + F + E + K + w[i]

	popq	%rdi		#Get address of A back in %rdi

	leaq	-32(%rdi), %rdx
	movl	-24(%rdi), %ebx
	movl	%ebx, (%rdx)	# E = D

	leaq	-24(%rdi), %rdx
	movl	-16(%rdi), %ebx
	movl	%ebx, (%rdx)	# D = C

	leaq	-16(%rdi), %rdx
	movl	-8(%rdi), %ebx
	rcll	$30, %ebx
	movl	%ebx, (%rdx)	# C = (B LEFTROTATE 30)

	leaq	-8(%rdi), %rdx
	movl	(%rdi), %ebx
	movl	%ebx, (%rdx)	# B = A

	leaq	(%rdi), %rdx
	movl	%eax, (%rbx)	
	ret


