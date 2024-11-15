MODULES = alu.sv top.sv core.sv decoder.sv dmemory.sv imemory.sv regfile.sv cpu_test.sv hazard.sv uart.sv gpio.sv gf180mcu_fd_ip_sram__sram512x8m8wm1.sv
TARGET :=
TARGET_DIR := ../test/isa
HEX_FILES := $(shell find $(TARGET_DIR) -type f | sort -n | grep -E 'rv32ui-p-.+\.hex')

all: cpu

cpu: $(MODULES)
	iverilog -o cpu -g 2012 $(MODULES)

program.hex:
	make -C ../program program.hex

test.hex: ../test/$(TARGET).S
	make -C ../test test.hex TARGET=$(TARGET)

make-hex:
	make -C ../test hex

run: cpu program.hex
	vvp cpu

test: cpu test.hex
	vvp cpu +hex=../test/test.hex

riscv-test: cpu make-hex
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
	rm -rf ../test/test.bin

.PHONY: all run make-hex riscv-test test verilator clean

