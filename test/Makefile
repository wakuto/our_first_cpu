PREFIX=riscv64-unknown-elf-
TARGET :=
TARGET_DIR := ./isa
PATTERN := ^rv32ui-p-[a-z]+$

FILES := $(shell find $(TARGET_DIR) -type f | sort -n | grep -E 'rv32ui-p-.+' | grep -v -e '\.dump$$' -e '\.hex$$' -e '\.bin$$')
BIN_FILES := $(shell find $(TARGET_DIR) -type f | sort -n | grep -E 'rv32ui-p-.+\.bin')

all: test.bin

test.bin: ${TARGET}.S link.ld
	$(PREFIX)as -march=rv32i -mabi=ilp32 ./${TARGET}.S -c -o ${TARGET}.o
	$(PREFIX)ld -b elf32-littleriscv ./${TARGET}.o -Tlink.ld -o ./${TARGET}.elf
	$(PREFIX)objcopy -O binary ./${TARGET}.elf ./test.bin

test.hex: test.bin
	hexdump -v -e '1/1 "%02x\n"' ./test.bin > ./test.hex

bin: link.ld
	@for name in $(FILES); do\
		$(PREFIX)objcopy -O binary $$name $$name.bin;\
	done

hex: bin
	@for name in $(FILES); do\
		hexdump -v -e '1/1 "%02x\n"' $$name.bin > $$name.hex;\
	done

dump:
	$(PREFIX)objdump -M numeric -M no-aliases -D ./${TARGET}.elf | less

clean:
	rm -rf *.elf *.o *.bin *.hex

.PHONY: all clean hex bin dump
