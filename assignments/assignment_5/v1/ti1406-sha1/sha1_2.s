.global sha1_chunk

#   sha1_chunk takes 2 arguments
#   %rdi, which holds the base address of H0
#   %rsi, which holds the base address of w[0]
#   Returns nothing, but changes H0 till H4
sha1_chunk:
    pushq   %rbp
    movq    %rsp, %rbp


    pushq   %rdi
    movq    %rsi, %rdi
    call    messageschedule_start
    popq    %rdi



    movq    %rbp, %rsp
    popq    %rsp
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
    popq    %rsp
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
    popq    %rsp
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

    movq	%rsi, %rax
	movq	$4, %r8
	mulq	%r8
	leaq	(%rax, %rdi), %r8
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

    pushq   %rdi
    pushq   %rsi

    subq    $20, %rsp
    movl    (%rdi), %eax
    movl    %eax, -16(%rbp)

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





mainloop_option_1:

    jmp     mainloop_option_end

mainloop_option_2:

    jmp     mainloop_option_end

mainloop_option_3:

    jmp     mainloop_option_end

mainloop_option_4:

    jmp     mainloop_option_end

mainloop_option_end:
    incq    %rcx
    jmp     mainloop_loop




mainloop_end:

    popq    %rsi
    popq    %rdi

    movq    %rbp, %rsp
    popq    %rbp
    ret