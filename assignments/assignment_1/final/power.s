.data                                                                               #this shows that here our strings will be stored

output1:    .asciz "\nWelcome to the best calculator! Please give a non-negative base: "       #this is the first string we will use for our programme
input:      .asciz "%ld"                                                            #this is the input we will use for the user input in our programme
output2:    .asciz "\nPlease give a non-negative exponent: "                                #this is the second string we will use in our programme
output3:    .asciz "\n\nThe solution to %ld^%ld is: %ld\n\n"                        #this is the last string we will use in our programme and has the final result stored

.text                                                                               #this labels where our executable code is

.global main                    #this labels that the programme is free to access by the OS

main:                           #this labels where the code begins being executed

    pushq   %rbp                #prologue: this pushes the base pointer to the stack
    movq    %rsp, %rbp          #prologue: this copies the value of the stack pointer to the base pointer

    movq    $output1, %rdi      #this loads the first string into the rdi register
    call    inout               #this calls the subroutine "inout" to be executed with the given parameters
    pushq   %rax                #Push result of inout into stack
    subq    $8, %rsp

    movq    $output2, %rdi      #this loads the second string into the rdi register
    call    inout               #this calls the subroutine "inout" to be executed witrh the given parameters
    
    addq    $8, %rsp
    popq    %rdi                #Get first input from stack
    movq    %rax, %rsi          #this copies the value of the rax register to the rsi register

    pushq   %rdi
    pushq   %rsi

    call    pow

    movq    %rax, %rcx
    popq    %rdx
    popq    %rsi

    movq    $0, %rax            #this copies the value 0 into the rax register
    movq    $output3, %rdi      #this loads the third string that contains the solution into the rdi register
    call    printf              #this calls the function printf to print the given arguments into the terminal
    movq    $0, %rax            #this copies the value 0 into the rax register

    movq    %rbp, %rsp          #epilogue: this copies the value of the base pointer to the stack pointer
    popq    %rbp                #epilogue: this pops the base pointer off the stack
    movq    $0, %rdi            #this loads the value 0 into the rdi register
    call    exit                   #this closes the programme

#Takes 1 argument, %rdi, which holds the output text
#Returns number %rax

inout:                          #this labels where the subroutine called "inout" is located
    pushq   %rbp                #prologue: this pushes the base pointer to the stack
    movq    %rsp, %rbp          #prologue: this copies the value of the stack pointer to the base pointer

    movq    $0, %rax            #this copies the value 0 into the rax register
    call    printf              #this calls the function printf to print the given arguments into the terminal

    movq    $0, %rax            #this copies the value 0 into the rax register
    movq    $input, %rdi        #this copies the input string into the rdi register
    subq    $16, %rsp           #this reserves space for an user-input and an adress to be stored onto the stack
    leaq    -16(%rbp), %rsi     #this loads the effective adress of the given user-input into the rsi register

    call    scanf               #this calls the function scanf to scan the user given input and store it

    movq    -16(%rbp), %rax     #this copies the given user-input into the rax register 
    addq    $16, %rsp           #this adds 16 to the value of the stack pointer so it goes back 2 bytes in the stack

    movq    %rbp, %rsp          #epilogue: this copies the value of the base pointer to the stack pointer
    popq    %rbp                #epilogue: this pops the base pointer of the stack
    ret                         #this returns to the return adress that was stored when inout was called


pow:
    pushq   %rbp
    movq    %rsp, %rbp

    cmpq    $0, %rdi            #this compares the rdi register with the value 0 to check if the base = 0
    jle     calc_zero           #this lets the programme jump to a special place to calculate when the base is 0

    movq    $1, %rax            #this moves the value 1 into the rax register
    movq    %rsi, %rcx          #this moves the value of the exponent into the rcx register
    jmp     calc_loop           #this lets the programme jump to the loop where the multiplying is done

    movq    %rbp, %rsp
    popq    %rbp
    ret


#Takes %rdi and %rsi as base and exponent
#Returns %rsi, %rdx and %rcx as outputs for final
    
calc_loop:                      #this labels where the looping part of the programme is located
    cmpq    $0, %rcx            #this compares the value 0 to the rcx register for the stopping condition
    jle     calc_end            #this lets the programme jump to the final part of the subroutine if the stopping condition is met

    mulq    %rdi                #this multiplies the current value in the rax register with the value in the rdi register
    decq    %rcx                #this decrements the value of the exponent each loop so the answer will be multiplied the amount of the value of the exponent times
    jmp    calc_loop            #this lets the programme jump back to the beginning of the loop so it can do the same multiplication again

calc_zero:                      #this labels the code that will be executed when the base is equal to 0
    cmpq    $0, %rsi
    je      calc_zero_zero

    movq    $0, %rax            #this copies the value 0 into the rax register
    jmp     calc_end            #this lets the programme jump to the end part of the subroutine

calc_zero_zero:
    movq    $1, %rax
    jmp     calc_end

#   Returns:
    #Base at %rax
calc_end:                       #this labels where the end of the subroutine is located
    #movq    %rax, %rcx          #this copies the value in the rax register into the rcx register
    #movq    %rsi, %rdx          #this copies the value in the rsi register into the rdx register
    #movq    %rdi, %rsi          #this copies the value of the rdi register into the rsi register

    movq    %rbp, %rsp          #epilogue: this copies the value of the base pointer to the stack ponter
    popq    %rbp                #epilogue: this pops the base pointer from the stack
    ret                         #this lets the programme return out of the subroutine, back into the main
