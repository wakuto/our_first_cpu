MODULES = alu.sv top.sv core.sv decoder.sv dmemory.sv imemory.sv regfile.sv cpu_test.sv hazard.sv uart.sv gf180mcu_fd_ip_sram__sram512x8m8wm1.sv

TARGET_DIR := ../test/isa
HEX_FILES := $(shell find $(TARGET_DIR) -type f | sort -n | grep -E 'rv32ui-p-.+\.hex')

all: cpu

cpu: $(MODULES)
	iverilog -o cpu -g 2012 $(MODULES)

program.hex:
	make -C ../program program.hex

make-hex:
	make -C ../test hex

run: cpu program.hex
	vvp cpu

test: cpu make-hex
	rm -f ./result.log
	touch ./result.log
	@for name in $(HEX_FILES); do\
		vvp cpu +hex=$$name;\
	done

	cat ./result.log

verilator:
	verilator --lint-only -Wall --timing $(MODULES)

clean:
	rm -rf cpu cpu.vcd

.PHONY: all run make-hex test verilator clean

