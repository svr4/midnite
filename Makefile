AS=i686-elf-as
CXX=i686-elf-g++ -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti

build: midnite_os.bin
	i686-elf-g++ -T linker.ld -o src/midnite_os.bin -ffreestanding -O2 -nostdlib src/boot.o src/kernel.o -lgcc
	grub-file --is-x86-multiboot src/midnite_os.bin
	mkdir -p isodir/boot/grub
	cp src/midnite_os.bin isodir/boot/myos.bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o midnite_os.iso isodir

midnite_os.bin: src/boot.o src/kernel.o

boot.o: src/boot.s
	i686-elf-as src/boot.s -o boot.o

kernel.o: src/kernel.cpp
	i686-elf-g++ -c src/kernel.cpp -o kernel.o