//! Base functionality (base.h)

const b3 = @import("../box3d.zig");

/// Prototype for user allocation function.
/// - `size`: the allocation size in bytes
/// - `alignment`: the required alignment, guaranteed to be a power of 2
pub const AllocFcn = *const fn (size: usize, alignment: i32) callconv(.c) ?*anyopaque;

/// Prototype for user free function.
/// - `mem`: the memory previously allocated through `AllocFcn`
/// - `size`: the size of the allocation in bytes.
pub const FreeFcn = *const fn (mem: ?*anyopaque, size: usize) callconv(.c) void;

/// Prototype for the user assert callback. Return 0 to skip the debugger break.
pub const AssertFcn = *const fn (condition: [*:0]const u8, fileName: [*:0]const u8, lineNumber: c_int) callconv(.c) c_int;

/// Prototype for user log callback. Used to log warnings.
pub const LogFcn = *const fn (message: [*:0]const u8) callconv(.c) void;

/// This allows the user to override the allocation functions. These should be
/// set during application startup.
pub const setAllocator = b3SetAllocator;
extern fn b3SetAllocator(allocFcn: ?AllocFcn, freeFcn: ?FreeFcn) void;

/// Total bytes allocated by Box3D
pub const getByteCount = b3GetByteCount;
extern fn b3GetByteCount() i64;

/// Override the default assert callback.
/// - `assertFcn`: a non-null assert callback
pub const setAssertFcn = b3SetAssertFcn;
extern fn b3SetAssertFcn(assertFcn: AssertFcn) void;

/// Override the default logging callback.
pub const setLogFcn = b3SetLogFcn;
extern fn b3SetLogFcn(logFcn: LogFcn) void;

/// Version numbering scheme.
/// See https://semver.org/
pub const Version = extern struct {
    /// Significant changes
    major: c_int,
    /// Incremental changes
    minor: c_int,
    /// Bug fixes
    revision: c_int,
};

/// Get the current version of Box3D
pub const getVersion = b3GetVersion;
extern fn b3GetVersion() Version;

/// Returns true if the library was built with BOX3D_DOUBLE_PRECISION (large world mode)
pub const isDoublePrecision = b3IsDoublePrecision;
extern fn b3IsDoublePrecision() bool;

/// Returns the value of `max_manifold_points` the library was compiled with. Useful for
/// an ABI test.
pub const getMaxManifoldPoints = b3GetMaxManifoldPoints;
extern fn b3GetMaxManifoldPoints() c_int;

/// Returns true if the current CPU has the AVX2 instruction set.
pub const isAVX2Available = b3IsAVX2Available;
extern fn b3IsAVX2Available() bool;

/// Get the absolute number of system ticks. The value is platform specific.
pub const getTicks = b3GetTicks;
extern fn b3GetTicks() u64;

/// Get the milliseconds passed from an initial tick value.
pub const getMilliseconds = b3GetMilliseconds;
extern fn b3GetMilliseconds(ticks: u64) f32;

/// Get the milliseconds passed from an initial tick value.
pub const getMillisecondsAndReset = b3GetMillisecondsAndReset;
extern fn b3GetMillisecondsAndReset(ticks: *u64) f32;

/// Yield to be used in a busy loop.
pub const yield = b3Yield;
extern fn b3Yield() void;

/// Sleep the current thread for a number of milliseconds.
pub const sleep = b3Sleep;
extern fn b3Sleep(milliseconds: c_int) void;

pub fn hash(seed: u32, data: []const u8) u32 {
    return b3Hash(seed, data.ptr, @intCast(data.len));
}
extern fn b3Hash(seed: u32, data: [*]const u8, count: c_int) u32;
