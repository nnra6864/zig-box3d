//! Joints (box3d.h, types.h)

const std = @import("std");

const b3 = @import("../box3d.zig");
const Body = b3.Body;
const Quat = b3.Quat;
const Transform = b3.Transform;
const Vec3 = b3.Vec3;
const World = b3.World;
/// Create a parallel joint
/// See `ParallelJointDef` for details.
pub const createParallelJoint = World.createParallelJoint;
/// Create a distance joint
/// See `DistanceJointDef` for details.
pub const createDistanceJoint = World.createDistanceJoint;
/// Create a motor joint
/// See `MotorJointDef` for details.
pub const createMotorJoint = World.createMotorJoint;
/// Create a filter joint.
/// See `FilterJointDef` for details.
pub const createFilterJoint = World.createFilterJoint;
/// Create a prismatic (slider) joint.
/// See `PrismaticJointDef` for details.
pub const createPrismaticJoint = World.createPrismaticJoint;
/// Create a revolute joint
/// See `RevoluteJointDef` for details.
pub const createRevoluteJoint = World.createRevoluteJoint;
/// Create a spherical joint
/// See `SphericalJointDef` for details.
pub const createSphericalJoint = World.createSphericalJoint;
/// Create a weld joint
/// See `WeldJointDef` for details.
pub const createWeldJoint = World.createWeldJoint;
/// Create a wheel joint.
/// See `WheelJointDef` for details.
pub const createWheelJoint = World.createWheelJoint;

/// Joint id references a joint instance. This should be treated as an opaque handle.
pub const Joint = extern struct {
    index1: i32 = 0,
    world0: u16 = 0,
    generation: u16 = 0,

    /// A null id. Zero initialization also gives a null id.
    pub const null_id: Joint = .{};

    /// Is this id null?
    pub fn isNull(id: Joint) bool {
        return id.index1 == 0;
    }

    /// Is this id non-null?
    pub fn isNonNull(id: Joint) bool {
        return id.index1 != 0;
    }

    /// Compare two ids for equality.
    pub fn eql(a: Joint, b: Joint) bool {
        return a.index1 == b.index1 and a.world0 == b.world0 and a.generation == b.generation;
    }

    /// Store a joint id into a u64.
    pub fn store(id: Joint) u64 {
        return @as(u64, @as(u32, @bitCast(id.index1))) << 32 | @as(u64, id.world0) << 16 | id.generation;
    }

    /// Load a u64 into a joint id.
    pub fn load(x: u64) Joint {
        return .{ .index1 = @bitCast(@as(u32, @truncate(x >> 32))), .world0 = @truncate(x >> 16), .generation = @truncate(x) };
    }

    /// Constraint tuning parameters.
    pub const ConstraintTuning = struct {
        /// The stiffness in Hertz (cycles per second)
        hertz: f32,
        /// The non-dimensional damping ratio (one for critical damping)
        dampingRatio: f32,
    };

    /// Cast to a typed joint handle such as `RevoluteJoint`. Asserts that the joint has that type.
    pub fn as(jointId: Joint, comptime T: type) T {
        std.debug.assert(jointId.getType() == T.joint_type);
        return .{ .joint = jointId };
    }

    /// Destroy a joint
    pub const destroy = b3DestroyJoint;
    extern fn b3DestroyJoint(jointId: Joint, wakeAttached: bool) void;

    /// Joint identifier validation. Provides validation for up to 64K allocations.
    pub const isValid = b3Joint_IsValid;
    extern fn b3Joint_IsValid(id: Joint) bool;

    /// Get the joint type
    pub const getType = b3Joint_GetType;
    extern fn b3Joint_GetType(jointId: Joint) JointType;

    /// Get body A id on a joint
    pub const getBodyA = b3Joint_GetBodyA;
    extern fn b3Joint_GetBodyA(jointId: Joint) Body;

    /// Get body B id on a joint
    pub const getBodyB = b3Joint_GetBodyB;
    extern fn b3Joint_GetBodyB(jointId: Joint) Body;

    /// Get the world that owns this joint
    pub const getWorld = b3Joint_GetWorld;
    extern fn b3Joint_GetWorld(jointId: Joint) World;

    /// Set the local frame on bodyA
    pub const setLocalFrameA = b3Joint_SetLocalFrameA;
    extern fn b3Joint_SetLocalFrameA(jointId: Joint, localFrame: Transform) void;

    /// Get the local frame on bodyA
    pub const getLocalFrameA = b3Joint_GetLocalFrameA;
    extern fn b3Joint_GetLocalFrameA(jointId: Joint) Transform;

    /// Set the local frame on bodyB
    pub const setLocalFrameB = b3Joint_SetLocalFrameB;
    extern fn b3Joint_SetLocalFrameB(jointId: Joint, localFrame: Transform) void;

    /// Get the local frame on bodyB
    pub const getLocalFrameB = b3Joint_GetLocalFrameB;
    extern fn b3Joint_GetLocalFrameB(jointId: Joint) Transform;

    /// Toggle collision between connected bodies
    pub const setCollideConnected = b3Joint_SetCollideConnected;
    extern fn b3Joint_SetCollideConnected(jointId: Joint, shouldCollide: bool) void;

    /// Is collision allowed between connected bodies?
    pub const getCollideConnected = b3Joint_GetCollideConnected;
    extern fn b3Joint_GetCollideConnected(jointId: Joint) bool;

    /// Set the user data on a joint
    pub const setUserData = b3Joint_SetUserData;
    extern fn b3Joint_SetUserData(jointId: Joint, userData: ?*anyopaque) void;

    /// Get the user data on a joint
    pub const getUserData = b3Joint_GetUserData;
    extern fn b3Joint_GetUserData(jointId: Joint) ?*anyopaque;

    /// Wake the bodies connect to this joint
    pub const wakeBodies = b3Joint_WakeBodies;
    extern fn b3Joint_WakeBodies(jointId: Joint) void;

    /// Is the joint awake? If true then an attached body is awake.
    pub const isAwake = b3Joint_IsAwake;
    extern fn b3Joint_IsAwake(jointId: Joint) bool;

    /// Get the current constraint force for this joint
    pub const getConstraintForce = b3Joint_GetConstraintForce;
    extern fn b3Joint_GetConstraintForce(jointId: Joint) Vec3;

    /// Get the current constraint torque for this joint
    pub const getConstraintTorque = b3Joint_GetConstraintTorque;
    extern fn b3Joint_GetConstraintTorque(jointId: Joint) Vec3;

    /// Get the current linear separation error for this joint. Does not consider admissible movement. Usually in meters.
    pub const getLinearSeparation = b3Joint_GetLinearSeparation;
    extern fn b3Joint_GetLinearSeparation(jointId: Joint) f32;

    /// Get the current angular separation error for this joint. Does not consider admissible movement. Usually in radians.
    pub const getAngularSeparation = b3Joint_GetAngularSeparation;
    extern fn b3Joint_GetAngularSeparation(jointId: Joint) f32;

    /// Set the joint constraint tuning. Advanced feature.
    /// - `jointId`: the joint
    /// - `hertz`: the stiffness in Hertz (cycles per second)
    /// - `dampingRatio`: the non-dimensional damping ratio (one for critical damping)
    pub const setConstraintTuning = b3Joint_SetConstraintTuning;
    extern fn b3Joint_SetConstraintTuning(jointId: Joint, hertz: f32, dampingRatio: f32) void;

    /// Get the joint constraint tuning. Advanced feature.
    pub fn getConstraintTuning(jointId: Joint) ConstraintTuning {
        var tuning: ConstraintTuning = undefined;
        b3Joint_GetConstraintTuning(jointId, &tuning.hertz, &tuning.dampingRatio);
        return tuning;
    }
    extern fn b3Joint_GetConstraintTuning(jointId: Joint, hertz: *f32, dampingRatio: *f32) void;

    /// Set the force threshold for joint events (Newtons)
    pub const setForceThreshold = b3Joint_SetForceThreshold;
    extern fn b3Joint_SetForceThreshold(jointId: Joint, threshold: f32) void;

    /// Get the force threshold for joint events (Newtons)
    pub const getForceThreshold = b3Joint_GetForceThreshold;
    extern fn b3Joint_GetForceThreshold(jointId: Joint) f32;

    /// Set the torque threshold for joint events (N-m)
    pub const setTorqueThreshold = b3Joint_SetTorqueThreshold;
    extern fn b3Joint_SetTorqueThreshold(jointId: Joint, threshold: f32) void;

    /// Get the torque threshold for joint events (N-m)
    pub const getTorqueThreshold = b3Joint_GetTorqueThreshold;
    extern fn b3Joint_GetTorqueThreshold(jointId: Joint) f32;
};

/// Joint type enumeration. This is useful because all joint types use `Joint` and sometimes you
/// want to get the type of a joint.
pub const JointType = enum(c_int) {
    parallel,
    distance,
    filter,
    motor,
    prismatic,
    revolute,
    spherical,
    weld,
    wheel,
};

