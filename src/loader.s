bits 16

org 0x7E00

start:
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
; Call the BIOS interrupt 0x10 to print a message on screen.
    ; mov ah, 0x13 ; Param: Indicates the function code to print. 
    ; mov al, 1 ; Param: Indicates the cursor will be set at the end of the screen. 
    ; mov bx, 0xA ; Param: Indicates the character attributes. Prints in bright green. [bh:bl] bh represents page number, bl char attributes
    ; xor dx, dx ; Param: [dh:dl] dh - rows dl - cols. In this case 0,0 zeroed out. 
    ; mov bp, Message2 ; Param: Addres of string. 
    ; mov cx, MessageLen2 ; Param: Num of chars to print. 
    ; int 0x10


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
    ; Call the BIOS interrupt 0x10 to print a message on screen.
    mov ah, 0x13 ; Param: Indicates the function code to print. 
    mov al, 1 ; Param: Indicates the cursor will be set at the end of the screen. 
    mov bx, 0xA ; Param: Indicates the character attributes. Prints in bright green. [bh:bl] bh represents page number, bl char attributes
    xor dx, dx ; Param: [dh:dl] dh - rows dl - cols. In this case 0,0 zeroed out. 
    mov bp, Message ; Param: Addres of string. 
    mov cx, MessageLen ; Param: Num of chars to print. 
    int 0x10

SetVideoMode:
    mov ax, 3
    int 0x10

KernelBootstrapper:
    extern callConstructors 
    extern kernel_main
    
    call callConstructors 
    call kernel_main

LoadKernel:
    mov [DriveId], dl
    mov si, ReadPacket
    mov word[si], 0x10
    mov word[si+2], 100
    mov word[si+4], 0 ; offset
    mov word[si+6], 0x1000 ; segment
    mov dword[si+8], 6 ; sector
    mov dword[si+12], 0
    mov ah, 0x42 ; https://en.wikipedia.org/wiki/INT_13H#INT_13h_AH=42h:_Extended_Read_Sectors_From_Drive
    int 0x13
    jc ReadError

ReadError:
    ; ; Call the BIOS interrupt 0x10 to print a message on screen.
    ; cmp ah, 0x1
    ; jne End
    ; mov ah, 0x13 ; Param: Indicates the function code to print. 
    ; mov al, 1 ; Param: Indicates the cursor will be set at the end of the screen. 
    ; mov bx, 0xA ; Param: Indicates the character attributes. Prints in bright green. [bh:bl] bh represents page number, bl char attributes
    ; xor dx, dx ; Param: [dh:dl] dh - rows dl - cols. In this case 0,0 zeroed out. 
    ; mov bp, Message3 ; Param: Addres of string. 
    ; mov cx, MessageLen3 ; Param: Num of chars to print. 
    ; int 0x10
NoSupport:
End:
    hlt
    jmp End


DriveId:    db 0
Message:    db "A20 line is on"
MessageLen: equ $-Message
; Message2:    db "Get memory info done"
; MessageLen2: equ $-Message2
; Message3:    db "Error found"
; MessageLen3: equ $-Message3

ReadPacket: times 16 db 0