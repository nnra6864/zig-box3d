//! World (box3d.h, types.h)

const b3 = @import("../box3d.zig");
const AABB = b3.AABB;
const Body = b3.Body;
const BodyDef = b3.BodyDef;
const BodyEvents = b3.BodyEvents;
const Capsule = b3.Capsule;
const ContactEvents = b3.ContactEvents;
const CreateDebugShapeCallback = b3.CreateDebugShapeCallback;
const DebugDraw = b3.DebugDraw;
const DestroyDebugShapeCallback = b3.DestroyDebugShapeCallback;
const DistanceJoint = b3.DistanceJoint;
const DistanceJointDef = b3.DistanceJointDef;
const FilterJoint = b3.FilterJoint;
const FilterJointDef = b3.FilterJointDef;
const Joint = b3.Joint;
const JointEvents = b3.JointEvents;
const MotorJoint = b3.MotorJoint;
const MotorJointDef = b3.MotorJointDef;
const MoverFilterFcn = b3.MoverFilterFcn;
const ParallelJoint = b3.ParallelJoint;
const ParallelJointDef = b3.ParallelJointDef;
const PlaneResultFcn = b3.PlaneResultFcn;
const Pos = b3.Pos;
const PrismaticJoint = b3.PrismaticJoint;
const PrismaticJointDef = b3.PrismaticJointDef;
const QueryFilter = b3.QueryFilter;
const RayResult = b3.RayResult;
const Recording = b3.Recording;
const RevoluteJoint = b3.RevoluteJoint;
const RevoluteJointDef = b3.RevoluteJointDef;
const SensorEvents = b3.SensorEvents;
const Shape = b3.Shape;
const ShapeProxy = b3.ShapeProxy;
const SphericalJoint = b3.SphericalJoint;
const SphericalJointDef = b3.SphericalJointDef;
const TreeStats = b3.TreeStats;
const Vec3 = b3.Vec3;
const WeldJoint = b3.WeldJoint;
const WeldJointDef = b3.WeldJointDef;
const WheelJoint = b3.WheelJoint;
const WheelJointDef = b3.WheelJointDef;

