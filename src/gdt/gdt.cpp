#include <types.hpp>
#include <gdt/gdt.hpp>

u8 tss[256];

GDT::GDT(): nullSegmentSelector(0, 0, 0),
    codeSegmentSelector(0, 0xFFFFFFFF, 0x9A),
    dataSegmentSelector(0, 0xFFFFFFFF, 0x92) {

        // The lgdt instruction expects a piece of contiguous memory that has the offset in high memory
        // and the size in low memory.

        u32 i[2];
        i[1] = (u32)this;
        i[0] = sizeof(GDT) << 16;
        
        u8 * gdt = (((u8 *) i)+2);

        asm volatile("lgdt %0": :"m"(gdt));
}
GDT::~GDT() {

}
// get the offset for the code segment selector
u16 GDT::getCodeSegmentSelector() {
    return (u8*)&codeSegmentSelector - (u8*)this;
}

u16 GDT::getDataSegmentSelector() {
    return (u8*)&dataSegmentSelector - (u8*)this;
}