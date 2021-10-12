.include "sha1_helper.s"

.global sha1_chunk

	#	Takes 2 arguments
	#	%rdi, the base address of h0
	#	%rsi, the base address of w[0]
	#	Returns:
	#	Nothing, but changes h0 till h4
sha1_chunk:
	###########################################
	######			  PROLOGUE	    	#######
	###########################################

	pushq 	%rbp
	movq 	%rsp, %rbp

	subq	$24, %rsp
	movq	$0, -8(%rbp)	#A <- (%rdx) 	& B	<-  -4(%rdx)
	movq	$0, -16(%rbp)	#C <- -8(%rdx)	& D	<- -12(%rdx)
	movq	$0, -24(%rbp)	#E <- -16(%rdx) & K	<- -20(%rdx)
	leaq	-4(%rbp), %rdx	#From this point on %rdx will be the base address of a

	###########################################
	######		MESSAGE SCHEDULE		#######
	###########################################

	pushq	%rdi
	pushq	%rsi
	pushq	%rdx
	subq	$8, %rsp

	movq	%rsi, %rdi

	call	message_schedule

	addq	$8, %rsp
	popq	%rdx
	popq	%rsi
	popq	%rdi

	###########################################
	######			 INIT HASHES  		#######
	###########################################

	pushq	%rdi
	pushq	%rsi
	pushq	%rdx
	subq	$8, %rsp

	movq	%rdx, %rsi	

	call	init_hashes

	addq	$8, %rsp
	popq	%rdx
	popq	%rsi
	popq	%rdi

	###########################################
	######			 MAIN LOOP  		#######
	###########################################

	pushq	%rdi
	pushq	%rsi
	pushq	%rdx
	subq	$8, %rsp

	call	main_loop

	addq	$8, %rsp
	popq	%rdx
	popq	%rsi
	popq	%rdi

	###########################################
	######		 ADD CHUNK RESULT   	#######
	###########################################

	pushq	%rdi
	pushq	%rsi
	pushq	%rdx
	subq	$8, %rsp

	movq	%rdx, %rsi

	call	add_result

	addq	$8, %rsp
	popq	%rdx
	popq	%rsi
	popq	%rdi

	###########################################
	######			  EPILOGUE	    	#######
	###########################################

	addq	$24, %rsp

	movq	%rbp, %rsp
	popq	%rbp
	ret

#	Takes:
#	%rdi <- the base address of w[0]
#	Returns:
#	Nothing, but changes w[16] till w[79]
#	No callee-saved arguments are spared
message_schedule:
	#	Prologue
	pushq	%rbp
	movq	%rsp, %rbp

	movq	$16, %rcx				#Starting from 16, till 79
	jmp		message_schedule_loop


message_schedule_loop:
	##	if %rcx >= 80 stop the loop 	
	##	(so loop loops from %rcx = 16 till %rcx = 79)
	cmpq	$80, %rcx			
	jge		message_schedule_end	

	movq	%rcx, %rsi
	subq	$3, %rsi
	call	read_w		#returns w[%rcx - 3]
	movl	%eax, %edx

	
	movq	%rcx, %rsi
	subq	$8, %rsi
	call	read_w		#returns w[%rcx - 8]

	xorl	%edx, %eax	#w[i-3] xor w[i-8]
	movl	%eax, %edx

	movq	%rcx, %rsi
	subq	$14, %rsi
	call	read_w		#returns w[%rcx - 14]
	

	xorl	%edx, %eax	#(w[i-3] xor w[i-8]) xor w[i-14]
	movl	%eax, %edx	

	movq	%rcx, %rsi
	subq	$16, %rsi
	call	read_w		#returns w[%rcx - 16]

	xorl	%edx, %eax	#((w[i-3] xor w[i-8]) xor w[i-14]) xor w[i-16]

	roll	$1, %eax

	movq	%rcx, %rsi
	movl	%eax, %edx
	call	write_w		#Writes ((w[i-3] xor w[i-8] xor w[i-14] xor w[i-16]) leftrotate 1) to w[%rcx]


	incq	%rcx
	jmp		message_schedule_loop

message_schedule_end:
	#	Epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret

