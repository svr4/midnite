bits 32
org 0x100000

start:

    mov byte[0xb8000], 'K'
    mov byte[0xb8001], 0x0A

    lgdt [Gdt32Ptr]
    lidt [Idt32Ptr]

    ; setup a stack
    ; add an amount to 0x100000 and save to esp

End:
    hlt
    jmp End


Gdt32:
    dq  0
Code32:
    dw  0xFFFF  ; limit 0-15
    dw  0       ; base 16-31
    db  0       ; base 32-39
    db  0x9A    ; access byte 40-47
    db  0xCF    ; limit (48-51) & flags(52-55)
    db  0       ; base 56-63
Data32:
    dw  0xFFFF  ; limit 0-15
    dw  0       ; base 16-31
    db  0       ; base 32-39
    db  0x92    ; access byte 40-47
    db  0xCF    ; limit (48-51) & flags(52-55)
    db  0       ; base 56-63

Gdt32Len: equ $-Gdt32

Gdt32Ptr:   dw Gdt32Ptr-1
            dd Gdt32

Idt32Ptr:   dw 0
            dd 0