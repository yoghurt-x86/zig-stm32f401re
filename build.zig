const std = @import("std");
const gatz = @import("stm32_hal").gatz;
const newlib = @import("stm32_hal").newlib;

pub fn build(b: *std.Build) void {
    //const target = b.resolveTargetQuery(.{
    //    .cpu_arch = .thumb,
    //    .os_tag = .freestanding,
    //    .abi = .eabihf,
    //    .cpu_model = std.zig.CrossTarget.CpuModel{ .explicit = &std.Target.arm.cpu.cortex_m4 },
    //    // Note that "fp_armv8d16sp" is the same instruction set as "fpv5-sp-d16", so LLVM only has the former
    //    // https://github.com/llvm/llvm-project/issues/95053
    //    .cpu_features_add = std.Target.arm.featureSet(&[_]std.Target.arm.Feature{std.Target.arm.Feature.fp_armv8d16sp}),
    //});

    const gatz_target = gatz.Target{
        .cpu = gatz.cpu.@"cortex-m4",
        .instruction_set = .thumb,
        .endianness = .little,
        .float_abi = .hard,
        .fpu = gatz.fpu.@"fpv4-sp-d16",
    };

    const target_query = gatz_target.toTargetQuery() catch |err| {
        std.log.err("Something is misconfigured, see: {any}\n", .{err});
        unreachable;
    };

    const target = b.resolveTargetQuery(target_query);

    const executable_name = "blinky";

    const optimize = b.standardOptimizeOption(.{});
    const blinky_exe = b.addExecutable(.{
        .name = executable_name ++ ".elf",
        .target = target,
        .optimize = optimize,
        .link_libc = false,
        .linkage = .static,
        .single_threaded = true,
        .root_source_file = b.path("src/main.zig"),
    });

    // Add STM32 Hal
    const stm32_hal = b.dependency("stm32_hal", .{ .target = target, .optimize = optimize }).artifact("stm32_hal");
    blinky_exe.addObject(stm32_hal);

    // This ideally won't be neccessary in the future, see:
    // - https://github.com/ziglang/zig/issues/20431
    newlib.addIncludeHeadersAndSystemPathsTo(b, target, blinky_exe) catch |err| switch (err) {
        newlib.Error.CompilerNotFound => {
            std.log.err("Couldn't find arm-none-eabi-gcc compiler!\n", .{});
            unreachable;
        },
        newlib.Error.IncompatibleCpu => {
            std.log.err("Cpu: {s} isn't supported by gatz!\n", .{target.result.cpu.model.name});
            unreachable;
        },
    };

    blinky_exe.link_gc_sections = true;
    blinky_exe.link_data_sections = true;
    blinky_exe.link_function_sections = true;

    // Produce .bin file from .elf
    const bin = b.addObjCopy(blinky_exe.getEmittedBin(), .{
        .format = .bin,
    });
    bin.step.dependOn(&blinky_exe.step);
    const copy_bin = b.addInstallBinFile(bin.getOutput(), executable_name ++ ".bin");
    b.default_step.dependOn(&copy_bin.step);

    // Produce .hex file from .elf
    const hex = b.addObjCopy(blinky_exe.getEmittedBin(), .{
        .format = .hex,
    });
    hex.step.dependOn(&blinky_exe.step);
    const copy_hex = b.addInstallBinFile(hex.getOutput(), executable_name ++ ".hex");
    b.default_step.dependOn(&copy_hex.step);

    b.installArtifact(blinky_exe);
}
