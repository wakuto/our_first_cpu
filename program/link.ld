OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
  imem (rx) : ORIGIN = 0x80000000, LENGTH = 0x800 /* SRAM 512B * 4 = 2KB */
  dmem (rw) : ORIGIN = 0x90000000, LENGTH = 0x800 /* SRAM 512B * 4 = 2KB */
}
SECTIONS
{
  . = 0x80000000;
  .text.init : { *(.text.init) } > imem
  . = ALIGN(0x1000);
  .tohost : { *(.tohost) } > dmem
  . = ALIGN(0x1000);
  .text : { *(.text) } > imem
  . = ALIGN(0x1000);
  .data : { *(.data) } > dmem
  .bss : { *(.bss) } > dmem
  _end = .;
}