/// Base joint definition used by all joint types. The local frames are measured from the
/// body's origin rather than the center of mass because:
/// 1. You might not know where the center of mass will be.
/// 2. If you add/remove shapes from a body and recompute the mass, the joints will be broken.
pub const JointDef = extern struct {
    /// User data pointer
    userData: ?*anyopaque,
    /// The first attached body
    bodyIdA: Body,
    /// The second attached body
    bodyIdB: Body,
    /// The first local joint frame
    localFrameA: Transform,
    /// The second local joint frame
    localFrameB: Transform,
    /// Force threshold for joint events
    forceThreshold: f32,
    /// Torque threshold for joint events
    torqueThreshold: f32,
    /// Constraint hertz (advanced feature)
    constraintHertz: f32,
    /// Constraint damping ratio (advanced feature)
    constraintDampingRatio: f32,
    /// Debug draw scale
    drawScale: f32,
    /// Set this flag to true if the attached bodies should collide
    collideConnected: bool,
    /// Used internally to detect a valid definition. DO NOT SET.
    internalValue: c_int,
};

/// Distance joint definition.
/// Connects a point on body A with a point on body B by a segment.
/// Useful for ropes and springs.
pub const DistanceJointDef = extern struct {
    /// Base joint definition
    base: JointDef,
    /// The rest length of this joint. Clamped to a stable minimum value.
    length: f32,
    /// Enable the distance constraint to behave like a spring. If false
    /// then the distance joint will be rigid, overriding the limit and motor.
    enableSpring: bool,
    /// The lower spring force controls how much tension it can sustain
    lowerSpringForce: f32,
    /// The upper spring force controls how much compression it can sustain
    upperSpringForce: f32,
    /// The spring linear stiffness Hertz, cycles per second
    hertz: f32,
    /// The spring linear damping ratio, non-dimensional
    dampingRatio: f32,
    /// Enable/disable the joint limit
    enableLimit: bool,
    /// Minimum length. Clamped to a stable minimum value.
    minLength: f32,
    /// Maximum length. Must be greater than or equal to the minimum length.
    maxLength: f32,
    /// Enable/disable the joint motor
    enableMotor: bool,
    /// The maximum motor force, usually in newtons
    maxMotorForce: f32,
    /// The desired motor speed, usually in meters per second
    motorSpeed: f32,

    /// Use this to initialize your joint definition
    pub const default = b3DefaultDistanceJointDef;
    extern fn b3DefaultDistanceJointDef() DistanceJointDef;
};

/// Use this to initialize your joint definition
pub const defaultDistanceJointDef = DistanceJointDef.default;

/// A motor joint is used to control the relative position and velocity between two bodies.
pub const MotorJointDef = extern struct {
    /// Base joint definition
    base: JointDef,
    /// The desired linear velocity
    linearVelocity: Vec3,
    /// The maximum motor force in newtons
    maxVelocityForce: f32,
    /// The desired angular velocity
    angularVelocity: Vec3,
    /// The maximum motor torque in newton-meters
    maxVelocityTorque: f32,
    /// Linear spring hertz for position control
    linearHertz: f32,
    /// Linear spring damping ratio
    linearDampingRatio: f32,
    /// Maximum spring force in newtons
    maxSpringForce: f32,
    /// Angular spring hertz for position control
    angularHertz: f32,
    /// Angular spring damping ratio
    angularDampingRatio: f32,
    /// Maximum spring torque in newton-meters
    maxSpringTorque: f32,

    /// Use this to initialize your joint definition
    pub const default = b3DefaultMotorJointDef;
    extern fn b3DefaultMotorJointDef() MotorJointDef;
};

/// Use this to initialize your joint definition
pub const defaultMotorJointDef = MotorJointDef.default;

/// A filter joint is used to disable collision between two specific bodies.
pub const FilterJointDef = extern struct {
    /// Base joint definition
    base: JointDef,

    /// Use this to initialize your joint definition
    pub const default = b3DefaultFilterJointDef;
    extern fn b3DefaultFilterJointDef() FilterJointDef;
};

/// Use this to initialize your joint definition
pub const defaultFilterJointDef = FilterJointDef.default;

/// Parallel joint definition. Constrains the angle between axis z in body A and axis z in body B
/// using a spring. Useful to keep a body upright.
pub const ParallelJointDef = extern struct {
    /// Base joint definition
    base: JointDef,
    /// The spring stiffness Hertz, cycles per second
    hertz: f32,
    /// The spring damping ratio, non-dimensional
    dampingRatio: f32,
    /// The maximum spring torque, typically in newton-meters.
    maxTorque: f32,

    /// Use this to initialize your joint definition
    pub const default = b3DefaultParallelJointDef;
    extern fn b3DefaultParallelJointDef() ParallelJointDef;
};

/// Use this to initialize your joint definition
pub const defaultParallelJointDef = ParallelJointDef.default;

/// Prismatic joint definition. Body B may slide along the x-axis in local frame A.
/// Body B cannot rotate relative to body A. The joint translation is zero when the
/// local frame origins coincide in world space.
pub const PrismaticJointDef = extern struct {
    /// Base joint definition
    base: JointDef,
    /// Enable a linear spring along the prismatic joint axis
    enableSpring: bool,
    /// The spring stiffness Hertz, cycles per second
    hertz: f32,
    /// The spring damping ratio, non-dimensional
    dampingRatio: f32,
    /// The target translation for the joint in meters. The spring-damper will drive
    /// to this translation.
    targetTranslation: f32,
    /// Enable/disable the joint limit
    enableLimit: bool,
    /// The lower translation limit
    lowerTranslation: f32,
    /// The upper translation limit
    upperTranslation: f32,
    /// Enable/disable the joint motor
    enableMotor: bool,
    /// The maximum motor force, typically in newtons
    maxMotorForce: f32,
    /// The desired motor speed, typically in meters per second
    motorSpeed: f32,

    /// Use this to initialize your joint definition
    pub const default = b3DefaultPrismaticJointDef;
    extern fn b3DefaultPrismaticJointDef() PrismaticJointDef;
};

/// Use this to initialize your joint definition
pub const defaultPrismaticJointDef = PrismaticJointDef.default;

/// Revolute joint definition. A point on body B is fixed to a point on body A.
/// Allows relative rotation about the z-axis.
pub const RevoluteJointDef = extern struct {
    /// Base joint definition.
    base: JointDef,
    /// The bodyB angle minus bodyA angle in the reference state (radians).
    /// This defines the zero angle for the joint limit.
    targetAngle: f32,
    /// Enable a rotational spring on the revolute hinge axis.
    enableSpring: bool,
    /// The spring stiffness Hertz, cycles per second.
    hertz: f32,
    /// The spring damping ratio, non-dimensional.
    dampingRatio: f32,
    /// A flag to enable joint limits.
    enableLimit: bool,
    /// The lower angle for the joint limit in radians. Minimum of -0.99*pi radians.
    lowerAngle: f32,
    /// The upper angle for the joint limit in radians. Maximum of 0.99*pi radians.
    upperAngle: f32,
    /// A flag to enable the joint motor.
    enableMotor: bool,
    /// The maximum motor torque, typically in newton-meters.
    maxMotorTorque: f32,
    /// The desired motor speed in radians per second.
    motorSpeed: f32,

    /// Use this to initialize your joint definition.
    pub const default = b3DefaultRevoluteJointDef;
    extern fn b3DefaultRevoluteJointDef() RevoluteJointDef;
};

/// Use this to initialize your joint definition.
pub const defaultRevoluteJointDef = RevoluteJointDef.default;

/// Spherical joint definition. A point on body B is fixed to a point on body A.
/// Allows rotation about the shared point.
pub const SphericalJointDef = extern struct {
    /// Base joint definition
    base: JointDef,
    /// Enable a rotational spring that attempts to align the two joint frames.
    enableSpring: bool,
    /// The spring stiffness Hertz, cycles per second. This may be clamped internally
    /// according to the time step to maintain stability. Non-negative number.
    hertz: f32,
    /// The spring damping ratio, non-dimensional. Non-negative number.
    dampingRatio: f32,
    /// Target spring rotation, joint frame B relative to joint frame A.
    targetRotation: Quat,
    /// A flag to enable the cone limit. The cone is centered on the frameA z-axis.
    enableConeLimit: bool,
    /// The angle for the cone limit in radians. Valid range is [0, pi]
    coneAngle: f32,
    /// A flag to enable the twist limit. The twist is centered on the frameB z-axis.
    enableTwistLimit: bool,
    /// The angle for the lower twist limit in radians. Minimum of -0.99*pi radians.
    lowerTwistAngle: f32,
    /// The angle for the upper twist limit in radians. Maximum of 0.99*pi radians.
    upperTwistAngle: f32,
    /// A flag to enable the joint motor
    enableMotor: bool,
    /// The maximum motor torque, typically in newton-meters. Non-negative number.
    maxMotorTorque: f32,
    /// The desired motor angular velocity in radians per second. This is the relative angular
    /// velocity between the two bodies in world space.
    /// motorVelocity = angularVelocityB - angularVelocityA
    motorVelocity: Vec3,

    /// Use this to initialize your joint definition.
    pub const default = b3DefaultSphericalJointDef;
    extern fn b3DefaultSphericalJointDef() SphericalJointDef;
};

/// Use this to initialize your joint definition.
pub const defaultSphericalJointDef = SphericalJointDef.default;

