.global sha1_chunk

#   sha1_chunk takes 2 arguments
#   %rdi, which holds the base address of H0
#   %rsi, which holds the base address of w[0]
#   Returns nothing, but changes H0 till H4
sha1_chunk:
    pushq   %rbp
    movq    %rsp, %rbp

	pushq	%rsi
    pushq   %rdi
    movq    %rsi, %rdi
    call    messageschedule_start
    popq    %rdi
	popq	%rsi

	call	mainloop_start

    movq    %rbp, %rsp
    popq    %rbp
    ret


#   messageschedule_start takes 1 argument
#   %rdi, which holds the base address of w[0]
#   Returns nothing, but changes w[16] till w[79]
#   Uses %rcx, 
messageschedule_start:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $16, %rcx
    jmp     messageschedule_loop


messageschedule_loop:
    cmpq    $80, %rcx
    jge     messageschedule_end

                        # %rdi already holds the address of w[0]
    movq    %rcx, %rsi  # %rsi holds the index of w

    movq    $3, %rdx    # %rdx holds the -index-offset for w
    call    readword
    pushq   %rax


    movq    $8, %rdx
    call    readword
    popq    %rdx 

    xorl    %edx, %eax
    pushq   %rax

    movq    $14, %rdx
    call    readword
    popq    %rdx 

    xorl    %edx, %eax
    pushq   %rax

    movq    $16, %rdx
    call    readword
    popq    %rdx 

    xorl    %edx, %eax
    rcll    $1, %eax    
    movl    %eax, %edx  # Holds the data for w[i]
    call    writeword

    incq    %rcx
    jmp     messageschedule_loop



messageschedule_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret 

#   Takes 3 arguments
#   %rdi, The base word address w[0]
#   %rsi, The index of w w[X-b]
#   %rdx, The offset of w w[a-X]
#   Returns the data inside w[a-b] at %eax
#   Changes %rax, %rdx and %r8
readword:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    %rsi, %rax
    subq    %rdx, %rax
    movq    $4, %r8
    mulq    %r8

    leaq    (%rax, %rdi), %r8
    movq    $0, %rax
    movl    (%r8), %eax

    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes 3 arguments
#   %rdi, The base word address w[0]
#   %rsi, The index in which data needs to be written w[X]
#   %edx, The data(32-bit word) which needs to be written
#   Returns nothing but writes w[%rsi]
#   Changes %rax, %rdx and %r8
	writeword:
		pushq	%rbp
		movq	%rsp, %rbp

		pushq	%rdx

		movq	%rsi, %rax
		movq	$4, %r8
		mulq	%r8
		leaq	(%rax, %rdi), %r8
		popq	%rdx
		movl	%edx, (%r8)
		
		movq	%rbp, %rsp
		popq	%rbp
		ret


####################################################################################
####################################################################################
#----------------------------------Main loop---------------------------------------#
####################################################################################
####################################################################################


#   Takes . arguments
#   %rdi, The base address of h0
#   %rsi, the base address of w[0]
#   
mainloop_start:
    pushq   %rbp
    movq    %rsp, %rbp


    subq    $24, %rsp
    movl    (%rdi), %eax
    movl    %eax, (%rbp)	#A
	movl    4(%rdi), %eax
    movl    %eax, -4(%rbp)	#B
	movl    8(%rdi), %eax
    movl    %eax, -8(%rbp)	#C
	movl    12(%rdi), %eax
    movl    %eax, -12(%rbp)	#D
	movl    16(%rdi), %eax
    movl    %eax, -16(%rbp)	#E

    pushq   %rdi
    pushq   %rsi

    movq    $0, %rcx
    jmp     mainloop_loop

mainloop_loop:
    cmpq    $80, %rcx
    jge     mainloop_end

    cmpq    $19, %rcx
    jle     mainloop_option_1
    cmpq    $39, %rcx
    jle     mainloop_option_2
    cmpq    $59, %rcx
    jle     mainloop_option_3
    cmpq    $79, %rcx
    jle     mainloop_option_4




#	All arguments take no arguments
#	Returns %eax(F) and %edx(K)
mainloop_option_1:
	pushq	%rcx
	movl	-4(%rbp), %eax	#B
	movl	-8(%rbp), %edx	#C
	andl	%edx, %eax		#B AND C

	movl	-4(%rbp), %edx	#B
	notl	%edx			#NOT B
	movl	-12(%rbp), %ecx	#D
	andl	%ecx, %edx		#(NOT B) AND D
	orl		%edx, %eax		#(B AND C) OR ((NOT B) AND D) -> F

	movl	$0x5A827999, %edx	#K

	popq	%rcx
    jmp     mainloop_option_end

