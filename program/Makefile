PREFIX=riscv32-unknown-elf-

all: program.bin

program.bin:
	$(PREFIX)as ./start.S -c -o start.o
	$(PREFIX)ld ./start.o -Tlink.ld -o ./start.elf
	$(PREFIX)objcopy -O binary ./start.elf ./program.bin

clean:
	rm -rf start.elf start.o program.bin

.PHONY: all clean program.bin
