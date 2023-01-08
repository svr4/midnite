AS=i686-elf-as --32
CXX=i686-elf-g++ -Iinclude -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -m32
CXXPARAMS = -Iinclude -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -m32

objects = obj/boot.o \
		obj/string.o \
		obj/terminal.o \
		obj/gdt_load.o \
		obj/gdt.o \
		obj/idt_load.o \
		obj/isr.o \
		obj/isr_stubs.o \
		obj/idt.o \
		obj/kernel.o \

.PHONY: build
build:
	mkdir -p bin/
	mkdir -p obj/
	yasm -f bin -o obj/boot.bin src/boot.s
	yasm -f bin -o obj/loader.bin src/loader.s
	yasm -f elf32 -o obj/k_bootstrap.o src/k_bootstrap.s
	i686-elf-g++ $(CXXPARAMS) -c src/kernel.cpp -o obj/kernel.o

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

obj/%.o: src/include/memory/%.cpp
	mkdir -p $(@D)
	i686-elf-g++ $(CXXPARAMS) -c $< -o $@

obj/%.o: src/include/interrupt/%.cpp
	mkdir -p $(@D)
	i686-elf-g++ $(CXXPARAMS) -c $< -o $@

obj/%.o: src/vmm/%.cpp
	mkdir -p $(@D)
	i686-elf-g++ $(CXXPARAMS) -c $< -o $@

midnite_os.bin: $(objects)

.PHONY: clean
clean:
	rm -f $(objects) bin/midnite_os.bin