#	Takes:
#	%rdi <- the base address of h0
#	%rsi <- the base address of a
#	Returns:
#	Nothing, but changes a till e
init_hashes:
	pushq	%rbp
	movq	%rsp, %rbp

	movl	(%rdi), %eax
	movl	%eax, (%rsi)
	movl	4(%rdi), %eax
	movl	%eax, -4(%rsi)
	movl	8(%rdi), %eax
	movl	%eax, -8(%rsi)
	movl	12(%rdi), %eax
	movl	%eax, -12(%rsi)
	movl	16(%rdi), %eax
	movl	%eax, -16(%rsi)

	movq	%rbp, %rsp
	popq	%rbp
	ret

#	Takes 3 arguments
#	%rdi <- Base address of h0
#	%rsi <- Base address of w[0]
#	%rdx <- Base address of a
#	Returns:
#	Nothing, but changes a till k
main_loop:
	pushq	%rbp
	movq	%rsp, %rbp

	movq	$0, %rcx
	jmp		main_loop_loop

main_loop_loop:
	cmpq	$80, %rcx
	jge		main_loop_end

	###########################################
	######	  OPTIONS	(4 diff cases) 	#######
	###########################################

	pushq	%rdi
	pushq	%rsi
	pushq	%rdx
	pushq	%rcx

	movq	%rdx, %rdi
	movq	%rcx, %rsi
	call	options
	
	popq	%rcx
	popq	%rdx
	popq	%rsi
	popq	%rdi

	###########################################
	######	 		   TEMP 			#######
	###########################################

	pushq	%rdi
	pushq	%rsi
	pushq	%rdx
	pushq	%rcx

	movq	%rdx, %rdi
	movl	%eax, %edx		#F from options
	call	temp
	
	popq	%rcx
	popq	%rdx
	popq	%rsi
	popq	%rdi

	###########################################
	###### 	  SWITCH A TILL E AROUND 	#######
	###########################################

	pushq	%rdi
	pushq	%rsi
	pushq	%rdx
	pushq	%rcx

	movq	%rdx, %rdi
	movl	%eax, %esi		#temp from temp
	call	switcharound
	
	popq	%rcx
	popq	%rdx
	popq	%rsi
	popq	%rdi

	###########################################
	###### 	  		END OF LOOP 		#######
	###########################################

	incq	%rcx
	jmp		main_loop_loop


main_loop_end:
	movq	%rbp, %rsp
	popq	%rbp
	ret

#	Takes:
#	%rdi <- base address of a
#	%rsi <- i
#	Returns:
#	%rax -> f	also changes k
options:
	pushq	%rbp
	movq	%rsp, %rbp

	cmpq	$19, %rsi
	jle		option_1
	cmpq	$39, %rsi
	jle		option_2
	cmpq	$59, %rsi
	jle		option_3
	cmpq	$79, %rsi
	jle		option_4
	jmp		options_end


option_1:
	movq	$5, %rsi
	movq	$0x5A827999, %rdx	#K
	call	write_a

	movq	$1, %rsi	#B
	call	read_a		
	movl	%eax, %edx

	movq	$2, %rsi	#C
	call	read_a

	andl	%edx, %eax	#B AND C
	movl	%eax, %ecx
	
	movq	$1, %rsi	#B
	call	read_a		
	notl	%eax		#NOT B
	movl	%eax, %edx

	movq	$3, %rsi	#D
	call	read_a	

	andl	%edx, %eax	#(NOT B) AND D
	orl		%ecx, %eax	#(B AND C) OR ((NOT B) AND D) -> F

	jmp		options_end

option_2:
	movq	$5, %rsi
	movq	$0x6ED9EBA1, %rdx	#K
	call	write_a

	movq	$1, %rsi	#B
	call	read_a		
	movl	%eax, %edx

	movq	$2, %rsi	#C
	call	read_a

	xorl	%eax, %edx	#B XOR C

	movq	$3, %rsi	#D
	call	read_a

	xorl	%edx, %eax	#B XOR C XOR D

	jmp		options_end


option_3:
	movq	$5, %rsi
	movq	$0x8F1BBCDC, %rdx	#K
	call	write_a

	movq	$1, %rsi	#B
	call	read_a		
	movl	%eax, %edx

	movq	$2, %rsi	#C
	call	read_a

	andl	%edx, %eax	#B AND C
	movl	%eax, %ecx

	movq	$1, %rsi	#B
	call	read_a		
	movl	%eax, %edx

	movq	$3, %rsi	#C
	call	read_a

	andl	%edx, %eax	#B AND D
	
	orl		%eax, %ecx	#(B AND C) OR (B AND D)

	movq	$2, %rsi	#C
	call	read_a		
	movl	%eax, %edx

	movq	$3, %rsi	#D
	call	read_a

	andl	%edx, %eax	#C AND D
	
	orl		%ecx, %eax	#(B AND C) OR (B AND D) OR (C AND D)

	jmp		options_end


