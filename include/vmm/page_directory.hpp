#ifndef MIDNITE_PAGE_DIR
#define MIDNITE_PAGE_DIR

#include <types.hpp>
#include <vmm/page_table.hpp>

class PageDirectory {
    public:
        PageDirectory();
        ~PageDirectory();
        PageTable tables[1024];
};

#endif