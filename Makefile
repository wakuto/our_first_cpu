MODULES = alu.sv cpu.sv decoder.sv dmemory.sv imemory.sv regfile.sv cpu_test.sv
PREFIX=riscv32-unknown-elf-

all: cpu

cpu: $(MODULES)
	iverilog -o cpu -g 2012 $(MODULES)

run: cpu
	vvp cpu

bin:
	$(PREFIX)as ./start.S -c -o start.o
	$(PREFIX)ld ./start.o -Tlink.ld -o ./start.elf
	$(PREFIX)objcopy -O binary ./start.elf ./program.bin

clean:
	rm -rf cpu cpu.vcd

.PHONY: all run clean bin
