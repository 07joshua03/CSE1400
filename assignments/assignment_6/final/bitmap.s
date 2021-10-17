.text

.include "bitmap_helper.s"
.include "read_file.s"

message:    .asciz "The answer for exam question 42 is not F."
leadtrail:  .asciz "CCCCCCCCSSSSEE1111444400000000"
barcode:    .asciz "WWWWWWWWBBBBBBBBWWWWBBBBWWBBBWWR"   #Always a multiple of 4

#filepath:   .asciz "/home/student/TUDelft/Assembly/assignments/assignment_6/final/barcode.bmp"
filepath:   .asciz "./barcode.bmp"

encrypt_output_1:  .asciz "\n#############################\n\nStarted encrypting...\n\nThe original message is: \n%s\n"
encrypt_output_2:  .asciz "\nThe message with lead-trail is:\n%s\n"
encrypt_output_3:  .asciz "\nThe RLE-encoded message is: (prob doesn't show correctly)\n%s\n"
encrypt_output_4:  .asciz "\nDecoding RLE-encoded message gives:(to show encoding/decoding works)\n%s\n\n"
encrypt_done:   .asciz "\nThe barcode bitmap is saved at: %s\n\nEncrypting done!\n\n"

decrypt_output_1:   .asciz "#############################\n\nStarted decrypting...\n\nThe file being decrypted is: %s\n"
decrypt_output_2:   .asciz "\nThe decrypted message with lead/trail is: %s\n"
decrypt_output_3:   .asciz "\nThe fully decrypted message is:\n%s\n\nDecrypting done!\n\n#############################\n\n"
decode_error:   .asciz "\nA non-bitmap file given. Exiting...\n\n"



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

    .byte   0x47    #GREEN
    .byte   0x00    #B
    .byte   0xFF    #G
    .byte   0x00    #R

    .byte   0x62    #BLUE
    .byte   0xFF    #B
    .byte   0x00    #G
    .byte   0x00    #R

.global main

main:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $message, %rdi
    call    encode

    movq    $filepath, %rdi
    call    decode

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
    movq    $encrypt_output_1, %rdi
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
    // movq    $encrypt_output_2, %rdi
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
    // movq    $encrypt_output_3, %rdi
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
    // movq    $encrypt_output_4, %rdi
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
#   %rdi <- the filepath of the bitmap
decode:
    pushq   %rbp
    movq    %rsp, %rbp

    ######################
    pushq   %rdi
    movq    %rdi, %rsi      
    movq    $decrypt_output_1, %rdi
    movq    $0, %rax
    call    printf
    popq    %rdi
    #####################

    subq    $8, %rsp
    leaq    (%rsp), %rsi
    call    read_file           #uses read_file from Assignment 7, written by TU Delft Staff
    movq    %rax, %rdi
    popq    %rsi

    pushq   %rdi
    call    bitmap_check
    popq    %rdi

    cmpq    $0, %rax
    jne     not_bitmap_error

    pushq   %rdi
    call    get_bitmap_width
    popq    %rdi
    movq    %rax, %rsi

    pushq   %rdi
    pushq   %rsi
    call    get_last_row_address
    popq    %rsi
    popq    %rdi
    movq    %rsi, %rcx
    movq    %rax, %rsi

    movq    $3, %rax
    mulq    %rcx                #%rsi always a multiple of 4
    mulq    %rcx 
    subq    %rax, %rsp
    movq    %rsp, %rdx        #address to barcode to

    pushq   %rdi                #base address
    pushq   %rdx                #address to write barcode to
    pushq   %rcx                #width of bitmap(in pixels)

    movq    %rsi, %rdi          #address of last row
    movq    %rdx, %rsi          #address to write barcode to
    movq    %rcx, %rdx          #width of bitmap(in pixels)
    call    write_decrypt_barcode

    popq    %rdx                #width of bitmap(in pixels)
    popq    %rsi                #address to write barcode to
    popq    %rdi                #base address

    addq    $54, %rdi

    // pushq   %rdi                #starting address of pixel data
    pushq   %rsi                #address where only barcode is in(only pixel data)
    pushq   %rdx                #barcode width/length(in pixels)
    call    XOR_decrypt
    popq    %rsi
    popq    %rdi
    // popq    %rdi

    //pushq   %rdi
    pushq   %rdi
    call    get_RLE_length
    popq    %rdi
    //popq    %rdi

    shrq    $3, %rax
    incq    %rax
    shlq    $3, %rax

    subq    %rax, %rsp
    movq    %rsp, %rsi

    pushq   %rdi
    pushq   %rsi
    movq    %rsi, %rdi
    movq    %rax, %rsi
    call    clearstackspace
    popq    %rsi
    popq    %rdi

    //pushq   %rdi            #Base address of RLE-encoded message
    pushq   %rsi            #Reserved space for RLE-decoded message
    call    decode_RLE
    popq    %rsi
    //popq    %rdi

    movq    %rsi, %rdi

    // ######################
    // pushq   %rdi
    // movq    %rdi, %rsi      
    // movq    $decrypt_output_2, %rdi
    // movq    $0, %rax
    // call    printf
    // popq    %rdi
    // #####################

    
    pushq   %rdi
    call    get_message_length
    popq    %rdi
    movq    %rax, %rsi

    pushq   %rdi
    pushq   %rsi
    movq    $leadtrail, %rdi
    call    get_message_length
    popq    %rsi
    popq    %rdi

    addq    %rax, %rdi      #add lead length to base message address to offset it
    shlq    $1, %rax        
    subq    %rax, %rsi

    shrq    $3, %rax
    incq    %rax
    shlq    $3, %rax
    subq    %rax, %rsp
    movq    %rsi, %rdx
    movq    %rsp, %rsi

    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    movq    %rsi, %rdi
    movq    %rax, %rsi
    call    clearstackspace
    popq    %rdx
    popq    %rsi
    popq    %rdi

    //pushq   %rdi            #Base address of message(no lead/trail)
    pushq   %rsi            #Reserved space for fully-decrypted message
    //pushq   %rdx            #Length of message
    call    remove_lead_trail
    popq    %rdi


    ######################
    pushq   %rdi
    movq    %rdi, %rsi      
    movq    $decrypt_output_3, %rdi
    movq    $0, %rax
    call    printf
    popq    %rdi
    #####################


    movq    %rbp, %rsp
    popq    %rbp
    ret

not_bitmap_error:
    movq    $decode_error, %rdi
    movq    $0, %rax
    call    printf

    movq    %rbp, %rsp
    popq    %rbp
    ret

