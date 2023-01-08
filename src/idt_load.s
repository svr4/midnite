.global idt_load
.type idt_load,%function

idt_load:

    movl 4(%esp), %eax
    lidt (%eax)
    ret 
