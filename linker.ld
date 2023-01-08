/* The bootloader will look at this image and start execution at the symbol
   designated as the entry point. Remmember the symbol is defined in src/boot.s */
OUTPUT_FORMAT("elf32-i386")
ENTRY(start)
 
/* Tell where the various sections of the object files will be put in the final
   kernel image. */
SECTIONS
{
	/* Begin putting sections at 1 MiB, a conventional place for kernels to be
	   loaded at by the bootloader. */
	. = 0x00100000;
 
	/* First put the multiboot header, as it is required to be put very early
	   early in the image or the bootloader won't recognize the file format.
	   Next we'll put the .text section. */

	.multiboot : {
		*(.multiboot)
	}

	/*: AT(ADDR(.text) - 0xC00000000)*/
/* BLOCK(4K) : ALIGN(4K) */
	.text :
	{
		/* (.multiboot) */
		*(.text)
	}
 
	/* Read-only data. */
	.rodata :
	{
		*(.rodata)
	}
 
	/* Read-write data (initialized) */
	.data :
	{
		start_ctors = .;
		KEEP(*( .init_array ));
		KEEP(*(SORT_BY_INIT_PRIORITY( .init_array.* )))
		end_ctors = .;

		*(.data)
	}
 
	/* Read-write data (uninitialized) and stack */
	.bss :
	{
		*(COMMON)
		*(.bss)
	}
 
	/* The compiler may produce other sections, by default it will put them in
	   a segment with the same name. Simply add stuff here as needed. */

	/DISCARD/ : { *(.fini_array*) *(.comment) }
}