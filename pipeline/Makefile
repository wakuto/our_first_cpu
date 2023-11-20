MODULES = alu.sv top.sv core.sv decoder.sv dmemory.sv imemory.sv regfile.sv cpu_test.sv hazard.sv

all: cpu

cpu: $(MODULES)
	iverilog -o cpu -g 2012 $(MODULES)

program.bin:
	make -C ../program

test.bin:
	make -C ../test

run: cpu program.bin
	vvp cpu

test: cpu test.bin
	vvp cpu

verilator:
	verilator --lint-only -Wall --timing $(MODULES)

clean:
	rm -rf cpu cpu.vcd

.PHONY: all run clean
