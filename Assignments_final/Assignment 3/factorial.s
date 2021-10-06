.text

welcome:   .asciz "Welcome! Please put in a non-negative integer: "
input:     .asciz "%ld"
output:    .asciz "\n\n     %ld! is: %ld\n\n"


.global main

main:
    pushq   %rbp                #push base pointer location to later return to
    movq    %rsp, %rbp          #set base pointer location to current stack pointer
    
    #Printing First message
    movq    $0, %rax            #no weird options for printf
    movq    $welcome, %rdi      #give text argument for printf
    call    printf              #output $welcome text

    #Scanning for number
    movq    $0, %rax            #no weird options and stuff for scanf

    subq    $16, %rsp           #reserve space for scanf output
    movq    $input, %rdi        #argument to set input format
    leaq    -16(%rbp), %rsi     #give address for scanf to put input

    call    scanf               #search for number input

    popq    %rdi                #save first input to callee-saved register
    addq    $8, %rsp            #return base pointer to location before scanf mem alloc

    #Calculating number

    pushq   %rdi
    subq    $8, %rsp
    call    factorial           #jump to calculate function 
    addq    $8, %rsp 
    popq    %rsi     

    #Printing solution
    movq    %rax, %rdx          #set solution(%rax) to second argument for printf
    movq    $0, %rax            #no weird options for printf
    movq    $output, %rdi       #set first argument(output text format) for printf

    call    printf              #print solution text and solution

    movq    $0, %rax            #set exit code 0
    movq    %rbp, %rsp
    popq    %rbp
    call    exit

#Returns 1 if n = 1 and else calls calc to get n * fac(n-1), 
#this means this function only returns on n=1 and after that lets calc do the work
#   Argument 1: %rdi, n
#   Returns: The factorial of n  | (n!) in %rax
#The pseudocode would look like:
#      fac(n):
#          incase n == 1:
#              return 1
#          return n * fac(n-1)  <- This is function calc

factorial:
    cmpq    $1, %rdi            #If %rdi(n) is larger than 1 call calc
    jg      calc
    movq    $1, %rax            #Set %rax(answer) to 1 in order to reteurn 1
    ret                         #And return


#This function returns n * fac(n-1)   where n = %rdi and the answer is returned in %rax
calc:
    decq    %rdi                #Subtract n by 1
    call    factorial                 #Call fac(n-1)
    incq    %rdi                #Increment n by 1 again  -> (n-1) + 1 = n
    mulq    %rdi                #Multiply answer(%rax) by n(%rdi)
    ret
    