//! Queries: ray casts, shape casts, distance and time of impact (types.h, collision.h)

const std = @import("std");

const b3 = @import("../box3d.zig");
const AABB = b3.AABB;
const Pos = b3.Pos;
const Quat = b3.Quat;
const Shape = b3.Shape;
const Transform = b3.Transform;
const Vec3 = b3.Vec3;

/// The query filter is used to filter collisions between queries and shapes. For example,
/// you may want a ray-cast representing a projectile to hit players and the static environment
/// but not debris.
pub const QueryFilter = extern struct {
    /// The collision category bits of this query. Normally you would just set one bit.
    categoryBits: u64,
    /// The collision mask bits. This states the shape categories that this
    /// query would accept for collision.
    maskBits: u64,
    /// Optional id combined with name to identify this query in a recording, e.g. an entity id.
    /// Need not be unique on its own. 0 with a null name means untagged. Ignored when not recording.
    id: u64,
    /// Optional label combined with id to identify this query, e.g. "bullet". Need not be unique
    /// on its own. The recorder hashes (id, name) into one stable key the viewer tracks the query by,
    /// so the same id and name pair identifies the same query across frames. null means none. Ignored
    /// when not recording.
    name: ?[*:0]const u8,

    /// Use this to initialize your query filter
    pub const default = b3DefaultQueryFilter;
    extern fn b3DefaultQueryFilter() QueryFilter;
};

/// Use this to initialize your query filter
pub const defaultQueryFilter = QueryFilter.default;

/// Low level ray cast input data.
pub const RayCastInput = extern struct {
    /// Start point of the ray cast.
    origin: Vec3,
    /// Translation of the ray cast.
    /// end = start + translation.
    translation: Vec3,
    /// The maximum fraction of the translation to consider, typically 1
    maxFraction: f32,

    /// Use this to ensure your ray cast input is valid and avoid internal assertions.
    pub const isValid = b3IsValidRay;
    extern fn b3IsValidRay(input: *const RayCastInput) bool;
};

/// Result from `World.castRayClosest`.
pub const RayResult = extern struct {
    /// The shape hit.
    shapeId: Shape,
    /// The world point of the hit.
    point: Pos,
    /// The world normal of the shape surface at the hit point.
    normal: Vec3,
    /// The user material id at the hit point. This can be per triangle
    /// if the shape is a mesh, height-field, or compound with child mesh.
    userMaterialId: u64,
    /// The fraction of the input ray.
    fraction: f32,
    /// The triangle index if the shape is a mesh, height-field, or compound with
    /// child mesh.
    triangleIndex: c_int,
    /// The child index if the shape is a compound.
    childIndex: c_int,
    /// The number of BVH nodes visited. Diagnostic.
    nodeVisits: c_int,
    /// The number of BVH leaves visited. Diagnostic.
    leafVisits: c_int,
    /// Did the ray hit? If false, all other data is invalid.
    hit: bool,
};

/// A shape proxy is used by the GJK algorithm. It can represent a convex shape.
pub const ShapeProxy = extern struct {
    /// The point cloud.
    points: [*]const Vec3,
    /// The number of points. Do not exceed `max_shape_cast_points`.
    count: c_int,
    /// The external radius of the point cloud.
    radius: f32,

    /// Make a shape proxy from a point cloud and radius. `points.len` must not exceed `max_shape_cast_points`.
    pub fn init(points: []const Vec3, radius: f32) ShapeProxy {
        std.debug.assert(points.len <= b3.max_shape_cast_points);
        return .{ .points = points.ptr, .count = @intCast(points.len), .radius = radius };
    }
};

/// Low level shape cast input in generic form. This allows casting an arbitrary point
/// cloud wrap with a radius. For example, a sphere is a single point with a non-zero radius.
/// A capsule is two points with a non-zero radius. A box is four points with a zero radius.
pub const ShapeCastInput = extern struct {
    /// A generic query shape.
    proxy: ShapeProxy,
    /// The translation of the shape cast.
    translation: Vec3,
    /// The maximum fraction of the translation to consider, typically 1.
    maxFraction: f32,
    /// Allow shape cast to encroach when initially touching. This only works if the radius is greater than zero.
    canEncroach: bool,
};

/// Input for sweeping an AABB through a dynamic tree. The box is in the tree's world float frame.
/// The caller folds the cast shape radius and any world origin into the box, so the tree traversal
/// stays a conservative box sweep and the precise narrow phase happens per shape in the callback.
pub const BoxCastInput = extern struct {
    /// The AABB to cast, in the tree's frame.
    box: AABB,
    /// The sweep translation.
    translation: Vec3,
    /// The maximum fraction of the translation to consider, typically 1.
    maxFraction: f32,
};

