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


TestDiskExtension:
; Contains the HDD drive ID that will be used when BIOS transfers control to boot code.
    mov [DriveId], dl
    mov ah, 0x41 ; https://en.wikipedia.org/wiki/INT_13H#INT_13h_AH=41h:_Check_Extensions_Present
    mov bx, 0x55AA
    int 0x13 ; Call the BIOS function to test for LBA
    ; If the service is not supported te carry flag is set.
    jc NoSupport
    cmp bx, 0xAA55 ; If bx is not eq to 0xAA55 it's not supported
    jne NoSupport

LoadLoader:
    mov si, ReadPacket
    mov word[si], 0x10
    mov word[si+2], 5
    mov word[si+4], 0x7E00
    mov word[si+6], 0
    mov dword[si+8], 1
    mov dword[si+12], 0
    mov dl, [DriveId]
    mov ah, 0x42 ; https://en.wikipedia.org/wiki/INT_13H#INT_13h_AH=42h:_Extended_Read_Sectors_From_Drive
    int 0x13
    jc ReadError

    mov dl, [DriveId]
    jmp 0x7E00

ReadError:
NoSupport:
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



DriveId:    db  0
Message:    db "We have error in boot process."
MessageLen: equ $-Message
ReadPacket: times 16 db 0

; Making the MBR
; We start at 0x1BE becasue the BIOS expects the first partition to be at this offset.
; https://wiki.osdev.org/MBR_(x86)
times   (0x1BE-($-$$)) db 0 ; $ = current address $$= start of program address
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
