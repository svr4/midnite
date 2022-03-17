bits 32
org 0x100000

; extern callConstructors 
; extern kernel_main

start:

    ; Setup a stack.
    ; The value of stack stop will be greater than 0x100000.
    ; Remember the stack grows downward.
    ; 16777216 = 0x1000000
    ; 0x1000000 > 0x100000
    mov esp, 0x1000000

    mov edi, Idt32
    mov eax, interrupt_handler0
    ; Lower 16 bits of offset to Idt Gate Descriptor
    mov [edi], ax
    shr eax, 16 ; shift contents of eax by 16 bits
    mov [edi+6], ax ; copy second part of offset

    lidt[IdtPtr]

    mov byte[0xb8000], 'K'
    mov byte[0xb8001], 0x0A

    xor ebx, ebx
    div ebx

    ; call callConstructors
    ; call kernel_main

End:
    hlt
    jmp End

interrupt_handler0:

    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp

    mov byte[0xb8000], 'D'
    mov byte[0xb8001], 0x0C

    jmp End

    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    iret

; stack_top:  times 16777216 db 0

Idt32:
    %rep 256
        dw 0
        dw 0x8
        db 0
        db 0x8E ; P=1 DPL=00 TYPE=01110
        dw 0
    %endrep
IdtLen: equ $-Idt32

IdtPtr: dw IdtLen-1
        dq Idt32