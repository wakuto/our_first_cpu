MODULES = alu.sv top.sv core.sv decoder.sv dmemory.sv imemory.sv regfile.sv cpu_test.sv hazard.sv uart.sv gf180mcu_fd_ip_sram__sram512x8m8wm1.sv

all: cpu

cpu: $(MODULES)
	iverilog -o cpu -g 2012 $(MODULES)

program.hex:
	make -C ../program program.hex

test.hex:
	make -C ../test test.hex

run: cpu program.hex
	vvp cpu

test: cpu test.hex
	vvp cpu

verilator:
	verilator --lint-only -Wall --timing $(MODULES)

clean:
	rm -rf cpu cpu.vcd

.PHONY: all run clean