/// Weld joint definition
/// Connects two bodies together rigidly. This constraint provides springs to mimic
/// soft-body simulation.
/// Note: The approximate solver in Box3D cannot hold many bodies together rigidly
pub const WeldJointDef = extern struct {
    /// Base joint definition
    base: JointDef,
    /// Linear stiffness expressed as Hertz (cycles per second). Use zero for maximum stiffness.
    linearHertz: f32,
    /// Angular stiffness as Hertz (cycles per second). Use zero for maximum stiffness.
    angularHertz: f32,
    /// Linear damping ratio, non-dimensional. Use 1 for critical damping.
    linearDampingRatio: f32,
    /// Linear damping ratio, non-dimensional. Use 1 for critical damping.
    angularDampingRatio: f32,

    /// Use this to initialize your joint definition
    pub const default = b3DefaultWeldJointDef;
    extern fn b3DefaultWeldJointDef() WeldJointDef;
};

/// Use this to initialize your joint definition
pub const defaultWeldJointDef = WeldJointDef.default;

/// Wheel joint definition
/// Body A is the chassis and body B is the wheel.
/// The wheel rotates around the local z-axis in frame B.
/// The wheel translates along the local x-axis in frame A.
/// The wheel can optionally steer along the x-axis in frame A.
pub const WheelJointDef = extern struct {
    /// Base joint definition
    base: JointDef,
    /// Enable a linear spring along the local axis
    enableSuspensionSpring: bool,
    /// Spring stiffness in Hertz
    suspensionHertz: f32,
    /// Spring damping ratio, non-dimensional
    suspensionDampingRatio: f32,
    /// Enable/disable the joint linear limit
    enableSuspensionLimit: bool,
    /// The lower suspension translation limit
    lowerSuspensionLimit: f32,
    /// The upper translation limit
    upperSuspensionLimit: f32,
    /// Enable/disable the joint rotational motor
    enableSpinMotor: bool,
    /// The maximum motor torque, typically in newton-meters
    maxSpinTorque: f32,
    /// The desired motor speed in radians per second
    spinSpeed: f32,
    /// Enable steering, otherwise the steering is fixed forward
    enableSteering: bool,
    /// Steering stiffness in Hertz
    steeringHertz: f32,
    /// Spring damping ratio, non-dimensional
    steeringDampingRatio: f32,
    /// The target steering angle in radians
    targetSteeringAngle: f32,
    /// The maximum steering torque in N*m
    maxSteeringTorque: f32,
    /// Enable/disable the steering angular limit
    enableSteeringLimit: bool,
    /// The lower steering angle in radians
    lowerSteeringLimit: f32,
    /// The upper steering angle in radians
    upperSteeringLimit: f32,

    /// Use this to initialize your joint definition
    pub const default = b3DefaultWheelJointDef;
    extern fn b3DefaultWheelJointDef() WheelJointDef;
};

/// Use this to initialize your joint definition
pub const defaultWheelJointDef = WheelJointDef.default;

/// A distance joint. Use `joint` for the functions shared by all joint types.
pub const DistanceJoint = extern struct {
    joint: Joint = .{},

    pub const joint_type: JointType = .distance;

    /// Set the rest length of a distance joint
    /// - `jointId`: The id for a distance joint
    /// - `length`: The new distance joint length
    pub fn setLength(self: DistanceJoint, length: f32) void {
        return b3DistanceJoint_SetLength(self.joint, length);
    }
    extern fn b3DistanceJoint_SetLength(jointId: Joint, length: f32) void;

    /// Get the rest length of a distance joint
    pub fn getLength(self: DistanceJoint) f32 {
        return b3DistanceJoint_GetLength(self.joint);
    }
    extern fn b3DistanceJoint_GetLength(jointId: Joint) f32;

    /// Enable/disable the distance joint spring. When disabled the distance joint is rigid.
    pub fn enableSpring(self: DistanceJoint, flag: bool) void {
        return b3DistanceJoint_EnableSpring(self.joint, flag);
    }
    extern fn b3DistanceJoint_EnableSpring(jointId: Joint, flag: bool) void;

    /// Is the distance joint spring enabled?
    pub fn isSpringEnabled(self: DistanceJoint) bool {
        return b3DistanceJoint_IsSpringEnabled(self.joint);
    }
    extern fn b3DistanceJoint_IsSpringEnabled(jointId: Joint) bool;

    /// Set the force range for the spring.
    pub fn setSpringForceRange(self: DistanceJoint, lowerForce: f32, upperForce: f32) void {
        return b3DistanceJoint_SetSpringForceRange(self.joint, lowerForce, upperForce);
    }
    extern fn b3DistanceJoint_SetSpringForceRange(jointId: Joint, lowerForce: f32, upperForce: f32) void;

    /// Get the force range for the spring.
    pub fn getSpringForceRange(self: DistanceJoint) SpringForceRange {
        var range: SpringForceRange = undefined;
        b3DistanceJoint_GetSpringForceRange(self.joint, &range.lower, &range.upper);
        return range;
    }

    /// The force range of a distance joint spring.
    pub const SpringForceRange = struct {
        /// How much tension the spring can sustain
        lower: f32,
        /// How much compression the spring can sustain
        upper: f32,
    };
    extern fn b3DistanceJoint_GetSpringForceRange(jointId: Joint, lowerForce: *f32, upperForce: *f32) void;

    /// Set the spring stiffness in Hertz
    pub fn setSpringHertz(self: DistanceJoint, hertz: f32) void {
        return b3DistanceJoint_SetSpringHertz(self.joint, hertz);
    }
    extern fn b3DistanceJoint_SetSpringHertz(jointId: Joint, hertz: f32) void;

    /// Set the spring damping ratio, non-dimensional
    pub fn setSpringDampingRatio(self: DistanceJoint, dampingRatio: f32) void {
        return b3DistanceJoint_SetSpringDampingRatio(self.joint, dampingRatio);
    }
    extern fn b3DistanceJoint_SetSpringDampingRatio(jointId: Joint, dampingRatio: f32) void;

    /// Get the spring Hertz
    pub fn getSpringHertz(self: DistanceJoint) f32 {
        return b3DistanceJoint_GetSpringHertz(self.joint);
    }
    extern fn b3DistanceJoint_GetSpringHertz(jointId: Joint) f32;

    /// Get the spring damping ratio
    pub fn getSpringDampingRatio(self: DistanceJoint) f32 {
        return b3DistanceJoint_GetSpringDampingRatio(self.joint);
    }
    extern fn b3DistanceJoint_GetSpringDampingRatio(jointId: Joint) f32;

    /// Enable joint limit. The limit only works if the joint spring is enabled. Otherwise the joint is rigid
    /// and the limit has no effect.
    pub fn enableLimit(self: DistanceJoint, flag: bool) void {
        return b3DistanceJoint_EnableLimit(self.joint, flag);
    }
    extern fn b3DistanceJoint_EnableLimit(jointId: Joint, flag: bool) void;

    /// Is the distance joint limit enabled?
    pub fn isLimitEnabled(self: DistanceJoint) bool {
        return b3DistanceJoint_IsLimitEnabled(self.joint);
    }
    extern fn b3DistanceJoint_IsLimitEnabled(jointId: Joint) bool;

    /// Set the minimum and maximum length parameters of a distance joint
    pub fn setLengthRange(self: DistanceJoint, minLength: f32, maxLength: f32) void {
        return b3DistanceJoint_SetLengthRange(self.joint, minLength, maxLength);
    }
    extern fn b3DistanceJoint_SetLengthRange(jointId: Joint, minLength: f32, maxLength: f32) void;

    /// Get the distance joint minimum length
    pub fn getMinLength(self: DistanceJoint) f32 {
        return b3DistanceJoint_GetMinLength(self.joint);
    }
    extern fn b3DistanceJoint_GetMinLength(jointId: Joint) f32;

    /// Get the distance joint maximum length
    pub fn getMaxLength(self: DistanceJoint) f32 {
        return b3DistanceJoint_GetMaxLength(self.joint);
    }
    extern fn b3DistanceJoint_GetMaxLength(jointId: Joint) f32;

    /// Get the current length of a distance joint
    pub fn getCurrentLength(self: DistanceJoint) f32 {
        return b3DistanceJoint_GetCurrentLength(self.joint);
    }
    extern fn b3DistanceJoint_GetCurrentLength(jointId: Joint) f32;

    /// Enable/disable the distance joint motor
    pub fn enableMotor(self: DistanceJoint, flag: bool) void {
        return b3DistanceJoint_EnableMotor(self.joint, flag);
    }
    extern fn b3DistanceJoint_EnableMotor(jointId: Joint, flag: bool) void;

    /// Is the distance joint motor enabled?
    pub fn isMotorEnabled(self: DistanceJoint) bool {
        return b3DistanceJoint_IsMotorEnabled(self.joint);
    }
    extern fn b3DistanceJoint_IsMotorEnabled(jointId: Joint) bool;

    /// Set the distance joint motor speed, usually in meters per second
    pub fn setMotorSpeed(self: DistanceJoint, motorSpeed: f32) void {
        return b3DistanceJoint_SetMotorSpeed(self.joint, motorSpeed);
    }
    extern fn b3DistanceJoint_SetMotorSpeed(jointId: Joint, motorSpeed: f32) void;

    /// Get the distance joint motor speed, usually in meters per second
    pub fn getMotorSpeed(self: DistanceJoint) f32 {
        return b3DistanceJoint_GetMotorSpeed(self.joint);
    }
    extern fn b3DistanceJoint_GetMotorSpeed(jointId: Joint) f32;

    /// Set the distance joint maximum motor force, usually in newtons
    pub fn setMaxMotorForce(self: DistanceJoint, force: f32) void {
        return b3DistanceJoint_SetMaxMotorForce(self.joint, force);
    }
    extern fn b3DistanceJoint_SetMaxMotorForce(jointId: Joint, force: f32) void;

    /// Get the distance joint maximum motor force, usually in newtons
    pub fn getMaxMotorForce(self: DistanceJoint) f32 {
        return b3DistanceJoint_GetMaxMotorForce(self.joint);
    }
    extern fn b3DistanceJoint_GetMaxMotorForce(jointId: Joint) f32;

    /// Get the distance joint current motor force, usually in newtons
    pub fn getMotorForce(self: DistanceJoint) f32 {
        return b3DistanceJoint_GetMotorForce(self.joint);
    }
    extern fn b3DistanceJoint_GetMotorForce(jointId: Joint) f32;
};

