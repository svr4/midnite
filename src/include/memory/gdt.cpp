#include "../../../include/memory/gdt.hpp"

gdt_entry_t GDT::gdt[NUM_SEGMENTS];

gdt_ptr_t GDT::gdt_ptr;

void GDT::init()
{
    gdt_ptr.size = (sizeof(gdt_entry_t) * NUM_SEGMENTS) - 1;
    gdt_ptr.base = (uint32_t)&gdt;

    set_entry(SEGMENT_UNUSED, 0, 0, 0, 0);
    set_entry(SEGMENT_KCODE, 0, 0xFFFFFFF, 0x9A, 0xCF);
    set_entry(SEGMENT_KDATA, 0, 0xFFFFFFF, 0x92, 0xCF);
    set_entry(SEGMENT_UCODE, 0, 0xFFFFFFF, 0xFA, 0xCF);
    set_entry(SEGMENT_UDATA, 0, 0xFFFFFFF, 0xF2, 0xCF);

    gdt_load((uint32_t)&gdt_ptr);

}
void GDT::set_entry(int index, uint32_t base, uint32_t limit, uint32_t access, uint32_t flags)
{
    gdt[index].base_low = (base & 0xFFFF);
    gdt[index].base_mid = (base >> 16) & 0xFF;
    gdt[index].base_hi = (base >> 24) & 0xFF;

    gdt[index].limit_low = (limit & 0xFFFF);
    gdt[index].flag_limit = ((limit >> 16) & 0x0F);
    gdt[index].flag_limit |= (flags & 0xF0);

    gdt[index].access = access;
}