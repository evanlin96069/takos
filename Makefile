TARGET = kernel.bin
ISO = takos.iso
BUILD = build
SRC := $(shell find src -name '*.ika')
ISO_DIR= iso
GRUB_DIR=$(ISO_DIR)/boot/grub

LDFLAGS = -nostdlib -z max-page-size=0x1000

all: $(ISO)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/kernel.s: $(SRC) | $(BUILD)
	ikac -S -e kernel_main -o $@ src/kernel.ika

$(BUILD)/kernel.o: $(BUILD)/kernel.s
	clang -target i386-elf -c $< -o $@

$(BUILD)/boot.o: src/boot.s | $(BUILD)
	nasm -f elf32 $< -o $@

$(BUILD)/$(TARGET): $(BUILD)/boot.o $(BUILD)/kernel.o
	ld.lld -T linker.ld $(LDFLAGS) -o $@ $^

iso: $(BUILD)/$(TARGET)
	mkdir -p $(GRUB_DIR)
	cp $< $(ISO_DIR)/boot/kernel.bin
	cp grub/grub.cfg $(GRUB_DIR)/grub.cfg

$(ISO): iso
	grub-mkrescue -o $@ $(ISO_DIR)

run: $(ISO)
	qemu-system-i386 -cdrom $<

clean:
	rm -rf $(BUILD) iso
	rm -f $(ISO)

.PHONY: all iso run clean
