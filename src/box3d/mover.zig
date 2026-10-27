//! Character mover (types.h, collision.h)

const b3 = @import("../box3d.zig");
const Plane = b3.Plane;
const Pos = b3.Pos;
const Shape = b3.Shape;
const Vec3 = b3.Vec3;

/// The plane between a character mover and a shape
pub const PlaneResult = extern struct {
    /// Outward pointing plane.
    plane: Plane,
    /// Closest point on the shape. May not be unique.
    point: Vec3,
    /// The index of the mesh or height field triangle hit.
    triangleIndex: c_int,
    /// The index of the compound child shape.
    childIndex: c_int,
    /// The material index.
    materialIndex: c_int,
};

/// These are collision planes that can be fed to `solvePlanes`. Normally
/// this is assembled by the user from plane results in `PlaneResult`.
pub const CollisionPlane = extern struct {
    /// The collision plane between the mover and some shape.
    plane: Plane,
    /// Setting this to FLT_MAX makes the plane as rigid as possible. Lower values can
    /// make the plane collision soft. Usually in meters.
    pushLimit: f32,
    /// The push on the mover determined by `solvePlanes`. Usually in meters.
    push: f32,
    /// Indicates if `clipVector` should clip against this plane. Should be false for soft collision.
    clipVelocity: bool,
};

/// Result returned by `solvePlanes`.
pub const PlaneSolverResult = extern struct {
    /// The final relative translation.
    delta: Vec3,
    /// The number of iterations used by the plane solver. For diagnostics.
    iterationCount: c_int,
};

/// Body plane result for movers.
pub const BodyPlaneResult = extern struct {
    /// The shape id on the body.
    shapeId: Shape,
    /// The plane result.
    result: PlaneResult,
};

/// Body time of impact result for movers.
pub const BodyTOIResult = extern struct {
    /// The hit point in world space.
    point: Pos,
    /// The hit normal. Points from the body to the mover.
    normal: Vec3,
    /// The sweep time of the collision.
    fraction: f32,
    /// The hit shape.
    shapeId: Shape,
};

/// Used to collect collision planes for character movers.
/// Return true to continue gathering planes.
pub const PlaneResultFcn = *const fn (shapeId: Shape, plane: *const PlaneResult, planeCount: c_int, context: ?*anyopaque) callconv(.c) bool;

/// Used to filter shapes for shape casting character movers.
/// Return true to accept the collision
pub const MoverFilterFcn = *const fn (shapeId: Shape, context: ?*anyopaque) callconv(.c) bool;

/// Solves the position of a mover that satisfies the given collision planes.
/// - `targetDelta`: the desired translation from the position used to generate the collision planes
/// - `planes`: the collision planes
/// - `count`: the number of collision planes
pub fn solvePlanes(targetDelta: Vec3, planes: []CollisionPlane) PlaneSolverResult {
    return b3SolvePlanes(targetDelta, planes.ptr, @intCast(planes.len));
}
extern fn b3SolvePlanes(targetDelta: Vec3, planes: [*]CollisionPlane, count: c_int) PlaneSolverResult;

/// Clips the velocity against the given collision planes. Planes with zero push or clipVelocity
/// set to false are skipped.
pub fn clipVector(vector: Vec3, planes: []const CollisionPlane) Vec3 {
    return b3ClipVector(vector, planes.ptr, @intCast(planes.len));
}
extern fn b3ClipVector(vector: Vec3, planes: [*]const CollisionPlane, count: c_int) Vec3;
