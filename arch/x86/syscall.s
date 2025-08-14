BITS 32
section .text

; fn syscall0(number: u32) u32;
; fn syscall1(number: u32, arg1: u32) u32;
; fn syscall2(number: u32, arg1: u32, arg2: u32) u32;

global syscall0, syscall1, syscall2, syscall3

; EAX = number
syscall0:
    mov     eax, [esp+4]          ; number
    int     0x7F
    ret

; EAX = number, EBX = arg1
syscall1:
    push    ebx
    mov     eax, [esp+8]           ; number
    mov     ebx, [esp+12]          ; arg1
    int     0x7F
    pop     ebx
    ret

; EAX = number, EBX = arg1, ECX = arg2
syscall2:
    push    ebx
    mov     eax, [esp+8]           ; number
    mov     ebx, [esp+12]          ; arg1
    mov     ecx, [esp+16]          ; arg2
    int     0x7F
    pop     ebx
    ret

; EAX = number, EBX = arg1, ECX = arg2, EDX = arg3
syscall3:
    push    ebx
    mov     eax, [esp+8]           ; number
    mov     ebx, [esp+12]          ; arg1
    mov     ecx, [esp+16]          ; arg2
    mov     edx, [esp+20]          ; arg3
    int     0x7F
    pop     ebx
    ret