#ifndef MIDNITE_MEMORY_HPP
#define MIDNITE_MEMORY_HPP

#include <stddef.h>
#include <stdint.h>

struct gdt_entry
{
    uint16_t limit_low;
    uint16_t base_low;
    uint8_t base_mid;
    uint8_t access;
    uint8_t flag_limit;
    uint8_t base_hi;

} __attribute__((packed));

typedef struct gdt_entry gdt_entry_t;


struct gdt_ptr
{
    uint16_t size;
    uint32_t base;
} __attribute__((packed));

typedef struct gdt_ptr gdt_ptr_t;

/* ASM routine to load the entry values into segment registers
and jump into CS after switching on protected mode. */
extern "C" void gdt_load(uint32_t);

#define SEGMENT_UNUSED  0x0
#define SEGMENT_KCODE   0x1
#define SEGMENT_KDATA   0x2
#define SEGMENT_UCODE   0x3
#define SEGMENT_UDATA   0x4
#define SEGMENT_TSS     0x5

#define NUM_SEGMENTS    0x5

class GDT
{
    public:
        static gdt_entry_t gdt[NUM_SEGMENTS];
        static gdt_ptr_t gdt_ptr;

        static void init();
        static void set_entry(int index, uint32_t base, uint32_t limit, uint32_t access, uint32_t flags);
};

#endif