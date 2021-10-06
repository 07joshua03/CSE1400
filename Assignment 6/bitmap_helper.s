.text

#   Takes:
#   %rdi <- the base address of message (where we start at the lowest address)
#   Returns:
#   %rax -> the length(in bytes) of message
get_message_length:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $0, %rcx
    jmp     get_message_length_loop


    get_message_length_loop:
        pushq   %rdi
        addq    %rcx, %rdi

        movb    (%rdi), %al

        cmpb    $0, %al
        je      get_message_length_end



        popq    %rdi
        incq    %rcx
        jmp     get_message_length_loop


    get_message_length_end:
        movq    %rcx, %rax
        movq    %rbp, %rsp
        popq    %rbp
        ret


#   Takes:
#   %rdi <- the base address to clear
#   %rsi <-  amount of bytes to clear
clearstackspace:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    movq    %rsi, %rcx
    jmp     clearstackspace_loop


clearstackspace_loop:
    cmpq    $0, %rcx
    jle     clearstackspace_end

    movb   $0, (%rdi)

    decq    %rcx
    addq    $1, %rdi
    jmp     clearstackspace_loop


clearstackspace_end:
    popq    %rdi

    movq    %rbp, %rsp
    popq    %rbp    
    ret

#   Takes:
#   %rdi <- base address(lowest) of place to write to (assumes space is cleared and has enough space for data)
#   %rsi <- base address(lowest) of data to write
write_data:
    pushq   %rbp
    movq    %rsp, %rbp

    jmp     write_data_loop

write_data_loop:
    pushq   %rdi
    pushq   %rsi
    addq    %rcx, %rdi
    addq    %rcx, %rsi

    movb    (%rsi), %al
    

    cmpb    $0, %al
    je      write_data_end

    movb    %al, (%rdi)

    popq    %rsi
    popq    %rdi
    incq    %rcx
    jmp     write_data_loop

write_data_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- base address(lowest) of message
#   %rsi <- base address(lowest) to write RLE-encoded message to
encode_RLE:
    pushq   %rbp
    movq    %rsp, %rbp

    movb    (%rdi), %ah  #prevChar
    movq    $0, %rcx
    movb    $1, %cl     #char count
    jmp     encode_RLE_loop

encode_RLE_loop:
    incq    %rdi                #Move message address 1 byte
    movb    (%rdi), %al         #currChar
    cmpb    %ah, %al            #compare currChar to prevChar
    jne     encode_RLE_else
    // cmpb    $255, %cl           #avoid int overflow (doesnt work tho :/)
    // jge     encode_RLE_else
    incb    %cl
    jmp     encode_RLE_loop

encode_RLE_else:
    movb    %cl, (%rsi)
    addq    $1, %rsi
    movb    %ah, (%rsi)
    addq    $1, %rsi
    movb    %al, %ah
    cmpb    $0, %ah
    je      encode_RLE_end
    movb    $1, %cl
    jmp     encode_RLE_loop


encode_RLE_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret


#   Takes:
#   %rdi <- base address(lowest) of RLE_encoded message
#   %rsi <- base address(lowest) to write RLE-decoded message to
decode_RLE:
    pushq   %rbp
    movq    %rsp, %rbp

    jmp decode_RLE_outer_loop

decode_RLE_outer_loop:
    movb    (%rdi), %cl
    incq    %rdi
    cmpb    $0, %cl
    je      decode_RLE_end
    movb    (%rdi), %al
    incq    %rdi

    jmp     decode_RLE_inner_loop

decode_RLE_inner_loop:
    cmpb    $0, %cl
    je      decode_RLE_outer_loop
    movb    %al, (%rsi)
    incq    %rsi
    decb    %cl
    jmp     decode_RLE_inner_loop

decode_RLE_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret