//! Vector math types and functions (math_functions.h)
//!
//! The inline functions from the C header are implemented here in Zig. They are available
//! both as free functions (`b3.add(a, b)`) and as methods (`a.add(b)`).

const std = @import("std");

const b3 = @import("../box3d.zig");

const flt_min = std.math.floatMin(f32);
const flt_epsilon = std.math.floatEps(f32);

/// https://en.wikipedia.org/wiki/Pi
pub const pi: f32 = 3.14159265359;

/// Convenience constant to convert from degrees to radians.
pub const deg_to_rad: f32 = 0.01745329251;

/// Convenience constant to convert from radians to degrees.
pub const rad_to_deg: f32 = 57.2957795131;

/// Minimum scale used for scaling collision meshes, etc.
pub const min_scale: f32 = 0.01;

/// A 2D vector.
pub const Vec2 = extern struct {
    x: f32,
    y: f32,
};

/// A 3D vector.
pub const Vec3 = extern struct {
    x: f32,
    y: f32,
    z: f32,

    pub const zero: Vec3 = .{ .x = 0, .y = 0, .z = 0 };
    pub const one: Vec3 = .{ .x = 1, .y = 1, .z = 1 };
    pub const axis_x: Vec3 = .{ .x = 1, .y = 0, .z = 0 };
    pub const axis_y: Vec3 = .{ .x = 0, .y = 1, .z = 0 };
    pub const axis_z: Vec3 = .{ .x = 0, .y = 0, .z = 1 };

    /// Make a vector from its components.
    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return .{ .x = x, .y = y, .z = z };
    }

    /// Make a vector with all components set to `s`.
    pub fn splat(s: f32) Vec3 {
        return .{ .x = s, .y = s, .z = s };
    }

    pub const add = b3.add;
    pub const sub = b3.sub;
    pub const mul = b3.mul;
    pub const neg = b3.neg;
    pub const dot = b3.dot;
    pub const length = b3.length;
    pub const lengthSquared = b3.lengthSquared;
    pub const distance = b3.distance;
    pub const distanceSquared = b3.distanceSquared;
    pub const normalize = b3.normalize;
    pub const getLengthAndNormalize = b3.getLengthAndNormalize;
    pub const perp = b3.perp;
    pub const isNormalized = b3.isNormalized;
    pub const mulAdd = b3.mulAdd;
    pub const mulSub = b3.mulSub;
    /// s * a
    pub fn scale(a: Vec3, s: f32) Vec3 {
        return mulSV(s, a);
    }
    pub const cross = b3.cross;
    pub const lerp = b3.lerp;
    pub const abs = b3.abs;
    pub const sign = b3.sign;
    pub const min = b3.min;
    pub const max = b3.max;
    pub const clamp = b3.clamp;
    pub const safeScale = b3.safeScale;
    pub const isValid = b3.isValidVec3;
};

/// Cosine and sine pair.
/// This uses a custom implementation designed for cross-platform determinism.
pub const CosSin = extern struct {
    /// cosine and sine
    cosine: f32,
    sine: f32,
};

/// A quaternion.
pub const Quat = extern struct {
    v: Vec3,
    s: f32,

    pub const identity: Quat = .{ .v = .zero, .s = 1 };

    pub const isNormalized = b3.isNormalizedQuat;
    pub const rotate = b3.rotateVector;
    pub const invRotate = b3.invRotateVector;
    pub const dot = b3.dotQuat;
    pub const mul = b3.mulQuat;
    pub const invMul = b3.invMulQuat;
    pub const conjugate = b3.conjugate;
    pub const negate = b3.negateQuat;
    pub const normalize = b3.normalizeQuat;
    pub const fromAxisAngle = b3.makeQuatFromAxisAngle;
    pub const getAxisAngle = b3.getAxisAngle;
    pub const getAngle = b3.getQuatAngle;
    pub const fromMatrix = b3.makeQuatFromMatrix;
    pub const between = b3.computeQuatBetweenUnitVectors;
    pub const getTwistAngle = b3.getTwistAngle;
    pub const getSwingAngle = b3.getSwingAngle;
    pub const nlerp = b3.nLerp;
    pub const toMatrix = b3.makeMatrixFromQuat;
    pub const isValid = b3.isValidQuat;
};

/// A rigid transform.
pub const Transform = extern struct {
    p: Vec3,
    q: Quat,

    pub const identity: Transform = .{ .p = .zero, .q = .identity };

    pub const mul = b3.mulTransforms;
    pub const invMul = b3.invMulTransforms;
    pub const invert = b3.invertTransform;
    pub const transformPoint = b3.transformPoint;
    pub const invTransformPoint = b3.invTransformPoint;
    pub const isValid = b3.isValidTransform;
};

