.macro ISR_NOERRCODE interrupt_code
    .global isr\interrupt_code
    .type isr\interrupt_code, @function
    isr\interrupt_code:
        pushl $0
        pushl $\interrupt_code
        jmp isr_handler_stub
.endm

.macro ISR_ERRCODE interrupt_code
    .global isr\interrupt_code
    .type isr\interrupt_code, @function
    isr\interrupt_code:
        pushl $\interrupt_code
        jmp isr_handler_stub
.endm

ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7

ISR_ERRCODE 8

ISR_NOERRCODE 9

ISR_ERRCODE 10
ISR_ERRCODE 11
ISR_ERRCODE 12
ISR_ERRCODE 13
ISR_ERRCODE 14

ISR_NOERRCODE 15
ISR_NOERRCODE 16

ISR_ERRCODE 17

ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20

ISR_ERRCODE 21

ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31

.extern isr_handler

.global isr_handler_stub
.type isr_handler_stub, @function
isr_handler_stub:
    /* save general use regs */
    pushal

    movw %ds, %ax
    pushl %eax

    movl %esp, %eax
    pushl %eax

    /* Load kernel data segment descriptor */
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs

    call isr_handler

    /* clean up pushed esp before call */
    addl $4, %esp

    popl %eax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    
    /* save general use regs */
    popal

    /* clean up error code and isr code */
    addl $8, %esp

    iret
