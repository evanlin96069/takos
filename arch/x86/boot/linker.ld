OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(_start)

SECTIONS
{
    . = 0x00100000;
    _kernel_start = .;

    .text ALIGN(0x1000) : {
        *(.text*)
    }

    .rodata ALIGN(0x1000) : {
        *(.rodata*)
    }

    .data   ALIGN(0x1000) : {
        *(.data*)
    }

    .bss    ALIGN(0x1000) : {
        *(COMMON)
        *(.bss*)
    }

    _kernel_end = .;

    /DISCARD/ : {
        *(.note*)
    }
}
