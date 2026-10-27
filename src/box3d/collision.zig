//! Shape collision (types.h, collision.h)

const std = @import("std");

const b3 = @import("../box3d.zig");
const Capsule = b3.Capsule;
const HullData = b3.HullData;
const SimplexCache = b3.SimplexCache;
const Sphere = b3.Sphere;
const Transform = b3.Transform;
const Vec2 = b3.Vec2;
const Vec3 = b3.Vec3;

/// Cached separating axis feature.
pub const SeparatingFeature = enum(u8) {
    invalid = 0,
    backside,
    face_a,
    face_b,
    edge_pair,
    closest_points,
    /// These are for testing
    manual_face_a,
    manual_face_b,
    manual_edge_pair,
};

/// Cached triangle feature.
pub const TriangleFeature = enum(c_int) {
    none = 0,
    triangle_face,
    hull_face,
    /// v1-v2
    edge1,
    /// v2-v3
    edge2,
    /// v3-v1
    edge3,
    vertex1,
    vertex2,
    vertex3,
};

/// Separating axis test cache. Provides temporal acceleration of collision routines.
pub const SATCache = extern struct {
    /// The separation when the cache is populated. Negative for overlap.
    separation: f32 = 0,
    /// `SeparatingFeature`.
    type: SeparatingFeature = .invalid,
    /// Index of the feature on shape A.
    indexA: u8 = 0,
    /// Index of the feature on shape B.
    indexB: u8 = 0,
    /// Was the cache re-used?
    hit: u8 = 0,
};

/// Contact points are always the result of two edges intersecting.
/// It can be two edges of the same shape, which is just a shape vertex.
/// Or a contact point can be the result of two edges crossing from different shapes.
/// This is designed to support hull versus hull, but it is adapted to work
/// with all shape types. The feature pair is used to identify contact points
/// for temporal coherence and warm starting.
pub const FeaturePair = extern struct {
    /// Incoming type (either edge on shape A or shape B)
    owner1: u8,
    /// Incoming edge index (into associated shape array)
    index1: u8,
    /// Outgoing type (either edge on shape A or shape B)
    owner2: u8,
    /// Outgoing edge index (into associated shape array)
    index2: u8,
};

/// A local manifold point and normal in frame A.
pub const LocalManifoldPoint = extern struct {
    /// Local point in frame A.
    point: Vec3,
    /// The contact point separation. Negative for overlap.
    separation: f32,
    /// The feature pair for this point.
    pair: FeaturePair,
    /// The triangle index when collide with a mesh or height-field.
    triangleIndex: c_int,
};

/// A local manifold with no dynamic information. Used by the `collide*` functions.
pub const LocalManifold = extern struct {
    /// Local normal in frame A.
    normal: Vec3,
    /// The triangle normal.
    triangleNormal: Vec3,
    /// The manifold points. From a point buffer.
    points: ?[*]LocalManifoldPoint,
    /// The number of manifold points. Only bounded by the buffer capacity.
    pointCount: c_int,
    /// The index of the triangle.
    triangleIndex: c_int,
    /// Vertex 1 index.
    i1: c_int,
    /// Vertex 2 index.
    i2: c_int,
    /// Vertex 3 index.
    i3: c_int,
    /// The squared distance of a sphere from a triangle. For ghost collision reduction.
    squaredDistance: f32,
    /// The triangle feature involved.
    feature: TriangleFeature,
    /// `MeshEdgeFlags`.
    triangleFlags: c_int,
};

/// Collide two spheres.
pub const collideSpheres = b3CollideSpheres;
extern fn b3CollideSpheres(manifold: *LocalManifold, capacity: c_int, sphereA: *const Sphere, sphereB: *const Sphere, transformBtoA: Transform) void;

/// Collide a capsule and a sphere.
pub const collideCapsuleAndSphere = b3CollideCapsuleAndSphere;
extern fn b3CollideCapsuleAndSphere(manifold: *LocalManifold, capacity: c_int, capsuleA: *const Capsule, sphereB: *const Sphere, transformBtoA: Transform) void;

/// Collide a hull and a sphere.
pub const collideHullAndSphere = b3CollideHullAndSphere;
extern fn b3CollideHullAndSphere(manifold: *LocalManifold, capacity: c_int, hullA: *const HullData, sphereB: *const Sphere, transformBtoA: Transform, cache: *SimplexCache) void;

/// Collide two capsules.
pub const collideCapsules = b3CollideCapsules;
extern fn b3CollideCapsules(manifold: *LocalManifold, capacity: c_int, capsuleA: *const Capsule, capsuleB: *const Capsule, transformBtoA: Transform) void;

/// Collide a hull and a capsule.
pub const collideHullAndCapsule = b3CollideHullAndCapsule;
extern fn b3CollideHullAndCapsule(manifold: *LocalManifold, capacity: c_int, hullA: *const HullData, capsuleB: *const Capsule, transformBtoA: Transform, cache: *SimplexCache) void;

/// Collide two hulls.
pub const collideHulls = b3CollideHulls;
extern fn b3CollideHulls(manifold: *LocalManifold, capacity: c_int, hullA: *const HullData, hullB: *const HullData, transformBtoA: Transform, cache: *SATCache) void;

/// Collide a triangle and capsule. Normal points from triangle to capsule.
pub const collideTriangleAndCapsule = b3CollideTriangleAndCapsule;
extern fn b3CollideTriangleAndCapsule(manifold: *LocalManifold, capacity: c_int, triangleA: *const [3]Vec3, capsuleB: *const Capsule, cache: *SimplexCache) void;

/// Collide a triangle and hull. Normal points from triangle to hull.
pub const collideTriangleAndHull = b3CollideTriangleAndHull;
extern fn b3CollideTriangleAndHull(manifold: *LocalManifold, capacity: c_int, v1: Vec3, v2: Vec3, v3: Vec3, triangleFlags: c_int, hullB: *const HullData, cache: *SATCache, enableSpeculative: bool) void;

/// Collide a triangle and sphere. Normal points from triangle to sphere.
pub const collideTriangleAndSphere = b3CollideTriangleAndSphere;
extern fn b3CollideTriangleAndSphere(manifold: *LocalManifold, capacity: c_int, triangleA: *const [3]Vec3, sphereB: *const Sphere) void;

/// This is used for computing 2D hulls in service of contact manifold simplification.
/// Placed here for testing. Internal.
pub const Point2D = extern struct {
    /// 2D point
    p: Vec2,
    /// separation of the associated contact point
    separation: f32,
    /// original index of the associated contact point
    originalIndex: c_int,
};

/// Compute a 2D hull. Used internally for contact manifold simplification. Here for testing.
pub fn hull2D(points: []Point2D, hull: []Point2D) []Point2D {
    std.debug.assert(hull.len >= points.len);
    return hull[0..@intCast(b3Hull2D(points.ptr, @intCast(points.len), hull.ptr))];
}
extern fn b3Hull2D(pts: [*]Point2D, count: c_int, hull: [*]Point2D) c_int;

/// Simplify a 2D hull. Used internally for contact manifold simplification. Here for testing.
pub fn simplifyHull2D(hull: []Point2D, target: c_int) []Point2D {
    return hull[0..@intCast(b3SimplifyHull2D(hull.ptr, @intCast(hull.len), target))];
}
extern fn b3SimplifyHull2D(hull: [*]Point2D, count: c_int, target: c_int) c_int;
