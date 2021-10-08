.global brainfuck

format_str: .asciz "We should be executing the following code:\n%s\n\n"

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
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rsi
	movq $format_str, %rdi
	call printf
	movq $0, %rax




	movq %rbp, %rsp
	popq %rbp
	ret
