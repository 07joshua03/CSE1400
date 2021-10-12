.text

#   Takes:
#   %rdi <- h0 address
#   %rsi <- 0 - 4 for h0 till h4
#   Returns:
#   %eax -> data at address
#   Changes: %eax
read_h:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    pushq   %rsi

    shlq    $2, %rsi    #multiply offset by 4
    addq    %rsi, %rdi
    movl    (%rdi), %eax

    popq    %rsi
    popq    %rdi

    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- w address
#   %rsi <- 0 - 79 for w[0] till w[79]
#   Returns:
#   %eax -> data at address
#   Changes: %eax
read_w:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    pushq   %rsi

    shlq    $2, %rsi    #multiply offset by 4
    addq    %rsi, %rdi
    movl    (%rdi), %eax

    popq    %rsi
    popq    %rdi

    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- a address
#   %rsi <- 0 - 5 for a, b, c, d, e, k
#   Returns:
#   %eax -> data at address
#   Changes: %eax
read_a:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    pushq   %rsi

    shlq    $2, %rsi    #multiply offset by 4
    subq    %rsi, %rdi
    movl    (%rdi), %eax

    popq    %rsi
    popq    %rdi

    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- h0 address
#   %rsi <- 0 - 4 for h0 till h4
#   %edx <- data to write(4 bytes)
#   Changes: data at %rdi + offset
write_h:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    subq    $8, %rsp

    shlq    $2, %rsi
    addq    %rsi, %rdi
    movl    %edx, (%rdi)

    addq    $8, %rsp
    popq    %rdx
    popq    %rsi
    popq    %rdi

    movq    %rbp, %rsp
    popq    %rbp
    ret

#   Takes:
#   %rdi <- w address
#   %rsi <- 0 - 79 for w[0] till w[79]
#   %edx <- data to write(4 bytes)
#   Returns:
#   Changes: data at %rdi + offset
write_w:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    subq    $8, %rsp

    shlq    $2, %rsi
    addq    %rsi, %rdi
    movl    %edx, (%rdi)

    addq    $8, %rsp
    popq    %rdx
    popq    %rsi
    popq    %rdi

    movq    %rbp, %rsp
    popq    %rbp
    ret


#   Takes:
#   %rdi <- a address
#   %rsi <- 0 - 5 for a, b, c, d, e, k
#   Returns:
#   Changes: %eax
write_a:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    subq    $8, %rsp

    shlq    $2, %rsi
    subq    %rsi, %rdi
    movl    %edx, (%rdi)

    addq    $8, %rsp
    popq    %rdx
    popq    %rsi
    popq    %rdi

    movq    %rbp, %rsp
    popq    %rbp
    ret
    