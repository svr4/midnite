AS=i686-elf-as --32
CXX=i686-elf-g++ -Iinclude -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -m32
CXXPARAMS = -Iinclude -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -m32

objects = obj/boot.o \
		obj/string.o \
		obj/terminal.o \
		obj/kernel.o \

run: midnite_os.iso
	qemu-system-i386 -cdrom midnite_os.iso

build: midnite_os.bin
	mkdir -p bin
	i686-elf-g++ -T linker.ld -z max-page-size=4096 -o bin/midnite_os.bin -ffreestanding -O2 -nostdlib $(objects)-lgcc
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

obj/%.o: src/include/common/%.cpp
	mkdir -p $(@D)
	i686-elf-g++ $(CXXPARAMS) -c $< -o $@

obj/%.o: src/include/display/%.cpp
	mkdir -p $(@D)
	i686-elf-g++ $(CXXPARAMS) -c $< -o $@

obj/%.o: src/vmm/%.cpp
	mkdir -p $(@D)
	i686-elf-g++ $(CXXPARAMS) -c $< -o $@

midnite_os.bin: $(objects)

.PHONY: clean
clean:
	rm -f $(objects) bin/midnite_os.bin midnite_os.iso
