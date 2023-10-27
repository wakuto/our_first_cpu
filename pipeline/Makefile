MODULES = alu.sv cpu.sv decoder.sv dmemory.sv imemory.sv regfile.sv cpu_test.sv hazard.sv

all: cpu

cpu: $(MODULES)
	iverilog -o cpu -g 2012 $(MODULES)

program.bin:
	make -C ../program

run: cpu program.bin
	vvp cpu

clean:
	rm -rf cpu cpu.vcd

.PHONY: all run clean
