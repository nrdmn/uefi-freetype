run: EFI/Boot/bootx64.efi
	qemu-system-x86_64 -bios /usr/share/edk2-ovmf/OVMF.fd -hdd fat:rw:. -serial stdio

EFI/Boot/bootx64.efi: main.zig glue.c modules.h build.zig
	zig build

clean:
	rm -rf zig-cache EFI/Boot/bootx64.efi NvVars
