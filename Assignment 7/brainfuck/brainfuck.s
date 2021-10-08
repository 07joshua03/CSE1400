.global brainfuck

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

	call	get_code_length
	movq	%rax, %rcx
	
	shlq	$3, %rax
	incq	%rax
	shrq	$3, %rax

	subq	$rax, %rsp
	movq	%rsp, %rsi

	pushq	%rsi
	pushq	%rcx
	call	translate_code
	popq	%rcx			#	code length
	popq	%rdi			#	Translated code

	#	Reserve array space (30.000 bytes)
	movq	$30000, %rax
	subq	%rax, %rsp
	movq	%rsp, %rdi		#address of array space

	shrq	$3, %rax		
	movq	%rax, %rsi		#amount of quad-words to clear
	call	clear_stack_space

	call	run_code

	movq 	%rbp, %rsp
	popq 	%rbp
	ret