/// A motor joint. Use `joint` for the functions shared by all joint types.
pub const MotorJoint = extern struct {
    joint: Joint = .{},

    pub const joint_type: JointType = .motor;

    /// Set the desired relative linear velocity in meters per second
    pub fn setLinearVelocity(self: MotorJoint, velocity: Vec3) void {
        return b3MotorJoint_SetLinearVelocity(self.joint, velocity);
    }
    extern fn b3MotorJoint_SetLinearVelocity(jointId: Joint, velocity: Vec3) void;

    /// Get the desired relative linear velocity in meters per second
    pub fn getLinearVelocity(self: MotorJoint) Vec3 {
        return b3MotorJoint_GetLinearVelocity(self.joint);
    }
    extern fn b3MotorJoint_GetLinearVelocity(jointId: Joint) Vec3;

    /// Set the desired relative angular velocity in radians per second
    pub fn setAngularVelocity(self: MotorJoint, velocity: Vec3) void {
        return b3MotorJoint_SetAngularVelocity(self.joint, velocity);
    }
    extern fn b3MotorJoint_SetAngularVelocity(jointId: Joint, velocity: Vec3) void;

    /// Get the desired relative angular velocity in radians per second
    pub fn getAngularVelocity(self: MotorJoint) Vec3 {
        return b3MotorJoint_GetAngularVelocity(self.joint);
    }
    extern fn b3MotorJoint_GetAngularVelocity(jointId: Joint) Vec3;

    /// Set the motor joint maximum force, usually in newtons
    pub fn setMaxVelocityForce(self: MotorJoint, maxForce: f32) void {
        return b3MotorJoint_SetMaxVelocityForce(self.joint, maxForce);
    }
    extern fn b3MotorJoint_SetMaxVelocityForce(jointId: Joint, maxForce: f32) void;

    /// Get the motor joint maximum force, usually in newtons
    pub fn getMaxVelocityForce(self: MotorJoint) f32 {
        return b3MotorJoint_GetMaxVelocityForce(self.joint);
    }
    extern fn b3MotorJoint_GetMaxVelocityForce(jointId: Joint) f32;

    /// Set the motor joint maximum torque, usually in newton-meters
    pub fn setMaxVelocityTorque(self: MotorJoint, maxTorque: f32) void {
        return b3MotorJoint_SetMaxVelocityTorque(self.joint, maxTorque);
    }
    extern fn b3MotorJoint_SetMaxVelocityTorque(jointId: Joint, maxTorque: f32) void;

    /// Get the motor joint maximum torque, usually in newton-meters
    pub fn getMaxVelocityTorque(self: MotorJoint) f32 {
        return b3MotorJoint_GetMaxVelocityTorque(self.joint);
    }
    extern fn b3MotorJoint_GetMaxVelocityTorque(jointId: Joint) f32;

    /// Set the spring linear hertz stiffness
    pub fn setLinearHertz(self: MotorJoint, hertz: f32) void {
        return b3MotorJoint_SetLinearHertz(self.joint, hertz);
    }
    extern fn b3MotorJoint_SetLinearHertz(jointId: Joint, hertz: f32) void;

    /// Get the spring linear hertz stiffness
    pub fn getLinearHertz(self: MotorJoint) f32 {
        return b3MotorJoint_GetLinearHertz(self.joint);
    }
    extern fn b3MotorJoint_GetLinearHertz(jointId: Joint) f32;

    /// Set the spring linear damping ratio. Use 1.0 for critical damping.
    pub fn setLinearDampingRatio(self: MotorJoint, damping: f32) void {
        return b3MotorJoint_SetLinearDampingRatio(self.joint, damping);
    }
    extern fn b3MotorJoint_SetLinearDampingRatio(jointId: Joint, damping: f32) void;

    /// Get the spring linear damping ratio.
    pub fn getLinearDampingRatio(self: MotorJoint) f32 {
        return b3MotorJoint_GetLinearDampingRatio(self.joint);
    }
    extern fn b3MotorJoint_GetLinearDampingRatio(jointId: Joint) f32;

    /// Set the spring angular hertz stiffness
    pub fn setAngularHertz(self: MotorJoint, hertz: f32) void {
        return b3MotorJoint_SetAngularHertz(self.joint, hertz);
    }
    extern fn b3MotorJoint_SetAngularHertz(jointId: Joint, hertz: f32) void;

    /// Get the spring angular hertz stiffness
    pub fn getAngularHertz(self: MotorJoint) f32 {
        return b3MotorJoint_GetAngularHertz(self.joint);
    }
    extern fn b3MotorJoint_GetAngularHertz(jointId: Joint) f32;

    /// Set the spring angular damping ratio. Use 1.0 for critical damping.
    pub fn setAngularDampingRatio(self: MotorJoint, damping: f32) void {
        return b3MotorJoint_SetAngularDampingRatio(self.joint, damping);
    }
    extern fn b3MotorJoint_SetAngularDampingRatio(jointId: Joint, damping: f32) void;

    /// Get the spring angular damping ratio.
    pub fn getAngularDampingRatio(self: MotorJoint) f32 {
        return b3MotorJoint_GetAngularDampingRatio(self.joint);
    }
    extern fn b3MotorJoint_GetAngularDampingRatio(jointId: Joint) f32;

    /// Set the maximum spring force in newtons.
    pub fn setMaxSpringForce(self: MotorJoint, maxForce: f32) void {
        return b3MotorJoint_SetMaxSpringForce(self.joint, maxForce);
    }
    extern fn b3MotorJoint_SetMaxSpringForce(jointId: Joint, maxForce: f32) void;

    /// Get the maximum spring force in newtons.
    pub fn getMaxSpringForce(self: MotorJoint) f32 {
        return b3MotorJoint_GetMaxSpringForce(self.joint);
    }
    extern fn b3MotorJoint_GetMaxSpringForce(jointId: Joint) f32;

    /// Set the maximum spring torque in newtons * meters
    pub fn setMaxSpringTorque(self: MotorJoint, maxTorque: f32) void {
        return b3MotorJoint_SetMaxSpringTorque(self.joint, maxTorque);
    }
    extern fn b3MotorJoint_SetMaxSpringTorque(jointId: Joint, maxTorque: f32) void;

    /// Get the maximum spring torque in newtons * meters
    pub fn getMaxSpringTorque(self: MotorJoint) f32 {
        return b3MotorJoint_GetMaxSpringTorque(self.joint);
    }
    extern fn b3MotorJoint_GetMaxSpringTorque(jointId: Joint) f32;
};

/// A filter joint. Use `joint` for the functions shared by all joint types.
pub const FilterJoint = extern struct {
    joint: Joint = .{},

    pub const joint_type: JointType = .filter;
};

/// A parallel joint. Use `joint` for the functions shared by all joint types.
pub const ParallelJoint = extern struct {
    joint: Joint = .{},

    pub const joint_type: JointType = .parallel;

    /// Set the spring stiffness in Hertz
    pub fn setSpringHertz(self: ParallelJoint, hertz: f32) void {
        return b3ParallelJoint_SetSpringHertz(self.joint, hertz);
    }
    extern fn b3ParallelJoint_SetSpringHertz(jointId: Joint, hertz: f32) void;

    /// Set the spring damping ratio, non-dimensional
    pub fn setSpringDampingRatio(self: ParallelJoint, dampingRatio: f32) void {
        return b3ParallelJoint_SetSpringDampingRatio(self.joint, dampingRatio);
    }
    extern fn b3ParallelJoint_SetSpringDampingRatio(jointId: Joint, dampingRatio: f32) void;

    /// Get the spring Hertz
    pub fn getSpringHertz(self: ParallelJoint) f32 {
        return b3ParallelJoint_GetSpringHertz(self.joint);
    }
    extern fn b3ParallelJoint_GetSpringHertz(jointId: Joint) f32;

    /// Get the spring damping ratio
    pub fn getSpringDampingRatio(self: ParallelJoint) f32 {
        return b3ParallelJoint_GetSpringDampingRatio(self.joint);
    }
    extern fn b3ParallelJoint_GetSpringDampingRatio(jointId: Joint) f32;

    /// Set the maximum spring torque, usually in newton-meters
    pub fn setMaxTorque(self: ParallelJoint, force: f32) void {
        return b3ParallelJoint_SetMaxTorque(self.joint, force);
    }
    extern fn b3ParallelJoint_SetMaxTorque(jointId: Joint, force: f32) void;

    /// Get the maximum spring torque, usually in newton-meters
    pub fn getMaxTorque(self: ParallelJoint) f32 {
        return b3ParallelJoint_GetMaxTorque(self.joint);
    }
    extern fn b3ParallelJoint_GetMaxTorque(jointId: Joint) f32;
};

