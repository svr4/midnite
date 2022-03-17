AS=i686-elf-as --32
CXX=i686-elf-g++ -g -Iinclude -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti
CXXPARAMS = -g -Iinclude -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti

objects = obj/boot.bin \
		obj/loader.bin \
		obj/k_bootstrap.bin

# run: midnite_os.iso
# 	qemu-system-i386 -cdrom midnite_os.iso


build: midnite_os.bin
	dd if=obj/boot.bin of=/home/marcel/OSDevelopment/bochs/midnite.img bs=512 count=1 conv=notrunc
	dd if=obj/loader.bin of=/home/marcel/OSDevelopment/bochs/midnite.img bs=512 count=5 seek=1 conv=notrunc
	dd if=obj/k_bootstrap.bin of=/home/marcel/OSDevelopment/bochs/midnite.img bs=512 count=100 seek=6 conv=notrunc
# build: midnite_os.bin
# 	mkdir -p bin
# i686-elf-g++ -T linker.ld -o bin/midnite_os.bin -ffreestanding -O2 -nostdlib $(objects)-lgcc

# obj/%.o: src/%.cpp
# 	mkdir -p $(@D)
# 	i686-elf-g++ $(CXXPARAMS) -c -o $@ $<

# obj/%.o: src/%.s
# 	mkdir -p $(@D)
# 	i686-elf-as -o $@ $<

obj/%.bin: src/%.s
	mkdir -p $(@D)
	yasm -f bin -o $@ $<
	
# obj/%.o: src/gdt/%.cpp
# 	mkdir -p $(@D)
# 	i686-elf-g++ $(CXXPARAMS) -c $< -o $@

# obj/%.o: src/vmm/%.cpp
# 	mkdir -p $(@D)
# 	i686-elf-g++ $(CXXPARAMS) -c $< -o $@

midnite_os.bin: $(objects)

.PHONY: clean
clean:
	rm -f $(objects) bin/midnite_os.bin midnite_os.iso
