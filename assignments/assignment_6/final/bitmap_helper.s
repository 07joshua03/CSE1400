.text

signature:  .asciz "BM"

#   Takes:
#   %rdi <- the base address of message (where we start at the lowest address)
#   Returns:
#   %rax -> the length(in bytes) of message till zero-byte
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

#   Takes:
#   %rdi <- the barcode message
#   %rsi <- the address for barcode data
#   %rdx <- the barcode colors
#   Returns:
#   %rax -> the length in bytes of barcode data
write_barcode:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    call    get_message_length
    popq    %rdx
    popq    %rsi
    popq    %rdi

    pushq   %rax

    movb    %al, %cl
    movb    %al, %ch

    jmp     write_barcode_outer_loop
write_barcode_outer_loop:
    cmpb    $0, %cl
    jle     write_barcode_end

    pushq   %rax
    pushq   %rdi
    jmp     write_barcode_inner_loop
    
write_barcode_outer_loop_2:
    popq    %rdi
    popq    %rax
    movb    %al, %ch

    decb    %cl
    jmp     write_barcode_outer_loop


write_barcode_inner_loop:
    cmpb    $0, %ch
    jle     write_barcode_outer_loop_2
    movb    (%rdi), %al
    movb    $0, %ah
    pushq   %rdx
    jmp     write_barcode_inner_inner_loop

write_barcode_inner_loop_2:
    popq    %rdx
    incq    %rdi
    decb    %ch
    jmp     write_barcode_inner_loop 

write_barcode_inner_inner_loop:
    cmpb    %al, (%rdx)
    je      write_barcode_inner_inner_loop_end
    addq    $4, %rdx
    jmp     write_barcode_inner_inner_loop

write_barcode_inner_inner_loop_end:
    movb    1(%rdx), %ah
    movb    %ah, (%rsi)
    movb    2(%rdx), %ah
    movb    %ah, 1(%rsi)
    movb    3(%rdx), %ah
    movb    %ah, 2(%rsi)
    addq    $3, %rsi

    jmp write_barcode_inner_loop_2


write_barcode_end:

    popq    %rax
    mulq    %rax 
    movq    $3, %rdi
    mulq    %rdi
    movq    %rbp, %rsp
    popq    %rbp
    ret


#   Takes:
#   %rdi <- the RLE-encoded message
#   %rsi <- the address of barcode data
#   Returns:
#   %rax -> the length in bytes of barcode data
XOR_encrypt:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    pushq   %rsi
    call    get_message_length
    popq    %rsi
    popq    %rdi

    shrq    $3, %rax
    incq    %rax
    movq    %rax, %rcx
    jmp     XOR_encrypt_loop     

XOR_encrypt_loop:
    cmpq    $0, %rcx
    jle     XOR_encrypt_end

    movq    (%rdi), %rax
    movq    (%rsi), %rdx
    xorq    %rdx, %rax
    movq    %rax, (%rsi)

    addq    $8, %rdi
    addq    $8, %rsi

    decq    %rcx
    jmp     XOR_encrypt_loop

XOR_encrypt_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- the address of bitmap
#   %rsi <- the address of barcode
#   %rdx <- the file size(in bytes)
#   %rcx <- the width/length of barcode(in bytes)
#   Returns:
#   %rax -> the length in bytes of barcode data
write_bitmap:
    pushq   %rbp
    movq    %rsp, %rbp

    #File Header
    movq    $signature, %rax
    movw    (%rax), %ax
    movw    %ax, (%rdi)     #signature
    addq    $2, %rdi
    movl    %ecx, (%rdi)    #file size
    addq    $4, %rdi
    movl    $0, (%rdi)      #reserve field
    addq    $4, %rdi
    movl    $0, (%rdi)      #offset of pixel data inside image
    addq    $4, %rdi

    #Bitmap Header
    movl    $40, (%rdi)     #header size
    addq    $4, %rdi
    movl    %ecx, (%rdi)    #image pixel width
    addq    $4, %rdi
    movl    %ecx, (%rdi)    #image pixel height
    addq    $4, %rdi
    movw    $1, (%rdi)      #reserved field
    addq    $2, %rdi
    movw    $24, (%rdi)     #bits per pixel
    addq    $2, %rdi
    movl    $0, (%rdi)      #compression method
    addq    $4, %rdi

    subq    $54, %rdx
    movl    %edx, (%rdi)    #size of pixel data
    addq    $4, %rdi
    movl    $2835, (%rdi)   #hor res ppm
    addq    $4, %rdi
    movl    $2835, (%rdi)   #ver res ppm
    addq    $4, %rdi
    movl    $0, (%rdi)      #color palette info
    addq    $4, %rdi
    movl    $0, (%rdi)      #n of important colors
    addq    $4, %rdi

    movq    %rdx, %rcx

    jmp     write_bitmap_loop

