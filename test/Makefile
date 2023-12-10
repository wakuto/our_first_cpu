PREFIX=riscv32-unknown-elf-
TARGET :=

all: test.bin

test.bin: ${TARGET}.S link.ld
	$(PREFIX)as ./${TARGET}.S -c -o ${TARGET}.o
	$(PREFIX)ld ./${TARGET}.o -Tlink.ld -o ./${TARGET}.elf
	$(PREFIX)objcopy -O binary ./${TARGET}.elf ./test.bin

test.hex: test.bin
	od -t x1 -A n -w1 -v ./test.bin > ./test.hex

dump:
	$(PREFIX)objdump -M numeric -M no-aliases -D ./${TARGET}.elf | less

clean:
	rm -rf *.elf *.o *.bin *.hex

# test.hex, test.bin は毎回実行
.PHONY: all clean dump test.hex test.bin
