BITS 32
section .text

; fn ctx_switch(new_cr3: u32, new_esp: u32) void;
global ctx_switch
ctx_switch:
    mov  eax, [esp+4] ; new_cr3
    mov  edx, [esp+8] ; new_esp
    cli
    mov  cr3, eax
    mov  esp, edx
    pop  gs
    pop  fs
    pop  es
    pop  ds
    popa
    add  esp, 8 ; err_code + int_no
    iret

; fn sched_start(new_cr3: u32, new_esp: u32) void;
global sched_start
sched_start:
    mov  eax, [esp+4]
    mov  edx, [esp+8]
    cli
    mov  cr3, eax
    mov  esp, edx
    pop  gs
    pop  fs
    pop  es
    pop  ds
    popa
    add  esp, 8
    iret

global kthread_entry
kthread_entry:
    push ebx
    call eax
    mov  eax, 0
    xor  ebx, ebx
    int  0x7F ; sys_exit(0)
.halt:
    hlt
    jmp .halt