/// World id references a world instance. This should be treated as an opaque handle.
pub const World = extern struct {
    index1: u16 = 0,
    generation: u16 = 0,

    /// A null id. Zero initialization also gives a null id.
    pub const null_id: World = .{};

    /// Is this id null?
    pub fn isNull(id: World) bool {
        return id.index1 == 0;
    }

    /// Is this id non-null?
    pub fn isNonNull(id: World) bool {
        return id.index1 != 0;
    }

    /// Compare two ids for equality.
    pub fn eql(a: World, b: World) bool {
        return a.index1 == b.index1 and a.generation == b.generation;
    }

    /// Store a world id into a u32.
    pub fn store(id: World) u32 {
        return @as(u32, id.index1) << 16 | id.generation;
    }

    /// Load a u32 into a world id.
    pub fn load(x: u32) World {
        return .{ .index1 = @truncate(x >> 16), .generation = @truncate(x) };
    }

    /// Create a world for rigid body simulation. A world contains bodies, shapes, and constraints. You may create
    /// up to 128 worlds. Each world is completely independent and may be simulated in parallel.
    /// Returns the world id.
    pub fn create(def: *const WorldDef) World {
        return b3CreateWorld(def);
    }
    // Box3D renames this symbol in large world mode so mismatched builds fail to link.
    const b3CreateWorld = @extern(*const fn (def: *const WorldDef) callconv(.c) World, .{
        .name = if (b3.double_precision) "b3CreateWorldDoublePrecision" else "b3CreateWorld",
    });

    /// Destroy a world
    pub const destroy = b3DestroyWorld;
    extern fn b3DestroyWorld(worldId: World) void;

    /// World id validation. Provides validation for up to 64K allocations.
    pub const isValid = b3World_IsValid;
    extern fn b3World_IsValid(id: World) bool;

    /// Simulate a world for one time step. This performs collision detection, integration, and constraint solution.
    /// A time step of zero runs the broad-phase and collision, but skips the solver. So you can still get contact
    /// and sensor events.
    /// - `worldId`: The world to simulate
    /// - `timeStep`: The amount of time to simulate, this should be a fixed number. Usually 1/60.
    /// - `subStepCount`: The number of sub-steps, increasing the sub-step count can increase accuracy. Usually 4.
    pub const step = b3World_Step;
    extern fn b3World_Step(worldId: World, timeStep: f32, subStepCount: c_int) void;

    /// Call this to draw shapes and other debug draw data
    pub const draw = b3World_Draw;
    extern fn b3World_Draw(worldId: World, debugDraw: *DebugDraw, maskBits: u64) void;

    /// Get the world's bounds. This is the bounding box that covers the current simulation. May have a small
    /// amount of padding.
    pub const getBounds = b3World_GetBounds;
    extern fn b3World_GetBounds(worldId: World) AABB;

    /// Get the body events for the current time step. The event data is transient. Do not store a reference to this data.
    pub fn getBodyEvents(worldId: World) BodyEvents {
        const e = b3World_GetBodyEvents(worldId);
        return .{ .moveEvents = if (e.moveEvents) |p| p[0..@intCast(e.moveCount)] else &.{} };
    }
    extern fn b3World_GetBodyEvents(worldId: World) BodyEvents.Extern;

    /// Get sensor events for the current time step. The event data is transient. Do not store a reference to this data.
    pub fn getSensorEvents(worldId: World) SensorEvents {
        const e = b3World_GetSensorEvents(worldId);
        return .{
            .beginEvents = if (e.beginEvents) |p| p[0..@intCast(e.beginCount)] else &.{},
            .endEvents = if (e.endEvents) |p| p[0..@intCast(e.endCount)] else &.{},
        };
    }
    extern fn b3World_GetSensorEvents(worldId: World) SensorEvents.Extern;

    /// Get contact events for this current time step. The event data is transient. Do not store a reference to this data.
    pub fn getContactEvents(worldId: World) ContactEvents {
        const e = b3World_GetContactEvents(worldId);
        return .{
            .beginEvents = if (e.beginEvents) |p| p[0..@intCast(e.beginCount)] else &.{},
            .endEvents = if (e.endEvents) |p| p[0..@intCast(e.endCount)] else &.{},
            .hitEvents = if (e.hitEvents) |p| p[0..@intCast(e.hitCount)] else &.{},
        };
    }
    extern fn b3World_GetContactEvents(worldId: World) ContactEvents.Extern;

    /// Get the joint events for the current time step. The event data is transient. Do not store a reference to this data.
    pub fn getJointEvents(worldId: World) JointEvents {
        const e = b3World_GetJointEvents(worldId);
        return .{ .jointEvents = if (e.jointEvents) |p| p[0..@intCast(e.count)] else &.{} };
    }
    extern fn b3World_GetJointEvents(worldId: World) JointEvents.Extern;

    /// Overlap test for all shapes that *potentially* overlap the provided AABB
    pub const overlapAABB = b3World_OverlapAABB;
    extern fn b3World_OverlapAABB(worldId: World, aabb: AABB, filter: QueryFilter, fcn: OverlapResultFcn, context: ?*anyopaque) TreeStats;

    /// Overlap test for all shapes that overlap the provided shape proxy. The proxy points are relative
    /// to the world origin, which lets the query stay precise far from the world origin.
    pub const overlapShape = b3World_OverlapShape;
    extern fn b3World_OverlapShape(worldId: World, origin: Pos, proxy: *const ShapeProxy, filter: QueryFilter, fcn: OverlapResultFcn, context: ?*anyopaque) TreeStats;

    /// Cast a ray into the world to collect shapes in the path of the ray.
    /// Your callback function controls whether you get the closest point, any point, or n-points.
    /// Ignores back-side collision on meshes and height-fields.
    /// Note: The callback function may receive shapes in any order
    /// - `worldId`: The world to cast the ray against
    /// - `origin`: The start point of the ray
    /// - `translation`: The translation of the ray from the start point to the end point
    /// - `filter`: Contains bit flags to filter unwanted shapes from the results
    /// - `fcn`: A user implemented callback function
    /// - `context`: A user context that is passed along to the callback function
    /// Returns traversal performance counters
    pub const castRay = b3World_CastRay;
    extern fn b3World_CastRay(worldId: World, origin: Pos, translation: Vec3, filter: QueryFilter, fcn: CastResultFcn, context: ?*anyopaque) TreeStats;

    /// Cast a ray into the world to collect the closest hit. This is a convenience function. Ignores initial overlap.
    /// This is less general than `World.castRay` and does not allow for custom filtering. Ignores back-side collision
    /// on meshes and height-fields.
    pub const castRayClosest = b3World_CastRayClosest;
    extern fn b3World_CastRayClosest(worldId: World, origin: Pos, translation: Vec3, filter: QueryFilter) RayResult;

    /// Cast a shape through the world. Similar to a cast ray except that a shape is cast instead of a point.
    /// The proxy points are relative to the origin and the hit points come back as world positions, so the
    /// cast stays precise far from the world origin. Ignores back-side collision on meshes and height-fields.
    /// See `World.castRay`.
    pub const castShape = b3World_CastShape;
    extern fn b3World_CastShape(worldId: World, origin: Pos, proxy: *const ShapeProxy, translation: Vec3, filter: QueryFilter, fcn: CastResultFcn, context: ?*anyopaque) TreeStats;

    /// Cast a capsule mover through the world. This is a special shape cast that handles sliding along other shapes while reducing
    /// clipping. This is not a good source of information about what the mover is touching. Instead use the planes returned by
    /// `World.collideMover`. Ignores back-side collision on meshes and height-fields.
    /// - `worldId`: World to cast the mover against
    /// - `origin`: World position the mover capsule is relative to
    /// - `mover`: Capsule mover, relative to the origin
    /// - `translation`: Desired mover translation
    /// - `filter`: Contains bit flags to filter unwanted shapes from the results
    /// - `fcn`: Optional callback for custom shape filtering
    /// - `context`: A user context that is passed along to the callback function
    /// Returns the translation fraction
    pub const castMover = b3World_CastMover;
    extern fn b3World_CastMover(worldId: World, origin: Pos, mover: *const Capsule, translation: Vec3, filter: QueryFilter, fcn: ?MoverFilterFcn, context: ?*anyopaque) f32;

    /// Collide a capsule mover with the world, gathering collision planes that can be fed to `solvePlanes`. Useful for
    /// kinematic character movement. The mover and the returned planes are relative to the origin.
    /// Ignores back-side collision on meshes and height-fields.
    pub const collideMover = b3World_CollideMover;
    extern fn b3World_CollideMover(worldId: World, origin: Pos, mover: *const Capsule, filter: QueryFilter, fcn: PlaneResultFcn, context: ?*anyopaque) void;

    /// Enable/disable sleep. If your application does not need sleeping, you can gain some performance
    /// by disabling sleep completely at the world level.
    /// See `WorldDef`.
    pub const enableSleeping = b3World_EnableSleeping;
    extern fn b3World_EnableSleeping(worldId: World, flag: bool) void;

    /// Is body sleeping enabled?
    pub const isSleepingEnabled = b3World_IsSleepingEnabled;
    extern fn b3World_IsSleepingEnabled(worldId: World) bool;

    /// Enable/disable continuous collision between dynamic and static bodies. Generally you should keep continuous
    /// collision enabled to prevent fast moving objects from going through static objects. The performance gain from
    /// disabling continuous collision is minor.
    /// See `WorldDef`.
    pub const enableContinuous = b3World_EnableContinuous;
    extern fn b3World_EnableContinuous(worldId: World, flag: bool) void;

    /// Is continuous collision enabled?
    pub const isContinuousEnabled = b3World_IsContinuousEnabled;
    extern fn b3World_IsContinuousEnabled(worldId: World) bool;

    /// Adjust the restitution threshold. It is recommended not to make this value very small
    /// because it will prevent bodies from sleeping. Usually in meters per second.
    /// See `WorldDef`.
    pub const setRestitutionThreshold = b3World_SetRestitutionThreshold;
    extern fn b3World_SetRestitutionThreshold(worldId: World, value: f32) void;

    /// Get the restitution speed threshold. Usually in meters per second.
    pub const getRestitutionThreshold = b3World_GetRestitutionThreshold;
    extern fn b3World_GetRestitutionThreshold(worldId: World) f32;

    /// Set the number of iterations used by the restitution solver.
    /// See `max_restitution_iterations`.
    pub const setRestitutionIterations = b3World_SetRestitutionIterations;
    extern fn b3World_SetRestitutionIterations(worldId: World, iterations: c_int) void;

    /// Get the number of iterations used by the restitution solver.
    pub const getRestitutionIterations = b3World_GetRestitutionIterations;
    extern fn b3World_GetRestitutionIterations(worldId: World) c_int;

    /// Enable restitution propagation.
    pub const enableRestitutionPropagation = b3World_EnableRestitutionPropagation;
    extern fn b3World_EnableRestitutionPropagation(worldId: World, flag: bool) void;

    /// Is restitution propagation enabled?
    pub const isRestitutionPropagationEnabled = b3World_IsRestitutionPropagationEnabled;
    extern fn b3World_IsRestitutionPropagationEnabled(worldId: World) bool;

    /// Adjust the hit event threshold. This controls the collision speed needed to generate a `ContactHitEvent`.
    /// Usually in meters per second.
    /// See `WorldDef.hitEventThreshold`.
    pub const setHitEventThreshold = b3World_SetHitEventThreshold;
    extern fn b3World_SetHitEventThreshold(worldId: World, value: f32) void;

    /// Get the hit event speed threshold. Usually in meters per second.
    pub const getHitEventThreshold = b3World_GetHitEventThreshold;
    extern fn b3World_GetHitEventThreshold(worldId: World) f32;

    /// Register the custom filter callback. This is optional.
    pub const setCustomFilterCallback = b3World_SetCustomFilterCallback;
    extern fn b3World_SetCustomFilterCallback(worldId: World, fcn: ?CustomFilterFcn, context: ?*anyopaque) void;

    /// Register the pre-solve callback. This is optional.
    pub const setPreSolveCallback = b3World_SetPreSolveCallback;
    extern fn b3World_SetPreSolveCallback(worldId: World, fcn: ?PreSolveFcn, context: ?*anyopaque) void;

    /// Set the gravity vector for the entire world. Box3D has no concept of an up direction and this
    /// is left as a decision for the application. Usually in m/s^2.
    /// See `WorldDef`.
    pub const setGravity = b3World_SetGravity;
    extern fn b3World_SetGravity(worldId: World, gravity: Vec3) void;

    /// Get the gravity vector
    pub const getGravity = b3World_GetGravity;
    extern fn b3World_GetGravity(worldId: World) Vec3;

    /// Apply a radial explosion
    /// - `worldId`: The world id
    /// - `explosionDef`: The explosion definition
    pub const explode = b3World_Explode;
    extern fn b3World_Explode(worldId: World, explosionDef: *const ExplosionDef) void;

    /// Adjust contact tuning parameters
    /// - `worldId`: The world id
    /// - `hertz`: The contact stiffness (cycles per second)
    /// - `dampingRatio`: The contact bounciness with 1 being critical damping (non-dimensional)
    /// - `contactSpeed`: The maximum contact constraint push out speed (meters per second)
    /// Note: Advanced feature
    pub const setContactTuning = b3World_SetContactTuning;
    extern fn b3World_SetContactTuning(worldId: World, hertz: f32, dampingRatio: f32, contactSpeed: f32) void;

    /// Set the contact point recycling distance. Setting this to zero disables contact point recycling.
    /// Usually in meters.
    pub const setContactRecycleDistance = b3World_SetContactRecycleDistance;
    extern fn b3World_SetContactRecycleDistance(worldId: World, recycleDistance: f32) void;

    /// Get the contact point recycling distance. Usually in meters.
    pub const getContactRecycleDistance = b3World_GetContactRecycleDistance;
    extern fn b3World_GetContactRecycleDistance(worldId: World) f32;

    /// Set the maximum linear speed. Usually in m/s.
    pub const setMaximumLinearSpeed = b3World_SetMaximumLinearSpeed;
    extern fn b3World_SetMaximumLinearSpeed(worldId: World, maximumLinearSpeed: f32) void;

    /// Get the maximum linear speed. Usually in m/s.
    pub const getMaximumLinearSpeed = b3World_GetMaximumLinearSpeed;
    extern fn b3World_GetMaximumLinearSpeed(worldId: World) f32;

    /// Set the tolerance for gyroscopic torque. [0, 1]
    /// Note: modifying this only affects new bodies or bodies that get their mass updated.
    pub const setIsotropicInertiaTolerance = b3World_SetIsotropicInertiaTolerance;
    extern fn b3World_SetIsotropicInertiaTolerance(worldId: World, tolerance: f32) void;

    /// Get the tolerance for gyroscopic torque. [0, 1]
    pub const getIsotropicInertiaTolerance = b3World_GetIsotropicInertiaTolerance;
    extern fn b3World_GetIsotropicInertiaTolerance(worldId: World) f32;

    /// Enable/disable constraint warm starting. Advanced feature for testing. Disabling
    /// warm starting greatly reduces stability and provides no performance gain.
    pub const enableWarmStarting = b3World_EnableWarmStarting;
    extern fn b3World_EnableWarmStarting(worldId: World, flag: bool) void;

    /// Is constraint warm starting enabled?
    pub const isWarmStartingEnabled = b3World_IsWarmStartingEnabled;
    extern fn b3World_IsWarmStartingEnabled(worldId: World) bool;

    /// Enable the SSE2 fallback even when AVX2 is present. This is for testing.
    /// Normally you should use the CMake build settings to disable AVX2.
    pub const enableSSE2Fallback = b3World_EnableSSE2Fallback;
    extern fn b3World_EnableSSE2Fallback(worldId: World, flag: bool) void;

    /// Get the number of awake bodies
    pub const getAwakeBodyCount = b3World_GetAwakeBodyCount;
    extern fn b3World_GetAwakeBodyCount(worldId: World) c_int;

    /// Get the current world performance profile
    pub const getProfile = b3World_GetProfile;
    extern fn b3World_GetProfile(worldId: World) Profile;

    /// Get world counters and sizes
    pub const getCounters = b3World_GetCounters;
    extern fn b3World_GetCounters(worldId: World) Counters;

    /// Get max capacity. This can be used with `WorldDef` to avoid run-time allocations and copies
    pub const getMaxCapacity = b3World_GetMaxCapacity;
    extern fn b3World_GetMaxCapacity(worldId: World) Capacity;

    /// Set the user data pointer.
    pub const setUserData = b3World_SetUserData;
    extern fn b3World_SetUserData(worldId: World, userData: ?*anyopaque) void;

    /// Get the user data pointer.
    pub const getUserData = b3World_GetUserData;
    extern fn b3World_GetUserData(worldId: World) ?*anyopaque;

    /// Set the friction callback. Passing null resets to default.
    pub const setFrictionCallback = b3World_SetFrictionCallback;
    extern fn b3World_SetFrictionCallback(worldId: World, callback: ?FrictionCallback) void;

    /// Set the restitution callback. Passing null resets to default.
    pub const setRestitutionCallback = b3World_SetRestitutionCallback;
    extern fn b3World_SetRestitutionCallback(worldId: World, callback: ?RestitutionCallback) void;

    /// Set the worker count. Must be in the range [1, `max_workers`]
    pub const setWorkerCount = b3World_SetWorkerCount;
    extern fn b3World_SetWorkerCount(worldId: World, count: c_int) void;

    /// Get the worker count.
    pub const getWorkerCount = b3World_GetWorkerCount;
    extern fn b3World_GetWorkerCount(worldId: World) c_int;

    /// Dump memory stats to log.
    pub const dumpMemoryStats = b3World_DumpMemoryStats;
    extern fn b3World_DumpMemoryStats(worldId: World) void;

    /// This is for internal testing
    pub const enableSpeculative = b3World_EnableSpeculative;
    extern fn b3World_EnableSpeculative(worldId: World, flag: bool) void;

    /// Begin recording world mutations into the provided buffer.
    /// The buffer is reset on each call so a single `Recording` can be reused for multiple sessions.
    /// - `worldId`: the world to record
    /// - `recording`: the recording handle to write into
    pub const startRecording = b3World_StartRecording;
    extern fn b3World_StartRecording(worldId: World, recording: *Recording) void;

    /// End the current recording session. Writes the trailing geometry registry and
    /// backpatches the header. The buffer remains valid until the recording is destroyed.
    /// - `worldId`: the world currently being recorded
    pub const stopRecording = b3World_StopRecording;
    extern fn b3World_StopRecording(worldId: World) void;

    /// Create a rigid body given a definition. No reference to the definition is retained. So you can create the definition
    /// on the stack and pass it as a pointer.
    /// ```zig
    /// const body_def = b3.defaultBodyDef();
    /// const body = world.createBody(&body_def);
    /// ```
    /// Warning: This function is locked during callbacks.
    pub const createBody = b3CreateBody;
    extern fn b3CreateBody(worldId: World, def: *const BodyDef) Body;

    /// Create a parallel joint
    /// See `ParallelJointDef` for details.
    pub fn createParallelJoint(worldId: World, def: *const ParallelJointDef) ParallelJoint {
        return .{ .joint = b3CreateParallelJoint(worldId, def) };
    }
    extern fn b3CreateParallelJoint(worldId: World, def: *const ParallelJointDef) Joint;

    /// Create a distance joint
    /// See `DistanceJointDef` for details.
    pub fn createDistanceJoint(worldId: World, def: *const DistanceJointDef) DistanceJoint {
        return .{ .joint = b3CreateDistanceJoint(worldId, def) };
    }
    extern fn b3CreateDistanceJoint(worldId: World, def: *const DistanceJointDef) Joint;

    /// Create a motor joint
    /// See `MotorJointDef` for details.
    pub fn createMotorJoint(worldId: World, def: *const MotorJointDef) MotorJoint {
        return .{ .joint = b3CreateMotorJoint(worldId, def) };
    }
    extern fn b3CreateMotorJoint(worldId: World, def: *const MotorJointDef) Joint;

    /// Create a filter joint.
    /// See `FilterJointDef` for details.
    pub fn createFilterJoint(worldId: World, def: *const FilterJointDef) FilterJoint {
        return .{ .joint = b3CreateFilterJoint(worldId, def) };
    }
    extern fn b3CreateFilterJoint(worldId: World, def: *const FilterJointDef) Joint;

    /// Create a prismatic (slider) joint.
    /// See `PrismaticJointDef` for details.
    pub fn createPrismaticJoint(worldId: World, def: *const PrismaticJointDef) PrismaticJoint {
        return .{ .joint = b3CreatePrismaticJoint(worldId, def) };
    }
    extern fn b3CreatePrismaticJoint(worldId: World, def: *const PrismaticJointDef) Joint;

    /// Create a revolute joint
    /// See `RevoluteJointDef` for details.
    pub fn createRevoluteJoint(worldId: World, def: *const RevoluteJointDef) RevoluteJoint {
        return .{ .joint = b3CreateRevoluteJoint(worldId, def) };
    }
    extern fn b3CreateRevoluteJoint(worldId: World, def: *const RevoluteJointDef) Joint;

    /// Create a spherical joint
    /// See `SphericalJointDef` for details.
    pub fn createSphericalJoint(worldId: World, def: *const SphericalJointDef) SphericalJoint {
        return .{ .joint = b3CreateSphericalJoint(worldId, def) };
    }
    extern fn b3CreateSphericalJoint(worldId: World, def: *const SphericalJointDef) Joint;

    /// Create a weld joint
    /// See `WeldJointDef` for details.
    pub fn createWeldJoint(worldId: World, def: *const WeldJointDef) WeldJoint {
        return .{ .joint = b3CreateWeldJoint(worldId, def) };
    }
    extern fn b3CreateWeldJoint(worldId: World, def: *const WeldJointDef) Joint;

    /// Create a wheel joint.
    /// See `WheelJointDef` for details.
    pub fn createWheelJoint(worldId: World, def: *const WheelJointDef) WheelJoint {
        return .{ .joint = b3CreateWheelJoint(worldId, def) };
    }
    extern fn b3CreateWheelJoint(worldId: World, def: *const WheelJointDef) Joint;
};

