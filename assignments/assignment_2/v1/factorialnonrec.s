.text

welcome:   .asciz "Welcome! Please put in a number: "
input:     .asciz "%ld"
exponent:  .asciz "\nPlease give an exponent: "
output:    .asciz "\n\nThe solution is: %ld\n"


.global main

main:
    pushq   %rbp                #push base pointer location to later return to
    movq    %rsp, %rbp          #set base pointer location to current stack pointer
    
    #Printing First message
    movq    $0, %rax            #no weird options for printf
    movq    $welcome, %rdi      #give text argument for printf
    call    printf              #output $exponent text

    #Scanning for number
    movq    $0, %rax            #no weird options and stuff for scanf

    subq    $16, %rsp           #reserve space for scanf output
    movq    $input, %rdi        #argument to set input format
    leaq    -16(%rbp), %rsi     #give address for scanf to put input

    call    scanf               #search for number input

    popq    %rdi                #save first input to callee-saved register
    addq    $8, %rsp            #return base pointer to location before scanf mem alloc

    #Calculating number
    movq    %rdi, %rcx

    call    pow                 #jump to calculate function       

    #Printing solution
    movq    %rax, %rsi          #set solution(%rax) to second argument for printf
    movq    $0, %rax            #no weird options for printf
    movq    $output, %rdi       #set first argument(output text format) for printf

    call    printf              #print solution text and solution

    movq    $0, %rax            #set exit code 0
    ret                         #return stack pointer and base pointer to base location            
    
pow:
    mulq    %rcx                #multiply %rax by %rsi
    loop pow
    ret