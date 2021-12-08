#ifndef MIDNITE_GDT
#define MIDNITE_GDT

#include <types.hpp>
#include <gdt/segmentDescriptor.hpp>

// setup a TSS structure
extern u8 tss[256];


class GDT {

    private:
        SegmentDescriptor nullSegmentSelector;
        SegmentDescriptor codeSegmentSelector;
        SegmentDescriptor dataSegmentSelector;
        // SegmentDescriptor tssSegmentSelector;
        // tssSegmentSelector(&tss, sizeof(tss), 0x89)

    public:

        GDT();
        ~GDT();
        u16 getCodeSegmentSelector();
        u16 getDataSegmentSelector();


};

#endif