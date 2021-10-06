.text

string: .asciz "Please enter a non negative base number: "
string2: .asciz "Please enter a non negative exponent: "
input: .asciz "%ld"
result: .asciz "The result is: %ld\n"

.global main

main:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %rax           
    movq $string, %rdi      #Move the argument into rdi so it can be printed
    call printf

    subq $16, %rsp          #Reserve 16 bytes for the input
    movq $input, %rdi
    leaq -16(%rbp), %rsi
    call scanf              #get non negative input for base


    movq $0, %rax
    movq $string2, %rdi
    call printf

    subq $16, %rsp          #Reserve 16 bytes for the input
    movq $input, %rdi
    leaq -32(%rbp), %rsi
    call scanf              #get non negative exponent

    popq %rsi               #retrieve value from rsi register
    addq $8, %rsp           #move the stack pointer back down to make up for reserved bytes
    popq %rdi               #retrieve value from rdi register
    addq $8, %rsp           #move the stack pointer back down to make up for reserved bytes

    call pow                #jump to pow subroutine

    movq %rax, %rsi
    movq $result, %rdi      #move result into an accessible register
    movq $0, %rax           
    call printf             #print out the result

    movq $0, %rdi

    #epilogue
    movq %rbp, %rsp
    popq %rbp
    call exit               #end the program

pow:
    ##prologue
    #pushq %rbp
    #movq %rsp, %rbp

    movq $1, %rax
    jmp loop            
    
loop:
    cmpq $0, %rsi           #check if exponent == 0
    je loopend              #if exponent == 0 jump to loopend
    mulq %rdi               #multiply base by base
    subq $1, %rsi           #substract 1 from exponent
    jmp loop                #jump back to the loop to run subroutine again

loopend:
    ##epilogue
    #movq %rbp, %rsp
    #popq %rbp
    
    ret                     #return to main routine