#   Takes:
#   %rdi <- the base address of message (where we start at the lowest address)
#   Returns:
#   %rax -> the length(in bytes) of message till zero-byte
get_code_length:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $0, %rcx
    jmp     get_message_length_loop

    get_code_length_loop:
        pushq   %rdi
        addq    %rcx, %rdi

        movb    (%rdi), %al

        cmpb    $0, %al
        je      get_message_length_end

        popq    %rdi
        incq    %rcx
        jmp     get_message_length_loop


    get_code_length_end:
        movq    %rcx, %rax
        movq    %rbp, %rsp
        popq    %rbp
        ret

#   Takes:
#   %rdi <- the address of brainfuck file
#   %rsi <- the address to write translation to
#   %rdx <- the address of translations
translate_code:
    pushq   %rbp
    movq    %rsp, %rbp

translate_code_loop:


translate_code_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret

clear_stack_space:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    movq    %rsi, %rcx
    jmp     clear_stack_space_loop


clear_stack_space_loop:
    cmpq    $0, %rcx
    jle     clear_stack_space_end

    movq   $0, (%rdi)

    decq    %rcx
    addq    $8, %rdi
    jmp     clear_stack_space_loop


clear_stack_space_end:
    popq    %rdi

    movq    %rbp, %rsp
    popq    %rbp    
    ret