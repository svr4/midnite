#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "../include/common/string.hpp"
#include "../include/display/terminal.hpp"
#include "../include/memory/gdt.hpp"
#include "../include/interrupt/idt.hpp"
 
/* Check if the compiler thinks you are targeting the wrong operating system. */
#if defined(__linux__)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif
 
/* This tutorial will only work for the 32-bit ix86 targets. */
#if !defined(__i386__)
#error "This tutorial needs to be compiled with a ix86-elf compiler"
#endif

/* Initialize Constructors */
typedef void (*constructor)();
extern "C" constructor start_ctors;
extern "C" constructor end_ctors;
extern "C" void callConstructors()
{
    for(constructor* i = &start_ctors; i != &end_ctors; i++)
        (*i)();
}
 
extern "C" void kernel_main(void) 
{
	/* Initialize terminal interface */
	Terminal::terminal_init();
	// terminal_initialize();
 
	/* Newline support is left as an exercise. */
	// terminal_writestring("Hello, kernel World!\n");
	const char* s = "Hello, kernel World!\n";
	Terminal::terminal_write(s, strlen(s));
	// asm volatile("hlt");

	GDT::init();	
	IDT::init();

	asm volatile("int $0x05");

	while(1);
}