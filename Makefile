MODULES = alu.sv cpu.sv dmemory.sv imemory.sv regfile.sv cpu_test.sv

all: cpu

cpu: $(MODULES)
	iverilog -o cpu -g 2012 $(MODULES)

run: cpu
	vvp cpu

clean:
	rm -rf cpu cpu.vcd

.PHONY: all run clean