/// A prismatic joint. Use `joint` for the functions shared by all joint types.
pub const PrismaticJoint = extern struct {
    joint: Joint = .{},

    pub const joint_type: JointType = .prismatic;

    /// Enable/disable the joint spring.
    pub fn enableSpring(self: PrismaticJoint, flag: bool) void {
        return b3PrismaticJoint_EnableSpring(self.joint, flag);
    }
    extern fn b3PrismaticJoint_EnableSpring(jointId: Joint, flag: bool) void;

    /// Is the prismatic joint spring enabled or not?
    pub fn isSpringEnabled(self: PrismaticJoint) bool {
        return b3PrismaticJoint_IsSpringEnabled(self.joint);
    }
    extern fn b3PrismaticJoint_IsSpringEnabled(jointId: Joint) bool;

    /// Set the prismatic joint stiffness in Hertz.
    /// This should usually be less than a quarter of the simulation rate. For example, if the simulation
    /// runs at 60Hz then the joint stiffness should be 15Hz or less.
    pub fn setSpringHertz(self: PrismaticJoint, hertz: f32) void {
        return b3PrismaticJoint_SetSpringHertz(self.joint, hertz);
    }
    extern fn b3PrismaticJoint_SetSpringHertz(jointId: Joint, hertz: f32) void;

    /// Get the prismatic joint stiffness in Hertz
    pub fn getSpringHertz(self: PrismaticJoint) f32 {
        return b3PrismaticJoint_GetSpringHertz(self.joint);
    }
    extern fn b3PrismaticJoint_GetSpringHertz(jointId: Joint) f32;

    /// Set the prismatic joint damping ratio (non-dimensional)
    pub fn setSpringDampingRatio(self: PrismaticJoint, dampingRatio: f32) void {
        return b3PrismaticJoint_SetSpringDampingRatio(self.joint, dampingRatio);
    }
    extern fn b3PrismaticJoint_SetSpringDampingRatio(jointId: Joint, dampingRatio: f32) void;

    /// Get the prismatic spring damping ratio (non-dimensional)
    pub fn getSpringDampingRatio(self: PrismaticJoint) f32 {
        return b3PrismaticJoint_GetSpringDampingRatio(self.joint);
    }
    extern fn b3PrismaticJoint_GetSpringDampingRatio(jointId: Joint) f32;

    /// Set the prismatic joint target translation. Usually in meters.
    pub fn setTargetTranslation(self: PrismaticJoint, targetTranslation: f32) void {
        return b3PrismaticJoint_SetTargetTranslation(self.joint, targetTranslation);
    }
    extern fn b3PrismaticJoint_SetTargetTranslation(jointId: Joint, targetTranslation: f32) void;

    /// Get the prismatic joint target translation. Usually in meters.
    pub fn getTargetTranslation(self: PrismaticJoint) f32 {
        return b3PrismaticJoint_GetTargetTranslation(self.joint);
    }
    extern fn b3PrismaticJoint_GetTargetTranslation(jointId: Joint) f32;

    /// Enable/disable a prismatic joint limit
    pub fn enableLimit(self: PrismaticJoint, flag: bool) void {
        return b3PrismaticJoint_EnableLimit(self.joint, flag);
    }
    extern fn b3PrismaticJoint_EnableLimit(jointId: Joint, flag: bool) void;

    /// Is the prismatic joint limit enabled?
    pub fn isLimitEnabled(self: PrismaticJoint) bool {
        return b3PrismaticJoint_IsLimitEnabled(self.joint);
    }
    extern fn b3PrismaticJoint_IsLimitEnabled(jointId: Joint) bool;

    /// Get the prismatic joint lower limit
    pub fn getLowerLimit(self: PrismaticJoint) f32 {
        return b3PrismaticJoint_GetLowerLimit(self.joint);
    }
    extern fn b3PrismaticJoint_GetLowerLimit(jointId: Joint) f32;

    /// Get the prismatic joint upper limit
    pub fn getUpperLimit(self: PrismaticJoint) f32 {
        return b3PrismaticJoint_GetUpperLimit(self.joint);
    }
    extern fn b3PrismaticJoint_GetUpperLimit(jointId: Joint) f32;

    /// Set the prismatic joint limits
    pub fn setLimits(self: PrismaticJoint, lower: f32, upper: f32) void {
        return b3PrismaticJoint_SetLimits(self.joint, lower, upper);
    }
    extern fn b3PrismaticJoint_SetLimits(jointId: Joint, lower: f32, upper: f32) void;

    /// Enable/disable a prismatic joint motor
    pub fn enableMotor(self: PrismaticJoint, flag: bool) void {
        return b3PrismaticJoint_EnableMotor(self.joint, flag);
    }
    extern fn b3PrismaticJoint_EnableMotor(jointId: Joint, flag: bool) void;

    /// Is the prismatic joint motor enabled?
    pub fn isMotorEnabled(self: PrismaticJoint) bool {
        return b3PrismaticJoint_IsMotorEnabled(self.joint);
    }
    extern fn b3PrismaticJoint_IsMotorEnabled(jointId: Joint) bool;

    /// Set the prismatic joint motor speed, usually in meters per second
    pub fn setMotorSpeed(self: PrismaticJoint, motorSpeed: f32) void {
        return b3PrismaticJoint_SetMotorSpeed(self.joint, motorSpeed);
    }
    extern fn b3PrismaticJoint_SetMotorSpeed(jointId: Joint, motorSpeed: f32) void;

    /// Get the prismatic joint motor speed, usually in meters per second
    pub fn getMotorSpeed(self: PrismaticJoint) f32 {
        return b3PrismaticJoint_GetMotorSpeed(self.joint);
    }
    extern fn b3PrismaticJoint_GetMotorSpeed(jointId: Joint) f32;

    /// Set the prismatic joint maximum motor force, usually in newtons
    pub fn setMaxMotorForce(self: PrismaticJoint, force: f32) void {
        return b3PrismaticJoint_SetMaxMotorForce(self.joint, force);
    }
    extern fn b3PrismaticJoint_SetMaxMotorForce(jointId: Joint, force: f32) void;

    /// Get the prismatic joint maximum motor force, usually in newtons
    pub fn getMaxMotorForce(self: PrismaticJoint) f32 {
        return b3PrismaticJoint_GetMaxMotorForce(self.joint);
    }
    extern fn b3PrismaticJoint_GetMaxMotorForce(jointId: Joint) f32;

    /// Get the prismatic joint current motor force, usually in newtons
    pub fn getMotorForce(self: PrismaticJoint) f32 {
        return b3PrismaticJoint_GetMotorForce(self.joint);
    }
    extern fn b3PrismaticJoint_GetMotorForce(jointId: Joint) f32;

    /// Get the current joint translation, usually in meters.
    pub fn getTranslation(self: PrismaticJoint) f32 {
        return b3PrismaticJoint_GetTranslation(self.joint);
    }
    extern fn b3PrismaticJoint_GetTranslation(jointId: Joint) f32;

    /// Get the current joint translation speed, usually in meters per second.
    pub fn getSpeed(self: PrismaticJoint) f32 {
        return b3PrismaticJoint_GetSpeed(self.joint);
    }
    extern fn b3PrismaticJoint_GetSpeed(jointId: Joint) f32;
};