write_bitmap_loop: 
    cmpq    $0, %rcx
    jle     write_bitmap_end

    movb    (%rsi), %al
    movb    %al, (%rdi)


    decq    %rcx
    incq    %rsi
    incq    %rdi
    jmp     write_bitmap_loop


write_bitmap_end:
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
    
#   Takes:
#   %rdi <- the base address of bitmap
#   Returns:
#   %rax -> 0 if valid bitmap file, otherwise 1
bitmap_check:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $signature, %rsi
    movw    (%rsi), %ax
    movw    (%rdi), %dx
    cmpw    %ax, %dx
    je      bitmap_check_correct
    movq    $1, %rax
    jmp     bitmap_check_end

bitmap_check_correct:
    movq    $0, %rax
    jmp     bitmap_check_end

bitmap_check_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- the base address of bitmap
#   Returns:
#   %rax -> bitmap width
get_bitmap_width:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $0, %rax
    movl    18(%rdi), %eax

    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- the base address of bitmap
#   %rsi <- bitmap width
#   Returns:
#   %rax -> pixel data size
get_last_row_address:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    %rsi, %rax
    mulq    %rsi
    subq    %rsi, %rax
    movq    $3, %rdx
    mulq    %rdx
    addq    $54, %rax
    addq    %rdi, %rax

    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <-  address of last row
#   %rsi <-  address to write barcode to
#   %rdx <-  width of bitmap(in pixels)
#
#   Returns:
#   Nothing, but writes the barcode(without message) into %rsi 
write_decrypt_barcode:
    pushq   %rbp
    movq    %rsp, %rbp
    movq    %rcx, %rdx
    movq    $3, %rax
    mulq    %rdx
    shrq    $2, %rax
    movq    %rax, %rdx
    
write_decrypt_barcode_outer_loop:
    cmpq    $0, %rcx
    jle     write_decrypt_barcode_end
    
    pushq   %rdi
    pushq   %rdx
    jmp     write_decrypt_barcode_inner_loop

write_decrypt_barcode_inner_loop:
    cmpq    $0, %rdx
    jle     write_decrypt_barcode_outer_loop_end

    movl    (%rdi), %eax
    movl    %eax, (%rsi)
    addq    $4, %rdi
    addq    $4, %rsi     

    decq    %rdx
    jmp     write_decrypt_barcode_inner_loop


write_decrypt_barcode_outer_loop_end:
    popq    %rdx
    popq    %rdi

    decq    %rcx
    jmp     write_decrypt_barcode_outer_loop


write_decrypt_barcode_end:
    popq    %rax
    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- Starting address of pixel data (including message)
#   %rsi <- Base address of only barcode(only pixel data)
#   %rdx <- Barcode width/length(in pixels)
XOR_decrypt:
    pushq   %rbp
    movq    %rsp, %rbp
    movq    $3, %rax
    movq    %rdx, %rcx
    mulq    %rcx
    mulq    %rcx
    shrq    $2, %rax
    movq    %rax, %rcx


XOR_decrypt_loop:
    cmpq    $0, %rcx
    jle     XOR_decrypt_end

    movl    (%rdi), %eax
    xorl    %eax, (%rsi)

    addq    $4, %rdi
    addq    $4, %rsi

    decq    %rcx
    jmp     XOR_decrypt_loop

XOR_decrypt_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- the base address of RLE-encoded message
#   Returns:
#   %rax -> the length(in bytes) of message(RLE-decoded)
get_RLE_length:
    pushq   %rbp
    movq    %rsp, %rbp
    movq    $0, %rcx
    movq    $0, %rax
    movq    $0, %rdx

get_RLE_length_loop:
    movb    (%rcx, %rdi), %dl
    cmpb    $0, %dl
    je      get_RLE_length_end
    addq    %rdx, %rax

    addq    $2, %rcx
    jmp     get_RLE_length_loop

get_RLE_length_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- The base address of message (without lead)
#   %rsi <- Base address of reserved space for fully-decrypted message
#   %rdx <- The length of the fully-decrypted message
remove_lead_trail:
    pushq   %rbp
    movq    %rsp, %rbp
    movq    %rdx, %rcx
    movq    $0, %rdx

remove_lead_trail_loop:
    cmpq    $0, %rcx
    jle     remove_lead_trail_end

    movb    (%rdx, %rdi), %al
    movb    %al, (%rdx, %rsi)

    incq    %rdx
    decq    %rcx
    jmp     remove_lead_trail_loop

remove_lead_trail_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret
    