.text

.global main

filename:  .asciz "/home/student/TUDelft/Assembly/Tests/textfile.txt"
message:   .asciz "test123 wtf it works amazing wow very good"

main:
    pushq   %rbp
    movq    %rsp, %rbp



    movq    $8, %rax
    movq    $filename, %rdi
    movq    $00100, %rsi

    syscall

    // movq    %rax, %rdi
    // movq    $message, %rsi
    // movq    $1, %rax
    // movq    $42, %rdx

    // syscall

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rdi
    call    exit