option_4:
	movq	$5, %rsi
	movq	$0xCA62C1D6, %rdx	#K
	call	write_a

	movq	$1, %rsi	#B
	call	read_a		
	movl	%eax, %edx

	movq	$2, %rsi	#C
	call	read_a

	xorl	%eax, %edx	#B XOR C

	movq	$3, %rsi	#D
	call	read_a

	xorl	%edx, %eax	#B XOR C XOR D
	jmp		options_end


options_end:
	#	Epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret
#	Takes:
#	%rdi <- base address of a
#	%rsi <- base address of w[0]
#	%edx <- f
#	Returns:
#	%eax -> temp
temp:
	#	Prologue
	pushq	%rbp
	movq	%rsp, %rbp
	
	#################################################
	####	W[I] + F	
	
	pushq	%rdi
	pushq	%rdx

	movq	%rsi, %rdi
	movq	%rcx, %rsi
	call	read_w
	movl	%eax, %ecx

	popq	%rdx
	popq	%rdi

	addl	%edx, %ecx

	#################################################
	####	W[I] + F + K
	
	movq	$5, %rsi	#K
	call	read_a

	addl 	%eax, %ecx

	#################################################
	####	W[I] + F + K + E
	
	movq	$4, %rsi	#E
	call	read_a

	addl 	%eax, %ecx

	#################################################
	####	W[I] + F + K + E + (A LEFTROTATE 5)
	
	movq	$0, %rsi	#A
	call	read_a
	roll	$5, %eax	#(A LEFTROTATE 5)

	addl 	%ecx, %eax

	#	Epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret

#	Takes:
#	%rdi <- the base address of a
#	%esi <- temp
#	Returns:
#	Nothing, but changes a till e
switcharound:
	pushq	%rbp
	movq	%rsp, %rbp

	pushq	%rsi
	subq	$8, %rsp

	#########################
	######	   E = D    #####

	movq	$3, %rsi	#D
	call	read_a

	movq	$4, %rsi	#E
	movl	%eax, %edx	#D
	call	write_a		#E = D

	#########################
	######	   D = C    #####

	movq	$2, %rsi	#C
	call	read_a

	movq	$3, %rsi	#D
	movl	%eax, %edx	#C
	call	write_a		#D = C

	#######################################
	######	   C = B LEFTROTATE 30    #####

	movq	$1, %rsi	#B
	call	read_a
	roll	$30, %eax

	movq	$2, %rsi	#C
	movl	%eax, %edx	#B LEFTROTATE 30
	call	write_a		#C = B LEFTROTATE 30
	
	#########################
	######	   B = A    #####

	movq	$0, %rsi	#A
	call	read_a

	movq	$1, %rsi	#B
	movl	%eax, %edx	#A
	call	write_a		#B = A

	############################
	######	   A = TEMP    #####

	movq	$0, %rsi	#A

	addq	$8, %rsp
	popq	%rdx		#TEMP

	call	write_a		#A = TEMP


	movq	%rbp, %rsp
	popq	%rbp
	ret

#	Takes:
#	%rdi <- the base address of h0
#	%rsi <- the base address of a
#	Returns:
#	Nothing, but changes h0 till h4
add_result:
	pushq	%rbp
	movq	%rsp, %rbp

	movl	(%rsi), %eax
	movl	(%rdi), %edx
	addl	%edx, %eax
	movl	%eax, (%rdi)

	movl	-4(%rsi), %eax
	movl	4(%rdi), %edx
	addl	%edx, %eax
	movl	%eax, 4(%rdi)

	movl	-8(%rsi), %eax
	movl	8(%rdi), %edx
	addl	%edx, %eax
	movl	%eax, 8(%rdi)

	movl	-12(%rsi), %eax
	movl	12(%rdi), %edx
	addl	%edx, %eax
	movl	%eax, 12(%rdi)

	movl	-16(%rsi), %eax
	movl	16(%rdi), %edx
	addl	%edx, %eax
	movl	%eax, 16(%rdi)

	movq	%rbp, %rsp
	popq	%rbp
	ret
