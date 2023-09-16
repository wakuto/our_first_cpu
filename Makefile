cpu: cpu.sv cpu_test.sv
	iverilog -o cpu -g 2012 cpu.sv cpu_test.sv

run: cpu
	vvp cpu

clean:
	rm -rf cpu cpu.vcd

.PHONY: run clean