/// A world position. Double precision in large world mode (`double_precision`) so coordinates
/// stay accurate far from the origin. In single precision mode this is the same type as `Vec3`.
pub const Pos = if (b3.double_precision) extern struct {
    x: f64,
    y: f64,
    z: f64,

    pub const zero: Pos = .{ .x = 0, .y = 0, .z = 0 };

    /// Make a position from its components.
    pub fn init(x: f64, y: f64, z: f64) Pos {
        return .{ .x = x, .y = y, .z = z };
    }

    pub const isValid = b3.isValidPosition;
} else Vec3;

/// A world transform with double precision translation and float quaternion rotation in large
/// world mode. In single precision mode this is the same type as `Transform`.
pub const WorldTransform = if (b3.double_precision) extern struct {
    p: Pos,
    q: Quat,

    pub const identity: WorldTransform = .{ .p = .zero, .q = .identity };

    pub const isValid = b3.isValidWorldTransform;
} else Transform;

/// A 3x3 matrix.
pub const Matrix3 = extern struct {
    cx: Vec3,
    cy: Vec3,
    cz: Vec3,

    pub const zero: Matrix3 = .{ .cx = .zero, .cy = .zero, .cz = .zero };
    pub const identity: Matrix3 = .{ .cx = .axis_x, .cy = .axis_y, .cz = .axis_z };

    pub const det = b3.det;
    pub const mulV = b3.mulMV;
    pub const negate = b3.negateMat3;
    pub const add = b3.addMM;
    pub const sub = b3.subMM;
    /// s * m, component-wise.
    pub fn scale(m: Matrix3, s: f32) Matrix3 {
        return mulSM(s, m);
    }
    pub const mul = b3.mulMM;
    pub const transpose = b3.transpose;
    pub const invert = b3.invertMatrix;
    pub const solve = b3.solve3;
    pub const invertT = b3.invertT;
    pub const abs = b3.absMatrix3;
    pub const fromQuat = b3.makeMatrixFromQuat;
    pub const isValid = b3.isValidMatrix3;
};

/// Axis aligned bounding box.
pub const AABB = extern struct {
    lowerBound: Vec3,
    upperBound: Vec3,

    pub const contains = b3.aabbContains;
    pub const area = b3.aabbArea;
    pub const center = b3.aabbCenter;
    pub const extents = b3.aabbExtents;
    pub const @"union" = b3.aabbUnion;
    pub const inflate = b3.aabbInflate;
    pub const overlaps = b3.aabbOverlaps;
    /// Transform an axis-aligned bounding box. See `aabbTransform`.
    pub fn transform(a: AABB, t: Transform) AABB {
        return aabbTransform(t, a);
    }
    /// Get the closest point on an axis-aligned bounding box.
    pub fn closestPoint(a: AABB, point: Vec3) Vec3 {
        return closestPointToAABB(point, a);
    }
    /// Translate by a world position, rounding outward. See `offsetAABB`.
    pub const offset = b3.offsetAABB;
    pub const isValid = b3.isValidAABB;
    pub const isBounded = b3.isBoundedAABB;
    pub const isSane = b3.isSaneAABB;
};

/// A plane.
/// separation = dot(normal, point) - offset
pub const Plane = extern struct {
    normal: Vec3,
    offset: f32,

    pub const isValid = b3.isValidPlane;
};

/// Returns the minimum of two integers.
pub fn minInt(a: c_int, b: c_int) c_int {
    return if (a < b) a else b;
}

/// Returns the maximum of two integers.
pub fn maxInt(a: c_int, b: c_int) c_int {
    return if (a > b) a else b;
}

/// Returns an integer clamped between a lower and upper bound.
pub fn clampInt(a: c_int, lower: c_int, upper: c_int) c_int {
    return if (a < lower) lower else if (upper < a) upper else a;
}

/// Returns the absolute value of a float.
pub fn absFloat(a: f32) f32 {
    return if (a < 0) -a else a;
}

/// Returns the minimum of two floats.
pub fn minFloat(a: f32, b: f32) f32 {
    return if (a < b) a else b;
}

/// Returns the maximum of two floats.
pub fn maxFloat(a: f32, b: f32) f32 {
    return if (a > b) a else b;
}

/// Returns a float clamped between a lower and upper bound.
pub fn clampFloat(a: f32, lower: f32, upper: f32) f32 {
    return if (a < lower) lower else if (upper < a) upper else a;
}

/// Interpolate a scalar.
pub fn lerpFloat(a: f32, b: f32, alpha: f32) f32 {
    return (1 - alpha) * a + alpha * b;
}

/// Compute an approximate arctangent in the range [-pi, pi]
/// This is hand coded for cross-platform determinism. The atan2f
/// function in the standard library is not cross-platform deterministic.
/// Accurate to around 0.0023 degrees.
pub const atan2 = b3Atan2;
extern fn b3Atan2(y: f32, x: f32) f32;

/// Compute the cosine and sine of an angle in radians. Implemented
/// for cross-platform determinism.
pub const computeCosSin = b3ComputeCosSin;
extern fn b3ComputeCosSin(radians: f32) CosSin;

/// Convert any angle into the range [-pi, pi].
pub fn unwindAngle(radians: f32) f32 {
    return remainderf(radians, 2 * pi);
}
extern fn remainderf(x: f32, y: f32) f32;

