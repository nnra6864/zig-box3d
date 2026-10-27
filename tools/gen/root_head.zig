//! Box3D bindings for Zig
//!
//! The API is grouped by topic under `src/box3d/` (`world.zig`, `body.zig`, `shape.zig`, ...),
//! following Box3D's documentation groups. Everything is re-exported from here, so the public
//! API is flat: `b3.World`, `b3.createHull`, `b3.Vec3`, ...
//!
//! Ids are handles with methods: `b3World_Step(worldId, ...)` is `world.step(...)` and
//! `b3Body_GetPosition(bodyId)` is `body.getPosition()`.

const std = @import("std");

/// True when Box3D is built in large world mode, where world positions (`Pos`) are doubles.
/// Set with the `double_precision` build option.
pub const double_precision = @import("build_options").double_precision;

