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

translate_code:
    pushq   %rbp
    movq    %rsp, %rbp


translate_code_loop:
    movb    (%rdi), %al         #curr char
    cmpb    $0, %al
    je      translate_code_end

    cmpb    $46, %al
    je      translate_code_output
    cmpb    $44, %al
    je      translate_code_input
    cmpb    $62, %al
    je      translate_code_incptr
    cmpb    $60, %al
    je      translate_code_decptr
    cmpb    $43, %al
    je      translate_code_incval
    cmpb    $45, %al
    je      translate_code_decval
    cmpb    $91, %al
    je      translate_code_sol
    cmpb    $93, %al
    je      translate_code_eol

    incq    %rdi
    jmp     translate_code_loop

translate_code_end:
    movb    $0, (%rsi)
    movw    $0, 1(%rsi)

    movq    %rbp, %rsp
    popq    %rbp
    ret

translate_code_output:
    movb    $1, (%rsi)
    #movw    $0, 1(%rsi)
    addq    $3, %rsi
    incq    %rdi
    jmp     translate_code_loop

translate_code_input:
    movb    $2, (%rsi)
    #movw    $0, 1(%rsi)
    addq    $3, %rsi
    
    incq    %rdi
    jmp     translate_code_loop

translate_code_incptr:
    movb    $3, (%rsi)
    movw    $1, %cx
    incq    %rdi

translate_code_incptr_loop:
    cmpb    $62, (%rdi)
    jne     translate_code_incptr_end
    incw    %cx
    incq    %rdi
    jmp     translate_code_incptr_loop


translate_code_incptr_end:
    movw    %cx, 1(%rsi)
    addq    $3, %rsi
    jmp     translate_code_loop

translate_code_decptr:
    movb    $4, (%rsi)
    movw    $1, %cx
    incq    %rdi

translate_code_decptr_loop:
    cmpb    $60, (%rdi)
    jne     translate_code_decptr_end
    incw    %cx
    incq    %rdi
    jmp     translate_code_decptr_loop


translate_code_decptr_end:
    movw    %cx, 1(%rsi)
    addq    $3, %rsi
    jmp     translate_code_loop

translate_code_incval:
    movb    $5, (%rsi)
    movw    $1, %cx
    incq    %rdi

translate_code_incval_loop:
    cmpb    $43, (%rdi)
    jne     translate_code_incval_end
    incw    %cx
    incq    %rdi
    jmp     translate_code_incval_loop


translate_code_incval_end:
    movw    %cx, 1(%rsi)
    addq    $3, %rsi
    jmp     translate_code_loop

translate_code_decval:
    movb    $6, (%rsi)
    movw    $1, %cx
    incq    %rdi

translate_code_decval_loop:
    cmpb    $45, (%rdi)
    jne     translate_code_decval_end
    incw    %cx
    incq    %rdi
    jmp     translate_code_decval_loop

translate_code_decval_end:
    movw    %cx, 1(%rsi)
    addq    $3, %rsi
    jmp     translate_code_loop


translate_code_sol:
    incq    %rdi
    cmpb    $45, (%rdi)
    je      translate_code_sol_special

translate_code_sol_special:
    cmpb    $93, 1(%rdi)
    jne     translate_code_sol_non_special
    movb    $9, (%rsi)
    #movw    $0, 1(%rsi)
    addq    $3, %rsi
    addq    $2, %rdi
    jmp     translate_code_loop
    
translate_code_sol_non_special:
    movb    $7, (%rsi)
    addq    $3, %rsi
    jmp     translate_code_loop


translate_code_eol:
    movb    $8, (%rsi)
    addq    $3, %rsi
    incq    %rdi
    jmp     translate_code_loop



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


sol_data:
    pushq   %rbp
    movq    %rsp, %rbp
    
sol_data_loop:
    movb    (%rcx, %rdi), %al
    cmpb    $7, %al
    je      sol_data_sol
    cmpb    $8, %al
    je      sol_data_eol
    cmpb    $0, %al
    je      sol_data_end

    addq    $3, %rcx
    jmp     sol_data_loop

sol_data_sol:
    pushq   %r8
    pushq   %r9
    incq    %rdx
    movq    %rdx, %r8
    movq    %rcx, %r9

    addq    $3, %rcx

    call    sol_data
    popq    %r9
    popq    %r8

    jmp     sol_data_loop

sol_data_eol:
    movq    %r8, %rax
    shlq    $2, %rax

    addq    $3, %rcx

    // movl    %ecx, (%rax, %rsi)
    movw    %cx, 1(%r9, %rdi)

    jmp     sol_data_end


sol_data_end:
    movq    %rbp, %rsp
    popq    %rbp
    ret