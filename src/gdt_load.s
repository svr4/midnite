.global gdt_load
.type gdt_load,%function

gdt_load:

    movl 4(%esp), %eax
    lgdt (%eax)

    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss

    jmp $0x08,$prot_mode

prot_mode:
    ret