mainloop_option_2:

	movl	-4(%rbp), %eax	#B
	movl	-8(%rbp), %edx	#C
	xorl	%edx, %eax		#B XOR C
	movl	-12(%rbp), %edx	#D
	xorl	%edx, %eax		#B XOR C XOR D

	movl	$0x6ED9EBA1, %edx

    jmp     mainloop_option_end

mainloop_option_3:
	pushq	%rcx
	movl	-4(%rbp), %eax	#B
	movl	-8(%rbp), %edx	#C
	andl	%edx, %eax		#B AND C

	movl	-4(%rbp), %edx	#B
	movl	-12(%rbp), %ecx	#D
	andl	%ecx, %edx		#B AND D
	orl		%edx, %eax		#(B AND C) OR (B AND D)

	movl	-8(%rbp), %edx	#C
	movl	-12(%rbp), %ecx	#D
	andl	%ecx, %edx		#C AND D

	orl		%edx, %eax		#(B AND C) OR (B AND D) OR (C AND D)

	movl	$0x8F1BBCDC, %edx

	popq	%rcx
    jmp     mainloop_option_end

mainloop_option_4:
	movl	-4(%rbp), %eax	#B
	movl	-8(%rbp), %edx	#C
	xorl	%edx, %eax		#B XOR C
	movl	-12(%rbp), %edx	#D
	xorl	%edx, %eax		#B XOR C XOR D

	movl	$0xCA62C1D6, %edx

    jmp     mainloop_option_end

#	Takes 3 arguments
#	%eax, which holds F
#	%edx, which holds K
#	%rsi, which holds the base address of w[0]
mainloop_option_end:
	movl	(%rbp), %edi	#A
	rcll	$5, %edi		#(A LR 5)
	addl	%edi, %eax		#(A LR 5) + F
	movl	-16(%rbp), %edi	#E
	addl	%edi, %eax		#(A LR 5) + F + E
	addl	%edx, %eax		#(A LR 5) + F + E + K

#------FOR W[i]-----------#
	pushq	%rax

	movq    %rcx, %rax
    movq    $4, %r8
    mulq    %r8

    leaq    (%rsi), %r8
	addq	%rax, %r8
    movl    (%r8), %edx

	popq	%rax
#------FOR W[i]-----------#

	addl	%edx, %eax		#(A LR 5) + F + E + K + w[i] -> temp
	movl	-12(%rbp), %edx
	movl	%edx, -16(%rbp)	#e = d

	movl	-8(%rbp), %edx
	movl	%edx, -12(%rbp)	#d = c

	movl	-4(%rbp), %edx
	rcll	$30, %edx
	movl	%edx, -8(%rbp)	#c = b LR 30	

	movl	(%rbp), %edx
	movl	%edx, -4(%rbp)	#b = a

	movl	%eax, (%rbp)	#a = temp

    incq    %rcx
    jmp     mainloop_loop




mainloop_end:

	popq    %rsi
    popq    %rdi

	movq	$0, %rax

	movl	(%rbp), %eax
	movl	(%rdi), %edx
	addl	%edx, %eax
	leaq	(%rdi), %rdx
	movl	%eax, (%rdx)		#h0 = h0 + a

	movl	-4(%rbp), %eax
	movl	4(%rdi), %edx
	addl	%edx, %eax
	leaq	4(%rdi), %rdx
	movl	%eax, (%rdx)		#h0 = h0 + a
	
	movl	-8(%rbp), %eax
	movl	8(%rdi), %edx
	addl	%edx, %eax
	leaq	8(%rdi), %rdx
	movl	%eax, (%rdx)		#h0 = h0 + a

	movl	-12(%rbp), %eax
	movl	12(%rdi), %edx
	addl	%edx, %eax
	leaq	12(%rdi), %rdx
	movl	%eax, (%rdx)		#h0 = h0 + a

	movl	-16(%rbp), %eax
	movl	16(%rdi), %edx
	addl	%edx, %eax
	leaq	16(%rdi), %rdx
	movl	%eax, (%rdx)		#h0 = h0 + a


	addq	$24, %rsp

    movq    %rbp, %rsp
    popq    %rbp
    ret
