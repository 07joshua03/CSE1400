.text

.include "final.s"

char:    .asciz "%c"

.global main

# ********************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ********************
main:
    pushq    %rbp             # push the base pointer (and align the stack)
    movq    %rsp, %rbp        # copy stack pointer value to base pointer

    movq    $MESSAGE, %rdi    # first parameter: address of the message
    call    decode            # call decode

    movq    %rbp, %rsp
    popq    %rbp            # restore base pointer location 
    movq    $0, %rdi        # load program exit code
    call    exit            # exit the program


decode:
    # prologue
    pushq    %rbp             # push the base pointer (and align the stack)
    movq    %rsp, %rbp        # copy stack pointer value to base pointer

    pushq   %rdi		#push the value in rdi to the stack

    call    firstchar		#call the method firstchar
    popq    %rdi		#pop the value on top of the stack into rdi
    movq    %rax, %rsi		#copy the value of rax into rsi
    call    char_loop		#call the method char_loop


    # epilogue
    movq    %rbp, %rsp        # clear local variables from stack
    popq    %rbp            # restore base pointer location 
    ret				#returns back to the main method

firstchar:
    pushq   %rbp		#prologue: push the base pointer to the stack
    movq    %rsp, %rbp		#copy the stack pointer value to the base pointer

    pushq   %rdi		#push the value of rdi to the stack
    movzb    1(%rdi), %rsi    #How many times character needs to be written
    movzb    (%rdi), %rdi    #The character that needs to be written
    call    print_loop		#call the method print_loop

    popq    %rdi     		#pops the value on top of the stack into rdi
    movq    $0, %rax		#copies the value 0 into rax
    movl    2(%rdi), %eax    #Move next index to %rax
    

    movq    %rbp, %rsp		#epilogue: copies the base pointer to the stack pointer
    popq    %rbp		#epilogue: pops the value on the stack into the base pointer
    ret				#returns back to the decode subroutine



char_loop:			
    pushq   %rbp		#prologue: pushes the base pointer to the stack
    movq    %rsp, %rbp		#copies the stack pointer to the base pointer

char_loop_loop:			
    cmpq    $0, %rsi		#checks if rsi contains 0
    jle     char_loop_end	#jumps if rsi is 0 or less

    pushq   %rdi		#pushes the value of rdi to the stack
    movq    $8, %rax		#copies the value 8 into rax
    mulq    %rsi		#multiplies rsi with 8
    addq    %rax, %rdi		#adds the contents of rax and rdi
    pushq   %rdi		#pushes the value of rdi to the stack
    movzb    1(%rdi), %rsi    #How many times character needs to be written
    movzb    (%rdi), %rdi    #The character that needs to be written
    call    print_loop		#calls the subroutine print_loop

    popq    %rdi		#pops the value on the stack into rdi
    movq    $0, %rsi		#copies the value 0 into rsi
    movl    2(%rdi), %esi    #Move next index to %rax
    popq    %rdi		#pops the value on top of the stack into rdi

    jmp     char_loop_loop	#jumps to char_loop_loop
	    

char_loop_end:			
    movq    %rbp, %rsp		#epilogue:copies the value of the base pointer to the stack pointer
    popq    %rbp		#pops the base pointer of the stack
    ret				#returns from the subroutine


print_loop:			
    pushq   %rbp		#prologue: push the value of rbp to the stack
    movq    %rsp, %rbp		#copies the stack pointer to the base pointer
    jmp     print_loop_loop	#jumps to the loop part of this subroutine

print_loop_loop:
    cmpq    $0, %rsi		#checks if the value of rsi is 0
    jle     print_loop_end	#if it is less or equal it jumps to the end

    pushq   %rdi		#pushes the value of rdi to the stack
    pushq   %rsi		#pushes the value of rsi to the stack
    call    print_char		#calls the subroutine print_char
    
    popq    %rsi		#pops the value on the top of the stack into rsi
    popq    %rdi		#pops the value on top of the stack into rdi
    
    decq    %rsi		#decrements the value of rsi by one
    jmp     print_loop_loop	#jumps to the loop part of the print_loop subroutine



print_loop_end:			
    movq    %rbp, %rsp		# copies the value of the base pointer to the stack pointer
    popq    %rbp		#pops the value on top of the stack into the base pointer
    ret				#returns from the subroutine

print_char:			
    pushq   %rbp		#prologue: pushes the value of the base pointer to the stack
    movq    %rsp, %rbp		#prologue: copies the value of the stack pointer to the base pointer

    movq    $0, %rax		#copies the value 0 into rax
    movq    %rdi, %rsi		#copies the value of rdi into rsi
    movq    $char, %rdi		#copies the value of char into rdi

    call    printf		#calls the print subroutine

    movq    %rbp, %rsp		#epilogue: copies the base pointer to the stack pointer
    popq    %rbp		#pops the value of the stack into the base pointer
    ret				#returns from the subroutine
