#ifndef MIDNITE_GDT_SEGMENT_DESC
#define MIDNITE_GDT_SEGMENT_DESC

#include <types.hpp>


class SegmentDescriptor {
    private:
        u16 limit_low;
        u16 base_low;
        u8  base_hi;
        u8  access;
        u8  flags_and_limit;
        u8  base_vhi;

    public:
        SegmentDescriptor();
        SegmentDescriptor(u32 base, u32 limit, u8 access);
        ~SegmentDescriptor();
        u32 Base();
        u32 Limit();

} __attribute__((packed));



#endif