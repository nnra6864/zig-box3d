
const modules = .{
@MODULES@};

test {
    refAllDeclsRecursive(@This(), 3);
    if (@import("test_options").abi_check) _ = @import("abi_test.zig");
    _ = @import("smoke_test.zig");
}

test "every public declaration is re-exported" {
    @setEvalBranchQuota(100_000);
    inline for (modules) |M| {
        inline for (comptime std.meta.declarations(M)) |decl| {
            if (!@hasDecl(@This(), decl)) @compileError("missing re-export: " ++ decl);
        }
    }
}

/// Like `std.testing.refAllDeclsRecursive`, but with a depth limit so it does not
/// recurse forever through the type aliases that point back at each other.
fn refAllDeclsRecursive(comptime T: type, comptime depth: usize) void {
    if (!@import("builtin").is_test) return;
    inline for (comptime std.meta.declarations(T)) |decl| {
        const value = @field(T, decl);
        if (@TypeOf(value) == type) {
            if (depth > 0) switch (@typeInfo(value)) {
                .@"struct", .@"enum", .@"union", .@"opaque" => refAllDeclsRecursive(value, depth - 1),
                else => {},
            };
        } else {
            _ = &value;
        }
    }
}
