#include "../../../include/interrupt/idt.hpp"
#include "../../../include/memory/gdt.hpp"


idt_entry_t IDT::idt[NUM_GATE_ENTRIES];
idt_ptr_t IDT::idt_ptr;

void IDT::init()
{
    for(size_t i=0; i < 256; i++)
    {
        set_gate((int)i, 0, 0, 0);
    }

    set_gate(0, (uint32_t)isr0, SEGMENT_KCODE << 3, 0x8E);
    set_gate(1, (uint32_t)isr1, SEGMENT_KCODE << 3, 0x8E);
    set_gate(2, (uint32_t)isr2, SEGMENT_KCODE << 3, 0x8E);
    set_gate(3, (uint32_t)isr3, SEGMENT_KCODE << 3, 0x8E);
    set_gate(4, (uint32_t)isr4, SEGMENT_KCODE << 3, 0x8E);
    set_gate(5, (uint32_t)isr5, SEGMENT_KCODE << 3, 0x8E);
    set_gate(6, (uint32_t)isr6, SEGMENT_KCODE << 3, 0x8E);
    set_gate(7, (uint32_t)isr7, SEGMENT_KCODE << 3, 0x8E);
    set_gate(8, (uint32_t)isr8, SEGMENT_KCODE << 3, 0x8E);
    set_gate(9, (uint32_t)isr9, SEGMENT_KCODE << 3, 0x8E);

    set_gate(10, (uint32_t)isr10, SEGMENT_KCODE << 3, 0x8E);
    set_gate(11, (uint32_t)isr11, SEGMENT_KCODE << 3, 0x8E);
    set_gate(12, (uint32_t)isr12, SEGMENT_KCODE << 3, 0x8E);
    set_gate(13, (uint32_t)isr13, SEGMENT_KCODE << 3, 0x8E);
    set_gate(14, (uint32_t)isr14, SEGMENT_KCODE << 3, 0x8E);
    set_gate(15, (uint32_t)isr15, SEGMENT_KCODE << 3, 0x8E);
    set_gate(16, (uint32_t)isr16, SEGMENT_KCODE << 3, 0x8E);
    set_gate(17, (uint32_t)isr17, SEGMENT_KCODE << 3, 0x8E);
    set_gate(18, (uint32_t)isr18, SEGMENT_KCODE << 3, 0x8E);
    set_gate(19, (uint32_t)isr19, SEGMENT_KCODE << 3, 0x8E);

    set_gate(20, (uint32_t)isr20, SEGMENT_KCODE << 3, 0x8E);
    set_gate(21, (uint32_t)isr21, SEGMENT_KCODE << 3, 0x8E);
    set_gate(22, (uint32_t)isr22, SEGMENT_KCODE << 3, 0x8E);
    set_gate(23, (uint32_t)isr23, SEGMENT_KCODE << 3, 0x8E);
    set_gate(24, (uint32_t)isr24, SEGMENT_KCODE << 3, 0x8E);
    set_gate(25, (uint32_t)isr25, SEGMENT_KCODE << 3, 0x8E);
    set_gate(26, (uint32_t)isr26, SEGMENT_KCODE << 3, 0x8E);
    set_gate(27, (uint32_t)isr27, SEGMENT_KCODE << 3, 0x8E);
    set_gate(28, (uint32_t)isr28, SEGMENT_KCODE << 3, 0x8E);
    set_gate(29, (uint32_t)isr29, SEGMENT_KCODE << 3, 0x8E);

    set_gate(30, (uint32_t)isr30, SEGMENT_KCODE << 3, 0x8E);
    set_gate(31, (uint32_t)isr31, SEGMENT_KCODE << 3, 0x8E);

    idt_ptr.size = ((sizeof(idt_entry_t) * NUM_GATE_ENTRIES) - 1);
    idt_ptr.base = (uint32_t)&idt;

    idt_load((uint32_t)&idt_ptr);
}

void IDT::set_gate(int index, uint32_t base, uint16_t selector, uint8_t flags)
{
    idt[index].base_low = (uint16_t) (base & 0xFFFF);
    idt[index].selector = selector;
    idt[index].reserved = 0;
    idt[index].access = flags;
    idt[index].base_high = (uint16_t) ((base >> 16) & 0xFFFF);
}