BITS 32

section .data
global irq_stub_table
irq_stub_table:
%assign i 0
%rep 16
    dd irq%+i
%assign i i+1
%endrep

%macro IRQ_STUB 1
global irq%+%1
irq%+%1:
    cli
    push dword 0 ; dummy error code
    push dword (32 + %1) ; int number
    jmp irq_common_stub
%endmacro

section .text
; IRQ 0‑15
%assign i 0
%rep 16
    IRQ_STUB i
%assign i i+1
%endrep

extern irq_handler
irq_common_stub:
    pusha
    push ds
    push es
    push fs
    push gs
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov eax, esp
    push eax
    mov eax, irq_handler
    call eax
    pop eax
    pop gs
    pop fs
    pop es
    pop ds
    popa
    add esp, 8
    iret
