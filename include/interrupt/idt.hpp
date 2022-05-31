#ifndef MIDNITE_IDT_HPP
#define MIDNITE_IDT_HPP

#include <stddef.h>
#include <stdint.h>

struct idt_entry
{
    uint16_t base_low;
    uint16_t selector;
    uint8_t reserved;
    uint8_t access;
    uint16_t base_high;
}__attribute__((packed));
typedef idt_entry idt_entry_t;


struct idt_ptr
{
    uint16_t size;
    uint32_t base;
}__attribute__((packed));
typedef idt_ptr idt_ptr_t;

#define NUM_GATE_ENTRIES    256

extern "C" void idt_load(uint32_t);

class IDT
{
    public:

        static idt_entry_t idt[NUM_GATE_ENTRIES];
        static idt_ptr_t idt_ptr;

        static void init();
        static void set_gate(int index, uint32_t base, uint16_t selector, uint8_t flags);
};


extern "C" void isr0();
extern "C" void isr1();
extern "C" void isr2();
extern "C" void isr3();
extern "C" void isr4();
extern "C" void isr5();
extern "C" void isr6();
extern "C" void isr7();
// has error code
extern "C" void isr8();
extern "C" void isr9();

// has error code
extern "C" void isr10();
// has error code
extern "C" void isr11();
// has error code
extern "C" void isr12();
// has error code
extern "C" void isr13();
// has error code
extern "C" void isr14();
extern "C" void isr15();
extern "C" void isr16();
// has error code
extern "C" void isr17();
extern "C" void isr18();
extern "C" void isr19();

extern "C" void isr20();
// has error code
extern "C" void isr21();
extern "C" void isr22();
extern "C" void isr23();
extern "C" void isr24();
extern "C" void isr25();
extern "C" void isr26();
extern "C" void isr27();
extern "C" void isr28();
extern "C" void isr29();

extern "C" void isr30();
extern "C" void isr31();

#endif