/// Task interface
/// This is the prototype for a Box3D task. Your task system is expected to run this callback on a worker thread,
/// exactly once per enqueue, passing back the same taskContext pointer supplied to `EnqueueTaskCallback`.
pub const TaskCallback = *const fn (taskContext: ?*anyopaque) callconv(.c) void;

/// These functions can be provided to Box3D to invoke a task system.
/// Returns a pointer to the user's task object. May be null. A null indicates to Box3D that the work was executed
/// serially within the callback and there is no need to call `FinishTaskCallback`. Otherwise the returned
/// value must be non-null will be passed to `FinishTaskCallback` as the userTask.
/// - `task`: the Box3D task to be called by the scheduler
/// - `taskContext`: the Box3D context object that the scheduler must pass to the task
/// - `userContext`: the scheduler context object that is opaque to Box3D
/// - `taskName`: the Box3D task name that the scheduler can use for diagnostics
pub const EnqueueTaskCallback = *const fn (task: TaskCallback, taskContext: ?*anyopaque, userContext: ?*anyopaque, taskName: [*:0]const u8) callconv(.c) ?*anyopaque;

/// Finishes a user task object that wraps a Box3D task. This must block until the task has completed.
/// The step blocks here on the tasks it spawned, so `World.step` holds its stack across every
/// fork/join. Drive it from a thread you can dedicate to the step, or from a fiber this callback can
/// park to free the underlying thread. In a job system that cannot park a job's stack, do not call
/// `World.step` from inside a job: a job that blocks on its own sub-jobs without yielding its thread
/// can deadlock. The in-tree scheduler instead runs other pending tasks on the waiting thread.
pub const FinishTaskCallback = *const fn (userTask: ?*anyopaque, userContext: ?*anyopaque) callconv(.c) void;

