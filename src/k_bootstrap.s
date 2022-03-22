section .data

stack_bottom: times 16777216 db 0
stack_top: equ $-stack_bottom

section .text

extern callConstructors 
extern kernel_main

global start
start:

; Programmable Interval Timer
; https://wiki.osdev.org/PIT
; init_pit:
;     ; 00 = Select Channel
;     ; 11 = Access Mode lobyte/hibyte
;     ; 010 = Operating Mode (Mode 2 - rate generator)
;     ; 0 = 16-bit binary mode
;     mov al, 00110100b
;     out 0x43, al ; Write out to the Mode/Command register the options
;     ; The oscillator used by the PIT chip runs at roughly 1.193182 MHz
;     ; In this setup's current state it will decrement a counter about 1.2 Million times per second.
;     ; Let's set it up so it decrements the counter at 100 times per second.
;     ; More info: https://wiki.osdev.org/PIT

;     mov ax, 11931 ; 1193182/100
;     ; In the lobyte/hibyte access mode we must send low bytes first followed by the high bytes
;     ; ax = [ah|al]
;     out 0x40, al ; 0x40 is Channel 0's data port (read/write)
;     mov al, ah ; move high bytes to al
;     out 0x40, al


; Programmable Interrupt Controller
; https://wiki.osdev.org/PIC
init_pic:
    ; 0x11 is written to the Master PIC Command port at 0x20 and the Slave PIC command port at 0xA0
    ; 0x11 makes the pic wait for another 3 initialization command words (ICW) on the data port 0x21 and 0xA1
    ; 0001 - makes the pic wait for 3 init command words. 0001 - indicates we use the last init command word

    ; ICW1
    mov al, 0x11
    out 0x20, al
    out 0xA0, al

    ; ICW2
    ; Specifies the starting vector number for the first IRQ.
    ; The CPU uses the firs 32 (0-31) numbers for its own interrupts.
    ; So we have 32-255 for us to define.
    mov al, 32
    out 0x21, al
    ; Each chip has 8 IRQ and the first vector number of the Master is 32.
    ; So the Slave IRQ vectors start at 40.
    mov al, 40
    out 0xA1, al

    ; ICW3
    ; Indicates which IRQ is used for connecting the two PIC chips
    ; 7 6 5 4 3 2 1 0
    ;-----------------
    ; 0 0 0 0 0 1 0 0

    mov al, 4 ; bit 2 is on so IRQ 2
    out 0x21, al

    ; 7 6 5 4 3 2 1 0
    ;-----------------
    ; 0 0 0 0 0 0 1 0
    mov al, 2 
    out 0xA1, al

    ; ICW4
    ; Select the mode at which the chips will operate.

    ; 7 6 5 4 3 2 1 0
    ;-----------------
    ; 0 0 0 0 0 0 0 1

    ; bit 0 = x86 system is used
    ; bit 1 = automatic end of interrupt
    ; bit 2 & 3 = bufferd mode
    ; bit 4 & 5 = fully nested mode

    mov al, 1
    out 0x21, al
    out 0xA1, al

    ; Now we need to mask incoming IRQ from the PIC so they don't interfere with the CPU IRQ's.
    ; We also leave IRQ 0 unmasked for the PIT.

    mov al, 11111110b
    out 0x21, al
    mov al, 11111111b
    out 0xA1, al

    ; Enable iterrupts.
    ; sti

kernel_entry:
    ; Setup a stack.
    ; The value of stack stop will be greater than 0x100000.
    ; Remember the stack grows downward.
    ; 16777216 = 0x1000000
    ; 0x1000000 > 0x100000
    mov esp, stack_top

    ; mov byte[0xb8000], 'K'
    ; mov byte[0xb8001], 0x0A
    call callConstructors
    call kernel_main

End:
    hlt
    jmp End