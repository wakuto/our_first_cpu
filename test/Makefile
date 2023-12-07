PREFIX=riscv32-unknown-elf-
TARGET :=

all: program.bin

program.bin: ${TARGET}.S link.ld
	$(PREFIX)as ./${TARGET}.S -c -o ${TARGET}.o
	$(PREFIX)ld ./${TARGET}.o -Tlink.ld -o ./${TARGET}.elf
	$(PREFIX)objcopy -O binary ./${TARGET}.elf ./test.bin

dump:
	$(PREFIX)objdump -M numeric -M no-aliases -D ./${TARGET}.elf | less

clean:
	rm -rf *.elf *.o *.bin

.PHONY: all clean dump 