/// Optional friction mixing callback. This intentionally provides no context objects because this is called
/// from a worker thread.
/// Warning: This function should not attempt to modify Box3D state or user application state.
pub const FrictionCallback = *const fn (frictionA: f32, userMaterialIdA: u64, frictionB: f32, userMaterialIdB: u64) callconv(.c) f32;

/// Optional restitution mixing callback. This intentionally provides no context objects because this is called
/// from a worker thread.
/// Warning: This function should not attempt to modify Box3D state or user application state.
pub const RestitutionCallback = *const fn (restitutionA: f32, userMaterialIdA: u64, restitutionB: f32, userMaterialIdB: u64) callconv(.c) f32;

/// Prototype for a contact filter callback.
/// This is called when a contact pair is considered for collision. This allows you to
/// perform custom logic to prevent collision between shapes. This is only called if
/// one of the two shapes has custom filtering enabled. See `ShapeDef`.
/// Notes:
/// - this function must be thread-safe
/// - this is only called if one of the two shapes has enabled custom filtering
/// - this is called only for awake dynamic bodies
/// Return false if you want to disable the collision
/// Warning: Do not attempt to modify the world inside this callback
pub const CustomFilterFcn = *const fn (shapeIdA: Shape, shapeIdB: Shape, context: ?*anyopaque) callconv(.c) bool;