/// Low level ray cast or shape-cast output data.
pub const CastOutput = extern struct {
    /// The surface normal at the hit point.
    normal: Vec3,
    /// The surface hit point.
    point: Vec3,
    /// The fraction of the input translation at collision.
    fraction: f32,
    /// The number of iterations used.
    iterations: c_int,
    /// The index of the mesh or height field triangle hit.
    triangleIndex: c_int,
    /// The index of the compound child shape.
    childIndex: c_int,
    /// The material index. May be -1 for null.
    materialIndex: c_int,
    /// Did the cast hit?
    hit: bool,
};

/// Body cast result for ray and shape casts.
pub const BodyCastResult = extern struct {
    /// The shape hit.
    shapeId: Shape,
    /// The world point on the shape surface.
    point: Pos,
    /// The world normal vector on the shape surface.
    normal: Vec3,
    /// The fraction along the ray hit.
    /// hit point = origin + fraction * translation
    fraction: f32,
    /// The triangle index if the shape is a mesh or height-field.
    triangleIndex: c_int,
    /// The user material id at the hit point. This can be per triangle
    /// if the shape is a mesh, height-field, or compound with child mesh.
    userMaterialId: u64,
    /// The number of iterations used. Diagnostic.
    iterations: c_int,
    /// Did the cast hit? If false, all other fields are invalid.
    hit: bool,
};

/// Used to warm start the GJK simplex. If you call this function multiple times with nearby
/// transforms this might improve performance. Otherwise you can zero initialize this.
/// The distance cache must be initialized to zero on the first call.
/// Users should generally just zero initialize this structure for each call.
pub const SimplexCache = extern struct {
    /// Value use to compare length, area, volume of two simplexes.
    metric: f32 = 0,
    /// The number of stored simplex points
    count: u16 = 0,
    /// The cached simplex indices on shape A
    indexA: [4]u8 = @splat(0),
    /// The cached simplex indices on shape B
    indexB: [4]u8 = @splat(0),

    /// An empty cache, the same as zero initialization.
    pub const empty: SimplexCache = .{};
};

/// Input parameters for `shapeCast`
pub const ShapeCastPairInput = extern struct {
    /// The proxy for shape A
    proxyA: ShapeProxy,
    /// The proxy for shape B
    proxyB: ShapeProxy,
    /// Transform of shape B in shape A's frame, the relative pose B in A
    transform: Transform,
    /// The translation of shape B, in A's frame
    translationB: Vec3,
    /// The fraction of the translation to consider, typically 1
    maxFraction: f32,
    /// Allows shapes with a radius to move slightly closer if already touching
    canEncroach: bool,
};

/// Input for `shapeDistance`
pub const DistanceInput = extern struct {
    /// The proxy for shape A
    proxyA: ShapeProxy,
    /// The proxy for shape B
    proxyB: ShapeProxy,
    /// Transform of shape B in shape A's frame, the relative pose B in A
    /// (`invMulWorldTransforms`( worldA, worldB )). The query is origin independent and runs in frame A.
    transform: Transform,
    /// Should the proxy radius be considered?
    useRadii: bool,
};

/// Output for `shapeDistance`
pub const DistanceOutput = extern struct {
    /// Closest point on shapeA, in shape A's frame
    pointA: Vec3,
    /// Closest point on shapeB, in shape A's frame
    pointB: Vec3,
    /// A to B normal in shape A's frame. Invalid if distance is zero.
    normal: Vec3,
    /// The final distance, zero if overlapped
    distance: f32,
    /// Number of GJK iterations used
    iterations: c_int,
    /// The number of simplexes stored in the simplex array
    simplexCount: c_int,
};

/// Simplex vertex for debugging the GJK algorithm
pub const SimplexVertex = extern struct {
    /// support point in proxyA
    wA: Vec3,
    /// support point in proxyB
    wB: Vec3,
    /// wB - wA
    w: Vec3,
    /// barycentric coordinates
    a: f32,
    /// wA index
    indexA: c_int,
    /// wB index
    indexB: c_int,
};

/// Simplex from the GJK algorithm
pub const Simplex = extern struct {
    /// vertices
    vertices: [4]SimplexVertex,
    /// number of valid vertices
    count: c_int,
};

