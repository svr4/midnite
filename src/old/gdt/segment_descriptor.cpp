#include <types.hpp>
#include <gdt/segmentDescriptor.hpp>

SegmentDescriptor::SegmentDescriptor(u32 base, u32 limit, u8 access) {

    u16 limit_low;
    u16 base_low;
    u8  base_hi;
    u8  flags_and_limit;
    u8  base_vhi;

    // We need to check the incoming limit.
    // The limit determines the amount of addressable memory the system has.

    if(limit <= 65536) {  // 2^16
        // 16-bit address space
        flags_and_limit = 0x40; // 0100 0000
    }
    else {

        // 32-bit address space
        // Now we have to squeeze the (32-bit) limit into 2.5 regiters (20-bit).
        // This is done by discarding the 12 least significant bits (right side), but this
        // is only legal, if they are all ==1, so they are implicitly still there

        // so if the last bits aren't all 1, we have to set them to 1, but this
        // would increase the limit (cannot do that, because we might go beyond
        // the physical limit or get overlap with other segments) so we have to
        // compensate this by decreasing a higher bit (and might have up to
        // 4095 wasted bytes behind the used memory)

        // Check if the last 12 bits of the limit are 1.
        // Example:
        // 0xFFFFFFFF >> 12 = 0xFFFFF
        // 0xFFFFF & 0xFFF = 0xFFF eg true
        if((limit & 0xFFF) != 0xFFF) {
            limit = (limit >> 12) - 1;
        }
        else {
            limit = limit >> 12;
        }

        flags_and_limit = 0xC0; // 1100 0000

    }

    // Encode the limit
    limit_low = limit & 0xFF;
    limit_low = limit_low | ((limit >> 8) & 0xFF);
    flags_and_limit = flags_and_limit | ((limit >> 16) & 0xF);
    // totals 20-bit limit

    // Encode the base
    base_low = base & 0xFF; // first 8 bits
    base_low = (base >> 8) & 0xFF; // second 8 bits
    base_hi = (base >> 16) && 0xFF; // third 8 bits
    base_vhi = (base >> 24) && 0xFF; // fourth 8 bits

    // set the object

    this->limit_low = limit_low;
    this->base_low = base_low;
    this->base_hi = base_hi;
    this->access = access;
    this->flags_and_limit = flags_and_limit;
    this->base_vhi = base_vhi;

}

SegmentDescriptor::SegmentDescriptor() {}

SegmentDescriptor::~SegmentDescriptor() {

}

u32 SegmentDescriptor::Base() {
    u32 result = this->base_vhi;
    result = (result << 8) + this->base_hi;
    result = (result << 16) + this->base_low;
    return result;
}

u32 SegmentDescriptor::Limit() {
    u32 result = this->flags_and_limit & 0xF;
    result = (result << 16) + this->limit_low;

    // if we removed the 12 bits, lets add them back.
    if((this->flags_and_limit & 0xC0) == 0xC0) {
        result = (result << 12) | 0xFFF;
    }

    return result;
}