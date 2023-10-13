PREFIX=riscv32-unknown-elf-

all: program.bin

program.bin: start.S link.ld
	$(PREFIX)as ./start.S -c -o start.o
	$(PREFIX)ld ./start.o -Tlink.ld -o ./start.elf
	$(PREFIX)objcopy -O binary ./start.elf ./program.bin

dump:
	$(PREFIX)objdump -M numeric -M no-aliases -D ./start.elf | less

clean:
	rm -rf start.elf start.o program.bin

.PHONY: all clean dump
