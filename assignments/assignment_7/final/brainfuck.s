.global brainfuck

.include "brainfuck_helper.s"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq 	%rbp
	movq 	%rsp, %rbp

	pushq	%rdi
	call	get_code_length
	popq	%rdi
	movq	%rax, %rcx
	
	shrq	$1, %rax
	incq	%rax
	shlq	$3, %rax

	subq	%rax, %rsp
	movq	%rsp, %rsi		#	space for translation

	pushq	%rsi
	call	translate_code
	popq	%rdi			#	Translated code

	pushq	%rdi

	movq    $0, %rcx        #line of code
    movq    $0, %rdx        #sol counter
	movq    $0, %r8         #curr sol
	movq	$0, %r9			#curr sol line of code

	call	sol_data

	popq	%rdi
	

	#	Reserve array space (30.000 bytes) + print buffer(256 bytes)
	movq	$30512, %rax
	subq	%rax, %rsp
	
	leaq	512(%rsp), %rsi		#	address of array space
	movq	%rsp, %rdx			#	print buffer

	pushq	%rdi				#	code
	pushq	%rsi				#	address of array space
	pushq	%rdx				#	print buffer

	movq	%rdx, %rdi
	
	shrq	$3, %rax		
	movq	%rax, %rsi		#	amount of quad-words to clear
	call	clear_stack_space

	popq	%rdx		
	popq	%rsi			
	popq	%rdi			

	subq	$16, %rsp		#just some reserve space for all the reasons

	call	run_code

	movq 	%rbp, %rsp
	popq 	%rbp
	ret

#	%rdi <- starting address of code
#	%rsi <- starting address of array
#	%rdx <- starting address of print buffer
#	%rcx <- current line of code
#	%r8  <- current pointer location	
#	%r9  <- print buffer size
#	$r10 <- sol counter
run_code:
	pushq	%rbp
	movq	%rsp, %rbp

	movq	$0, %rcx
	movq	$0, %r8
	movq	$0, %r9
	movq	$0, %r10

run_code_loop:
	
	movb	(%rcx, %rdi), %al
	cmpb	$0, %al
	je		run_code_end

	
	cmpb	$1, %al
	je		command_output
	cmpb	$2, %al
	je		command_input
	cmpb	$3, %al
	je		command_pointerinc
	cmpb	$4, %al
	je		command_pointerdec
	cmpb	$5, %al
	je		command_valueinc
	cmpb	$6, %al
	je		command_valuedec
	cmpb	$7, %al
	je		command_sol
	cmpb	$8, %al
	je		command_eol
	cmpb	$9, %al
	je		command_valuezero

	jmp		command_error	

run_code_end:
	cmpq	$0, %r9
	jne		print
	movq	%rbp, %rsp
	popq	%rbp
	ret


command_output:
	movb	(%r8, %rsi), %al
	movb	%al, (%r9, %rdx)
	incq	%r9

	addq	$3, %rcx

	cmpq	$511, %r9
	jge		print

	jmp 	run_code_loop
command_input:
	addq	$3, %rcx
	jmp 	run_code_loop
command_pointerinc:
	incq	%rcx
	movzb	(%rcx, %rdi), %rax
	
	addq	%rax, %r8
	addq	$2, %rcx
	jmp		run_code_loop

command_pointerdec:
	incq	%rcx
	movzb	(%rcx, %rdi), %rax

	subq	%rax, %r8
	addq	$2, %rcx
	jmp		run_code_loop
command_valueinc:
	incq	%rcx
	movzb	(%rcx, %rdi), %rax

	addq	%rax, (%r8, %rsi)
	addq	$2, %rcx
	jmp		run_code_loop

command_valuedec:
	incq	%rcx
	movzb	(%rcx, %rdi), %rax

	subq	%rax, (%r8, %rsi)
	addq	$2, %rcx
	jmp		run_code_loop

command_sol:
	cmpb	$0, (%r8, %rsi)
	je		command_sol_no
	addq	$3, %rcx
	pushq	%rcx		#command following sol
	jmp		run_code_loop
	
command_sol_no:
	movw	1(%rcx, %rdi), %cx
	
	jmp		run_code_loop	

command_eol:
	cmpb	$0, (%r8, %rsi)
	je		command_eol_no
	popq	%rcx

	pushq	%rcx
	jmp		run_code_loop

command_eol_no:
	addq	$8, %rsp
	addq	$3, %rcx
	jmp		run_code_loop


command_valuezero:
	movb	$0, (%r8, %rsi)
	addq	$3, %rcx
	jmp		run_code_loop


command_error:
	addq	$3, %rcx
	#call	exit
	jmp		run_code_loop

print:
	pushq	%rdi
	pushq	%rsi
	pushq	%rdx
	pushq	%rcx
	pushq	%r8
	pushq	%r10
	pushq	%r11
	movq	$1, %rax
	movq	$1, %rdi
	movq	%rdx, %rsi
	movq	%r9, %rdx

	syscall

	popq	%r11
	popq	%r10
	popq	%r8
	popq	%rcx
	popq	%rdx
	popq	%rsi
	popq	%rdi

	movq	$0, %r9
	
	jmp		run_code_loop
