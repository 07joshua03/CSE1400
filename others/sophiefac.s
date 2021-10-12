.text

.global main 

parameter:	.asciz "Give a non-negative parameter\n"
formatstr: 	.asciz "%ld"
result: 	.asciz "The result is: %ld\n"

main: 
	
	#prologue
	pushq %rbp				#push the base pointer
	movq %rsp, %rbp			#copy stack pointer value to base pointer

	movq $0, %rax			#no vector registers in use for printf
	movq $parameter,%rdi 	#load string into rdi
	call printf				#call printf to print

	movq $0, %rax			#no vector registers in use for scanf
	movq $formatstr, %rdi 	#load string into rdi
	subq $16, %rsp 			#make room in the stack
	leaq -16(%rbp), %rsi 	#load address to store input
	call scanf				#call scanf

	popq %rdi				#load input into rdi

	addq $8, %rsp

	movq $1, %rax			#copy 1 into rax to multiply

	call factorial 	 			#call subroutine factorial

	movq %rax, %rsi 		#copy result to rsi
	movq $0, %rax			#no vector registers in use for printf
	movq $result,%rdi 		#load string into rdi
	call printf				#call printf to print

	#epilogue
	movq %rbp, %rsp 		#clear local variables from stack
	popq %rbp				#restore base pointer location

	call exit 				#end 


factorial:
	pushq %rbp
	movq  %rsp, %rbp
	jmp   factorial_loop

factorial_loop: 
	cmp $1, %rdi
	je if 
	jg else 

if: 
	
	mulq %rdi
	jmp end  

else:

	decq %rdi				#decrement r8
	call factorial 
	incq %rdi 
	mulq %rdi				#multiply rax with the value in r8

	jmp end 

end: 
	movq %rbp, %rsp
	popq %rbp
	ret 					#return from subroutine

#pseudo

#int factorial(int n){
#	if(n == 1) {
#		return 1;
#	}

#	else{
#		return n*factorial(n-1);	
#	}
#}

