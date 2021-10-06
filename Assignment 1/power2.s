.text

welcome:   .asciz "Welcome! Please put in a number: "
input:     .asciz "%ld"
exponent:  .asciz "\nPlease give an exponent: "
output:    .asciz "\n\nThe solution to %ld^%ld is: %ld\n"


.global main

main:
    pushq   %rbp                #push base pointer location to later return to
    movq    %rsp, %rbp          #set base pointer location to current stack pointer
    
    #Printing First message
    movq    $0, %rax            #no vector registers for printf
    movq    $welcome, %rdi      #give text argument for printf
    call    printf              #output $exponent text

    #Scanning for number
    movq    $0, %rax            

    subq    $16, %rsp           #reserve space for scanf output
    movq    $input, %rdi        #argument to set input format
    leaq    -16(%rbp), %rsi     #give address for scanf to put input

    call    scanf               #search for number input

    popq    %rdx                #save first input to callee-saved register
    addq    $8, %rsp            #return base pointer to location before scanf mem alloc
    movq    %rdx, %r8

    #Printing exponent text
    movq    $0, %rax            #no vector registers for printf
    movq    $exponent, %rdi     #give text argument for printf
    call    printf              #output $exponent text


    #Scanning for exponent
    movq    $0, %rax            #no vector registers for scanf

    subq    $16, %rsp           #reserve space for scanf output
    movq    $input, %rdi        #argument to set input format
    leaq    -16(%rbp), %rsi     #give address for scanf to put input

    call    scanf               #search for number input

    #Calculating number
    movq    $0, %rax            #Set solution to 0 in case 0^n
    popq    %rcx                 #counting number which will make calc loop x times, put into first arg for calc
    addq    $8, %rsp            #put the stack pointer back where it was before scanning
    movq    %rcx, %r9

    movq    %rdx, %rsi          #base number

    
    cmpq    $0, %rsi            #Check if base is not equal to zero
    je      end                 #If a^b a == 0 then immediately go to end       

    movq    $1, %rax            #solution which will be multiplied %rdi times by %rsi, with a base of 1 in case of n^0
    cmpq    $0, %rcx            #If exponent = 0, so n^0 where n != 0, then immediately give sol 1 
    je      end                 #Jump to end in case n^0
    
    call    pow                 #call pow function which loops %rcx times
    
    jmp     end                 #go to end function which prints solution
    
end:
    #Printing solution
    movq    $0, %rax            #no vector registers for printf
    movq    $output, %rdi       #set first argument(output text format) for printf
    movq    %r8, %rsi          #set solution(%rax) to second argument for printf
    movq    %r9, %rdx
    movq    %rax, %rcx
    call    printf              #print solution text and solution

    movq    $0, %rax            #set exit code 0
    movq    %rbp, %rsp
    popq    %rbp
    call    exit  


pow:
    mulq    %rsi                #multiply %rax by %rsi
    loop pow
    ret
    