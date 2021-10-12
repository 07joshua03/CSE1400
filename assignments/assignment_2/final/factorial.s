.data

welcome:   .asciz "\nWelcome! Please put in a non-negative integer: "
input:     .asciz "%ld"
output:    .asciz "\nThe solution is: %lu\n\n"

.text

.global main

main:
    #Prologue
    pushq   %rbp                #push base pointer location to later return to
    movq    %rsp, %rbp          #set base pointer location to current stack pointer
    
    #Printing First message
    movq    $0, %rax            #no vector options for printf
    movq    $welcome, %rdi      #give text argument for printf
    call    printf              #output $welcome text

    #Scanning for number
    movq    $0, %rax            #no vector options for scanf

    subq    $16, %rsp           #reserve space for scanf output
    movq    $input, %rdi        #argument to set input format
    leaq    -16(%rbp), %rsi     #give address for scanf to put input

    call    scanf               #search for number input

    popq    %rdi                #save first input to callee-saved register
    addq    $8, %rsp            #return base pointer to location before scanf mem alloc

    #Calculating number

    call    factorial           #jump to calculate function       

    #Printing solution
    movq    %rax, %rsi          #set solution(%rax) to second argument for printf
    movq    $0, %rax            #no vector options for printf
    movq    $output, %rdi       #set first argument(output text format) for printf

    call    printf              #print solution text and solution

    #Epilogue
    movq    $0, %rdi            #set exit code 0
    movq    %rbp, %rsp		    
    popq    %rbp		        
 	  
    call exit 			        


#   Argument 1: %rdi, n
#   Returns: The factorial of n  | (n!) in %rax
#The pseudocode would look like:
#      factorial(n):
#          incase n == 1:
#              return 1
#          return factorial(n-1) * n  
factorial:
    #Prologue
    pushq   %rbp
    movq    %rsp, %rbp

    cmpq    $1, %rdi            #If %rdi(n) is larger than 1 call calc
    
    jle     factorial_one       #If %rdi is one return one
    pushq   %rdi
    decq    %rdi                #Subtract n by 1
    call    factorial           #Call factorial(n-1)
    popq    %rdi
    mulq    %rdi                #Multiply answer(%rax) by n(%rdi)
    jmp     factorial_end       #Return answer


factorial_one:
    movq    $1, %rax            #Set %rax(answer) to 1 in order to reteurn 1
    jmp     factorial_end       #Return answer


factorial_end:                                  
    #Epilogue
    movq    %rbp, %rsp
    popq    %rbp
    ret                         #And return
