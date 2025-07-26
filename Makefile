TARGET        := kernel.bin
BUILD         := build
OBJDIR        := $(BUILD)/obj
ISO_DIR       := $(BUILD)/iso
BOOT_DIR      := $(ISO_DIR)/boot
GRUB_DIR      := $(BOOT_DIR)/grub
ISO           := takos.iso

BOOT_ASM        := boot/boot.s
LINKER_SCRIPT   := boot/linker.ld
GRUB_CFG        := boot/grub.cfg

SRC := $(shell find arch drivers kernel lib -name '*.ika')

IKAC_FLAGS  := -S -e kmain -I arch/x86 -I drivers -I lib
LDFLAGS     := -nostdlib -z max-page-size=0x1000

all: $(ISO)

$(OBJDIR) $(BOOT_DIR) $(GRUB_DIR):
	mkdir -p $@

$(OBJDIR)/kernel.s: $(SRC) | $(OBJDIR)
	ikac $(IKAC_FLAGS) -o $@ kernel/main.ika

$(OBJDIR)/kernel.o: $(OBJDIR)/kernel.s
	clang -target i386-elf -c $< -o $@

$(OBJDIR)/boot.o: $(BOOT_ASM) | $(OBJDIR)
	nasm -f elf32 $< -o $@

$(BOOT_DIR)/$(TARGET): $(OBJDIR)/boot.o $(OBJDIR)/kernel.o $(LINKER_SCRIPT) | $(BOOT_DIR)
	ld.lld -T $(LINKER_SCRIPT) $(LDFLAGS) -o $@ $^

$(ISO): $(BOOT_DIR)/$(TARGET) $(GRUB_CFG)
	cp $(GRUB_CFG) $(GRUB_DIR)/grub.cfg
	grub-mkrescue -o $@ $(ISO_DIR)

run: $(ISO)
	qemu-system-i386 -cdrom $<

clean:
	rm -rf $(BUILD) $(ISO)

.PHONY: all iso run clean