/// Prototype for a pre-solve callback.
/// This is called after a contact is updated. This allows you to inspect a
/// collision before it goes to the solver.
/// Notes:
/// - this function must be thread-safe
/// - this is only called if the shape has enabled pre-solve events
/// - this may be called for awake dynamic bodies and sensors
/// - this is not called for sensors
/// Return false if you want to disable the contact this step
/// This has limited information because it is used during CCD which does not have the
/// full contact manifold.
/// Warning: Do not attempt to modify the world inside this callback
pub const PreSolveFcn = *const fn (shapeIdA: Shape, shapeIdB: Shape, point: Pos, normal: Vec3, context: ?*anyopaque) callconv(.c) bool;

/// Prototype callback for overlap queries.
/// Called for each shape found in the query.
/// See `World.overlapAABB`.
/// Returns false to terminate the query.
pub const OverlapResultFcn = *const fn (shapeId: Shape, context: ?*anyopaque) callconv(.c) bool;

/// Prototype callback for ray casts.
/// Called for each shape found in the query. You control how the ray cast
/// proceeds by returning a float:
/// return -1: ignore this shape and continue
/// return 0: terminate the ray cast
/// return fraction: clip the ray to this point
/// return 1: don't clip the ray and continue
/// - `shapeId`: the shape hit by the ray
/// - `point`: the point of initial intersection
/// - `normal`: the normal vector at the point of intersection
/// - `fraction`: the fraction along the ray at the point of intersection
/// - `userMaterialId`: the shape or triangle surface type
/// - `triangleIndex`: the triangle index for mesh or height field shapes or -1 for other shape types
/// - `childIndex`: the child shape index for compound shapes
/// - `context`: the user context
/// Returns -1 to filter, 0 to terminate, fraction to clip the ray for closest hit, 1 to continue
/// See `World.castRay`.
pub const CastResultFcn = *const fn (shapeId: Shape, point: Pos, normal: Vec3, fraction: f32, userMaterialId: u64, triangleIndex: c_int, childIndex: c_int, context: ?*anyopaque) callconv(.c) f32;

