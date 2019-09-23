const uefi = @import("std").os.uefi;
const GraphicsOutputBltOperation = uefi.protocols.GraphicsOutputBltOperation;
const GraphicsOutputBltPixel = uefi.protocols.GraphicsOutputBltPixel;
const GraphicsOutputProtocol = uefi.protocols.GraphicsOutputProtocol;
const fmt = @import("std").fmt;

const freetype = @cImport({
    @cInclude("glue.c");
});

const face_ttf = @embedFile("comicneue/Web/ComicNeue-Bold.ttf");

export fn ft_smalloc(size: usize) *c_void {
    var buf: *c_void = undefined;
    _ = @intToPtr(extern fn (usize, usize, **c_void) usize, uefi.system_table.boot_services.?.allocatePool)(6, size, &buf);
    return buf;
}

pub fn main() void {
    const boot_services = uefi.system_table.boot_services.?;

    var intf: *GraphicsOutputProtocol = undefined;
    _ = boot_services.locateProtocol(&GraphicsOutputProtocol.guid, null, @ptrCast(*?*c_void, &intf));

    var ft_handle: freetype.FT_Library = undefined;
    _ = freetype.FT_Init_FreeType(&ft_handle);

    var face: freetype.FT_Face = undefined;
    _ = freetype.FT_New_Memory_Face(ft_handle, @ptrCast([*c]const u8, &face_ttf), face_ttf.len, 0, &face);

    _ = freetype.FT_Set_Char_Size(face, 0, 64 * 64, 100, 100);

    const color = [1]GraphicsOutputBltPixel{GraphicsOutputBltPixel{
        .blue = 255,
        .green = 255,
        .red = 255,
        .reserved = 0,
    }};

    var offset_x: c_int = 0;
    var offset_y: c_int = 100;
    for ("Hello, world!") |c| {
        const index = freetype.FT_Get_Char_Index(face, c);
        _ = freetype.FT_Load_Glyph(face, index, freetype.FT_LOAD_DEFAULT);
        _ = freetype.FT_Render_Glyph(face.*.glyph, freetype.FT_RENDER_MODE_MONO);
        const glyph = face.*.glyph.*;
        const bitmap = glyph.bitmap;
        var x: c_uint = 0;
        var y: c_uint = 0;
        while (y < bitmap.rows) : (y += 1) {
            while (x < bitmap.width) : (x += 1) {
                if (bitmap.buffer[x / 8 + y * @intCast(usize, bitmap.pitch)] & (u8(1) << @intCast(u3, 7 - @mod(x, 8))) != 0) {
                    _ = intf.blt(&color, GraphicsOutputBltOperation.BltVideoFill, 0, 0, @intCast(usize, offset_x + glyph.bitmap_left + @intCast(c_int, x)), @intCast(usize, offset_y - glyph.bitmap_top + @intCast(c_int, y)), 1, 1, 0);
                }
            }
            x = 0;
        }
        offset_x += glyph.advance.x >> 6;
        offset_y += glyph.advance.y >> 6;
    }

    _ = boot_services.stall(3 * 1000 * 1000);
}