/// This describes the motion of a body/shape for TOI computation. Shapes are defined with respect to the body origin,
/// which may not coincide with the center of mass. However, to support dynamics we must interpolate the center of mass
/// position.
pub const Sweep = extern struct {
    /// Local center of mass position
    localCenter: Vec3,
    /// Starting center of mass world position
    c1: Vec3,
    /// Ending center of mass world position
    c2: Vec3,
    /// Starting world rotation
    q1: Quat,
    /// Ending world rotation
    q2: Quat,

    /// Evaluate the transform sweep at a specific time.
    pub const getTransform = b3GetSweepTransform;
    extern fn b3GetSweepTransform(sweep: *const Sweep, time: f32) Transform;
};

/// Time of impact input
pub const TOIInput = extern struct {
    /// The proxy for shape A
    proxyA: ShapeProxy,
    /// The proxy for shape B
    proxyB: ShapeProxy,
    /// The movement of shape A
    sweepA: Sweep,
    /// The movement of shape B
    sweepB: Sweep,
    /// Defines the sweep interval [0, tMax]
    maxFraction: f32,
};

/// Describes the TOI output
pub const TOIState = enum(c_int) {
    unknown,
    failed,
    overlapped,
    hit,
    separated,
};

/// Time of impact output.
pub const TOIOutput = extern struct {
    /// The type of result.
    state: TOIState,
    /// The hit point. A shared point if overlapped.
    point: Vec3,
    /// The hit normal. Zero if overlapped.
    normal: Vec3,
    /// The sweep time of the collision. 0 if overlapped.
    fraction: f32,
    /// The final distance. 0 if overlapped.
    distance: f32,
    /// Number of outer iterations.
    distanceIterations: c_int,
    /// Total number of push back iterations.
    pushBackIterations: c_int,
    /// Total number of root iterations.
    rootIterations: c_int,
    /// Indicates that the time of impact detected initial
    /// overlap and used a fallback sphere as a last ditch effort
    /// to prevent tunneling.
    usedFallback: bool,
};

/// Query callback.
pub const MeshQueryFcn = *const fn (a: Vec3, b: Vec3, c: Vec3, triangleIndex: c_int, context: ?*anyopaque) callconv(.c) bool;

/// Compute the closest points between two shapes represented as point clouds.
/// `SimplexCache` cache is input/output. On the first call set `SimplexCache.count` to zero.
/// The query runs in frame A, so the witness points and normal are returned in frame A.
/// The underlying GJK algorithm may be debugged by passing in debug simplexes and capacity. You may pass in null and 0 for these.
pub fn shapeDistance(input: *const DistanceInput, cache: *SimplexCache, simplexes: []Simplex) DistanceOutput {
    return b3ShapeDistance(input, cache, simplexes.ptr, @intCast(simplexes.len));
}
extern fn b3ShapeDistance(input: *const DistanceInput, cache: *SimplexCache, simplexes: ?[*]Simplex, simplexCapacity: c_int) DistanceOutput;

/// Perform a linear shape cast of shape B moving and shape A fixed. Determines the hit point, normal, and translation fraction.
/// The query runs in frame A, so the hit point and normal are returned in frame A. Initially touching shapes are a miss.
pub const shapeCast = b3ShapeCast;
extern fn b3ShapeCast(input: *const ShapeCastPairInput) CastOutput;

/// Compute the upper bound on time before two shapes penetrate. Time is represented as
/// a fraction between [0,tMax]. This uses a swept separating axis and may miss some intermediate,
/// non-tunneling collisions. If you change the time interval, you should call this function
/// again.
pub const timeOfImpact = b3TimeOfImpact;
extern fn b3TimeOfImpact(input: *const TOIInput) TOIOutput;

/// Ray cast or shape-cast output in world space. In large world mode the hit point is a
/// world position so the result stays precise far from the world origin. In single precision
/// mode this is the same type as `CastOutput`.
pub const WorldCastOutput = if (b3.double_precision) extern struct {
    /// The surface normal at the hit point.
    normal: Vec3,
    /// The surface hit point in world space.
    point: Pos,
    /// The fraction of the input translation at collision.
    fraction: f32,
    /// The number of iterations used.
    iterations: c_int,
    /// The index of the mesh or height field triangle hit.
    triangleIndex: c_int,
    /// The index of the compound child shape.
    childIndex: c_int,
    /// The material index. May be -1 for null.
    materialIndex: c_int,
    /// Did the cast hit?
    hit: bool,
} else CastOutput;
