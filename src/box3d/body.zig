//! Body (box3d.h, types.h)

const std = @import("std");

const b3 = @import("../box3d.zig");
const AABB = b3.AABB;
const BodyCastResult = b3.BodyCastResult;
const BodyPlaneResult = b3.BodyPlaneResult;
const BodyTOIResult = b3.BodyTOIResult;
const Capsule = b3.Capsule;
const CompoundData = b3.CompoundData;
const ContactData = b3.ContactData;
const HeightFieldData = b3.HeightFieldData;
const HullData = b3.HullData;
const Joint = b3.Joint;
const MassData = b3.MassData;
const Matrix3 = b3.Matrix3;
const MeshData = b3.MeshData;
const Pos = b3.Pos;
const Quat = b3.Quat;
const QueryFilter = b3.QueryFilter;
const Shape = b3.Shape;
const ShapeDef = b3.ShapeDef;
const ShapeProxy = b3.ShapeProxy;
const Sphere = b3.Sphere;
const Transform = b3.Transform;
const Vec3 = b3.Vec3;
const World = b3.World;
const WorldTransform = b3.WorldTransform;

/// Body id references a body instance. This should be treated as an opaque handle.
pub const Body = extern struct {
    index1: i32 = 0,
    world0: u16 = 0,
    generation: u16 = 0,

    /// A null id. Zero initialization also gives a null id.
    pub const null_id: Body = .{};

    /// Is this id null?
    pub fn isNull(id: Body) bool {
        return id.index1 == 0;
    }

    /// Is this id non-null?
    pub fn isNonNull(id: Body) bool {
        return id.index1 != 0;
    }

    /// Compare two ids for equality.
    pub fn eql(a: Body, b: Body) bool {
        return a.index1 == b.index1 and a.world0 == b.world0 and a.generation == b.generation;
    }

    /// Store a body id into a u64.
    pub fn store(id: Body) u64 {
        return @as(u64, @as(u32, @bitCast(id.index1))) << 32 | @as(u64, id.world0) << 16 | id.generation;
    }

    /// Load a u64 into a body id.
    pub fn load(x: u64) Body {
        return .{ .index1 = @bitCast(@as(u32, @truncate(x >> 32))), .world0 = @truncate(x >> 16), .generation = @truncate(x) };
    }

    /// The closest point on a body and its distance to the target.
    pub const ClosestPoint = struct {
        point: Vec3,
        distance: f32,
    };

    /// Destroy a rigid body given an id. This destroys all shapes and joints attached to the body.
    /// Do not keep references to the associated shapes and joints.
    pub const destroy = b3DestroyBody;
    extern fn b3DestroyBody(bodyId: Body) void;

    /// Body identifier validation. A valid body exists in a world and is non-null.
    /// This can be used to detect orphaned ids. Provides validation for up to 64K allocations.
    pub const isValid = b3Body_IsValid;
    extern fn b3Body_IsValid(id: Body) bool;

    /// Get the body type: static, kinematic, or dynamic
    pub const getType = b3Body_GetType;
    extern fn b3Body_GetType(bodyId: Body) BodyType;

    /// Change the body type. This is an expensive operation. This automatically updates the mass
    /// properties regardless of the automatic mass setting.
    pub const setType = b3Body_SetType;
    extern fn b3Body_SetType(bodyId: Body, bodyType: BodyType) void;

    /// Set the body name.
    pub const setName = b3Body_SetName;
    extern fn b3Body_SetName(bodyId: Body, name: [*:0]const u8) void;

    /// Get the body name. Returns an empty string if the name isn't set.
    pub fn getName(bodyId: Body) [:0]const u8 {
        return std.mem.span(b3Body_GetName(bodyId));
    }
    extern fn b3Body_GetName(bodyId: Body) [*:0]const u8;

    /// Set the user data for a body
    pub const setUserData = b3Body_SetUserData;
    extern fn b3Body_SetUserData(bodyId: Body, userData: ?*anyopaque) void;

    /// Get the user data stored in a body
    pub const getUserData = b3Body_GetUserData;
    extern fn b3Body_GetUserData(bodyId: Body) ?*anyopaque;

    /// Get the world position of a body. This is the location of the body origin.
    pub const getPosition = b3Body_GetPosition;
    extern fn b3Body_GetPosition(bodyId: Body) Pos;

    /// Get the world rotation of a body as a quaternion
    pub const getRotation = b3Body_GetRotation;
    extern fn b3Body_GetRotation(bodyId: Body) Quat;

    /// Get the world transform of a body.
    pub const getTransform = b3Body_GetTransform;
    extern fn b3Body_GetTransform(bodyId: Body) WorldTransform;

    /// Set the world transform of a body. This acts as a teleport and is fairly expensive.
    /// Note: Generally you should create a body with the intended transform.
    /// See `BodyDef.position` and `BodyDef.rotation`.
    pub const setTransform = b3Body_SetTransform;
    extern fn b3Body_SetTransform(bodyId: Body, position: Pos, rotation: Quat) void;

    /// Get a local point on a body given a world point.
    pub const getLocalPoint = b3Body_GetLocalPoint;
    extern fn b3Body_GetLocalPoint(bodyId: Body, worldPoint: Pos) Vec3;

    /// Get a world point on a body given a local point.
    pub const getWorldPoint = b3Body_GetWorldPoint;
    extern fn b3Body_GetWorldPoint(bodyId: Body, localPoint: Vec3) Pos;

    /// Get a local vector on a body given a world vector.
    pub const getLocalVector = b3Body_GetLocalVector;
    extern fn b3Body_GetLocalVector(bodyId: Body, worldVector: Vec3) Vec3;

    /// Get a world vector on a body given a local vector.
    pub const getWorldVector = b3Body_GetWorldVector;
    extern fn b3Body_GetWorldVector(bodyId: Body, localVector: Vec3) Vec3;

    /// Get the linear velocity of a body's center of mass. Usually in meters per second.
    pub const getLinearVelocity = b3Body_GetLinearVelocity;
    extern fn b3Body_GetLinearVelocity(bodyId: Body) Vec3;

    /// Get the angular velocity of a body in radians per second.
    pub const getAngularVelocity = b3Body_GetAngularVelocity;
    extern fn b3Body_GetAngularVelocity(bodyId: Body) Vec3;

    /// Set the linear velocity of a body at the center of mass. Usually in meters per second.
    pub const setLinearVelocity = b3Body_SetLinearVelocity;
    extern fn b3Body_SetLinearVelocity(bodyId: Body, linearVelocity: Vec3) void;

    /// Set the angular velocity of a body in radians per second.
    pub const setAngularVelocity = b3Body_SetAngularVelocity;
    extern fn b3Body_SetAngularVelocity(bodyId: Body, angularVelocity: Vec3) void;

    /// Set the velocity to reach the given transform after a given time step.
    /// The result will be close but maybe not exact. This is meant for kinematic bodies.
    /// The target is not applied if the velocity would be below the sleep threshold.
    /// This will optionally wake the body if asleep, but only if the movement is significant.
    pub const setTargetTransform = b3Body_SetTargetTransform;
    extern fn b3Body_SetTargetTransform(bodyId: Body, target: WorldTransform, timeStep: f32, wake: bool) void;

    /// Get the linear velocity of a local point attached to a body. Usually in meters per second.
    pub const getLocalPointVelocity = b3Body_GetLocalPointVelocity;
    extern fn b3Body_GetLocalPointVelocity(bodyId: Body, localPoint: Vec3) Vec3;

    /// Get the linear velocity of a world point attached to a body. Usually in meters per second.
    pub const getWorldPointVelocity = b3Body_GetWorldPointVelocity;
    extern fn b3Body_GetWorldPointVelocity(bodyId: Body, worldPoint: Pos) Vec3;

    /// Apply a force at a world point. If the force is not applied at the center of mass,
    /// it will generate a torque and affect the angular velocity. This optionally wakes up the body.
    /// The force is ignored if the body is not awake.
    /// - `bodyId`: The body id
    /// - `force`: The world force vector, usually in newtons (N)
    /// - `point`: The world position of the point of application
    /// - `wake`: Option to wake up the body
    pub const applyForce = b3Body_ApplyForce;
    extern fn b3Body_ApplyForce(bodyId: Body, force: Vec3, point: Pos, wake: bool) void;

    /// Apply a force to the center of mass. This optionally wakes up the body.
    /// The force is ignored if the body is not awake.
    /// - `bodyId`: The body id
    /// - `force`: the world force vector, usually in newtons (N).
    /// - `wake`: also wake up the body
    pub const applyForceToCenter = b3Body_ApplyForceToCenter;
    extern fn b3Body_ApplyForceToCenter(bodyId: Body, force: Vec3, wake: bool) void;

    /// Apply a torque. This affects the angular velocity without affecting the linear velocity.
    /// This optionally wakes the body. The torque is ignored if the body is not awake.
    /// - `bodyId`: The body id
    /// - `torque`: the world torque vector, usually in N*m.
    /// - `wake`: also wake up the body
    pub const applyTorque = b3Body_ApplyTorque;
    extern fn b3Body_ApplyTorque(bodyId: Body, torque: Vec3, wake: bool) void;

    /// Apply an impulse at a point. This immediately modifies the velocity.
    /// It also modifies the angular velocity if the point of application
    /// is not at the center of mass. This optionally wakes the body.
    /// The impulse is ignored if the body is not awake.
    /// - `bodyId`: The body id
    /// - `impulse`: the world impulse vector, usually in N*s or kg*m/s.
    /// - `point`: the world position of the point of application.
    /// - `wake`: also wake up the body
    /// Warning: This should be used for one-shot impulses. If you need a steady force,
    /// use a force instead, which will work better with the sub-stepping solver.
    pub const applyLinearImpulse = b3Body_ApplyLinearImpulse;
    extern fn b3Body_ApplyLinearImpulse(bodyId: Body, impulse: Vec3, point: Pos, wake: bool) void;

    /// Apply an impulse to the center of mass. This immediately modifies the velocity.
    /// The impulse is ignored if the body is not awake. This optionally wakes the body.
    /// - `bodyId`: The body id
    /// - `impulse`: the world impulse vector, usually in N*s or kg*m/s.
    /// - `wake`: also wake up the body
    /// Warning: This should be used for one-shot impulses. If you need a steady force,
    /// use a force instead, which will work better with the sub-stepping solver.
    pub const applyLinearImpulseToCenter = b3Body_ApplyLinearImpulseToCenter;
    extern fn b3Body_ApplyLinearImpulseToCenter(bodyId: Body, impulse: Vec3, wake: bool) void;

    /// Apply an angular impulse in world space. The impulse is ignored if the body is not awake.
    /// This optionally wakes the body.
    /// - `bodyId`: The body id
    /// - `impulse`: the world angular impulse vector, usually in units of kg*m*m/s
    /// - `wake`: also wake up the body
    /// Warning: This should be used for one-shot impulses. If you need a steady torque,
    /// use a torque instead, which will work better with the sub-stepping solver.
    pub const applyAngularImpulse = b3Body_ApplyAngularImpulse;
    extern fn b3Body_ApplyAngularImpulse(bodyId: Body, impulse: Vec3, wake: bool) void;

    /// Get the mass of the body, usually in kilograms
    pub const getMass = b3Body_GetMass;
    extern fn b3Body_GetMass(bodyId: Body) f32;

    /// Get the rotational inertia of the body in local space, usually in kg*m^2
    pub const getLocalRotationalInertia = b3Body_GetLocalRotationalInertia;
    extern fn b3Body_GetLocalRotationalInertia(bodyId: Body) Matrix3;

    /// Get the inverse mass of the body, usually in 1/kilograms
    pub const getInverseMass = b3Body_GetInverseMass;
    extern fn b3Body_GetInverseMass(bodyId: Body) f32;

    /// Get the inverse rotational inertia of the body in world space, usually in 1/kg*m^2
    pub const getWorldInverseRotationalInertia = b3Body_GetWorldInverseRotationalInertia;
    extern fn b3Body_GetWorldInverseRotationalInertia(bodyId: Body) Matrix3;

    /// Get the center of mass position of the body in local space
    pub const getLocalCenter = b3Body_GetLocalCenter;
    extern fn b3Body_GetLocalCenter(bodyId: Body) Vec3;

    /// Get the center of mass position of the body in world space
    pub const getWorldCenter = b3Body_GetWorldCenter;
    extern fn b3Body_GetWorldCenter(bodyId: Body) Pos;

    /// Override the body's mass properties. Normally this is computed automatically using the
    /// shape geometry and density. This information is lost if a shape is added or removed or if the
    /// body type changes.
    pub const setMassData = b3Body_SetMassData;
    extern fn b3Body_SetMassData(bodyId: Body, massData: MassData) void;

    /// Get the mass data for a body
    pub const getMassData = b3Body_GetMassData;
    extern fn b3Body_GetMassData(bodyId: Body) MassData;

    /// This updates the mass properties to the sum of the mass properties of the shapes.
    /// This normally does not need to be called unless you called SetMassData to override
    /// the mass and you later want to reset the mass.
    /// You may also use this when automatic mass computation has been disabled.
    /// You should call this regardless of body type.
    pub const applyMassFromShapes = b3Body_ApplyMassFromShapes;
    extern fn b3Body_ApplyMassFromShapes(bodyId: Body) void;

    /// Adjust the linear damping. Normally this is set in `BodyDef` before creation.
    pub const setLinearDamping = b3Body_SetLinearDamping;
    extern fn b3Body_SetLinearDamping(bodyId: Body, linearDamping: f32) void;

    /// Get the current linear damping.
    pub const getLinearDamping = b3Body_GetLinearDamping;
    extern fn b3Body_GetLinearDamping(bodyId: Body) f32;

    /// Adjust the angular damping. Normally this is set in `BodyDef` before creation.
    pub const setAngularDamping = b3Body_SetAngularDamping;
    extern fn b3Body_SetAngularDamping(bodyId: Body, angularDamping: f32) void;

    /// Get the current angular damping.
    pub const getAngularDamping = b3Body_GetAngularDamping;
    extern fn b3Body_GetAngularDamping(bodyId: Body) f32;

    /// Adjust the gravity scale. Normally this is set in `BodyDef` before creation.
    /// See `BodyDef.gravityScale`.
    pub const setGravityScale = b3Body_SetGravityScale;
    extern fn b3Body_SetGravityScale(bodyId: Body, gravityScale: f32) void;

    /// Get the current gravity scale
    pub const getGravityScale = b3Body_GetGravityScale;
    extern fn b3Body_GetGravityScale(bodyId: Body) f32;

    /// Returns true if this body is awake
    pub const isAwake = b3Body_IsAwake;
    extern fn b3Body_IsAwake(bodyId: Body) bool;

    /// Wake a body from sleep. This wakes the entire island the body is touching.
    /// Warning: Putting a body to sleep will put the entire island of bodies touching this body to sleep,
    /// which can be expensive and possibly unintuitive.
    pub const setAwake = b3Body_SetAwake;
    extern fn b3Body_SetAwake(bodyId: Body, awake: bool) void;

    /// Enable or disable sleeping for this body. If sleeping is disabled the body will wake.
    pub const enableSleep = b3Body_EnableSleep;
    extern fn b3Body_EnableSleep(bodyId: Body, flag: bool) void;

    /// Returns true if sleeping is enabled for this body
    pub const isSleepEnabled = b3Body_IsSleepEnabled;
    extern fn b3Body_IsSleepEnabled(bodyId: Body) bool;

    /// Set the sleep threshold, usually in meters per second
    pub const setSleepThreshold = b3Body_SetSleepThreshold;
    extern fn b3Body_SetSleepThreshold(bodyId: Body, sleepThreshold: f32) void;

    /// Get the sleep threshold, usually in meters per second.
    pub const getSleepThreshold = b3Body_GetSleepThreshold;
    extern fn b3Body_GetSleepThreshold(bodyId: Body) f32;

    /// Set the continuous collision safety factor. Smaller is safer but can lead to hitching. Recommended range [0.01, 0.5]. Non-dimensional.
    pub const setSafetyFactor = b3Body_SetSafetyFactor;
    extern fn b3Body_SetSafetyFactor(bodyId: Body, safetyFactor: f32) void;

    /// Get the continuous collision safety factor. Non-dimensional.
    pub const getSafetyFactor = b3Body_GetSafetyFactor;
    extern fn b3Body_GetSafetyFactor(bodyId: Body) f32;

    /// Returns true if this body is enabled
    pub const isEnabled = b3Body_IsEnabled;
    extern fn b3Body_IsEnabled(bodyId: Body) bool;

    /// Disable a body by removing it completely from the simulation. This is expensive.
    pub const disable = b3Body_Disable;
    extern fn b3Body_Disable(bodyId: Body) void;

    /// Enable a body by adding it to the simulation. This is expensive.
    pub const enable = b3Body_Enable;
    extern fn b3Body_Enable(bodyId: Body) void;

    /// Set the motion locks on this body.
    pub const setMotionLocks = b3Body_SetMotionLocks;
    extern fn b3Body_SetMotionLocks(bodyId: Body, locks: MotionLocks) void;

    /// Get the motion locks for this body.
    pub const getMotionLocks = b3Body_GetMotionLocks;
    extern fn b3Body_GetMotionLocks(bodyId: Body) MotionLocks;

    /// Set this body to be a bullet. A bullet does continuous collision detection
    /// against dynamic bodies (but not other bullets).
    pub const setBullet = b3Body_SetBullet;
    extern fn b3Body_SetBullet(bodyId: Body, flag: bool) void;

    /// Is this body a bullet?
    pub const isBullet = b3Body_IsBullet;
    extern fn b3Body_IsBullet(bodyId: Body) bool;

    /// Allow this body to rotate fast. Useful for axially symmetric bodies, such as vehicle wheels.
    /// Normally rotation speed is clamped to improve CCD. However, this clamping is unnecessary for
    /// bodies that only rotate fast around an axis of symmetry.
    pub const allowFastRotation = b3Body_AllowFastRotation;
    extern fn b3Body_AllowFastRotation(bodyId: Body, flag: bool) void;

    /// Is this body allowed to rotate fast?
    pub const isFastRotationAllowed = b3Body_IsFastRotationAllowed;
    extern fn b3Body_IsFastRotationAllowed(bodyId: Body) bool;

    /// Enable or disable contact recycling for this body. Contact recycling is a performance optimization
    /// that reuses contact manifolds when bodies move slightly. Disabling it can avoid ghost collisions
    /// on characters at the cost of higher per-step work. Existing contacts retain their prior setting;
    /// only contacts created after this call see the new value.
    /// See `BodyDef.enableContactRecycling`.
    pub const enableContactRecycling = b3Body_EnableContactRecycling;
    extern fn b3Body_EnableContactRecycling(bodyId: Body, flag: bool) void;

    /// Is contact recycling enabled on this body?
    pub const isContactRecyclingEnabled = b3Body_IsContactRecyclingEnabled;
    extern fn b3Body_IsContactRecyclingEnabled(bodyId: Body) bool;

    /// Enable/disable hit events on all shapes
    /// See `ShapeDef.enableHitEvents`.
    pub const enableHitEvents = b3Body_EnableHitEvents;
    extern fn b3Body_EnableHitEvents(bodyId: Body, flag: bool) void;

    /// Get the world that owns this body
    pub const getWorld = b3Body_GetWorld;
    extern fn b3Body_GetWorld(bodyId: Body) World;

    /// Get the number of shapes on this body
    pub const getShapeCount = b3Body_GetShapeCount;
    extern fn b3Body_GetShapeCount(bodyId: Body) c_int;

    /// Get the shape ids for all shapes on this body, up to the provided capacity.
    /// Returns the number of shape ids stored in the user array
    pub fn getShapes(bodyId: Body, shapeArray: []Shape) []Shape {
        return shapeArray[0..@intCast(b3Body_GetShapes(bodyId, shapeArray.ptr, @intCast(shapeArray.len)))];
    }
    extern fn b3Body_GetShapes(bodyId: Body, shapeArray: [*]Shape, capacity: c_int) c_int;

    /// Get the number of joints on this body
    pub const getJointCount = b3Body_GetJointCount;
    extern fn b3Body_GetJointCount(bodyId: Body) c_int;

    /// Get the joint ids for all joints on this body, up to the provided capacity
    /// Returns the number of joint ids stored in the user array
    pub fn getJoints(bodyId: Body, jointArray: []Joint) []Joint {
        return jointArray[0..@intCast(b3Body_GetJoints(bodyId, jointArray.ptr, @intCast(jointArray.len)))];
    }
    extern fn b3Body_GetJoints(bodyId: Body, jointArray: [*]Joint, capacity: c_int) c_int;

    /// Get the maximum capacity required for retrieving all the touching contacts on a body
    pub const getContactCapacity = b3Body_GetContactCapacity;
    extern fn b3Body_GetContactCapacity(bodyId: Body) c_int;

    /// Get the touching contact data for a body
    pub fn getContactData(bodyId: Body, contactData: []ContactData) []ContactData {
        return contactData[0..@intCast(b3Body_GetContactData(bodyId, contactData.ptr, @intCast(contactData.len)))];
    }
    extern fn b3Body_GetContactData(bodyId: Body, contactData: [*]ContactData, capacity: c_int) c_int;

    /// Get the current world AABB that contains all the attached shapes. Note that this may not encompass the body origin.
    /// If there are no shapes attached then the returned AABB is empty and centered on the body origin.
    pub const computeAABB = b3Body_ComputeAABB;
    extern fn b3Body_ComputeAABB(bodyId: Body) AABB;

    /// The minimum distance from any shape to the shape centroid.
    pub const getMinExtent = b3Body_GetMinExtent;
    extern fn b3Body_GetMinExtent(bodyId: Body) f32;

    /// The maximum extent vector from any point on the body shapes to the center of mass.
    pub const getMaxExtent = b3Body_GetMaxExtent;
    extern fn b3Body_GetMaxExtent(bodyId: Body) Vec3;

    /// The maximum extent vector from any point on the body shapes to the body origin. Conservative.
    pub const getMaxExtentOrigin = b3Body_GetMaxExtentOrigin;
    extern fn b3Body_GetMaxExtentOrigin(bodyId: Body) Vec3;

    /// Get the closest point on a body to a world target.
    pub fn getClosestPoint(bodyId: Body, target: Vec3) ClosestPoint {
        var point: Vec3 = undefined;
        const distance = b3Body_GetClosestPoint(bodyId, &point, target);
        return .{ .point = point, .distance = distance };
    }
    extern fn b3Body_GetClosestPoint(bodyId: Body, result: *Vec3, target: Vec3) f32;

    /// Cast a ray at a specific body using a specified body transform.
    /// Ignores back-side collision on meshes and height-fields.
    pub const castRay = b3Body_CastRay;
    extern fn b3Body_CastRay(bodyId: Body, origin: Pos, translation: Vec3, filter: QueryFilter, maxFraction: f32, bodyTransform: WorldTransform) BodyCastResult;

    /// Cast a shape at a specific body using a specified body transform.
    /// Ignores back-side collision on meshes and height-fields.
    pub const castShape = b3Body_CastShape;
    extern fn b3Body_CastShape(bodyId: Body, origin: Pos, proxy: *const ShapeProxy, translation: Vec3, filter: QueryFilter, maxFraction: f32, canEncroach: bool, bodyTransform: WorldTransform) BodyCastResult;

    /// Overlap a shape with a specific body using a specified body transform.
    pub const overlapShape = b3Body_OverlapShape;
    extern fn b3Body_OverlapShape(bodyId: Body, origin: Pos, proxy: *const ShapeProxy, filter: QueryFilter, bodyTransform: WorldTransform) bool;

    /// Collide a character mover with a specific body using a specified body transform.
    /// Only considers convex shapes on the body.
    pub fn collideMover(
        bodyId: Body,
        bodyPlanes: []BodyPlaneResult,
        origin: Pos,
        mover: *const Capsule,
        filter: QueryFilter,
        bodyTransform: WorldTransform,
    ) []BodyPlaneResult {
        const n = b3Body_CollideMover(bodyId, bodyPlanes.ptr, @intCast(bodyPlanes.len), origin, mover, filter, bodyTransform);
        return bodyPlanes[0..@intCast(n)];
    }
    extern fn b3Body_CollideMover(bodyId: Body, bodyPlanes: [*]BodyPlaneResult, planeCapacity: c_int, origin: Pos, mover: *const Capsule, filter: QueryFilter, bodyTransform: WorldTransform) c_int;

    /// Perform a time of impact between a character mover and a body using specified sweep transforms.
    /// Initial overlap of any shape on the body is ignored. A non-overlapped shape can still be hit.
    /// Only considers convex shapes on the body.
    pub const timeOfImpactMover = b3Body_TimeOfImpactMover;
    extern fn b3Body_TimeOfImpactMover(bodyId: Body, origin: Pos, mover: *const Capsule, moverTranslation: Vec3, filter: QueryFilter, bodyTransform1: WorldTransform, bodyTransform2: WorldTransform) BodyTOIResult;

    /// Create a circle shape and attach it to a body. The shape definition and geometry are fully cloned.
    /// Contacts are not created until the next time step.
    /// Returns the shape id for accessing the shape
    pub const createSphereShape = b3CreateSphereShape;
    extern fn b3CreateSphereShape(bodyId: Body, def: *const ShapeDef, sphere: *const Sphere) Shape;

    /// Create a capsule shape and attach it to a body. The shape definition and geometry are fully cloned.
    /// Contacts are not created until the next time step.
    /// Returns the shape id for accessing the shape
    pub const createCapsuleShape = b3CreateCapsuleShape;
    extern fn b3CreateCapsuleShape(bodyId: Body, def: *const ShapeDef, capsule: *const Capsule) Shape;

    /// Create a convex hull shape and attach it to a body. The shape definition is fully cloned. Contacts are not created
    /// until the next time step.
    /// Returns the shape id for accessing the shape
    pub const createHullShape = b3CreateHullShape;
    extern fn b3CreateHullShape(bodyId: Body, def: *const ShapeDef, hull: *const HullData) Shape;

    /// Create a convex hull shape and attach it to a body. The hull is cloned then transformed with scale applied first.
    /// Use this for non-uniform or mirrored scale or a baked local transform. The baked result is shared through the
    /// world hull database. The shape definition and geometry are fully cloned. Contacts are not created until the next time step.
    /// Returns the shape id for accessing the shape
    pub const createTransformedHullShape = b3CreateTransformedHullShape;
    extern fn b3CreateTransformedHullShape(bodyId: Body, def: *const ShapeDef, hull: *const HullData, transform: Transform, scale: Vec3) Shape;

    /// Create a mesh hull shape and attach it to a body. The shape definition is fully cloned but the mesh is not.
    /// Contacts are not created until the next time step.
    /// Mesh collision only creates contacts on static bodies.
    /// Warning: this holds reference to the input mesh data which must remain valid for the lifetime of this shape
    /// Returns the shape id for accessing the shape
    pub const createMeshShape = b3CreateMeshShape;
    extern fn b3CreateMeshShape(bodyId: Body, def: *const ShapeDef, mesh: *const MeshData, scale: Vec3) Shape;

    /// Create a height-field shape and attach it to a body. The shape definition is fully cloned but the height field is not.
    /// Contacts are not created until the next time step.
    /// Height field is only allowed on static bodies.
    /// Warning: this holds reference to the input height field which must remain valid for the lifetime of this shape
    /// Returns the shape id for accessing the shape
    pub const createHeightFieldShape = b3CreateHeightFieldShape;
    extern fn b3CreateHeightFieldShape(bodyId: Body, def: *const ShapeDef, heightField: *const HeightFieldData) Shape;

    /// Baked compound shapes are only allowed on static bodies.
    /// Note: runtime compounds are achieved by adding multiple shapes to a body.
    /// Runtime compounds can be dynamic and/or kinematic.
    pub const createBakedCompoundShape = b3CreateBakedCompoundShape;
    extern fn b3CreateBakedCompoundShape(bodyId: Body, def: *const ShapeDef, compound: *const CompoundData) Shape;
};

