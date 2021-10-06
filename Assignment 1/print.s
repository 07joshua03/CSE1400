.text

message:    .asciz "\nAssignment 1a: \nName: Joshua Gort en Jordy ??????\nNetids: 5540852 en ?????????\nJa my bad weet zowel je achternaam als netid niet\n\n"

.global main

main:
    push    %rbp

    movq    %rsp, %rbp

    movq    $0, %rax
    movq    $message, %rdi
    call    printf

    movq    %rbp, %rsp
    pop     %rbp
    call    exit
