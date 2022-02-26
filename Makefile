AS=i686-elf-as
CXX=i686-elf-g++ -Iinclude -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti

build: midnite_os.bin
	i686-elf-g++ -T linker.ld -o src/midnite_os.bin -ffreestanding -O2 -nostdlib src/boot.o src/reload_segments.o src/gdt/segmentDescriptor.o src/gdt/gdt.o src/kernel.o -lgcc
	grub-file --is-x86-multiboot src/midnite_os.bin
	mkdir -p isodir/boot/grub
	cp src/midnite_os.bin isodir/boot/midnite_os.bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o midnite_os.iso isodir

midnite_os.bin: src/boot.o src/reload_segments.o src/kernel.o src/gdt/segmentDescriptor.o src/gdt/gdt.o

boot.o: src/boot.s
	i686-elf-as src/boot.s -o boot.o

reload_segments.o: src/reload_segments.s
	i686-elf-as src/reload_segments.s -o reload_segments.o

segmentDescriptor.o:
	i686-elf-g++ -c src/gdt/segmentDescriptor.cpp -o segmentDescriptor.o

gdt.o:
	i686-elf-g++ -c src/gdt/segmentDescriptor.cpp src/gdt/gdt.cpp -o gdt.o

kernel.o: src/kernel.cpp
	i686-elf-g++ -c src/kernel.cpp -o kernel.o

run: midnite_os.iso
	qemu-system-i386 -cdrom midnite_os.iso

.PHONY: clean
clean:
	rm src/*.o src/gdt/*.o