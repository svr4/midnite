#ifndef MIDNITE_PAGE_TABLE
#define MIDNITE_PAGE_TABLE

#include <types.hpp>

class PageTable {
    public:
        PageTable();
        ~PageTable();
        u32 entries[1024];
};

#endif