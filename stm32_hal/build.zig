const std = @import("std");
pub const gatz = @import("gatz");
pub const newlib = gatz.newlib;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const stm32_hal = b.addObject(.{
        .name = "stm32_hal",
        .target = target,
        .optimize = optimize,
    });

    // Includes
    const headers = .{
        "Core/Inc",
        "Drivers/STM32F4xx_HAL_Driver/Inc",
        "Drivers/STM32F4xx_HAL_Driver/Inc/Legacy",
        "Drivers/CMSIS/Device/ST/STM32F4xx/Include",
        "Drivers/CMSIS/Include",
        "Core/Inc",
    };
    inline for (headers) |header| {
        stm32_hal.installHeadersDirectory(b.path(header), "", .{});
        stm32_hal.addIncludePath(b.path(header));
    }

    // Source files
    stm32_hal.addCSourceFiles(.{
        .files = &.{
            "Core/Src/main.c",
            "Core/Src/stm32f4xx_it.c",
            "Core/Src/stm32f4xx_hal_msp.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim_ex.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_uart.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ramfunc.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma_ex.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c",
            "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_exti.c",
            "Core/Src/system_stm32f4xx.c",
            "Core/Src/sysmem.c",
            "Core/Src/syscalls.c",
        },
        .flags = &.{"-std=c11"},
    });

    // Neccessary for HAL
    stm32_hal.defineCMacro("USE_HAL_DRIVER", null);
    stm32_hal.defineCMacro("STM32F401xE", null);

    // Startup file
    stm32_hal.addAssemblyFile(b.path("startup_stm32f401xe.s"));

    // Linker Script
    stm32_hal.setLinkerScriptPath(b.path("STM32F401RETx_FLASH.ld"));

    // Pull in Newlib with a utility
    newlib.addTo(b, target, stm32_hal) catch |err| switch (err) {
        newlib.Error.CompilerNotFound => {
            std.log.err("Couldn't find arm-none-eabi-gcc compiler!\n", .{});
            unreachable;
        },
        newlib.Error.IncompatibleCpu => {
            std.log.err("Cpu: {s} isn't supported by gatz!\n", .{target.result.cpu.model.name});
            unreachable;
        },
    };

    // Create artifact for top level project to depend on
    b.getInstallStep().dependOn(&b.addInstallArtifact(stm32_hal, .{ .dest_dir = .{ .override = .{ .custom = "" } } }).step);
}
