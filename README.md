# midnite
The Midnite Operating System - An exploration on how to build an OS from scratch.

# Introduction

This project was born out of a need to learn how an operating system could be developed from scratch. Along the way I learned that it takes a combination of things to make it happen. As a primer I suggest reading and looking into the following:

1. Assembly Language (x86_64). [You can find an intro book here](http://www.egr.unlv.edu/~ed/assembly64.pdf). You can find Intel's manual [here](https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-instruction-set-reference-manual-325383.pdf).
2. Knowledge of C and C++. I will be using C++ for this project.
3. [How computers boot.](https://wiki.osdev.org/Boot_Sequence)
4. [This "Getting Started" article from the OSDev Wiki.](https://wiki.osdev.org/Getting_Started)
5. I will add more resources as development progresses.

# Getting Started

## Writing a Bare Bones Kernel

This section is based on the Bare Bones page example located [here](https://wiki.osdev.org/Bare_Bones). I will try to explain concisely and with as much detail as possible on the `why?` of everything.

Our target in this section is to produce a bootable kernel that will be able to write some text on the screen. Seems simple enough but how does that even work exactly? Well we need the following:

1. We need to build a working cross compiler for our target architecture. Details on how to do this are [here](https://wiki.osdev.org/GCC_Cross-Compiler).
2. We need to write some bootstraping code so the bootloader knows we're making an OS.
3. We need to write some bootstraping code to setup a working stack in memory. (We need this because languages like C and C++ depend on a stack already set in memory in order to do anything.)
4. In the bootstraping code we need to call (think of function call) our kernel and write a message on the screen.
5. We need to actually write our kernel so it writes something on the screen.
6. We need to link the different parts (boostraping code and kernel) into a single executable that the bootloader can then use to load it into memory. This will be done via a `.ld` script.

`NOTE: It's best if you have some basic knowledge on assembly before going forward.`


### Bootstraping code

We're now going to be writing the code that tells the bootloader that we're an OS, makes a stack for our kernel to execute and then calls the kernel. We need to do this in `assembly` since there's no mechanism in C\C++ available to achieve this.

#### How does the bootloader know it's dealing with an Operating System?

The hard disk will contain an MBR entry [(Master Boot Record)](https://wiki.osdev.org/Boot_Sequence#Master_Boot_Record) in the first sector of the disk. The MBR is 512 bytes long and contains the so called "magic number" byte sequence `0x55` and `0xAA` at byte offsets 510 and 511 respectivley.

In the bootstraping code in the kernel will be data structures specifically created to interface with the bootloader. This structure is called the [multiboot](https://www.gnu.org/software/grub/manual/multiboot/multiboot.html) header. With the multiboot header the bootloader will know it's dealing with an operating system, will load it into memory and will also provide valuable information to the OS.

`NOTE: that the executable portion of the MBR could simply load to another larger executable where you can do some more advanced setup.`


You can check out the bootstraping code [here](https://github.com/svr4/midnite/blob/main/src/boot.s).


### Bare Bones Kernel

Now that we have our bootstraping code set, lets get started on the kernel. We're going to be calling our version of the `printf` function in order to write some text on screen. But how does that actually write on the screen you might ask? The bootloader will actually create a VGA text mode buffer for us and we simply write to it. The buffer is a two dimenssional array with 25 rows and 80 columns. You can find more information [here](https://en.wikipedia.org/wiki/VGA_text_mode).

You can checkout the kernel code [here](https://github.com/svr4/midnite/blob/main/src/kernel.cpp).

### Linking our OS

We use the linker file to specify the order we want our executable to be assembled. We make sure that our `multiboot` section is specified early per the specification. Take a moment to look over the file located [here](https://github.com/svr4/midnite/blob/main/linker.ld).

### GRUB Menu Entry

The build process takes care of creating a [GRUB](https://www.gnu.org/software/grub/) menu entry so that the bootloader will show the option to boot into our OS. It bundles it up in a nice `.iso` file. Take a look at the makefile or [here](https://wiki.osdev.org/Bare_Bones#Building_a_bootable_cdrom_image) for more details.