/// Vector addition.
pub fn add(a: Vec3, b: Vec3) Vec3 {
    return .{ .x = a.x + b.x, .y = a.y + b.y, .z = a.z + b.z };
}

/// Vector subtraction.
pub fn sub(a: Vec3, b: Vec3) Vec3 {
    return .{ .x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z };
}

/// Vector component-wise multiplication.
pub fn mul(a: Vec3, b: Vec3) Vec3 {
    return .{ .x = a.x * b.x, .y = a.y * b.y, .z = a.z * b.z };
}

/// Vector negation.
pub fn neg(a: Vec3) Vec3 {
    return .{ .x = -a.x, .y = -a.y, .z = -a.z };
}

/// Vector dot product.
pub fn dot(a: Vec3, b: Vec3) f32 {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

/// Vector length.
pub fn length(v: Vec3) f32 {
    return @sqrt(dot(v, v));
}

/// Vector length squared.
pub fn lengthSquared(a: Vec3) f32 {
    return a.x * a.x + a.y * a.y + a.z * a.z;
}

/// Distance between two points.
pub fn distance(a: Vec3, b: Vec3) f32 {
    return length(.{ .x = b.x - a.x, .y = b.y - a.y, .z = b.z - a.z });
}

/// Squared distance between two points.
pub fn distanceSquared(a: Vec3, b: Vec3) f32 {
    const dv: Vec3 = .{ .x = b.x - a.x, .y = b.y - a.y, .z = b.z - a.z };
    return dv.x * dv.x + dv.y * dv.y + dv.z * dv.z;
}

/// Normalize a vector. Returns a zero vector if the input vector is very small.
pub fn normalize(a: Vec3) Vec3 {
    const length_squared = a.x * a.x + a.y * a.y + a.z * a.z;
    if (length_squared > 1000 * flt_min) {
        const s = 1 / @sqrt(length_squared);
        return .{ .x = s * a.x, .y = s * a.y, .z = s * a.z };
    }
    return .zero;
}

/// A unit vector and the length of the vector it came from.
pub const LengthAndNormal = struct {
    length: f32,
    normal: Vec3,
};

/// Normalize a vector and return the length. Returns a zero vector
/// if the input is very small.
pub fn getLengthAndNormalize(a: Vec3) LengthAndNormal {
    const length_squared = a.x * a.x + a.y * a.y + a.z * a.z;
    if (length_squared > 1000 * flt_min) {
        const len = @sqrt(length_squared);
        const s = 1 / len;
        return .{ .length = len, .normal = .{ .x = s * a.x, .y = s * a.y, .z = s * a.z } };
    }
    return .{ .length = 0, .normal = .zero };
}

/// Get a unit vector that is perpendicular to the supplied vector.
pub fn perp(a: Vec3) Vec3 {
    // Suppose vector a has all equal components and is a unit vector: a = (s, s, s)
    // Then 3*s*s = 1, s = sqrt(1/3) = 0.57735. This means that at least one component
    // of a unit vector must be greater or equal to 0.57735.
    const p: Vec3 = if (a.x < -0.5 or 0.5 < a.x)
        .{ .x = a.y, .y = -a.x, .z = 0 }
    else
        .{ .x = 0, .y = a.z, .z = -a.y };
    return normalize(p);
}

/// Is a vector normalized? In other words, does it have unit length?
pub fn isNormalized(a: Vec3) bool {
    const aa = dot(a, a);
    return absFloat(1 - aa) < 100 * flt_epsilon;
}

/// a + s * b
pub fn mulAdd(a: Vec3, s: f32, b: Vec3) Vec3 {
    return .{ .x = a.x + s * b.x, .y = a.y + s * b.y, .z = a.z + s * b.z };
}

/// a - s * b
pub fn mulSub(a: Vec3, s: f32, b: Vec3) Vec3 {
    return .{ .x = a.x - s * b.x, .y = a.y - s * b.y, .z = a.z - s * b.z };
}

/// s * a
pub fn mulSV(s: f32, a: Vec3) Vec3 {
    return .{ .x = s * a.x, .y = s * a.y, .z = s * a.z };
}

/// https://en.wikipedia.org/wiki/Cross_product
pub fn cross(a: Vec3, b: Vec3) Vec3 {
    return .{
        .x = a.y * b.z - a.z * b.y,
        .y = a.z * b.x - a.x * b.z,
        .z = a.x * b.y - a.y * b.x,
    };
}

/// Linearly interpolate between two vectors.
pub fn lerp(a: Vec3, b: Vec3, alpha: f32) Vec3 {
    std.debug.assert(0 <= alpha and alpha <= 1);
    return .{
        .x = (1 - alpha) * a.x + alpha * b.x,
        .y = (1 - alpha) * a.y + alpha * b.y,
        .z = (1 - alpha) * a.z + alpha * b.z,
    };
}

/// Blend two vectors: s * a + t * b
pub fn blend2(s: f32, a: Vec3, t: f32, b: Vec3) Vec3 {
    return .{
        .x = s * a.x + t * b.x,
        .y = s * a.y + t * b.y,
        .z = s * a.z + t * b.z,
    };
}

/// Component-wise absolute value.
pub fn abs(a: Vec3) Vec3 {
    return .{ .x = absFloat(a.x), .y = absFloat(a.y), .z = absFloat(a.z) };
}

/// Component-wise -1 or 1 (1 if zero).
pub fn sign(a: Vec3) Vec3 {
    return .{
        .x = if (a.x >= 0) 1 else -1,
        .y = if (a.y >= 0) 1 else -1,
        .z = if (a.z >= 0) 1 else -1,
    };
}

/// Component-wise minimum value.
pub fn min(a: Vec3, b: Vec3) Vec3 {
    return .{ .x = minFloat(a.x, b.x), .y = minFloat(a.y, b.y), .z = minFloat(a.z, b.z) };
}

/// Component-wise maximum value.
pub fn max(a: Vec3, b: Vec3) Vec3 {
    return .{ .x = maxFloat(a.x, b.x), .y = maxFloat(a.y, b.y), .z = maxFloat(a.z, b.z) };
}

/// Component-wise clamped value.
pub fn clamp(a: Vec3, lower: Vec3, upper: Vec3) Vec3 {
    return .{
        .x = clampFloat(a.x, lower.x, upper.x),
        .y = clampFloat(a.y, lower.y, upper.y),
        .z = clampFloat(a.z, lower.z, upper.z),
    };
}

/// Create a safe scaling value for scaling collision. This allows
/// negative scale, but keeps scale sufficiently far from zero.
pub fn safeScale(a: Vec3) Vec3 {
    return mul(sign(a), max(abs(a), .splat(min_scale)));
}

/// Does the supplied quaternion have unit length?
pub fn isNormalizedQuat(q: Quat) bool {
    const qq = q.v.x * q.v.x + q.v.y * q.v.y + q.v.z * q.v.z + q.s * q.s;
    return 1 - 20 * flt_epsilon < qq and qq < 1 + 20 * flt_epsilon;
}

/// Rotate a vector.
pub fn rotateVector(q: Quat, v: Vec3) Vec3 {
    // v + 2 * cross(q.v, cross(q.v, v) + q.s * v)
    const t1 = cross(q.v, v);
    const t2 = mulAdd(t1, q.s, v);
    const t3 = cross(q.v, t2);
    return mulAdd(v, 2, t3);
}

/// Inverse rotate a vector.
pub fn invRotateVector(q: Quat, v: Vec3) Vec3 {
    // v + 2 * cross(q.v, cross(q.v, v) - q.s * v)
    const t1 = cross(q.v, v);
    const t2 = mulSub(t1, q.s, v);
    const t3 = cross(q.v, t2);
    return mulAdd(v, 2, t3);
}

/// Compute dot product of two quaternions. Useful for polarity tests.
pub fn dotQuat(a: Quat, b: Quat) f32 {
    return a.v.x * b.v.x + a.v.y * b.v.y + a.v.z * b.v.z + a.s * b.s;
}

/// Multiply two quaternions.
pub fn mulQuat(q1: Quat, q2: Quat) Quat {
    const t1 = cross(q1.v, q2.v);
    const t2 = mulAdd(t1, q1.s, q2.v);
    const t3 = mulAdd(t2, q2.s, q1.v);
    return .{ .v = t3, .s = q1.s * q2.s - dot(q1.v, q2.v) };
}

/// Compute a relative quaternion.
/// inv(q1) * q2
pub fn invMulQuat(q1: Quat, q2: Quat) Quat {
    const t1 = cross(q2.v, q1.v);
    const t2 = mulAdd(t1, q1.s, q2.v);
    const t3 = mulSub(t2, q2.s, q1.v);
    return .{ .v = t3, .s = q1.s * q2.s + dot(q1.v, q2.v) };
}

/// Quaternion conjugate (cheap inverse).
pub fn conjugate(q: Quat) Quat {
    return .{ .v = neg(q.v), .s = q.s };
}

/// Component-wise quaternion negation.
pub fn negateQuat(q: Quat) Quat {
    return .{ .v = neg(q.v), .s = -q.s };
}

/// Normalize a quaternion.
pub fn normalizeQuat(q: Quat) Quat {
    const length_sq = dotQuat(q, q);
    if (length_sq > 1000 * flt_min) {
        const s = 1 / @sqrt(length_sq);
        return .{ .v = mulSV(s, q.v), .s = s * q.s };
    }
    return .identity;
}

/// Make a quaternion that is equivalent to rotating around an axis by a specified angle.
pub fn makeQuatFromAxisAngle(axis: Vec3, radians: f32) Quat {
    std.debug.assert(isNormalized(axis));
    const cs = computeCosSin(0.5 * radians);
    return .{ .v = mulSV(cs.sine, axis), .s = cs.cosine };
}

/// A rotation axis and angle.
pub const AxisAngle = struct {
    axis: Vec3,
    radians: f32,
};

/// Get the axis and angle from a quaternion. Assumes the quaternion is normalized.
pub fn getAxisAngle(q: Quat) AxisAngle {
    const len = @sqrt(q.v.x * q.v.x + q.v.y * q.v.y + q.v.z * q.v.z);
    const radians = 2 * atan2(len, q.s);
    if (len > 0) {
        return .{ .axis = mulSV(1 / len, q.v), .radians = radians };
    }
    return .{ .axis = .zero, .radians = radians };
}

/// Get the angle for a quaternion in radians
pub fn getQuatAngle(q: Quat) f32 {
    const len = @sqrt(q.v.x * q.v.x + q.v.y * q.v.y + q.v.z * q.v.z);
    return 2 * atan2(len, q.s);
}

/// Extract a quaternion from a rotation matrix.
pub const makeQuatFromMatrix = b3MakeQuatFromMatrix;
extern fn b3MakeQuatFromMatrix(m: *const Matrix3) Quat;

/// Find a quaternion that rotates one vector to another.
pub const computeQuatBetweenUnitVectors = b3ComputeQuatBetweenUnitVectors;
extern fn b3ComputeQuatBetweenUnitVectors(v1: Vec3, v2: Vec3) Quat;

/// Twist angle around the z-axis, used for twist limit and revolute angle limit
pub fn getTwistAngle(q: Quat) f32 {
    // Account for polarity to keep the twist angle in range.
    // This is simpler than asking the user to check polarity or unwinding.
    const twist = 2 * (if (q.s < 0) atan2(-q.v.z, -q.s) else atan2(q.v.z, q.s));
    std.debug.assert(-pi <= twist and twist <= pi);
    return twist;
}

/// Swing angle used for cone limit
pub fn getSwingAngle(q: Quat) f32 {
    // Polarity should not matter because all terms are squared.
    const x = @sqrt(q.v.z * q.v.z + q.s * q.s);
    const y = @sqrt(q.v.x * q.v.x + q.v.y * q.v.y);
    const swing = 2 * atan2(y, x);
    std.debug.assert(0 <= swing and swing <= pi);
    return swing;
}

/// Linearly interpolate and normalize between two quaternions
pub fn nLerp(q1: Quat, q2: Quat, alpha: f32) Quat {
    const a = if (dotQuat(q1, q2) < 0) negateQuat(q1) else q1;
    return normalizeQuat(.{
        .v = lerp(a.v, q2.v, alpha),
        .s = (1 - alpha) * a.s + alpha * q2.s,
    });
}

/// Multiply two transforms. If the result is applied to a point p local to frame B,
/// the transform would first convert p to a point local to frame A, then into a point
/// in the world frame. This is useful if frame B is a child of frame A.
pub fn mulTransforms(a: Transform, b: Transform) Transform {
    return .{ .p = add(rotateVector(a.q, b.p), a.p), .q = mulQuat(a.q, b.q) };
}

/// Creates a transform that converts a local point in frame B to a local point in frame A.
/// This is useful for transforming points between the local spaces of two frames that are
/// in world space.
pub fn invMulTransforms(a: Transform, b: Transform) Transform {
    return .{ .p = invRotateVector(a.q, sub(b.p, a.p)), .q = invMulQuat(a.q, b.q) };
}

/// Get the inverse of a transform.
pub fn invertTransform(t: Transform) Transform {
    return .{ .p = invRotateVector(t.q, neg(t.p)), .q = conjugate(t.q) };
}

/// Transform a point.
pub fn transformPoint(t: Transform, v: Vec3) Vec3 {
    return add(rotateVector(t.q, v), t.p);
}

/// Inverse transform a point.
pub fn invTransformPoint(t: Transform, v: Vec3) Vec3 {
    return invRotateVector(t.q, sub(v, t.p));
}

// World position boundary. These cross between the double precision world space at the public
// boundary and the float interior. In single precision mode `Pos` is `Vec3`, so they are no-ops.

/// Convert a vector to a world position.
pub fn toPos(v: Vec3) Pos {
    return .{ .x = v.x, .y = v.y, .z = v.z };
}

/// Lossy conversion of a world position to a float vector.
pub fn toVec3(p: Pos) Vec3 {
    return .{ .x = @floatCast(p.x), .y = @floatCast(p.y), .z = @floatCast(p.z) };
}

/// Narrow a world coordinate to float, rounding toward negative infinity. Use with
/// `roundUpFloat` to build a conservative float box that always contains the double bounds,
/// where plain rounding far from the origin could clip. With large world mode off this is a
/// plain conversion.
pub fn roundDownFloat(x: f64) f32 {
    const f: f32 = @floatCast(x);
    if (!b3.double_precision) return f;
    return if (@as(f64, f) > x) std.math.nextAfter(f32, f, -std.math.floatMax(f32)) else f;
}

/// Narrow a world coordinate to float, rounding toward positive infinity.
pub fn roundUpFloat(x: f64) f32 {
    const f: f32 = @floatCast(x);
    if (!b3.double_precision) return f;
    return if (@as(f64, f) < x) std.math.nextAfter(f32, f, std.math.floatMax(f32)) else f;
}

/// a - b, demoted to float. The primary precision boundary operation.
pub fn subPos(a: Pos, b: Pos) Vec3 {
    return .{ .x = @floatCast(a.x - b.x), .y = @floatCast(a.y - b.y), .z = @floatCast(a.z - b.z) };
}

/// The scalar type of `Pos`: `f64` in large world mode, otherwise `f32`.
pub const PosScalar = if (b3.double_precision) f64 else f32;

/// p + d
pub fn offsetPos(p: Pos, d: Vec3) Pos {
    return .{ .x = p.x + @as(PosScalar, d.x), .y = p.y + @as(PosScalar, d.y), .z = p.z + @as(PosScalar, d.z) };
}

/// World position interpolation for sweeps and sampling.
pub fn lerpPosition(a: Pos, b: Pos, t: f32) Pos {
    const u: PosScalar = t;
    return .{
        .x = (1 - u) * a.x + u * b.x,
        .y = (1 - u) * a.y + u * b.y,
        .z = (1 - u) * a.z + u * b.z,
    };
}

/// Transform a local point to a world position. Rotation in float, translation in double.
pub fn transformWorldPoint(t: WorldTransform, p: Vec3) Pos {
    return offsetPos(t.p, rotateVector(t.q, p));
}

/// Transform a world position to a local point. One double subtraction, then float.
pub fn invTransformWorldPoint(t: WorldTransform, p: Pos) Vec3 {
    return invRotateVector(t.q, subPos(p, t.p));
}

/// Compose a world transform with a local transform.
pub fn mulWorldTransforms(a: WorldTransform, b: Transform) WorldTransform {
    return .{ .p = offsetPos(a.p, rotateVector(a.q, b.p)), .q = mulQuat(a.q, b.q) };
}

/// Relative transform of frame B in frame A. The narrow phase boundary.
pub fn invMulWorldTransforms(a: WorldTransform, b: WorldTransform) Transform {
    return .{ .p = invRotateVector(a.q, subPos(b.p, a.p)), .q = invMulQuat(a.q, b.q) };
}

/// Shift a world transform into the frame of a base position.
pub fn toRelativeTransform(t: WorldTransform, base: Pos) Transform {
    return .{ .p = subPos(t.p, base), .q = t.q };
}

/// Promote a float transform to a world transform. Lossless.
pub fn makeWorldTransform(t: Transform) WorldTransform {
    return .{ .p = toPos(t.p), .q = t.q };
}

/// Translate a local AABB by a world position, rounding outward so the single precision box
/// encloses the double precision box. Far from the origin a plain conversion could clip a
/// shape out of its own box.
/// In single precision mode the rounding is a no-op.
pub fn offsetAABB(local_box: AABB, origin: Pos) AABB {
    const lo = local_box.lowerBound;
    const hi = local_box.upperBound;
    const P = PosScalar;
    return .{
        .lowerBound = .{
            .x = roundDownFloat(origin.x + @as(P, lo.x)),
            .y = roundDownFloat(origin.y + @as(P, lo.y)),
            .z = roundDownFloat(origin.z + @as(P, lo.z)),
        },
        .upperBound = .{
            .x = roundUpFloat(origin.x + @as(P, hi.x)),
            .y = roundUpFloat(origin.y + @as(P, hi.y)),
            .z = roundUpFloat(origin.z + @as(P, hi.z)),
        },
    };
}

/// Compute the determinant of a 3-by-3 matrix.
pub fn det(m: Matrix3) f32 {
    return dot(m.cx, cross(m.cy, m.cz));
}

/// Multiply a matrix times a column vector.
pub fn mulMV(m: Matrix3, a: Vec3) Vec3 {
    return .{
        .x = m.cx.x * a.x + m.cy.x * a.y + m.cz.x * a.z,
        .y = m.cx.y * a.x + m.cy.y * a.y + m.cz.y * a.z,
        .z = m.cx.z * a.x + m.cy.z * a.y + m.cz.z * a.z,
    };
}

/// Negate a matrix.
pub fn negateMat3(a: Matrix3) Matrix3 {
    return .{ .cx = neg(a.cx), .cy = neg(a.cy), .cz = neg(a.cz) };
}

/// Matrix addition.
/// Returns a + b
pub fn addMM(a: Matrix3, b: Matrix3) Matrix3 {
    return .{ .cx = add(a.cx, b.cx), .cy = add(a.cy, b.cy), .cz = add(a.cz, b.cz) };
}

/// Matrix subtraction.
/// Returns a - b
pub fn subMM(a: Matrix3, b: Matrix3) Matrix3 {
    return .{ .cx = sub(a.cx, b.cx), .cy = sub(a.cy, b.cy), .cz = sub(a.cz, b.cz) };
}

/// Multiply a matrix by a scalar, component-wise.
pub fn mulSM(s: f32, a: Matrix3) Matrix3 {
    return .{ .cx = mulSV(s, a.cx), .cy = mulSV(s, a.cy), .cz = mulSV(s, a.cz) };
}

/// Matrix multiplication.
/// Returns a * b
pub fn mulMM(a: Matrix3, b: Matrix3) Matrix3 {
    return .{ .cx = mulMV(a, b.cx), .cy = mulMV(a, b.cy), .cz = mulMV(a, b.cz) };
}

/// Matrix transpose.
pub fn transpose(m: Matrix3) Matrix3 {
    return .{
        .cx = .{ .x = m.cx.x, .y = m.cy.x, .z = m.cz.x },
        .cy = .{ .x = m.cx.y, .y = m.cy.y, .z = m.cz.y },
        .cz = .{ .x = m.cx.z, .y = m.cy.z, .z = m.cz.z },
    };
}

/// General matrix inverse.
pub fn invertMatrix(m: Matrix3) Matrix3 {
    return transpose(invertT(m));
}

/// Solve a matrix equation.
/// Returns inv(m) * a
pub fn solve3(m: Matrix3, a: Vec3) Vec3 {
    const d = det(m);
    if (absFloat(d) > 1000 * flt_min) {
        const inv_det = 1 / d;
        const sx = cross(m.cy, m.cz);
        const sy = cross(m.cz, m.cx);
        const sz = cross(m.cx, m.cy);
        return .{ .x = inv_det * dot(sx, a), .y = inv_det * dot(sy, a), .z = inv_det * dot(sz, a) };
    }
    return .zero;
}

/// Invert a matrix, returning the transpose of the inverse.
pub fn invertT(m: Matrix3) Matrix3 {
    const d = det(m);
    if (absFloat(d) > 1000 * flt_min) {
        const inv_det = 1 / d;
        return .{
            .cx = mulSV(inv_det, cross(m.cy, m.cz)),
            .cy = mulSV(inv_det, cross(m.cz, m.cx)),
            .cz = mulSV(inv_det, cross(m.cx, m.cy)),
        };
    }
    return .zero;
}

/// Get the component-wise absolute value of a matrix.
pub fn absMatrix3(m: Matrix3) Matrix3 {
    return .{ .cx = abs(m.cx), .cy = abs(m.cy), .cz = abs(m.cz) };
}

/// Make a matrix from a quaternion. This is useful if you need to
/// rotate many vectors.
pub fn makeMatrixFromQuat(q: Quat) Matrix3 {
    const xx = q.v.x * q.v.x;
    const yy = q.v.y * q.v.y;
    const zz = q.v.z * q.v.z;
    const xy = q.v.x * q.v.y;
    const xz = q.v.x * q.v.z;
    const xw = q.v.x * q.s;
    const yz = q.v.y * q.v.z;
    const yw = q.v.y * q.s;
    const zw = q.v.z * q.s;
    return .{
        .cx = .{ .x = 1 - 2 * (yy + zz), .y = 2 * (xy + zw), .z = 2 * (xz - yw) },
        .cy = .{ .x = 2 * (xy - zw), .y = 1 - 2 * (xx + zz), .z = 2 * (yz + xw) },
        .cz = .{ .x = 2 * (xz + yw), .y = 2 * (yz - xw), .z = 1 - 2 * (xx + yy) },
    };
}

/// Get the inertia tensor of an offset point.
/// https://en.wikipedia.org/wiki/Parallel_axis_theorem
pub const steiner = b3Steiner;
extern fn b3Steiner(mass: f32, origin: Vec3) Matrix3;

/// Get the AABB of a point cloud. `points` must not be empty.
pub fn makeAABB(points: []const Vec3, radius: f32) AABB {
    std.debug.assert(points.len > 0);
    var a: AABB = .{ .lowerBound = points[0], .upperBound = points[0] };
    for (points[1..]) |p| {
        a.lowerBound = min(a.lowerBound, p);
        a.upperBound = max(a.upperBound, p);
    }
    return aabbInflate(a, radius);
}

/// Does a fully contain b?
pub fn aabbContains(a: AABB, b: AABB) bool {
    if (a.lowerBound.x > b.lowerBound.x or b.upperBound.x > a.upperBound.x) return false;
    if (a.lowerBound.y > b.lowerBound.y or b.upperBound.y > a.upperBound.y) return false;
    if (a.lowerBound.z > b.lowerBound.z or b.upperBound.z > a.upperBound.z) return false;
    return true;
}

/// Get the surface area of an axis-aligned bounding box.
pub fn aabbArea(a: AABB) f32 {
    const delta = sub(a.upperBound, a.lowerBound);
    return 2 * (delta.x * delta.y + delta.y * delta.z + delta.z * delta.x);
}

/// Get the center of an axis-aligned bounding box.
pub fn aabbCenter(a: AABB) Vec3 {
    return mulSV(0.5, add(a.upperBound, a.lowerBound));
}

/// Get the extents (half-widths) of an axis-aligned bounding box.
pub fn aabbExtents(a: AABB) Vec3 {
    return mulSV(0.5, sub(a.upperBound, a.lowerBound));
}

/// Get the union of two axis-aligned bounding boxes.
pub fn aabbUnion(a: AABB, b: AABB) AABB {
    return .{ .lowerBound = min(a.lowerBound, b.lowerBound), .upperBound = max(a.upperBound, b.upperBound) };
}

/// Add uniform padding to an axis-aligned bounding box.
pub fn aabbInflate(a: AABB, extension: f32) AABB {
    const r: Vec3 = .splat(extension);
    return .{ .lowerBound = sub(a.lowerBound, r), .upperBound = add(a.upperBound, r) };
}

/// Do two axis-aligned boxes overlap?
pub fn aabbOverlaps(a: AABB, b: AABB) bool {
    // No intersection if separated along one axis
    if (a.upperBound.x < b.lowerBound.x or a.lowerBound.x > b.upperBound.x) return false;
    if (a.upperBound.y < b.lowerBound.y or a.lowerBound.y > b.upperBound.y) return false;
    if (a.upperBound.z < b.lowerBound.z or a.lowerBound.z > b.upperBound.z) return false;
    // Overlapping on all axis means bounds are intersecting
    return true;
}

/// Transform an axis-aligned bounding box. This can create a larger box
/// than if you recomputed the AABB of the original shape with the transform
/// applied.
pub fn aabbTransform(t: Transform, a: AABB) AABB {
    const c = transformPoint(t, aabbCenter(a));
    const m = makeMatrixFromQuat(t.q);
    const extent = mulMV(absMatrix3(m), aabbExtents(a));
    return .{ .lowerBound = sub(c, extent), .upperBound = add(c, extent) };
}

/// Get the closest point on an axis-aligned bounding box.
pub fn closestPointToAABB(point: Vec3, a: AABB) Vec3 {
    return clamp(point, a.lowerBound, a.upperBound);
}

/// The closest points between to segments or infinite lines.
pub const SegmentDistanceResult = extern struct {
    point1: Vec3,
    fraction1: f32,
    point2: Vec3,
    fraction2: f32,
};

/// Compute the closest point on the segment a-b to the target q.
pub const pointToSegmentDistance = b3PointToSegmentDistance;
extern fn b3PointToSegmentDistance(a: Vec3, b: Vec3, q: Vec3) Vec3;

/// Compute the closest points on two infinite lines.
pub const lineDistance = b3LineDistance;
extern fn b3LineDistance(p1: Vec3, d1: Vec3, p2: Vec3, d2: Vec3) SegmentDistanceResult;

/// Compute the closest points on two line segments.
pub const segmentDistance = b3SegmentDistance;
extern fn b3SegmentDistance(p1: Vec3, q1: Vec3, p2: Vec3, q2: Vec3) SegmentDistanceResult;

/// Is this a valid number? Not NaN or infinity.
pub const isValidFloat = b3IsValidFloat;
extern fn b3IsValidFloat(a: f32) bool;

/// Is this a valid vector? Not NaN or infinity.
pub const isValidVec3 = b3IsValidVec3;
extern fn b3IsValidVec3(a: Vec3) bool;

/// Is this a valid quaternion? Not NaN or infinity. Is normalized.
pub const isValidQuat = b3IsValidQuat;
extern fn b3IsValidQuat(q: Quat) bool;

/// Is this a valid transform? Not NaN or infinity. Is normalized.
pub const isValidTransform = b3IsValidTransform;
extern fn b3IsValidTransform(a: Transform) bool;

/// Is this a valid matrix? Not NaN or infinity.
pub const isValidMatrix3 = b3IsValidMatrix3;
extern fn b3IsValidMatrix3(a: Matrix3) bool;

/// Is this a valid bounding box? Not Nan or infinity. Upper bound greater than or equal to lower bound.
pub const isValidAABB = b3IsValidAABB;
extern fn b3IsValidAABB(a: AABB) bool;

/// Is this AABB reasonably close to the origin? See `huge`.
pub const isBoundedAABB = b3IsBoundedAABB;
extern fn b3IsBoundedAABB(a: AABB) bool;

/// Is this AABB valid and reasonable?
pub const isSaneAABB = b3IsSaneAABB;
extern fn b3IsSaneAABB(a: AABB) bool;

/// Is this a valid plane? Normal is a unit vector. Not Nan or infinity.
pub const isValidPlane = b3IsValidPlane;
extern fn b3IsValidPlane(a: Plane) bool;

/// Is this a valid world position? Not NaN or infinity.
pub const isValidPosition = b3IsValidPosition;
extern fn b3IsValidPosition(p: Pos) bool;

/// Is this a valid world transform? Not NaN or infinity. Rotation is normalized.
pub const isValidWorldTransform = b3IsValidWorldTransform;
extern fn b3IsValidWorldTransform(t: WorldTransform) bool;
