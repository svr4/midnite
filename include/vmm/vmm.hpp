#ifndef MIDNITE_VMM
#define MIDNITE_VMM

#define HIGHER_HALF_KERNEL_BASE 0xC0000000
#define USER_SPACE_BASE 0xBFFFFFFF

#include <types.hpp>
#include <vmm/page_directory.hpp>

class Vmm {

    private:
        // PageDirectory page_directory;
        u32 * page_directory[1024];
        // u32 page_table_1[1024];

    public:
        Vmm();
        ~Vmm();
        void init();
        u32 generatePdEntry(u32 entry_data);
        u32 generatePtEntry(u32 entry_data);
};


#endif