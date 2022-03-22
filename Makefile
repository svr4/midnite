AS=i686-elf-as --32
CXX=i686-elf-g++ -g -Iinclude -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -fno-stack-protector -mno-red-zone
CXXPARAMS = -g -Iinclude -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -fno-stack-protector -mno-red-zone

objects = obj/boot.bin \
		obj/loader.bin \
		obj/k_bootstrap.o \
		obj/kernel.o

.PHONY: build
build:
	mkdir -p bin/
	mkdir -p obj/
	yasm -f bin -o obj/boot.bin src/boot.s
	yasm -f bin -o obj/loader.bin src/loader.s
	yasm -f elf32 -o obj/k_bootstrap.o src/k_bootstrap.s
	i686-elf-g++ $(CXXPARAMS) -c src/kernel.cpp -o obj/kernel.o

	i686-elf-g++ -T linker.ld -o bin/midnite_os.bin -ffreestanding -O2 -nostdlib obj/k_bootstrap.o obj/kernel.o -lgcc

	dd if=obj/boot.bin of=/home/marcel/OSDevelopment/bochs/midnite.img bs=512 count=1 conv=notrunc
	dd if=obj/loader.bin of=/home/marcel/OSDevelopment/bochs/midnite.img bs=512 count=5 seek=1 conv=notrunc
	dd if=bin/midnite_os.bin of=/home/marcel/OSDevelopment/bochs/midnite.img bs=512 count=100 seek=6 conv=notrunc

.PHONY: clean
clean:
	rm -f $(objects) bin/midnite_os.bin
