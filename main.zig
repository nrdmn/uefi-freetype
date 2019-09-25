const uefi = @import("std").os.uefi;
const GraphicsOutputBltOperation = uefi.protocols.GraphicsOutputBltOperation;
const GraphicsOutputBltPixel = uefi.protocols.GraphicsOutputBltPixel;
const GraphicsOutputProtocol = uefi.protocols.GraphicsOutputProtocol;
const hii = uefi.protocols.hii;
const HIIDatabaseProtocol = uefi.protocols.HIIDatabaseProtocol;
const fmt = @import("std").fmt;

const freetype = @cImport({
    @cInclude("glue.c");
});

const face_ttf = @embedFile("comicneue/Web/ComicNeue-Bold.ttf");

export fn ft_smalloc(size: usize) [*]u8 {
    var buf: [*]u8 = undefined;
    _ = uefi.system_table.boot_services.?.allocatePool(uefi.tables.MemoryType.BootServicesData, size, &buf);
    return buf;
}

pub fn print(msg: []const u8) void {
    const con_out = uefi.system_table.con_out.?;
    for (msg) |c| {
        _ = con_out.outputString(&[_]u16{ c, 0 });
    }
}

pub fn main() void {
    var buf: [100]u8 = undefined;
    var status: usize = undefined;
    const boot_services = uefi.system_table.boot_services.?;

    var intf: *HIIDatabaseProtocol = undefined;
    status = boot_services.locateProtocol(&HIIDatabaseProtocol.guid, null, @ptrCast(*?*c_void, &intf));
    print(fmt.bufPrint(buf[0..], "locate hii db protocol = {}\r\n", status) catch "");

    var ft_handle: freetype.FT_Library = undefined;
    status = @intCast(usize, freetype.FT_Init_FreeType(&ft_handle));
    print(fmt.bufPrint(buf[0..], "init freetype = {}\r\n", status) catch "");

    var face: freetype.FT_Face = undefined;
    status = @intCast(usize, freetype.FT_New_Memory_Face(ft_handle, @ptrCast([*c]const u8, &face_ttf), face_ttf.len, 0, &face));
    print(fmt.bufPrint(buf[0..], "new memory face = {}\r\n", status) catch "");

    status = @intCast(usize, freetype.FT_Set_Char_Size(face, 0, 10 * 64, 100, 100));
    print(fmt.bufPrint(buf[0..], "set char size = {}\r\n", status) catch "");

    var buffer_length: usize = 0;
    var handles: [*]hii.HIIHandle = undefined;
    status = intf.listPackageLists(7, null, &buffer_length, handles);
    print(fmt.bufPrint(buf[0..], "list package lists = {}\r\n", status) catch "");

    status = uefi.system_table.boot_services.?.allocatePool(uefi.tables.MemoryType.BootServicesData, buffer_length, @ptrCast(*[*]u8, &handles));
    print(fmt.bufPrint(buf[0..], "allocate pool = {}\r\n", status) catch "");

    status = intf.listPackageLists(7, null, &buffer_length, handles);
    print(fmt.bufPrint(buf[0..], "list package lists = {}\r\n", status) catch "");

    var pkg_buf: *hii.HIIPackageList align(8) = undefined;
    var pkg_buf_size: usize = 0;
    status = intf.exportPackageLists(handles[0], &pkg_buf_size, pkg_buf);
    print(fmt.bufPrint(buf[0..], "export package lists = {}\r\n", status) catch "");

    status = uefi.system_table.boot_services.?.allocatePool(uefi.tables.MemoryType.BootServicesData, pkg_buf_size, @ptrCast(*[*]u8, &pkg_buf));
    print(fmt.bufPrint(buf[0..], "allocate pool = {}, allocated {} bytes\r\n", status, pkg_buf_size) catch "");

    status = intf.exportPackageLists(handles[0], &pkg_buf_size, pkg_buf);
    print(fmt.bufPrint(buf[0..], "export package lists = {}\r\n", status) catch "");

    const font = @ptrCast(*hii.HIISimplifiedFontPackage, &@ptrCast([*]hii.HIIPackageList, pkg_buf)[1]); // TODO use iterator
    for (font.getNarrowGlyphs()) |*g| {
        if (g.unicode_weight < 256) {
            const index = freetype.FT_Get_Char_Index(face, g.unicode_weight);
            if (freetype.FT_Load_Glyph(face, index, freetype.FT_LOAD_DEFAULT) == 0) {
                for (g.glyph_col_1) |*c| c.* = 0;
                _ = freetype.FT_Render_Glyph(face.*.glyph, freetype.FT_RENDER_MODE_MONO);
                const glyph = face.*.glyph.*;
                const bitmap = glyph.bitmap;
                var x: c_uint = 0;
                var y: c_uint = 0;
                while (y < bitmap.rows and y < 19) : (y += 1) {
                    while (x < bitmap.width and x < 8) : (x += 1) {
                        if (16 + @intCast(c_int, y) - glyph.bitmap_top >= 0 and 16 + @intCast(c_int, y) - glyph.bitmap_top < 19) {
                            g.glyph_col_1[@intCast(usize, 16 + @intCast(c_int, y) - glyph.bitmap_top)] = bitmap.buffer[x / 8 + y * @intCast(usize, bitmap.pitch)] >> @intCast(u3, glyph.bitmap_left);
                        }
                    }
                    x = 0;
                }
            }
        }
    }
    print("replacing font package...\r\n");
    status = intf.updatePackageList(handles[0], pkg_buf);
    print(fmt.bufPrint(buf[0..], "update package list = {}\r\n", status) catch "");
}
