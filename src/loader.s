bits 16

org 0x7E00

start:

; Call the BIOS interrupt 0x10 to print a message on screen.
    ; mov ah, 0x13 ; Param: Indicates the function code to print. 
    ; mov al, 1 ; Param: Indicates the cursor will be set at the end of the screen. 
    ; mov bx, 0xA ; Param: Indicates the character attributes. Prints in bright green. [bh:bl] bh represents page number, bl char attributes
    ; xor dx, dx ; Param: [dh:dl] dh - rows dl - cols. In this case 0,0 zeroed out. 
    ; mov bp, Message2 ; Param: Addres of string. 
    ; mov cx, MessageLen2 ; Param: Num of chars to print. 
    ; int 0x10

    ; mov byte[0xb8000], 'K'
    ; mov byte[0xb8001], 0x0A

LoadKernel:
    mov [DriveId], dl
    mov si, ReadPacket
    mov word[si], 0x10
    mov word[si+2], 100
    mov word[si+4], 0 ; offset
    mov word[si+6], 0x1000 ; segment address where the code will be loaded
    mov dword[si+8], 6 ; sector
    mov dword[si+12], 0
    mov dl, [DriveId]
    mov ah, 0x42 ; https://en.wikipedia.org/wiki/INT_13H#INT_13h_AH=42h:_Extended_Read_Sectors_From_Drive
    int 0x13
    jc ReadError



GetMemoryInfoStart:
    mov eax, 0xE820
    mov edx, 0x534D4150 ; smap in ascii
    mov ecx, 20
    mov edi, 0x9000
    xor ebx, ebx
    int 0x15
    jc NoSupport

GetMemoryInfo:
    add edi, 20 ; we want the next 20 bytes of memory
    mov eax, 0xE820
    mov edx, 0x534D4150 ; smap in ascii
    mov ecx, 20
    int 0x15
    jc GetMemoryDone

    test ebx, ebx
    jnz GetMemoryInfo

GetMemoryDone:

TestA20:
    mov ax, 0xFFFF
    mov es, ax
    mov word[ds:0x7C00], 0xA200
    cmp word[es:0x7C10], 0xA200
    jne SetA20LineDone
    mov word[0x7C00], 0xB200
    cmp word[es:0x7C10], 0xB200
    je End


SetA20LineDone:
    xor ax, ax
    mov es, ax


SetVideoMode:
    mov ax, 3
    int 0x10

    cli
    lgdt [Gdt32Ptr]
    lidt [Idt32Ptr]

    ; enable protected mode
    mov eax, cr0
    or  eax, 1
    mov cr0, eax

    jmp 8:PMEntry


ReadError:
    ; Call the BIOS interrupt 0x10 to print a message on screen.
    cmp ah, 0x01
    jne End
    mov ah, 0x13 ; Param: Indicates the function code to print. 
    mov al, 1 ; Param: Indicates the cursor will be set at the end of the screen. 
    mov bx, 0xA ; Param: Indicates the character attributes. Prints in bright green. [bh:bl] bh represents page number, bl char attributes
    xor dx, dx ; Param: [dh:dl] dh - rows dl - cols. In this case 0,0 zeroed out. 
    mov bp, Message3 ; Param: Addres of string. 
    mov cx, MessageLen3 ; Param: Num of chars to print. 
    int 0x10
NoSupport:
End:
    hlt
    jmp End

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PROTECTED MODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bits 32
PMEntry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; move loaded kernel to 1MB address
    cld
    mov edi, 0x100000
    mov esi, 0x10000
    mov ecx, 51200/8
    rep movsd


    jmp 0x100000 ; jump into the kernel bootstrap


PEnd:
    hlt
    jmp PEnd



    ; Setup for print fn
;     mov si, Message
;     mov ax, 0xB800
;     mov es, ax
;     xor di, di
;     mov cx, MessageLen

; PrintMessage:
;     mov al, [si]
;     mov [es:di], al
;     mov byte[es:di+1], 0xa

;     add di, 2
;     add si, 1
;     loop PrintMessage



; KernelBootstrapper:
;     ; setup a stack
;     mov esp, 


;     extern callConstructors 
;     extern kernel_main

;     cli ; Disable interrupts
    
    
;     call callConstructors 
;     call kernel_main


DriveId:    db 0
; Message:    db "Kernel loaded."
; MessageLen: equ $-Message
; Message2:    db "Get memory info done"
; MessageLen2: equ $-Message2
Message3:    db "Error found"
MessageLen3: equ $-Message3

ReadPacket: times 16 db 0

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

Gdt32Ptr:   dw Gdt32Len-1
            dd Gdt32

Idt32Ptr:   dw 0
            dd 0