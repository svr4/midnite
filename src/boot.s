; Indicates we are running in real mode 16-bits
bits 16
; Indicates the code is supposed to be running in this memory location
org 0x7c00

start:
; instruction destination, source
; Clean the segment registers by setting them to 0
; Set the stack segment to 0 to indicate the stack starts at memory location 0
; Set stack pointer to 0x7c00
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

PrintMessage:
; Call the BIOS interrupt 0x10 to print a message on screen.
    mov ah, 0x13 ; Param: Indicates the function code to print. 
    mov al, 1 ; Param: Indicates the cursor will be set at the end of the screen. 
    mov bx, 0xA ; Param: Indicates the character attributes. Prints in bright green. [bh:bl] bh represents page number, bl char attributes
    xor dx, dx ; Param: [dh:dl] dh - rows dl - cols. In this case 0,0 zeroed out. 
    mov bp, Message ; Param: Addres of string. 
    mov cx, MessageLen ; Param: Num of chars to print. 
    int 0x10

End:
    hlt
    jmp End



Message:    db "Hello"
MessageLen: equ $-Message

; Making the MBR
; We start at 0x1BE becasue the BIOS expects the first partition to be at this offset.
; https://wiki.osdev.org/MBR_(x86)
times   (0x1BE-($-$$)) db 0
; This is the first partition indicator
    db 0x80 ; Boot indicator. Tells the BIOS this partition is bootable.

    ; Head and cyllinder values start at 0. Sectors start at 1.
    ; head value, [0-5] sector value [6-7]cyllinder value, lower 8-bits of cyllinder value

    db 0,2,0 ; Starting CHS - Cyllinder, Head, Sectors
    db 0xF0 ; Partition Type */
    db 0xFF, 0xFF, 0xFF ; Ending CHS
    dd 1 ; Logical Block Address (LBA) of Starting Sector
    dd (20*16*63-1) ; Size or number of sectors in the partition

    times (16*3) db 0 ; Create 3 more stub partition entries with 0

; These two numbers indicate a valid bootsector. These are magic numbers.
    db 0x55
    db 0xAA
