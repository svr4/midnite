#include <types.hpp>
#include <vmm/vmm.hpp>

Vmm::Vmm() {

}

Vmm::~Vmm() {}


void Vmm::init() {

    // Create page table entries for the first 256 entrites.
    // u32 page_table_1[1024];

    // We need to map the kernel to the first 1 Mb of physicall memory.

    // int kernel_start_address = 0x00100000; // The 1Mb mark.
    // for(int i=0; i < 1023; i++) {
    //     // (i * 4096) will increment the address.
    //     page_table_1[i] = (((i * 4096) + kernel_start_address) - HIGHER_HALF_KERNEL_BASE) | 0x00000003; // bits 0011 set R/W & P
    // }
    // // Setup the Identity Mapping for the VGA buffer address 0x000B8000.
    // page_table_1[1023] = (0x000B8000 - HIGHER_HALF_KERNEL_BASE) | 0x00000003;

    // // Now we place the addresses of the table entries in their appropriate place in the Page Directory.
    // // We need to set element [0] and [768] because once we enable paging the following instruction would start
    // // using paging immediately. If the PT wasn't set at element [0] the CPU would page fault.

    // this->page_directory[0] = (u32)(page_table_1 - HIGHER_HALF_KERNEL_BASE) | 0x00000003;
    // u32 pd = (u32)this->page_directory - HIGHER_HALF_KERNEL_BASE;


    // Create page table entries for the first 256 entrites.
    u32 page_table_1[1024];

    // We need to map the kernel to the first 1 Mb of physicall memory.

    int kernel_start_address = 0x00000000; // The 1Mb mark.
    for(int i=0; i < 1024; i++) {
        page_table_1[i] = kernel_start_address | 0x00000003; // bits 0011 set R/W & P
        kernel_start_address += 4096;
    }
    // Setup the Identity Mapping for the VGA buffer address 0x000B8000.
    page_table_1[1023] = 0x000B8000 | 0x00000003;

    // Now we place the addresses of the table entries in their appropriate place in the Page Directory.
    // We need to set element [0] and [768] because once we enable paging the following instruction would start
    // using paging immediately. If the PT wasn't set at element [0] the CPU would page fault.

    this->page_directory[0] = (u32 *)((u32)page_table_1 | 0x03);
    u32* pd = this->page_directory[0];



    // PageDirectory p_dir;
    // PageTable p_table;

    // this->page_directory = p_dir;
    // this->page_directory.tables[0] = p_table;

    // int kernel_start_address = 0x00100000; // The 1Mb mark.
    // for(int i=0; i < 1023; i++) {
    //     // (i * 4096) will increment the address.
    //     this->page_directory.tables->entries[i] = ((i * 4096) + kernel_start_address) | 0x00000003; // bits 0011 set R/W & P
    // }
    // // Setup the Identity Mapping for the VGA buffer address 0x000B8000.
    // this->page_directory.tables->entries[1023] = 0xB8000 | 0x00000003;

    // // Now we place the addresses of the table entries in their appropriate place in the Page Directory.
    // // We need to set element [0] and [768] because once we enable paging the following instruction would start
    // // using paging immediately. If the PT wasn't set at element [0] the CPU would page fault.

    // this->page_directory.tables[0].entries[0] = (u32)this->page_directory.tables | 0x00000003;
    // u32 pd = (u32)this->page_directory.tables;


    // asm volatile("  mov %0, %%eax \n \
    //                 mov %%eax, %%cr3 \n \
    //                 mov %%cr0, %%eax \n \
    //                 orl $0x80010000, %%eax \n \
    //                 mov %%eax, %%cr0 \n \
    //                 mov $0, %0 \n \
    //                 mov %%cr3, %%eax \n \
    //                 mov %%eax, %%cr3" :: "m"(pd));

    asm volatile("  mov %0, %%eax \n \
                    mov %%eax, %%cr3 \n \
                    mov %%cr0, %%eax \n \
                    orl $0x80000001, %%eax \n \
                    mov %%eax, %%cr0" :: "m"(pd));

}

u32 Vmm::generatePdEntry(u32 entry_data) {
    return 0x0;
}

u32 Vmm::generatePtEntry(u32 entry_data) {
    return 0x0;
}