/// The body simulation type.
/// Each body is one of these three types. The type determines how the body behaves in the simulation.
pub const BodyType = enum(c_int) {
    /// zero mass, zero velocity, may be manually moved
    static = 0,
    /// zero mass, velocity set by user, moved by solver
    kinematic = 1,
    /// positive mass, velocity determined by forces, moved by solver
    dynamic = 2,

    /// The number of BodyType values.
    pub const count = 3;
};

/// Motion locks to restrict the body movement
pub const MotionLocks = extern struct {
    /// Prevent translation along the x-axis
    linearX: bool,
    /// Prevent translation along the y-axis
    linearY: bool,
    /// Prevent translation along the z-axis
    linearZ: bool,
    /// Prevent rotation around the x-axis
    angularX: bool,
    /// Prevent rotation around the y-axis
    angularY: bool,
    /// Prevent rotation around the z-axis
    angularZ: bool,
};

/// A body definition holds all the data needed to construct a rigid body.
/// You can safely re-use body definitions. Shapes are added to a body after construction.
/// Body definitions are temporary objects used to bundle creation parameters.
/// Must be initialized using `BodyDef.default`.
pub const BodyDef = extern struct {
    /// The body type: static, kinematic, or dynamic.
    type: BodyType,
    /// The initial world position of the body. Bodies should be created with the desired position.
    /// Note: Creating bodies at the origin and then moving them nearly doubles the cost of body creation, especially
    /// if the body is moved after shapes have been added.
    position: Pos,
    /// The initial world rotation of the body.
    rotation: Quat,
    /// The initial linear velocity of the body's origin. Usually in meters per second.
    linearVelocity: Vec3,
    /// The initial angular velocity of the body. Radians per second.
    angularVelocity: Vec3,
    /// Linear damping is used to reduce the linear velocity. The damping parameter
    /// can be larger than 1 but the damping effect becomes sensitive to the
    /// time step when the damping parameter is large.
    /// Generally linear damping is undesirable because it makes objects move slowly
    /// as if they are floating.
    linearDamping: f32,
    /// Angular damping is used to reduce the angular velocity. The damping parameter
    /// can be larger than 1.0f but the damping effect becomes sensitive to the
    /// time step when the damping parameter is large.
    /// Angular damping can be used to slow down rotating bodies.
    angularDamping: f32,
    /// Scale the gravity applied to this body. Non-dimensional.
    gravityScale: f32,
    /// Sleep speed threshold, default is 0.05 meters per second
    sleepThreshold: f32,
    /// Continuous collision safety factor. The solver only uses continuous collision if there is a
    /// risk of tunneling. If the body is moving fast enough to risk tunneling then it is considered a "fast body".
    /// This improves performance and prevents movement hitches. If a body moving N meter risks tunneling, then the
    /// body will be considered fast if it moves more than a safetyFactor times N meters over one full time step.
    /// Non-dimensional. Recommended range [0.01, 0.5]. Default is 0.5 for high performance with low tunneling risk.
    safetyFactor: f32,
    /// Optional body name for debugging.
    name: ?[*:0]const u8,
    /// Use this to store application specific body data.
    userData: ?*anyopaque,
    /// Motions locks to restrict linear and angular movement
    motionLocks: MotionLocks,
    /// Set this flag to false if this body should never fall asleep.
    enableSleep: bool,
    /// Is this body initially awake or sleeping?
    isAwake: bool,
    /// Treat this body as a high speed object that performs continuous collision detection
    /// against dynamic and kinematic bodies, but not other bullet bodies.
    /// Warning: Bullets should be used sparingly. They are not a solution for general dynamic-versus-dynamic
    /// continuous collision. They do not guarantee accurate collision if both bodies are fast moving because
    /// the bullet does a continuous check after all non-bullet bodies have moved. You could get unlucky and have
    /// the bullet body end a time step very close to a non-bullet body and the non-bullet body then moves over
    /// the bullet body. In continuous collision, initial overlap is ignored to avoid freezing bodies in place.
    /// I do not recommend using them for game projectiles if precise collision timing is needed. Instead consider
    /// using a ray or shape cast. You can use a marching ray or shape cast for projectile that moves over time.
    /// If you want a fast moving projectile to collide with a fast moving target, you need to consider the relative
    /// movement in your ray or shape cast. This is out of the scope of Box3D.
    /// So what are good use cases for bullets? Pinball games or games with dynamic containers that hold other objects.
    /// It should be a use case where it doesn't break the game if there is a collision missed, but having them
    /// captured improves the quality of the game.
    isBullet: bool,
    /// Used to disable a body. A disabled body does not move or collide.
    isEnabled: bool,
    /// This allows this body to bypass rotational speed limits. Should only be used
    /// for circular objects, like wheels.
    allowFastRotation: bool,
    /// Enable contact recycling. True by default. Leaving this enabled improves performance
    /// but may lead to ghost collision that should be avoided on characters.
    enableContactRecycling: bool,
    /// Used internally to detect a valid definition. DO NOT SET.
    internalValue: c_int,

    /// Use this to initialize your body definition
    pub const default = b3DefaultBodyDef;
    extern fn b3DefaultBodyDef() BodyDef;
};

/// Use this to initialize your body definition
pub const defaultBodyDef = BodyDef.default;

/// Create a rigid body given a definition. No reference to the definition is retained. So you can create the definition
/// on the stack and pass it as a pointer.
/// ```zig
/// const body_def = b3.defaultBodyDef();
/// const body = world.createBody(&body_def);
/// ```
/// Warning: This function is locked during callbacks.
pub const createBody = World.createBody;