/// A revolute joint. Use `joint` for the functions shared by all joint types.
pub const RevoluteJoint = extern struct {
    joint: Joint = .{},

    pub const joint_type: JointType = .revolute;

    /// Enable/disable the revolute joint spring
    pub fn enableSpring(self: RevoluteJoint, flag: bool) void {
        return b3RevoluteJoint_EnableSpring(self.joint, flag);
    }
    extern fn b3RevoluteJoint_EnableSpring(jointId: Joint, flag: bool) void;

    /// Is the revolute angular spring enabled?
    pub fn isSpringEnabled(self: RevoluteJoint) bool {
        return b3RevoluteJoint_IsSpringEnabled(self.joint);
    }
    extern fn b3RevoluteJoint_IsSpringEnabled(jointId: Joint) bool;

    /// Set the revolute joint spring stiffness in Hertz
    pub fn setSpringHertz(self: RevoluteJoint, hertz: f32) void {
        return b3RevoluteJoint_SetSpringHertz(self.joint, hertz);
    }
    extern fn b3RevoluteJoint_SetSpringHertz(jointId: Joint, hertz: f32) void;

    /// Get the revolute joint spring stiffness in Hertz
    pub fn getSpringHertz(self: RevoluteJoint) f32 {
        return b3RevoluteJoint_GetSpringHertz(self.joint);
    }
    extern fn b3RevoluteJoint_GetSpringHertz(jointId: Joint) f32;

    /// Set the revolute joint spring damping ratio, non-dimensional
    pub fn setSpringDampingRatio(self: RevoluteJoint, dampingRatio: f32) void {
        return b3RevoluteJoint_SetSpringDampingRatio(self.joint, dampingRatio);
    }
    extern fn b3RevoluteJoint_SetSpringDampingRatio(jointId: Joint, dampingRatio: f32) void;

    /// Get the revolute joint spring damping ratio, non-dimensional
    pub fn getSpringDampingRatio(self: RevoluteJoint) f32 {
        return b3RevoluteJoint_GetSpringDampingRatio(self.joint);
    }
    extern fn b3RevoluteJoint_GetSpringDampingRatio(jointId: Joint) f32;

    /// Set the revolute joint target angle in radians
    pub fn setTargetAngle(self: RevoluteJoint, targetRadians: f32) void {
        return b3RevoluteJoint_SetTargetAngle(self.joint, targetRadians);
    }
    extern fn b3RevoluteJoint_SetTargetAngle(jointId: Joint, targetRadians: f32) void;

    /// Get the revolute joint target angle in radians
    pub fn getTargetAngle(self: RevoluteJoint) f32 {
        return b3RevoluteJoint_GetTargetAngle(self.joint);
    }
    extern fn b3RevoluteJoint_GetTargetAngle(jointId: Joint) f32;

    /// Get the revolute joint current angle in radians relative to the reference angle
    /// See `RevoluteJointDef.referenceAngle`.
    pub fn getAngle(self: RevoluteJoint) f32 {
        return b3RevoluteJoint_GetAngle(self.joint);
    }
    extern fn b3RevoluteJoint_GetAngle(jointId: Joint) f32;

    /// Enable/disable the revolute joint limit
    pub fn enableLimit(self: RevoluteJoint, flag: bool) void {
        return b3RevoluteJoint_EnableLimit(self.joint, flag);
    }
    extern fn b3RevoluteJoint_EnableLimit(jointId: Joint, flag: bool) void;

    /// Is the revolute joint limit enabled?
    pub fn isLimitEnabled(self: RevoluteJoint) bool {
        return b3RevoluteJoint_IsLimitEnabled(self.joint);
    }
    extern fn b3RevoluteJoint_IsLimitEnabled(jointId: Joint) bool;

    /// Get the revolute joint lower limit in radians
    pub fn getLowerLimit(self: RevoluteJoint) f32 {
        return b3RevoluteJoint_GetLowerLimit(self.joint);
    }
    extern fn b3RevoluteJoint_GetLowerLimit(jointId: Joint) f32;

    /// Get the revolute joint upper limit in radians
    pub fn getUpperLimit(self: RevoluteJoint) f32 {
        return b3RevoluteJoint_GetUpperLimit(self.joint);
    }
    extern fn b3RevoluteJoint_GetUpperLimit(jointId: Joint) f32;

    /// Set the revolute joint limits in radians
    pub fn setLimits(self: RevoluteJoint, lowerLimitRadians: f32, upperLimitRadians: f32) void {
        return b3RevoluteJoint_SetLimits(self.joint, lowerLimitRadians, upperLimitRadians);
    }
    extern fn b3RevoluteJoint_SetLimits(jointId: Joint, lowerLimitRadians: f32, upperLimitRadians: f32) void;

    /// Enable/disable a revolute joint motor
    pub fn enableMotor(self: RevoluteJoint, flag: bool) void {
        return b3RevoluteJoint_EnableMotor(self.joint, flag);
    }
    extern fn b3RevoluteJoint_EnableMotor(jointId: Joint, flag: bool) void;

    /// Is the revolute joint motor enabled?
    pub fn isMotorEnabled(self: RevoluteJoint) bool {
        return b3RevoluteJoint_IsMotorEnabled(self.joint);
    }
    extern fn b3RevoluteJoint_IsMotorEnabled(jointId: Joint) bool;

    /// Set the revolute joint motor speed in radians per second
    pub fn setMotorSpeed(self: RevoluteJoint, motorSpeed: f32) void {
        return b3RevoluteJoint_SetMotorSpeed(self.joint, motorSpeed);
    }
    extern fn b3RevoluteJoint_SetMotorSpeed(jointId: Joint, motorSpeed: f32) void;

    /// Get the revolute joint motor speed in radians per second
    pub fn getMotorSpeed(self: RevoluteJoint) f32 {
        return b3RevoluteJoint_GetMotorSpeed(self.joint);
    }
    extern fn b3RevoluteJoint_GetMotorSpeed(jointId: Joint) f32;

    /// Get the revolute joint current motor torque, usually in newton-meters
    pub fn getMotorTorque(self: RevoluteJoint) f32 {
        return b3RevoluteJoint_GetMotorTorque(self.joint);
    }
    extern fn b3RevoluteJoint_GetMotorTorque(jointId: Joint) f32;

    /// Set the revolute joint maximum motor torque, usually in newton-meters
    pub fn setMaxMotorTorque(self: RevoluteJoint, torque: f32) void {
        return b3RevoluteJoint_SetMaxMotorTorque(self.joint, torque);
    }
    extern fn b3RevoluteJoint_SetMaxMotorTorque(jointId: Joint, torque: f32) void;

    /// Get the revolute joint maximum motor torque, usually in newton-meters
    pub fn getMaxMotorTorque(self: RevoluteJoint) f32 {
        return b3RevoluteJoint_GetMaxMotorTorque(self.joint);
    }
    extern fn b3RevoluteJoint_GetMaxMotorTorque(jointId: Joint) f32;
};

/// A spherical joint. Use `joint` for the functions shared by all joint types.
pub const SphericalJoint = extern struct {
    joint: Joint = .{},

    pub const joint_type: JointType = .spherical;

    /// Enable/disable the spherical joint cone limit
    pub fn enableConeLimit(self: SphericalJoint, flag: bool) void {
        return b3SphericalJoint_EnableConeLimit(self.joint, flag);
    }
    extern fn b3SphericalJoint_EnableConeLimit(jointId: Joint, flag: bool) void;

    /// Is the spherical joint cone limit enabled?
    pub fn isConeLimitEnabled(self: SphericalJoint) bool {
        return b3SphericalJoint_IsConeLimitEnabled(self.joint);
    }
    extern fn b3SphericalJoint_IsConeLimitEnabled(jointId: Joint) bool;

    /// Get the spherical joint cone limit in radians
    pub fn getConeLimit(self: SphericalJoint) f32 {
        return b3SphericalJoint_GetConeLimit(self.joint);
    }
    extern fn b3SphericalJoint_GetConeLimit(jointId: Joint) f32;

    /// Set the spherical joint limits in radians
    pub fn setConeLimit(self: SphericalJoint, angleRadians: f32) void {
        return b3SphericalJoint_SetConeLimit(self.joint, angleRadians);
    }
    extern fn b3SphericalJoint_SetConeLimit(jointId: Joint, angleRadians: f32) void;

    /// Get the spherical joint current cone angle in radians.
    pub fn getConeAngle(self: SphericalJoint) f32 {
        return b3SphericalJoint_GetConeAngle(self.joint);
    }
    extern fn b3SphericalJoint_GetConeAngle(jointId: Joint) f32;

    /// Enable/disable the spherical joint limit
    pub fn enableTwistLimit(self: SphericalJoint, flag: bool) void {
        return b3SphericalJoint_EnableTwistLimit(self.joint, flag);
    }
    extern fn b3SphericalJoint_EnableTwistLimit(jointId: Joint, flag: bool) void;

    /// Is the spherical joint limit enabled?
    pub fn isTwistLimitEnabled(self: SphericalJoint) bool {
        return b3SphericalJoint_IsTwistLimitEnabled(self.joint);
    }
    extern fn b3SphericalJoint_IsTwistLimitEnabled(jointId: Joint) bool;

    /// Get the spherical joint lower limit in radians
    pub fn getLowerTwistLimit(self: SphericalJoint) f32 {
        return b3SphericalJoint_GetLowerTwistLimit(self.joint);
    }
    extern fn b3SphericalJoint_GetLowerTwistLimit(jointId: Joint) f32;

    /// Get the spherical joint upper limit in radians
    pub fn getUpperTwistLimit(self: SphericalJoint) f32 {
        return b3SphericalJoint_GetUpperTwistLimit(self.joint);
    }
    extern fn b3SphericalJoint_GetUpperTwistLimit(jointId: Joint) f32;

    /// Set the spherical joint limits in radians
    pub fn setTwistLimits(self: SphericalJoint, lowerLimitRadians: f32, upperLimitRadians: f32) void {
        return b3SphericalJoint_SetTwistLimits(self.joint, lowerLimitRadians, upperLimitRadians);
    }
    extern fn b3SphericalJoint_SetTwistLimits(jointId: Joint, lowerLimitRadians: f32, upperLimitRadians: f32) void;

    /// Get the spherical joint current twist angle in radians.
    pub fn getTwistAngle(self: SphericalJoint) f32 {
        return b3SphericalJoint_GetTwistAngle(self.joint);
    }
    extern fn b3SphericalJoint_GetTwistAngle(jointId: Joint) f32;

    /// Enable/disable the spherical joint spring
    pub fn enableSpring(self: SphericalJoint, flag: bool) void {
        return b3SphericalJoint_EnableSpring(self.joint, flag);
    }
    extern fn b3SphericalJoint_EnableSpring(jointId: Joint, flag: bool) void;

    /// Is the spherical angular spring enabled?
    pub fn isSpringEnabled(self: SphericalJoint) bool {
        return b3SphericalJoint_IsSpringEnabled(self.joint);
    }
    extern fn b3SphericalJoint_IsSpringEnabled(jointId: Joint) bool;

    /// Set the spherical joint spring stiffness in Hertz
    pub fn setSpringHertz(self: SphericalJoint, hertz: f32) void {
        return b3SphericalJoint_SetSpringHertz(self.joint, hertz);
    }
    extern fn b3SphericalJoint_SetSpringHertz(jointId: Joint, hertz: f32) void;

    /// Get the spherical joint spring stiffness in Hertz
    pub fn getSpringHertz(self: SphericalJoint) f32 {
        return b3SphericalJoint_GetSpringHertz(self.joint);
    }
    extern fn b3SphericalJoint_GetSpringHertz(jointId: Joint) f32;

    /// Set the spherical joint spring damping ratio, non-dimensional
    pub fn setSpringDampingRatio(self: SphericalJoint, dampingRatio: f32) void {
        return b3SphericalJoint_SetSpringDampingRatio(self.joint, dampingRatio);
    }
    extern fn b3SphericalJoint_SetSpringDampingRatio(jointId: Joint, dampingRatio: f32) void;

    /// Get the spherical joint spring damping ratio, non-dimensional
    pub fn getSpringDampingRatio(self: SphericalJoint) f32 {
        return b3SphericalJoint_GetSpringDampingRatio(self.joint);
    }
    extern fn b3SphericalJoint_GetSpringDampingRatio(jointId: Joint) f32;

    /// Set the spherical joint spring target rotation
    pub fn setTargetRotation(self: SphericalJoint, targetRotation: Quat) void {
        return b3SphericalJoint_SetTargetRotation(self.joint, targetRotation);
    }
    extern fn b3SphericalJoint_SetTargetRotation(jointId: Joint, targetRotation: Quat) void;

    /// Get the spherical joint spring target rotation
    pub fn getTargetRotation(self: SphericalJoint) Quat {
        return b3SphericalJoint_GetTargetRotation(self.joint);
    }
    extern fn b3SphericalJoint_GetTargetRotation(jointId: Joint) Quat;

    /// Enable/disable a spherical joint motor
    pub fn enableMotor(self: SphericalJoint, flag: bool) void {
        return b3SphericalJoint_EnableMotor(self.joint, flag);
    }
    extern fn b3SphericalJoint_EnableMotor(jointId: Joint, flag: bool) void;

    /// Is the spherical joint motor enabled?
    pub fn isMotorEnabled(self: SphericalJoint) bool {
        return b3SphericalJoint_IsMotorEnabled(self.joint);
    }
    extern fn b3SphericalJoint_IsMotorEnabled(jointId: Joint) bool;

    /// Set the spherical joint motor velocity in radians per second. This is the relative angular
    /// velocity between the two bodies in world space.
    /// motorVelocity = angularVelocityB - angularVelocityA
    pub fn setMotorVelocity(self: SphericalJoint, motorVelocity: Vec3) void {
        return b3SphericalJoint_SetMotorVelocity(self.joint, motorVelocity);
    }
    extern fn b3SphericalJoint_SetMotorVelocity(jointId: Joint, motorVelocity: Vec3) void;

    /// Get the spherical joint motor velocity in radians per second
    pub fn getMotorVelocity(self: SphericalJoint) Vec3 {
        return b3SphericalJoint_GetMotorVelocity(self.joint);
    }
    extern fn b3SphericalJoint_GetMotorVelocity(jointId: Joint) Vec3;

    /// Get the spherical joint current motor torque, usually in newton-meters
    pub fn getMotorTorque(self: SphericalJoint) Vec3 {
        return b3SphericalJoint_GetMotorTorque(self.joint);
    }
    extern fn b3SphericalJoint_GetMotorTorque(jointId: Joint) Vec3;

    /// Set the spherical joint maximum motor torque, usually in newton-meters
    pub fn setMaxMotorTorque(self: SphericalJoint, torque: f32) void {
        return b3SphericalJoint_SetMaxMotorTorque(self.joint, torque);
    }
    extern fn b3SphericalJoint_SetMaxMotorTorque(jointId: Joint, torque: f32) void;

    /// Get the spherical joint maximum motor torque, usually in newton-meters
    pub fn getMaxMotorTorque(self: SphericalJoint) f32 {
        return b3SphericalJoint_GetMaxMotorTorque(self.joint);
    }
    extern fn b3SphericalJoint_GetMaxMotorTorque(jointId: Joint) f32;
};

