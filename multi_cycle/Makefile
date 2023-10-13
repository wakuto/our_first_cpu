MODULES = alu.sv cpu.sv decoder.sv memory.sv regfile.sv cpu_test.sv

all: cpu

cpu: $(MODULES)
	iverilog -o cpu -g 2012 $(MODULES)

program.bin:
	make -C ../program

dump:
	make -C ../program dump

run: cpu program.bin
	vvp cpu

clean:
	rm -rf cpu cpu.vcd

.PHONY: all run clean dump
