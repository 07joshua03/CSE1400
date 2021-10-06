.text

.include "bitmap_helper.s"

message:    .asciz "The answer for exam question 42 is not F."
leadtrail:  .asciz "CCCCCCCCSSSSEE1111444400000000"

.global main

main:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $message, %rdi
    call    start

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rdi
    call    exit

#Takes:
#   %rdi <- the address of message


start:
    pushq   %rbp
    movq    %rsp, %rbp

    
    pushq   %rdi
    call    get_message_length
    popq    %rdi

    addq    $60, %rax
    
    shrq    $3, %rax    #Divide length by 8
    incq    %rax        #Add reserve space for remainder + nullbyte
    shlq    $3, %rax    #Multiply length by 8
    movq    %rax, %rsi  #Total message length (leadmessagetrail)

    subq    %rsi, %rsp
    movq    %rsp, %rdx  #Base address for message in stack

    pushq   %rdx
    pushq   %rdi

    movq    %rdx, %rdi
    call    clearstackspace

    movq    %rdx, %rdi
    call    writelead_trail

    popq    %rdi

    movq    %rdi, %rsi
    movq    %rax, %rdi
    call    writemessage

    movq    %rax, %rdi
    call    writelead_trail

    popq    %rdx

    movq    %rdx, %rdi
    movq    $0, %rax
    call    printf

    movq    %rsi, %rcx
    jmp     end

end:
    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- the base address(lowest) of space to write lead in
#   Returns:
#   %rax -> the address post-lead
writelead_trail:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $leadtrail, %rsi
    call    write_data  

    call    get_message_length
    addq    %rdi, %rax

    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- the base address(lowest) of space to write lead in
#   %rsi <- the base address(lowest) of message
#   Returns:
#   %rax -> the address post-message
writemessage:
    pushq   %rbp
    movq    %rsp, %rbp

    call    write_data  

    call    get_message_length
    addq    %rdi, %rax

    movq    %rbp, %rsp
    popq    %rbp
    ret