/// A weld joint. Use `joint` for the functions shared by all joint types.
pub const WeldJoint = extern struct {
    joint: Joint = .{},

    pub const joint_type: JointType = .weld;

    /// Set the weld joint linear stiffness in Hertz. 0 is rigid.
    pub fn setLinearHertz(self: WeldJoint, hertz: f32) void {
        return b3WeldJoint_SetLinearHertz(self.joint, hertz);
    }
    extern fn b3WeldJoint_SetLinearHertz(jointId: Joint, hertz: f32) void;

    /// Get the weld joint linear stiffness in Hertz
    pub fn getLinearHertz(self: WeldJoint) f32 {
        return b3WeldJoint_GetLinearHertz(self.joint);
    }
    extern fn b3WeldJoint_GetLinearHertz(jointId: Joint) f32;

    /// Set the weld joint linear damping ratio (non-dimensional)
    pub fn setLinearDampingRatio(self: WeldJoint, dampingRatio: f32) void {
        return b3WeldJoint_SetLinearDampingRatio(self.joint, dampingRatio);
    }
    extern fn b3WeldJoint_SetLinearDampingRatio(jointId: Joint, dampingRatio: f32) void;

    /// Get the weld joint linear damping ratio (non-dimensional)
    pub fn getLinearDampingRatio(self: WeldJoint) f32 {
        return b3WeldJoint_GetLinearDampingRatio(self.joint);
    }
    extern fn b3WeldJoint_GetLinearDampingRatio(jointId: Joint) f32;

    /// Set the weld joint angular stiffness in Hertz. 0 is rigid.
    pub fn setAngularHertz(self: WeldJoint, hertz: f32) void {
        return b3WeldJoint_SetAngularHertz(self.joint, hertz);
    }
    extern fn b3WeldJoint_SetAngularHertz(jointId: Joint, hertz: f32) void;

    /// Get the weld joint angular stiffness in Hertz
    pub fn getAngularHertz(self: WeldJoint) f32 {
        return b3WeldJoint_GetAngularHertz(self.joint);
    }
    extern fn b3WeldJoint_GetAngularHertz(jointId: Joint) f32;

    /// Set weld joint angular damping ratio, non-dimensional
    pub fn setAngularDampingRatio(self: WeldJoint, dampingRatio: f32) void {
        return b3WeldJoint_SetAngularDampingRatio(self.joint, dampingRatio);
    }
    extern fn b3WeldJoint_SetAngularDampingRatio(jointId: Joint, dampingRatio: f32) void;

    /// Get the weld joint angular damping ratio, non-dimensional
    pub fn getAngularDampingRatio(self: WeldJoint) f32 {
        return b3WeldJoint_GetAngularDampingRatio(self.joint);
    }
    extern fn b3WeldJoint_GetAngularDampingRatio(jointId: Joint) f32;
};

