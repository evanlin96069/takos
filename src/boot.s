; boot.s - Multiboot2 header and kernel entry point
BITS 32

SECTION .multiboot2
align 8
mb_header:
    dd 0xE85250D6         ; magic
    dd 0                  ; architecture (i386)
    dd mb_end - mb_header ; header length
    dd -(0xE85250D6 + 0 + (mb_end - mb_header)) ; checksum
    ; end tag
    dw 0
    dw 0
    align 8
mb_end:

SECTION .text
global _start
_start:
    ; On entry:
    ;  EAX = multiboot magic
    ;  EBX = multiboot info structure pointer
    push ebx
    push eax
    extern kernel_main
    call kernel_main

.hang:
    cli
    hlt
    jmp .hang