/// Optional world capacities that can be use to avoid run-time allocations
pub const Capacity = extern struct {
    /// Number of expected static shapes.
    staticShapeCount: c_int,
    /// Number of expected dynamic and kinematic shapes.
    dynamicShapeCount: c_int,
    /// Number of expected static bodies.
    staticBodyCount: c_int,
    /// Number of expected dynamic and kinematic bodies.
    dynamicBodyCount: c_int,
    /// Number of expected contacts.
    contactCount: c_int,
};

/// World definition used to create a simulation world. Must be initialized using `WorldDef.default`.
pub const WorldDef = extern struct {
    /// Gravity vector. Box3D has no up-vector defined.
    gravity: Vec3,
    /// Restitution speed threshold, usually in m/s. Collisions above this
    /// speed have restitution applied (will bounce).
    restitutionThreshold: f32,
    /// Number of iterations of the restitution solver. More iterations can lead to less box spinning.
    /// See `max_restitution_iterations`.
    restitutionIterations: c_int,
    /// Enable full contact propagation in the restitution solver. Expensive.
    enableRestitutionPropagation: bool,
    /// Hit event speed threshold, usually in m/s. Collisions above this
    /// speed can generate hit events if the shape also enables hit events.
    hitEventThreshold: f32,
    /// Contact stiffness. Cycles per second. Increasing this increases the speed of overlap recovery, but can introduce jitter.
    contactHertz: f32,
    /// Contact bounciness. Non-dimensional. You can speed up overlap recovery by decreasing this with
    /// the trade-off that overlap resolution becomes more energetic.
    contactDampingRatio: f32,
    /// This parameter controls how fast overlap is resolved and usually has units of meters per second. This only
    /// puts a cap on the resolution speed. The resolution speed is increased by increasing the hertz and/or
    /// decreasing the damping ratio.
    contactSpeed: f32,
    /// Maximum linear speed. Usually meters per second.
    maximumLinearSpeed: f32,
    /// Use this to disable gyroscopic torque on sphere-like objects automatically.
    /// Range is [0, 1]. A sphere is 0 and a 1x1x2 box is 0.5.
    isotropicInertiaTolerance: f32,
    /// Optional mixing callback for friction. The default uses sqrt(frictionA * frictionB).
    frictionCallback: ?FrictionCallback,
    /// Optional mixing callback for restitution. The default uses max(restitutionA, restitutionB).
    restitutionCallback: ?RestitutionCallback,
    /// Can bodies go to sleep to improve performance
    enableSleep: bool,
    /// Enable continuous collision
    enableContinuous: bool,
    /// Number of workers to use with the provided task system. Box3D performs best when using only
    /// performance cores and accessing a single L2 cache. Efficiency cores and hyper-threading provide
    /// little benefit and may even harm performance.
    /// This is clamped to the range [1, `max_workers`]. Using a value above 1 will turn on multithreading.
    /// If task callbacks are provided then Box3D will use the user provided task system. Otherwise Box3D
    /// will create threads and use an internal scheduler.
    workerCount: u32,
    /// function to spawn task
    enqueueTask: ?EnqueueTaskCallback,
    /// function to finish a task
    finishTask: ?FinishTaskCallback,
    /// User context that is provided to enqueueTask and finishTask
    userTaskContext: ?*anyopaque,
    /// User data associated with a world
    userData: ?*anyopaque,
    /// Used to create debug draw shapes. This is called when a shape is
    /// first drawn using `DebugDraw`.
    createDebugShape: ?CreateDebugShapeCallback,
    /// Used to destroy debug draw shapes. This is called when a shape is modified or destroyed.
    destroyDebugShape: ?DestroyDebugShapeCallback,
    /// This is passed to the debug shape callbacks to provide a user context.
    userDebugShapeContext: ?*anyopaque,
    /// Optional initial capacities
    capacity: Capacity,
    /// Used internally to detect a valid definition. DO NOT SET.
    internalValue: c_int,

    /// Use this to initialize your world definition
    pub const default = b3DefaultWorldDef;
    extern fn b3DefaultWorldDef() WorldDef;
};