/// A wheel joint. Use `joint` for the functions shared by all joint types.
pub const WheelJoint = extern struct {
    joint: Joint = .{},

    pub const joint_type: JointType = .wheel;

    /// Enable/disable the wheel joint spring.
    pub fn enableSuspension(self: WheelJoint, flag: bool) void {
        return b3WheelJoint_EnableSuspension(self.joint, flag);
    }
    extern fn b3WheelJoint_EnableSuspension(jointId: Joint, flag: bool) void;

    /// Is the wheel joint spring enabled?
    pub fn isSuspensionEnabled(self: WheelJoint) bool {
        return b3WheelJoint_IsSuspensionEnabled(self.joint);
    }
    extern fn b3WheelJoint_IsSuspensionEnabled(jointId: Joint) bool;

    /// Set the wheel joint stiffness in Hertz.
    pub fn setSuspensionHertz(self: WheelJoint, hertz: f32) void {
        return b3WheelJoint_SetSuspensionHertz(self.joint, hertz);
    }
    extern fn b3WheelJoint_SetSuspensionHertz(jointId: Joint, hertz: f32) void;

    /// Get the wheel joint stiffness in Hertz.
    pub fn getSuspensionHertz(self: WheelJoint) f32 {
        return b3WheelJoint_GetSuspensionHertz(self.joint);
    }
    extern fn b3WheelJoint_GetSuspensionHertz(jointId: Joint) f32;

    /// Set the wheel joint damping ratio, non-dimensional.
    pub fn setSuspensionDampingRatio(self: WheelJoint, dampingRatio: f32) void {
        return b3WheelJoint_SetSuspensionDampingRatio(self.joint, dampingRatio);
    }
    extern fn b3WheelJoint_SetSuspensionDampingRatio(jointId: Joint, dampingRatio: f32) void;

    /// Get the wheel joint damping ratio, non-dimensional.
    pub fn getSuspensionDampingRatio(self: WheelJoint) f32 {
        return b3WheelJoint_GetSuspensionDampingRatio(self.joint);
    }
    extern fn b3WheelJoint_GetSuspensionDampingRatio(jointId: Joint) f32;

    /// Enable/disable the wheel joint limit.
    pub fn enableSuspensionLimit(self: WheelJoint, flag: bool) void {
        return b3WheelJoint_EnableSuspensionLimit(self.joint, flag);
    }
    extern fn b3WheelJoint_EnableSuspensionLimit(jointId: Joint, flag: bool) void;

    /// Is the wheel joint limit enabled?
    pub fn isSuspensionLimitEnabled(self: WheelJoint) bool {
        return b3WheelJoint_IsSuspensionLimitEnabled(self.joint);
    }
    extern fn b3WheelJoint_IsSuspensionLimitEnabled(jointId: Joint) bool;

    /// Get the wheel joint lower limit.
    pub fn getLowerSuspensionLimit(self: WheelJoint) f32 {
        return b3WheelJoint_GetLowerSuspensionLimit(self.joint);
    }
    extern fn b3WheelJoint_GetLowerSuspensionLimit(jointId: Joint) f32;

    /// Get the wheel joint upper limit.
    pub fn getUpperSuspensionLimit(self: WheelJoint) f32 {
        return b3WheelJoint_GetUpperSuspensionLimit(self.joint);
    }
    extern fn b3WheelJoint_GetUpperSuspensionLimit(jointId: Joint) f32;

    /// Set the wheel joint limits.
    pub fn setSuspensionLimits(self: WheelJoint, lower: f32, upper: f32) void {
        return b3WheelJoint_SetSuspensionLimits(self.joint, lower, upper);
    }
    extern fn b3WheelJoint_SetSuspensionLimits(jointId: Joint, lower: f32, upper: f32) void;

    /// Enable/disable the wheel joint motor.
    pub fn enableSpinMotor(self: WheelJoint, flag: bool) void {
        return b3WheelJoint_EnableSpinMotor(self.joint, flag);
    }
    extern fn b3WheelJoint_EnableSpinMotor(jointId: Joint, flag: bool) void;

    /// Is the wheel joint motor enabled?
    pub fn isSpinMotorEnabled(self: WheelJoint) bool {
        return b3WheelJoint_IsSpinMotorEnabled(self.joint);
    }
    extern fn b3WheelJoint_IsSpinMotorEnabled(jointId: Joint) bool;

    /// Set the wheel joint motor speed in radians per second.
    pub fn setSpinMotorSpeed(self: WheelJoint, speed: f32) void {
        return b3WheelJoint_SetSpinMotorSpeed(self.joint, speed);
    }
    extern fn b3WheelJoint_SetSpinMotorSpeed(jointId: Joint, speed: f32) void;

    /// Get the wheel joint motor speed in radians per second.
    pub fn getSpinMotorSpeed(self: WheelJoint) f32 {
        return b3WheelJoint_GetSpinMotorSpeed(self.joint);
    }
    extern fn b3WheelJoint_GetSpinMotorSpeed(jointId: Joint) f32;

    /// Set the wheel joint maximum motor torque, usually in newton-meters.
    pub fn setMaxSpinTorque(self: WheelJoint, torque: f32) void {
        return b3WheelJoint_SetMaxSpinTorque(self.joint, torque);
    }
    extern fn b3WheelJoint_SetMaxSpinTorque(jointId: Joint, torque: f32) void;

    /// Get the wheel joint maximum motor torque, usually in newton-meters.
    pub fn getMaxSpinTorque(self: WheelJoint) f32 {
        return b3WheelJoint_GetMaxSpinTorque(self.joint);
    }
    extern fn b3WheelJoint_GetMaxSpinTorque(jointId: Joint) f32;

    /// Get the current spin speed in radians per second.
    pub fn getSpinSpeed(self: WheelJoint) f32 {
        return b3WheelJoint_GetSpinSpeed(self.joint);
    }
    extern fn b3WheelJoint_GetSpinSpeed(jointId: Joint) f32;

    /// Get the wheel joint current motor torque, usually in newton-meters.
    pub fn getSpinTorque(self: WheelJoint) f32 {
        return b3WheelJoint_GetSpinTorque(self.joint);
    }
    extern fn b3WheelJoint_GetSpinTorque(jointId: Joint) f32;

    /// Enable/disable wheel steering. Steering allows the wheel to rotate about the suspension axis.
    pub fn enableSteering(self: WheelJoint, flag: bool) void {
        return b3WheelJoint_EnableSteering(self.joint, flag);
    }
    extern fn b3WheelJoint_EnableSteering(jointId: Joint, flag: bool) void;

    /// Can the wheel steer?
    pub fn isSteeringEnabled(self: WheelJoint) bool {
        return b3WheelJoint_IsSteeringEnabled(self.joint);
    }
    extern fn b3WheelJoint_IsSteeringEnabled(jointId: Joint) bool;

    /// Set the wheel joint steering stiffness in Hertz.
    pub fn setSteeringHertz(self: WheelJoint, hertz: f32) void {
        return b3WheelJoint_SetSteeringHertz(self.joint, hertz);
    }
    extern fn b3WheelJoint_SetSteeringHertz(jointId: Joint, hertz: f32) void;

    /// Get the wheel joint steering stiffness in Hertz.
    pub fn getSteeringHertz(self: WheelJoint) f32 {
        return b3WheelJoint_GetSteeringHertz(self.joint);
    }
    extern fn b3WheelJoint_GetSteeringHertz(jointId: Joint) f32;

    /// Set the wheel joint steering damping ratio, non-dimensional.
    pub fn setSteeringDampingRatio(self: WheelJoint, dampingRatio: f32) void {
        return b3WheelJoint_SetSteeringDampingRatio(self.joint, dampingRatio);
    }
    extern fn b3WheelJoint_SetSteeringDampingRatio(jointId: Joint, dampingRatio: f32) void;

    /// Get the wheel joint steering damping ratio, non-dimensional.
    pub fn getSteeringDampingRatio(self: WheelJoint) f32 {
        return b3WheelJoint_GetSteeringDampingRatio(self.joint);
    }
    extern fn b3WheelJoint_GetSteeringDampingRatio(jointId: Joint) f32;

    /// Set the wheel joint maximum steering torque in N*m.
    pub fn setMaxSteeringTorque(self: WheelJoint, torque: f32) void {
        return b3WheelJoint_SetMaxSteeringTorque(self.joint, torque);
    }
    extern fn b3WheelJoint_SetMaxSteeringTorque(jointId: Joint, torque: f32) void;

    /// Get the wheel joint maximum steering torque in N*m.
    pub fn getMaxSteeringTorque(self: WheelJoint) f32 {
        return b3WheelJoint_GetMaxSteeringTorque(self.joint);
    }
    extern fn b3WheelJoint_GetMaxSteeringTorque(jointId: Joint) f32;

    /// Enable/disable the wheel joint steering limit.
    pub fn enableSteeringLimit(self: WheelJoint, flag: bool) void {
        return b3WheelJoint_EnableSteeringLimit(self.joint, flag);
    }
    extern fn b3WheelJoint_EnableSteeringLimit(jointId: Joint, flag: bool) void;

    /// Is the wheel joint steering limit enabled?
    pub fn isSteeringLimitEnabled(self: WheelJoint) bool {
        return b3WheelJoint_IsSteeringLimitEnabled(self.joint);
    }
    extern fn b3WheelJoint_IsSteeringLimitEnabled(jointId: Joint) bool;

    /// Get the wheel joint lower steering limit in radians.
    pub fn getLowerSteeringLimit(self: WheelJoint) f32 {
        return b3WheelJoint_GetLowerSteeringLimit(self.joint);
    }
    extern fn b3WheelJoint_GetLowerSteeringLimit(jointId: Joint) f32;

    /// Get the wheel joint upper steering limit in radians.
    pub fn getUpperSteeringLimit(self: WheelJoint) f32 {
        return b3WheelJoint_GetUpperSteeringLimit(self.joint);
    }
    extern fn b3WheelJoint_GetUpperSteeringLimit(jointId: Joint) f32;

    /// Set the wheel joint steering limits in radians.
    pub fn setSteeringLimits(self: WheelJoint, lowerRadians: f32, upperRadians: f32) void {
        return b3WheelJoint_SetSteeringLimits(self.joint, lowerRadians, upperRadians);
    }
    extern fn b3WheelJoint_SetSteeringLimits(jointId: Joint, lowerRadians: f32, upperRadians: f32) void;

    /// Set the wheel joint target steering angle in radians.
    pub fn setTargetSteeringAngle(self: WheelJoint, radians: f32) void {
        return b3WheelJoint_SetTargetSteeringAngle(self.joint, radians);
    }
    extern fn b3WheelJoint_SetTargetSteeringAngle(jointId: Joint, radians: f32) void;

    /// Get the wheel joint target steering angle in radians.
    pub fn getTargetSteeringAngle(self: WheelJoint) f32 {
        return b3WheelJoint_GetTargetSteeringAngle(self.joint);
    }
    extern fn b3WheelJoint_GetTargetSteeringAngle(jointId: Joint) f32;

    /// Get the current steering angle in radians.
    pub fn getSteeringAngle(self: WheelJoint) f32 {
        return b3WheelJoint_GetSteeringAngle(self.joint);
    }
    extern fn b3WheelJoint_GetSteeringAngle(jointId: Joint) f32;

    /// Get the current steering torque in N*m.
    pub fn getSteeringTorque(self: WheelJoint) f32 {
        return b3WheelJoint_GetSteeringTorque(self.joint);
    }
    extern fn b3WheelJoint_GetSteeringTorque(jointId: Joint) f32;
};
