.data
h0:
    .long 0x80000000
    .long 0x00000000
    .long 0x00000000
    .long 0x00000000
    .long 0x00000000

a:
    .long 0x00000000
    .long 0x00000000
    .long 0x00000000
    .long 0x00000000
    .long 0x00000000

fk:
    .long 0x00000000
    .long 0x00000000


.text
#   Takes 2 arguments:

read_h:


final_hash:
    pushq   %rbp
    movq    %rsp, %rbp

    leaq    $h0, %rdi

    movl    (%rdi), %eax
    shll    $128, %eax

    movl    4(%rdi), %edx
    shll    $96, %edx

    orl    %edx, %eax

    movl    8(%rdi), %edx
    shll    $64, %edx

    orl    %edx, %eax

    movl    12(%rdi), %edx
    shll    $32, %edx

    orl    %edx, %eax



    movq    %rbp, %rsp
    popq    %rbp
    ret
