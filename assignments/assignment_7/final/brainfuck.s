.global brainfuck

.include "brainfuck_helper.s"

commands:
	.word	0x015D	#	]	end of loop
	.word	0x025B	#	[	start of loop
	.word	0x033E	#	>	move pointer right
	.word	0x043C	#	<	move pointer left
	.word	0x052E	#	.	print current pointer
	.word	0x062D	#	-	dec current pointer
	.word	0x072C	#	,	get input -> curr pointer
	.word	0x082B	#	+	inc	current pointer

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq 	%rbp
	movq 	%rsp, %rbp

	pushq	%rdi
	call	get_code_length
	popq	%rdi
	movq	%rax, %rcx
	
	shlq	$3, %rax
	incq	%rax
	shrq	$3, %rax

	subq	%rax, %rsp
	movq	%rsp, %rsi		#	space for translation

	pushq	%rsi
	movq	$commands, %rdx
	call	translate_code
	popq	%rdi			#	Translated code

	#	Reserve array space (30.000 bytes)
	movq	$30000, %rax
	subq	%rax, %rsp
	
	pushq	%rdi
	pushq	%rsp

	movq	%rsp, %rdi		#	address of array space
	shrq	$3, %rax		
	movq	%rax, %rsi		#	amount of quad-words to clear
	call	clear_stack_space

	popq	%rsi			
	popq	%rdi			


	pushq	%rdi
	pushq	%rsi
	call	get_code_length
	movq	%rax, %rdx		#	Code length

	popq	%rsi			#	starting address of array
	popq	%rdi			#	starting address of code


	call	run_code

	movq 	%rbp, %rsp
	popq 	%rbp
	ret

#	%rdi <- starting address of code
#	%rsi <- starting address of array
#	%rcx <- current line of code
#	%rdx <- last line of code (n = 0 ... n = %rdx)
#	%r8  <- current pointer location
#
#
run_code:
	pushq	%rbp
	movq	%rsp, %rbp

	movq	$0, %rcx
	movq	$0, %r8

run_code_loop:
	cmpq	%rdx, %rcx
	je		run_code_end

	movb	(%rcx, %rdi), %al
	cmpb	$1, %al
	je		_1
	cmpb	$2, %al
	je		_2
	cmpb	$3, %al
	je		_3
	cmpb	$4, %al
	je		_4
	cmpb	$5, %al
	je		_5
	cmpb	$6, %al
	je		_6
	cmpb	$7, %al
	je		_7
	cmpb	$8, %al
	je		_8
	jne		_error


run_code_end:
	movq	%rbp, %rsp
	popq	%rbp
	ret

_1:

_2:

_3:

_4:

_5:

_6:

_7:

_8:

_error:
	movq	$-1, %rdi
	call	exit