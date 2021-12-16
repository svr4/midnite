AS=i686-elf-as --32
CXX=i686-elf-g++ -Iinclude -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti
CXXPARAMS = -Iinclude -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti

objects = obj/boot.o \
		obj/segment_descriptor.o \
		obj/gdt.o \
		obj/vmm.o \
		obj/kernel.o \

#		obj/page_directory.o \
		obj/page_table.o \

run: midnite_os.iso
	qemu-system-i386 -cdrom midnite_os.iso

build: midnite_os.bin
	mkdir -p bin
	i686-elf-g++ -T linker.ld -o bin/midnite_os.bin -ffreestanding -O2 -nostdlib $(objects)-lgcc
	grub-file --is-x86-multiboot bin/midnite_os.bin
	mkdir -p isodir/boot/grub
	cp bin/midnite_os.bin isodir/boot/midnite_os.bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o midnite_os.iso isodir

obj/%.o: src/%.cpp
	mkdir -p $(@D)
	i686-elf-g++ $(CXXPARAMS) -c -o $@ $<

obj/%.o: src/%.s
	mkdir -p $(@D)
	i686-elf-as -o $@ $<
	
obj/%.o: src/gdt/%.cpp
	mkdir -p $(@D)
	i686-elf-g++ $(CXXPARAMS) -c $< -o $@

obj/%.o: src/vmm/%.cpp
	mkdir -p $(@D)
	i686-elf-g++ $(CXXPARAMS) -c $< -o $@

midnite_os.bin: $(objects)

# midnite_os.bin: src/boot.o src/kernel.o src/gdt/segmentDescriptor.o src/gdt/gdt.o

# boot.o: src/boot.s
# 	i686-elf-as src/boot.s -o boot.o

# segmentDescriptor.o:
# 	i686-elf-g++ -c src/gdt/segmentDescriptor.cpp -o segmentDescriptor.o

# gdt.o:
# 	i686-elf-g++ -c src/gdt/segmentDescriptor.cpp src/gdt/gdt.cpp -o gdt.o

# kernel.o: src/kernel.cpp
# 	i686-elf-g++ -c src/kernel.cpp -o kernel.o