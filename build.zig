const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const system_box3d = b.option(
        bool,
        "system_box3d",
        "Link the Box3D installed on the system instead of building it from source (default: false)",
    ) orelse false;
    const linkage = b.option(
        std.builtin.LinkMode,
        "linkage",
        "Build Box3D as a static or a dynamic library (default: static)",
    ) orelse .static;
    const double_precision = b.option(
        bool,
        "double_precision",
        "Large world mode, world positions are stored as doubles. Changes the ABI (default: false)",
    ) orelse false;
    const disable_simd = b.option(
        bool,
        "disable_simd",
        "Build the scalar fallback instead of SSE2/AVX2/NEON (default: false)",
    ) orelse false;
    const validate = b.option(
        bool,
        "validate",
        "Enable Box3D's heavy internal validation in debug builds (default: false)",
    ) orelse false;

    const options = b.addOptions();
    options.addOption(bool, "double_precision", double_precision);

    const box3d = b.addModule("box3d", .{
        .root_source_file = b.path("src/box3d.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    box3d.addOptions("build_options", options);

    // Only needed by the ABI test, which translates the C headers.
    var include_path: ?std.Build.LazyPath = null;

    if (system_box3d) {
        box3d.linkSystemLibrary("box3d", .{});
    } else if (b.lazyDependency("box3d", .{})) |dep| {
        include_path = dep.path("include");

        const lib = b.addLibrary(.{
            .name = "box3d",
            .linkage = linkage,
            .root_module = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .link_libc = true,
            }),
        });
        const mod = lib.root_module;
        mod.addIncludePath(dep.path("include"));
        mod.addIncludePath(dep.path("src"));

        // Same flags as Box3D's CMake: C17 with extensions, no FMA contraction for determinism.
        var flags: std.ArrayList([]const u8) = .empty;
        flags.appendSlice(b.allocator, &.{ "-std=gnu17", "-ffp-contract=off" }) catch @panic("OOM");
        if (linkage == .dynamic) {
            mod.addCMacro("box3d_EXPORTS", "");
            flags.append(b.allocator, "-fvisibility=hidden") catch @panic("OOM");
        }
        if (double_precision) mod.addCMacro("BOX3D_DOUBLE_PRECISION", "");
        if (disable_simd) mod.addCMacro("BOX3D_DISABLE_SIMD", "");
        if (validate) mod.addCMacro("BOX3D_VALIDATE", "");
        switch (optimize) {
            .Debug => {},
            // Keep Box3D's assertions in safe builds.
            .ReleaseSafe => mod.addCMacro("B3_ENABLE_ASSERT", ""),
            .ReleaseFast, .ReleaseSmall => mod.addCMacro("NDEBUG", ""),
        }
        if (target.result.cpu.arch.isWasm()) {
            flags.appendSlice(b.allocator, &.{ "-msimd128", "-msse2" }) catch @panic("OOM");
        }

        mod.addCSourceFiles(.{
            .root = dep.path("src"),
            .files = &c_sources,
            .flags = flags.items,
        });

        box3d.linkLibrary(lib);
        // Installed so dependents can get it with `dependency.artifact("box3d")`,
        // e.g. to install the shared library next to their executable.
        b.installArtifact(lib);
    }

    const test_module = b.createModule(.{
        .root_source_file = b.path("src/box3d.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    test_module.addOptions("build_options", options);
    for (box3d.link_objects.items) |obj| switch (obj) {
        .other_step => |lib| test_module.linkLibrary(lib),
        .system_lib => |lib| test_module.linkSystemLibrary(lib.name, .{}),
        else => {},
    };
    if (include_path) |path| {
        // The C headers translated to Zig, used to check that the bindings match the C ABI.
        const translate = b.addTranslateC(.{
            .root_source_file = b.addWriteFiles().add("box3d_c.h", "#include <box3d/box3d.h>\n"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        translate.addIncludePath(path);
        if (double_precision) translate.defineCMacro("BOX3D_DOUBLE_PRECISION", null);
        test_module.addImport("box3d_c", translate.createModule());
    }
    const test_options = b.addOptions();
    test_options.addOption(bool, "abi_check", include_path != null);
    test_module.addOptions("test_options", test_options);

    const tests = b.addTest(.{ .root_module = test_module });
    const test_step = b.step("test", "Run the binding tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}

const c_sources = [_][]const u8{
    "aabb.c",
    "arena_allocator.c",
    "bitset.c",
    "block_allocator.c",
    "body.c",
    "broad_phase.c",
    "capsule.c",
    "compound.c",
    "constraint_graph.c",
    "contact.c",
    "contact_solver.c",
    "convex_manifold.c",
    "core.c",
    "distance.c",
    "distance_joint.c",
    "dynamic_tree.c",
    "height_field.c",
    "hull.c",
    "id_pool.c",
    "island.c",
    "joint.c",
    "manifold.c",
    "math_functions.c",
    "mesh.c",
    "mesh_contact.c",
    "motor_joint.c",
    "mover.c",
    "name_cache.c",
    "parallel_for.c",
    "parallel_joint.c",
    "physics_world.c",
    "prismatic_joint.c",
    "recording.c",
    "replay.c",
    "revolute_joint.c",
    "scheduler.c",
    "sensor.c",
    "shape.c",
    "simd.c",
    "solver.c",
    "solver_set.c",
    "sphere.c",
    "spherical_joint.c",
    "table.c",
    "timer.c",
    "triangle_manifold.c",
    "types.c",
    "weld_joint.c",
    "wheel_joint.c",
    "wide4.c",
    "wide8.c",
    "world_snapshot.c",
};
