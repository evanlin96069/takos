# Configuration
ARCH                ?= x86
BOOTLOADER          ?= multiboot2

ARCH_DIR            := arch/$(ARCH)
BOOTLOADER_DIR      := $(ARCH_DIR)/boot/$(BOOTLOADER)
multiboot2_ENTRY    := multiboot2_main
BOOTLOADER_ENTRY    := $($(BOOTLOADER)_ENTRY)

BUILD               := build
OBJ_DIR             := $(BUILD)/obj
ISO_DIR             := $(BUILD)/iso
BOOT_OBJ_DIR        := $(OBJ_DIR)/boot
CONFIG_DIR          := config
BOOT_DIR            := $(ISO_DIR)/boot
GRUB_DIR            := $(BOOT_DIR)/grub

ISO                 := takos.iso

GRUB_CFG            := $(CONFIG_DIR)/grub.cfg
LINKER_SCRIPT       := $(ARCH_DIR)/boot/linker.ld

KERNEL              := $(BOOT_DIR)/kernel.bin
KERNEL_OBJ          := $(OBJ_DIR)/kernel.o

BOOT_ASM            := $(BOOTLOADER_DIR)/boot.s
BOOT_IKA            := $(BOOTLOADER_DIR)/entry.ika
BOOT_OBJS           := $(BOOT_OBJ_DIR)/boot.o $(BOOT_OBJ_DIR)/entry.o

IKA_SRC := $(shell find arch drivers kernel lib -not -path '$(BOOTLOADER_DIR)/*' -name '*.ika')
ASM_SRC := $(shell find arch drivers kernel lib -not -path '$(BOOTLOADER_DIR)/*' -name '*.s')
ASM_OBJS := $(patsubst %,$(OBJ_DIR)/%.o,$(basename $(ASM_SRC)))

OBJ_FILES := $(BOOT_OBJS) $(ASM_OBJS) $(KERNEL_OBJ)

IKAC_FLAGS          := -S -I lib
KERNEL_INC_FLAGS    := $(IKAC_FLAGS) -e kmain -I $(ARCH_DIR) -I drivers -I kernel -I kernel/lib -I boot
BOOT_INC_FLAGS      := $(IKAC_FLAGS) -e $(BOOTLOADER_ENTRY) -I boot
LDFLAGS    		    := -nostdlib -z max-page-size=0x1000

GRUB_MKRESCUE := $(shell command -v grub-mkrescue 2>/dev/null || command -v grub2-mkrescue 2>/dev/null)

ifeq ($(GRUB_MKRESCUE),)
$(error grub-mkrescue or grub2-mkrescue not found)
endif


all: $(ISO)

$(OBJ_DIR) $(BOOT_OBJ_DIR) $(BOOT_DIR) $(GRUB_DIR):
	mkdir -p $@

# Boot
$(BOOT_OBJ_DIR)/boot.o: $(BOOT_ASM) | $(BOOT_OBJ_DIR)
	nasm -f elf32 $< -o $@

$(BOOT_OBJ_DIR)/entry.s: $(BOOT_IKA) | $(BOOT_OBJ_DIR)
	ikac $(BOOT_INC_FLAGS) -o $@ $(BOOT_IKA)

$(BOOT_OBJ_DIR)/entry.o: $(BOOT_OBJ_DIR)/entry.s | $(BOOT_OBJ_DIR)
	clang -target i386-elf -c $< -o $@

# Kernel
$(OBJ_DIR)/kernel.s: $(IKA_SRC) | $(OBJ_DIR)
	ikac $(KERNEL_INC_FLAGS) -o $@ kernel/main.ika

$(KERNEL_OBJ): $(OBJ_DIR)/kernel.s | $(OBJ_DIR)
	clang -target i386-elf -c $< -o $@

$(OBJ_DIR)/%.o: %.s | $(OBJ_DIR)
	mkdir -p $(dir $@)
	nasm -f elf32 $< -o $@

$(KERNEL): $(OBJ_FILES) $(LINKER_SCRIPT) | $(BOOT_DIR)
	ld.lld -T $(LINKER_SCRIPT) $(LDFLAGS) -o $@ $(OBJ_FILES)

# ISO
$(ISO): $(KERNEL) $(GRUB_CFG) | $(GRUB_DIR)
	cp $(GRUB_CFG) $(GRUB_DIR)/grub.cfg
	$(GRUB_MKRESCUE) -o $@ $(ISO_DIR)

# Helpers
run: $(ISO)
	qemu-system-i386 -cdrom $<

clean:
	rm -rf $(BUILD) $(ISO)

.PHONY: all run clean