/// Use this to initialize your world definition
pub const defaultWorldDef = WorldDef.default;

/// Profiling data. Times are in milliseconds.
pub const Profile = extern struct {
    step: f32,
    pairs: f32,
    collide: f32,
    solve: f32,
    solverSetup: f32,
    constraints: f32,
    prepareConstraints: f32,
    integrateVelocities: f32,
    warmStart: f32,
    solveImpulses: f32,
    integratePositions: f32,
    relaxImpulses: f32,
    restitution: f32,
    storeImpulses: f32,
    splitIslands: f32,
    transforms: f32,
    sensorHits: f32,
    jointEvents: f32,
    hitEvents: f32,
    refit: f32,
    bullets: f32,
    sleepIslands: f32,
    sensors: f32,
};

/// Counters that give details of the simulation size.
pub const Counters = extern struct {
    byteCount: i64,
    bodyCount: c_int,
    shapeCount: c_int,
    contactCount: c_int,
    jointCount: c_int,
    islandCount: c_int,
    stackUsed: c_int,
    arenaCapacity: c_int,
    staticTreeHeight: c_int,
    treeHeight: c_int,
    satCallCount: c_int,
    satCacheHitCount: c_int,
    taskCount: c_int,
    colorCounts: [24]c_int,
    manifoldCounts: [b3.contact_manifold_count_buckets]c_int,
    /// Number of contacts touched by the collide pass
    /// graph contacts + awake-set non-touching
    awakeContactCount: c_int,
    /// Number of contacts recycled in the most recent step.
    recycledContactCount: c_int,
    /// Maximum number of time of impact outer iterations
    distanceIterations: c_int,
    /// Maximum TOI push backs.
    pushBackIterations: c_int,
    /// Maximum TOI root solver iterations.
    rootIterations: c_int,
};

