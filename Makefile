run: EFI/Boot/bootx64.efi
	qemu-system-x86_64 -bios /usr/share/edk2-ovmf/OVMF.fd -hdd fat:rw:. -serial stdio

EFI/Boot/bootx64.efi: main.zig glue.lib
	zig build

glue.lib: glue.c
	clang -c -I. -I freetype2/include/ -I freetype2/src/ -D FT2_BUILD_LIBRARY -o glue.lib -target x86_64-pc-win32-coff glue.c

clean:
	rm -rf zig-cache glue.lib EFI/Boot/bootx64.efi NvVars
