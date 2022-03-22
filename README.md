# midnite
The Midnite Operating System - An exploration on how to build an OS from scratch.

# Introduction

This project was born out of a need to learn how an operating system could be developed from scratch. Along the way I learned that it takes a combination of things to make it happen. As a primer I suggest reading and looking into the following:

1. Assembly Language (x86_64). [You can find an intro book here](http://www.egr.unlv.edu/~ed/assembly64.pdf). You can find Intel's manual [here](https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-instruction-set-reference-manual-325383.pdf).
2. Knowledge of C and C++. I will be using C++ for this project.
3. [How computers boot.](https://wiki.osdev.org/Boot_Sequence)
4. [This "Getting Started" article from the OSDev Wiki.](https://wiki.osdev.org/Getting_Started)
5. I will add more resources as development progresses.

`NOTE: We're going to implementing a 32-bit x86 Operating System`

# Getting Started

## Writing a Bare Bones Kernel

This section is based on the Bare Bones page example located [here](https://wiki.osdev.org/Bare_Bones). I will try to explain with as much detail as possible on the `why?` of everything.

Our target in this section is to produce a bootable kernel that will be able to write some text on the screen. Seems simple enough but how does that even work exactly? Well we need the following:

1. We need to build a working cross compiler for our target architecture. Details on how to do this are [here](https://wiki.osdev.org/GCC_Cross-Compiler).
2. We need to write some boot code so the BIOS knows we're making an OS.
3. We need to write some code to run hardware checks and load our kernel into memory once we enter `protected` mode.
3. We need to write some bootstraping code to setup a working stack in memory. (We need this because languages like C and C++ depend on a stack already set in memory in order to do anything.)
4. In the bootstraping code we need to call (think of function call) our kernel and write a message on the screen.
5. We need to actually write our kernel so it writes something on the screen.
6. We need to link the different parts (boostraping code and kernel) into a single executable that the bootloader can then use to load it into memory. This will be done via a `.ld` script.

`NOTE: It's highly recommended to familiarize yourself with assembly language before going forward.`


### Boot code

We're now going to be writing the code that tells the bootloader that we're an OS, makes a stack for our kernel to execute and then calls the kernel. We need to do this in `assembly` since there's no mechanism in C\C++ available to achieve this.

#### How does the bootloader know it's dealing with an Operating System?

The hard disk will contain an MBR entry [(Master Boot Record)](https://wiki.osdev.org/Boot_Sequence#Master_Boot_Record) in the first sector of the disk. The MBR is 512 bytes long and contains the so called "magic number" byte sequence `0x55` and `0xAA` at byte offsets 510 and 511 respectivley.


`NOTE: The executable portion of the MBR could simply load to another larger executable where you can do some more advanced setup.`


You can check out the boot code [here](https://github.com/svr4/midnite/blob/main/src/boot.s).


## Loading our Kernel

As noted in the previous section the boot code could simply load another larger piece of code since we are limited to only the first 512 bytes of the disk.

Our loader will take care of loading the kernel at the `0x0100000` (1MB) mark of memory, it will put the CPU in `protected` mode and `jmp` the execution into the kernel.

The code is heavily documented and you can look at it [here](https://github.com/svr4/midnite/blob/main/src/loader.s)

### Bare Bones Kernel

Now that we have our loader code set, lets get started on the kernel. We're going to be calling our version of the `printf` function in order to write some text on screen. But how does that actually write on the screen you might ask? The loader will actually setup a VGA text mode buffer for us and we simply write to it. The buffer is a two dimenssional array with 25 rows and 80 columns. You can find more information [here](https://en.wikipedia.org/wiki/VGA_text_mode).

You can checkout the kernel code [here](https://github.com/svr4/midnite/blob/main/src/kernel.cpp).

### Linking our OS

We use the linker file to specify the order we want our executable to be assembled. Take a moment to look over the file located [here](https://github.com/svr4/midnite/blob/main/linker.ld). More information on linker scripts can be found [here](https://wiki.osdev.org/Linker_Scripts).


# Memory Management

In this section we're going to be implementing memory management in our OS. This can be achieved with the following mechanisms:

1. [Segmentation](https://en.wikipedia.org/wiki/Memory_segmentation)
    - [Segmentation OSDev Wiki](https://wiki.osdev.org/Segmentation)
    - [Global Descriptor Table](https://wiki.osdev.org/Global_Descriptor_Table)
    - [x86 Memory Segmentation](https://en.wikipedia.org/wiki/X86_memory_segmentation) `I like the history and detailed explanation in this article.`
2. [Paging](https://wiki.osdev.org/Paging)
    - [Page Table](https://en.wikipedia.org/wiki/Page_table)

Let's talk a little about each one.

`NOTE: The maximum addressable memory on x86 systems is 4 GB (4,294,967,296 bytes).`

## Segmentation

This a mechanism the OS can use to manage its memory. It consists of dividing the computers memory into pieces called `segments`. Once a program is loaded into memory it's different parts (text, code and bss sections) are loaded into separate contiguous (and often overlapping) memory segments.

The different program parts are loaded into the following 16-bit (in x86) registers:

| Register  | Description |
| ------------- | ------------- |
| CS  | Code Segment  |
| DS  | Data Segment  |
| SS  | Stack Segment  |
| ES  | Extra Segment  |
| FS  | General Purpose Segment |
| GS  | General Purpose Segment |

Segmentation also results in `memory fragmentation` which can happen when there's not enough contiguous free space in memory, even though there may be enough total memory available.

Today, segmentation is only used to provide backwards compatibility and is not used in current x86_64 operating systems in favor of paging. All the literature recommends setting up a flat-memory model (AKA make each segment as long as the whole width of available memory) and set up segmentation because we can't turn it off at the CPU level.

### How do we set up segmentation?

In order to setup segmentation we need to implement a Global Descriptor Table (GDT). This table contains entries that tell the CPU about memory segments.

Each entry (called Segment Selectors that reference [Segment Descriptors](https://en.wikipedia.org/wiki/Segment_descriptor)) in the GDT is `8-bytes` long and contains information about the process like the base address, size and privileges like executability and writability.

Once we setup our GDT data structure we have to load the base address of the table into the `gdtr` register like so:

```asm
    lgdt address_of_gdt
```

`NOTE: We're going to be using assembly to setup our kernel's GDT.`

You can check out the GDT code [here](https://github.com/svr4/midnite/blob/main/src/loader.s).


## Paging

Paging allows an operating system see a large `virtual` memory address space without requiring the full amount of physical memory to be present in the system. This method replaces segmentation and solves the memory fragmentation problem since contiguous virtual address can point to non contiguous spaces of physical memory.

### How does paging work?

Paging uses the [Memory Management Unit](https://wiki.osdev.org/Memory_Management_Unit) (MMU) in the computer for virtual address translation to a physical address in RAM. On x86 virtual memory is mapped throught the use of two tables:

1. Page Directory (PD)
2. Page Table (PT)

Each table contains 1,024 entries which are 4-bytes in size, making them 4096 KB each. In the PD each entry points to a PT. In the PT each entry points to a 4096 KB physical page frame.

According to the [OSDev Wiki](https://wiki.osdev.org/Paging):

```
Translation of a virtual address into a physical address first involves dividing the virtual address into three parts: the most significant 10 bits (bits 22-31) specify the index of the page directory entry, the next 10 bits (bits 12-21) specify the index of the page table entry, and the least significant 12 bits (bits 0-11) specify the page offset. The then MMU walks through the paging structures, starting with the page directory, and uses the page directory entry to locate the page table. The page table entry is used to locate the base address of the physical page frame, and the page offset is added to the physical base address to produce the physical address. If translation fails for some reason (entry is marked as not present, for example), then the processor issues a page fault. 

```


## High Half Kernel

You might be wondering why this section exists here. I'll tell you why. Linux and other Unices reside in `0xC0000000 – 0xFFFFFFFF` in the address space of every process, leaving the range of `0x00000000 – 0xBFFFFFFF` for user code, stack, etc. (Remmember the GDT we designed is a flat one that encompases the whole 4 GB of addressable memory). That means that the kernel will reside in the `higher half` of `virtual` memory, while the rest is left for the user's code. In the physicall address space the kernel will be in the 1 Mb mark of memory, as specified by our linker file.

According to the [OS Dev Wiki](https://wiki.osdev.org/Higher_Half_Kernel) these are the advantages:

'''
Advantages of a higher half kernel are:

    1. It's easier to set up VM86 processes since the region below 1 MB is userspace.
    2. More generally, user applications are not dependent on how much memory is kernel space (your application can be linked to 0x400000 regardless of whether kernel is at 0xC0000000, 0x80000000 or 0xE0000000 ...), which makes the ABI nicer.
    3. If your OS is 64-bit, then 32-bit applications will be able to use the full 32-bit address space.
    'Mnemonic' invalid pointers such as 0xCAFEBABE, 0xDEADBEEF, 0xDEADC0DE, etc. can be used. 
'''

`Note: #1 actually refers to the virtual memory address space.`

We're going to be setting up `Paging` and the `higher half kernel` at the same time.

You can check out the Paging code here.