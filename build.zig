const Builder = @import("std").build.Builder;
const Target = @import("std").build.Target;
const CrossTarget = @import("std").build.CrossTarget;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    const glue = b.addStaticLibrary("glue", null);
    glue.addIncludeDir(".");
    glue.addIncludeDir("freetype2/include");
    glue.addIncludeDir("freetype2/src");
    glue.addCSourceFile("glue.c", [_][]const u8{
        "--target=x86_64-pc-win32-coff", "-DFT2_BUILD_LIBRARY",
    });
    glue.setBuildMode(b.standardReleaseOptions());
    const exe = b.addExecutable("bootx64", "main.zig");
    exe.setBuildMode(b.standardReleaseOptions());
    exe.setTheTarget(Target{
        .Cross = CrossTarget{
            .arch = builtin.Arch.x86_64,
            .os = builtin.Os.uefi,
            .abi = builtin.Abi.msvc,
        },
    });
    exe.addIncludeDir(".");
    exe.addIncludeDir("freetype2/include");
    exe.setOutputDir("EFI/Boot");
    exe.linkLibrary(glue);
    b.default_step.dependOn(&exe.step);
}
