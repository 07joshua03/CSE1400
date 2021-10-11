.text

.include "bitmap_helper.s"

message:    .asciz "The answer for exam question 42 is not F."
leadtrail:  .asciz "CCCCCCCCSSSSEE1111444400000000"
barcode:    .asciz "WWWWWWWWBBBBBBBBWWWWBBBBWWBBBWWR"

filepath:   .asciz "/home/student/TUDelft/Assembly/Assignment\ 6/barcode.bmp"

test_output_1:  .asciz "\nThe original message is:\n%s\n"
test_output_2:  .asciz "\nThe message with lead-trail is:\n%s\n"
test_output_3:  .asciz "\nThe RLE-encoded message is: (prob doesn't show correctly)\n%s\n"
test_output_4:  .asciz "\nDecoding RLE-encoded message gives:(to show encoding/decoding works)\n%s\n\n"

encrypt_done:   .asciz "\nThe barcode bitmap is saved at: %s\n\n"

barcode_colors:
    .byte   0x57    #WHITE
    .byte   0xFF
    .byte   0xFF
    .byte   0xFF

    .byte   0x42    #BLACK
    .byte   0x00
    .byte   0x00
    .byte   0x00

    .byte   0x52    #RED
    .byte   0x00    #B
    .byte   0x00    #G
    .byte   0xFF    #R

.global main

main:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $message, %rdi
    
    call    encode

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rdi
    call    exit

#Takes:
#   %rdi <- the address of message
encode:
    pushq   %rbp
    movq    %rsp, %rbp

    #################################
    pushq   %rdi
    subq    $8, %rsp
    movq    $0, %rax
    movq    %rdi, %rsi
    movq    $test_output_1, %rdi
    call    printf
    addq    $8, %rsp
    popq    %rdi
    #################################

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

    // #################################
    // pushq   %rdi
    // subq    $8, %rsp
    // movq    $0, %rax
    // movq    %rdi, %rsi
    // movq    $test_output_2, %rdi
    // call    printf
    // addq    $8, %rsp
    // popq    %rdi
    // #################################

    pushq   %rdi

    call    get_message_length
    shrq    $2, %rax    #Divide by 4
    incq    %rax
    shlq    $3, %rax

    popq    %rdi

    subq    %rax, %rsp
    movq    %rsp, %rsi

    pushq   %rdi    #Leadtrailmessage address
    pushq   %rsi    #RLE address

    call    encode_RLE

    popq    %rsi
    popq    %rdi

    // #################################
    // pushq   %rdi
    // pushq   %rsi
    // movq    $0, %rax
    // movq    $test_output_3, %rdi
    // call    printf
    // popq    %rsi
    // popq    %rdi
    // #################################

    // pushq   %rsi

    // movq    %rsi, %rdi
    // call    get_message_length
    // shrq    $2, %rax    #Divide by 4
    // incq    %rax
    // shlq    $3, %rax

    // popq    %rdi

    // subq    %rax, %rsp
    // movq    %rsp, %rsi

    // pushq   %rdi
    // pushq   %rsi

    // call    decode_RLE

    // popq    %rsi
    // popq    %rdi

    // #################################
    // pushq   %rdi
    // pushq   %rsi
    // movq    $0, %rax
    // movq    $test_output_4, %rdi
    // call    printf
    // popq    %rsi
    // popq    %rdi
    // #################################

    movq    $barcode, %rdi
    pushq   %rdi
    pushq   %rsi

    call    get_message_length
    pushq   %rax
    movq    $3, %rcx
    mulq    %rcx    
    shrq    $3, %rax
    incq    %rax
    shlq    $3, %rax
    mulq    %rax

    popq    %rcx

    popq    %rsi
    popq    %rdi

    movq    %rdi, %rdx  #barcode text
    movq    %rsi, %rdi  #RLE-encoded message

    subq    %rax, %rsp
    movq    %rsp, %rsi  #Space for barcode data

    pushq   %rdi
    pushq   %rsi
    pushq   %rcx
    movq    %rdx, %rdi
    movq    $barcode_colors, %rdx

    call    write_barcode
    popq    %rcx
    popq    %rsi
    popq    %rdi

    movq    %rax, %rdx

    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    pushq   %rcx
    call    XOR_encrypt
    popq    %rcx        #barcode width/length
    popq    %rdx
    popq    %rsi        #barcode address
    popq    %rdi

    addq    $54, %rdx   #Total file size
    subq    %rdx, %rsp
    movq    %rsp, %rdi  #Address of bitmap  

    pushq   %rdi
    pushq   %rdx
    call    write_bitmap
    popq    %rdx
    popq    %rdi

    pushq   %rdi
    pushq   %rdx

    movq    $2, %rax
    movq    $filepath, %rdi
    movq    $0102, %rsi
    movq    $00700, %rdx

    syscall

    popq    %rdx
    popq    %rsi

    movq    %rax, %rdi
    movq    $1, %rax

    syscall

    movq    $0, %rax
    movq    $encrypt_done, %rdi
    movq    $filepath, %rsi
    call    printf


    movq    %rbp, %rsp
    popq    %rbp
    ret

#Takes:
#   %rdi <- the address of the bitmap
decode:
    pushq   %rbp
    movq    %rsp, %rbp

    


    movq    %rbp, %rsp
    popq    %rbp
    ret


