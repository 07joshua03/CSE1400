#   Takes:
#   %rdi <- the base address of code (where we start at the lowest address)
#   Returns:
#   %rax -> the length(in bytes) of code till zero-byte
get_code_length:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $0, %rcx
    jmp     get_code_length_loop

    get_code_length_loop:
        pushq   %rdi
        addq    %rcx, %rdi

        movb    (%rdi), %al

        cmpb    $0, %al
        je      get_code_length_end

        popq    %rdi
        incq    %rcx
        jmp     get_code_length_loop


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

    jmp     translate_code_outer_loop

translate_code_outer_loop:
    cmpq    $0, %rcx
    jle     translate_code_end

    pushq   %rcx
    pushq   %rdx
    movq    $7, %rcx
    movb    (%rdi), %al
    jmp     translate_code_inner_loop

translate_code_inner_loop:
    cmpb    %al, (%rdx)
    je      translate_code_inner_loop_if
    jmp     translate_code_inner_loop_else

translate_code_inner_loop_if:
    movb    1(%rdx), %al
    movb    %al, (%rsi)
    incq    %rsi
    jmp     translate_code_outer_loop_end

translate_code_inner_loop_else:
    addq    $2, %rdx
    decq    %rcx
    cmpq    $0, %rcx
    jle     translate_code_outer_loop_end
    jmp     translate_code_inner_loop

translate_code_outer_loop_end:
    popq    %rdx
    popq    %rcx
    decq    %rcx
    incq    %rdi
    
    jmp     translate_code_outer_loop


translate_code_end:
    movb    $0, (%rsi)

    movq    %rbp, %rsp
    popq    %rbp
    ret

clear_stack_space:
    pushq   %rbp
    movq    %rsp, %rbp

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
    movq    %rbp, %rsp
    popq    %rbp    
    ret