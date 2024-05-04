const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // setup executable
    const exe = b.addExecutable(.{
        .name = "learning-zig",
        .target = target,
        .optimize = optimize,
        // .root_source_file = .{ .path = "./main.zig" }, 也行
        .root_source_file = b.path("./main.zig"),
    });

    // config local library depends (if necessary)
    const arith_module = b.addModule("arith", .{
        .root_source_file = .{ .path = "./arith/calc.zig" },
    });
    // add library dependency
    exe.root_module.addImport("arith", arith_module);

    // // config remote library depends (if necessary)
    // const calc_dep = b.dependency("calc", .{ .target = target, .optimize = optimize });
    // const calc_module = calc_dep.module("calc");
    // exe.root_module.addImport("calc", calc_module);

    // zig build install
    // zig build install -Doptimize=ReleaseSmall -Dtarget=x86_64-windows-gnu
    b.installArtifact(exe);

    // config run option
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "哈哈你将在zig build --help输出中看到这个选项!");
    run_step.dependOn(&run_cmd.step);

    // config test option
    const tests = b.addTest(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "./main.zig" },
    });
    // add local library dependency
    tests.root_module.addImport("arith", arith_module);
    // // add remote library dependency
    // tests.root_module.addImport("calc", calc_module);
    const test_cmd = b.addRunArtifact(tests);
    test_cmd.step.dependOn(b.getInstallStep());
    const test_step = b.step("test", "你将在zig build --help输出中看到这个选项！");
    test_step.dependOn(&test_cmd.step);
    // zig build test --summary all

}