/// The explosion definition is used to configure options for explosions. Explosions
/// consider shape geometry when computing the impulse.
pub const ExplosionDef = extern struct {
    /// Mask bits to filter shapes
    maskBits: u64,
    /// The center of the explosion in world space
    position: Pos,
    /// The radius of the explosion
    radius: f32,
    /// The falloff distance beyond the radius. Impulse is reduced to zero at this distance.
    falloff: f32,
    /// Impulse per unit area. This applies an impulse according to the shape area that
    /// is facing the explosion. Explosions only apply to spheres, capsules, and hulls. This
    /// may be negative for implosions.
    impulsePerArea: f32,

    /// Use this to initialize your explosion definition
    pub const default = b3DefaultExplosionDef;
    extern fn b3DefaultExplosionDef() ExplosionDef;
};

/// Use this to initialize your explosion definition
pub const defaultExplosionDef = ExplosionDef.default;

/// Create a world for rigid body simulation. A world contains bodies, shapes, and constraints. You may create
/// up to 128 worlds. Each world is completely independent and may be simulated in parallel.
/// Returns the world id.
pub const createWorld = World.create;

/// Get the current number of worlds
pub const getWorldCount = b3GetWorldCount;
extern fn b3GetWorldCount() c_int;

/// Get the maximum number of simultaneous worlds that have been created
pub const getMaxWorldCount = b3GetMaxWorldCount;
extern fn b3GetMaxWorldCount() c_int;
