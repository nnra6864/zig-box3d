//! Constants and length units (constants.h)
//!
//! Constants that scale with the length units are functions, because the length units can be
//! changed at run-time with `setLengthUnitsPerMeter`.

const b3 = @import("../box3d.zig");

/// Box3D bases all length units on meters, but you may need different units for your game.
/// You can set this value to use different units. This should be done at application startup
/// and only modified once. Default value is 1.
/// Warning: This must be modified before any calls to Box3D
pub const setLengthUnitsPerMeter = b3SetLengthUnitsPerMeter;
extern fn b3SetLengthUnitsPerMeter(lengthUnits: f32) void;

/// Get the current length units per meter.
pub const getLengthUnitsPerMeter = b3GetLengthUnitsPerMeter;
extern fn b3GetLengthUnitsPerMeter() f32;

/// This is used to indicate null for interfaces that work with indices instead of pointers
pub const null_index: c_int = -1;

/// Default collision category bits.
pub const default_category_bits: u64 = 0xFFFF_FFFF_FFFF_FFFF;

/// Default collision mask bits.
pub const default_mask_bits: u64 = 0xFFFF_FFFF_FFFF_FFFF;

/// Used to detect bad values. In float mode positions greater than about 16km have precision
/// problems, so 100km is a safe limit. Large world mode keeps coordinates accurate much farther
/// from the origin, so the sanity limit widens to keep valid far-field positions from tripping it.
pub fn huge() f32 {
    return (if (b3.double_precision) 1.0e9 else 1.0e5) * getLengthUnitsPerMeter();
}

/// Maximum parallel workers. Used for some fixed size arrays.
pub const max_workers = 32;

/// Maximum number of tasks queued per world step. `EnqueueTaskCallback` will never be called
/// more than this per world step. This is related to `max_workers`. With 32 workers,
/// the maximum observed task count is 130. This allows an external task system to use a fixed
/// size array for Box3D task, which may help with creating stable user task pointers.
pub const max_tasks = 256;

/// Maximum number of colors in the constraint graph. Constraints that cannot
/// find a color are added to the overflow set which are solved single-threaded.
pub const graph_color_count = 24;

/// Number of contact point buckets for counting the number of contact points per
/// shape contact pair. This is just for reporting and doesn't affect simulation.
pub const contact_manifold_count_buckets = 8;

/// A small length used as a collision and constraint tolerance. Usually it is
/// chosen to be numerically significant, but visually insignificant. In meters.
/// Warning: modifying this can have a significant impact on stability
pub fn linearSlop() f32 {
    return 0.005 * getLengthUnitsPerMeter();
}

/// The minimum length of a capsules. Very short capsules should be created as spheres
/// to avoid numerical problems.
pub fn minCapsuleLength() f32 {
    return linearSlop();
}

/// Minimum contact point friction weight, lower bound for speculative points. Made small
/// enough to be washed away by weights that hit 1.
pub const min_friction_weight: f32 = 1e-10;

/// The distance between shapes where they are considered overlapped. This is needed
/// because GJK may return small positive values for overlapped shapes in degenerate
/// configurations.
pub fn overlapSlop() f32 {
    return 0.1 * linearSlop();
}

/// Maximum number of simultaneous worlds that can be allocated
pub const max_worlds = 128;

/// The maximum rotation of a body per time step. This limit is very large and is used
/// to prevent numerical problems. You shouldn't need to adjust this.
pub const max_rotation: f32 = 0.25 * b3.pi;

/// The speculative contact distance.
pub fn speculativeDistance() f32 {
    return 4 * linearSlop();
}

/// The rest offset is used for mesh contact to reduce ghost collisions and assist with CCD.
/// The rest offset adjusts the contact point separation value, making the solver push the shapes
/// apart by this distance.
pub fn meshRestOffset() f32 {
    return linearSlop();
}

/// The default contact recycling distance.
pub fn contactRecycleDistance() f32 {
    return 10 * linearSlop();
}

/// The default contact recycling world angle threshold. For performance this value
/// is cos(angle/2)^2. This value corresponds to 10 degrees.
pub const contact_recycle_angular_distance: f32 = 0.99240388;

/// This is used to fatten AABBs in the dynamic tree. This allows proxies
/// to move by a small amount without triggering a tree adjustment. This is in meters.
pub fn maxAABBMargin() f32 {
    return 0.05 * getLengthUnitsPerMeter();
}

/// Per-shape AABB margin is a fraction of the shape extent (capped by `maxAABBMargin`).
/// Small shapes get small margins; large shapes are clamped to the cap.
pub const aabb_margin_fraction: f32 = 0.125;

/// The time that a body must be still before it will go to sleep. In seconds.
pub const time_to_sleep: f32 = 0.5;

/// The maximum number of restitution iterations. Needed to avoid a solver overflow.
pub const max_restitution_iterations = 63;

/// The maximum number of contact points between two touching shapes.
/// Box3D must be compiled with the default value of 4 for these bindings.
pub const max_manifold_points = 4;

/// The maximum number of convex hull vertices. This is fixed for performance reasons.
pub const max_hull_vertices = 128;

/// The maximum number of convex hull faces.
pub const max_hull_faces = 128;

/// The maximum number of convex hull edges. Full edges, not half-edges.
pub const max_hull_edges = 128;

/// Relative tolerance used to determine if two edges are parallel.
pub const parallel_edge_tol: f32 = 0.005;

/// The maximum number points to use for shape cast proxies (swept point cloud).
pub const max_shape_cast_points = max_hull_vertices;

/// These generous limits allow for easy hashing.
pub const shape_power = 22;
pub const child_power = 64 - 2 * shape_power;
pub const max_shapes = 1 << shape_power;
pub const max_child_shapes = 1 << child_power;

/// This is the limit on how many mesh or heightfield triangles a single convex shape can collide with.
pub const max_mesh_contact_triangles = 512;
