.text

.include "bitmap_helper.s"

message:    .asciz "The answer for exam question 42 is not F."
leadtrail:  .asciz "CCCCCCCCSSSSEE1111444400000000"
barcode:    .asciz "WWWWWWWWBBBBBBBBWWWWBBBBWWBBBWWR"

test_output_1:  .asciz "\nThe original message is:\n%s\n"
test_output_2:  .asciz "\nThe message with lead-trail is:\n%s\n"
test_output_3:  .asciz "\nThe RLE-encoded message is: (prob doesn't show correctly)\n%s\n"
test_output_4:  .asciz "\nDecoding RLE-encoded message gives:(to show encoding/decoding works)\n%s\n\n"

barcode_colors:
    .byte   0x57
    .byte   0xFF
    .byte   0xFF
    .byte   0xFF

    .byte   0x42
    .byte   0x00
    .byte   0x00
    .byte   0x00

    .byte   0x52
    .byte   0xFF
    .byte   0x00
    .byte   0x00

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

    #################################
    pushq   %rdi
    subq    $8, %rsp
    movq    $0, %rax
    movq    %rdi, %rsi
    movq    $test_output_2, %rdi
    call    printf
    addq    $8, %rsp
    popq    %rdi
    #################################

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

    #################################
    pushq   %rdi
    pushq   %rsi
    movq    $0, %rax
    movq    $test_output_3, %rdi
    call    printf
    popq    %rsi
    popq    %rdi
    #################################

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
    movq    $3, %rcx
    mulq    %rcx    
    shrq    $3, %rax
    incq    %rax
    shlq    $3, %rax
    mulq    %rax

    popq    %rsi
    popq    %rdi

    movq    %rdi, %rdx  #barcode text
    movq    %rsi, %rdi  #RLE-encoded message

    subq    %rax, %rsp
    movq    %rsp, %rsi  #Space for barcode data

    pushq   %rdi
    pushq   %rsi
    movq    %rdx, %rdi
    movq    $barcode_colors, %rdx

    call    write_barcode
    popq    %rsi
    popq    %rdi

    call    XOR_encrypt

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

