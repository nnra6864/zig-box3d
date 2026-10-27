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

const base_h = @import("box3d/base.zig");
pub const AllocFcn = base_h.AllocFcn;
pub const FreeFcn = base_h.FreeFcn;
pub const AssertFcn = base_h.AssertFcn;
pub const LogFcn = base_h.LogFcn;
pub const setAllocator = base_h.setAllocator;
pub const getByteCount = base_h.getByteCount;
pub const setAssertFcn = base_h.setAssertFcn;
pub const setLogFcn = base_h.setLogFcn;
pub const Version = base_h.Version;
pub const getVersion = base_h.getVersion;
pub const isDoublePrecision = base_h.isDoublePrecision;
pub const getMaxManifoldPoints = base_h.getMaxManifoldPoints;
pub const isAVX2Available = base_h.isAVX2Available;
pub const getTicks = base_h.getTicks;
pub const getMilliseconds = base_h.getMilliseconds;
pub const getMillisecondsAndReset = base_h.getMillisecondsAndReset;
pub const yield = base_h.yield;
pub const sleep = base_h.sleep;
pub const hash = base_h.hash;
const body_h = @import("box3d/body.zig");
pub const Body = body_h.Body;
pub const BodyType = body_h.BodyType;
pub const MotionLocks = body_h.MotionLocks;
pub const BodyDef = body_h.BodyDef;
pub const defaultBodyDef = body_h.defaultBodyDef;
pub const createBody = body_h.createBody;
const collision_h = @import("box3d/collision.zig");
pub const SeparatingFeature = collision_h.SeparatingFeature;
pub const TriangleFeature = collision_h.TriangleFeature;
pub const SATCache = collision_h.SATCache;
pub const FeaturePair = collision_h.FeaturePair;
pub const LocalManifoldPoint = collision_h.LocalManifoldPoint;
pub const LocalManifold = collision_h.LocalManifold;
pub const collideSpheres = collision_h.collideSpheres;
pub const collideCapsuleAndSphere = collision_h.collideCapsuleAndSphere;
pub const collideHullAndSphere = collision_h.collideHullAndSphere;
pub const collideCapsules = collision_h.collideCapsules;
pub const collideHullAndCapsule = collision_h.collideHullAndCapsule;
pub const collideHulls = collision_h.collideHulls;
pub const collideTriangleAndCapsule = collision_h.collideTriangleAndCapsule;
pub const collideTriangleAndHull = collision_h.collideTriangleAndHull;
pub const collideTriangleAndSphere = collision_h.collideTriangleAndSphere;
pub const Point2D = collision_h.Point2D;
pub const hull2D = collision_h.hull2D;
pub const simplifyHull2D = collision_h.simplifyHull2D;
const constants_h = @import("box3d/constants.zig");
pub const setLengthUnitsPerMeter = constants_h.setLengthUnitsPerMeter;
pub const getLengthUnitsPerMeter = constants_h.getLengthUnitsPerMeter;
pub const null_index = constants_h.null_index;
pub const default_category_bits = constants_h.default_category_bits;
pub const default_mask_bits = constants_h.default_mask_bits;
pub const huge = constants_h.huge;
pub const max_workers = constants_h.max_workers;
pub const max_tasks = constants_h.max_tasks;
pub const graph_color_count = constants_h.graph_color_count;
pub const contact_manifold_count_buckets = constants_h.contact_manifold_count_buckets;
pub const linearSlop = constants_h.linearSlop;
pub const minCapsuleLength = constants_h.minCapsuleLength;
pub const min_friction_weight = constants_h.min_friction_weight;
pub const overlapSlop = constants_h.overlapSlop;
pub const max_worlds = constants_h.max_worlds;
pub const max_rotation = constants_h.max_rotation;
pub const speculativeDistance = constants_h.speculativeDistance;
pub const meshRestOffset = constants_h.meshRestOffset;
pub const contactRecycleDistance = constants_h.contactRecycleDistance;
pub const contact_recycle_angular_distance = constants_h.contact_recycle_angular_distance;
pub const maxAABBMargin = constants_h.maxAABBMargin;
pub const aabb_margin_fraction = constants_h.aabb_margin_fraction;
pub const time_to_sleep = constants_h.time_to_sleep;
pub const max_restitution_iterations = constants_h.max_restitution_iterations;
pub const max_manifold_points = constants_h.max_manifold_points;
pub const max_hull_vertices = constants_h.max_hull_vertices;
pub const max_hull_faces = constants_h.max_hull_faces;
pub const max_hull_edges = constants_h.max_hull_edges;
pub const parallel_edge_tol = constants_h.parallel_edge_tol;
pub const max_shape_cast_points = constants_h.max_shape_cast_points;
pub const shape_power = constants_h.shape_power;
pub const child_power = constants_h.child_power;
pub const max_shapes = constants_h.max_shapes;
pub const max_child_shapes = constants_h.max_child_shapes;
pub const max_mesh_contact_triangles = constants_h.max_mesh_contact_triangles;
const contact_h = @import("box3d/contact.zig");
pub const Contact = contact_h.Contact;
pub const ContactData = contact_h.ContactData;
pub const ManifoldPoint = contact_h.ManifoldPoint;
pub const Manifold = contact_h.Manifold;
const debug_draw_h = @import("box3d/debug_draw.zig");
pub const CreateDebugShapeCallback = debug_draw_h.CreateDebugShapeCallback;
pub const DestroyDebugShapeCallback = debug_draw_h.DestroyDebugShapeCallback;
pub const HexColor = debug_draw_h.HexColor;
pub const DebugMaterial = debug_draw_h.DebugMaterial;
pub const getGraphColor = debug_draw_h.getGraphColor;
pub const DebugShape = debug_draw_h.DebugShape;
pub const DebugDraw = debug_draw_h.DebugDraw;
pub const defaultDebugDraw = debug_draw_h.defaultDebugDraw;
const events_h = @import("box3d/events.zig");
pub const SensorBeginTouchEvent = events_h.SensorBeginTouchEvent;
pub const SensorEndTouchEvent = events_h.SensorEndTouchEvent;
pub const SensorEvents = events_h.SensorEvents;
pub const ContactBeginTouchEvent = events_h.ContactBeginTouchEvent;
pub const ContactEndTouchEvent = events_h.ContactEndTouchEvent;
pub const ContactHitEvent = events_h.ContactHitEvent;
pub const ContactEvents = events_h.ContactEvents;
pub const BodyMoveEvent = events_h.BodyMoveEvent;
pub const BodyEvents = events_h.BodyEvents;
pub const JointEvent = events_h.JointEvent;
pub const JointEvents = events_h.JointEvents;
const geometry_h = @import("box3d/geometry.zig");
pub const MassData = geometry_h.MassData;
pub const Sphere = geometry_h.Sphere;
pub const Capsule = geometry_h.Capsule;
pub const HullVertex = geometry_h.HullVertex;
pub const HullHalfEdge = geometry_h.HullHalfEdge;
pub const HullFace = geometry_h.HullFace;
pub const HullData = geometry_h.HullData;
pub const BoxHull = geometry_h.BoxHull;
pub const MeshDef = geometry_h.MeshDef;
pub const MeshTriangle = geometry_h.MeshTriangle;
pub const MeshNode = geometry_h.MeshNode;
pub const MeshData = geometry_h.MeshData;
pub const Mesh = geometry_h.Mesh;
pub const HeightFieldDef = geometry_h.HeightFieldDef;
pub const HeightFieldData = geometry_h.HeightFieldData;
pub const CompoundCapsuleDef = geometry_h.CompoundCapsuleDef;
pub const CompoundHullDef = geometry_h.CompoundHullDef;
pub const CompoundMeshDef = geometry_h.CompoundMeshDef;
pub const CompoundSphereDef = geometry_h.CompoundSphereDef;
pub const CompoundDef = geometry_h.CompoundDef;
pub const CompoundData = geometry_h.CompoundData;
pub const CompoundCapsule = geometry_h.CompoundCapsule;
pub const CompoundHull = geometry_h.CompoundHull;
pub const CompoundMesh = geometry_h.CompoundMesh;
pub const CompoundSphere = geometry_h.CompoundSphere;
pub const ChildShape = geometry_h.ChildShape;
pub const CompoundQueryFcn = geometry_h.CompoundQueryFcn;
pub const createCylinder = geometry_h.createCylinder;
pub const createCone = geometry_h.createCone;
pub const createRock = geometry_h.createRock;
pub const createComplexHull = geometry_h.createComplexHull;
pub const createHull = geometry_h.createHull;
pub const makeCubeHull = geometry_h.makeCubeHull;
pub const makeBoxHull = geometry_h.makeBoxHull;
pub const makeOffsetBoxHull = geometry_h.makeOffsetBoxHull;
pub const makeTransformedBoxHull = geometry_h.makeTransformedBoxHull;
pub const makeScaledBoxHull = geometry_h.makeScaledBoxHull;
pub const scaleBox = geometry_h.scaleBox;
pub const createGridMesh = geometry_h.createGridMesh;
pub const createWaveMesh = geometry_h.createWaveMesh;
pub const createTorusMesh = geometry_h.createTorusMesh;
pub const createBoxMesh = geometry_h.createBoxMesh;
pub const createHollowBoxMesh = geometry_h.createHollowBoxMesh;
pub const createPlatformMesh = geometry_h.createPlatformMesh;
pub const createMesh = geometry_h.createMesh;
pub const createHeightField = geometry_h.createHeightField;
pub const createGrid = geometry_h.createGrid;
pub const createWave = geometry_h.createWave;
pub const dumpHeightData = geometry_h.dumpHeightData;
pub const loadHeightField = geometry_h.loadHeightField;
pub const createCompound = geometry_h.createCompound;
pub const validateCompound = geometry_h.validateCompound;
pub const MeshEdgeFlags = geometry_h.MeshEdgeFlags;
const joint_h = @import("box3d/joint.zig");
pub const Joint = joint_h.Joint;
pub const JointType = joint_h.JointType;
pub const JointDef = joint_h.JointDef;
pub const DistanceJointDef = joint_h.DistanceJointDef;
pub const defaultDistanceJointDef = joint_h.defaultDistanceJointDef;
pub const MotorJointDef = joint_h.MotorJointDef;
pub const defaultMotorJointDef = joint_h.defaultMotorJointDef;
pub const FilterJointDef = joint_h.FilterJointDef;
pub const defaultFilterJointDef = joint_h.defaultFilterJointDef;
pub const ParallelJointDef = joint_h.ParallelJointDef;
pub const defaultParallelJointDef = joint_h.defaultParallelJointDef;
pub const PrismaticJointDef = joint_h.PrismaticJointDef;
pub const defaultPrismaticJointDef = joint_h.defaultPrismaticJointDef;
pub const RevoluteJointDef = joint_h.RevoluteJointDef;
pub const defaultRevoluteJointDef = joint_h.defaultRevoluteJointDef;
pub const SphericalJointDef = joint_h.SphericalJointDef;
pub const defaultSphericalJointDef = joint_h.defaultSphericalJointDef;
pub const WeldJointDef = joint_h.WeldJointDef;
pub const defaultWeldJointDef = joint_h.defaultWeldJointDef;
pub const WheelJointDef = joint_h.WheelJointDef;
pub const defaultWheelJointDef = joint_h.defaultWheelJointDef;
pub const createParallelJoint = joint_h.createParallelJoint;
pub const createDistanceJoint = joint_h.createDistanceJoint;
pub const createMotorJoint = joint_h.createMotorJoint;
pub const createFilterJoint = joint_h.createFilterJoint;
pub const createPrismaticJoint = joint_h.createPrismaticJoint;
pub const createRevoluteJoint = joint_h.createRevoluteJoint;
pub const createSphericalJoint = joint_h.createSphericalJoint;
pub const createWeldJoint = joint_h.createWeldJoint;
pub const createWheelJoint = joint_h.createWheelJoint;
pub const DistanceJoint = joint_h.DistanceJoint;
pub const MotorJoint = joint_h.MotorJoint;
pub const FilterJoint = joint_h.FilterJoint;
pub const ParallelJoint = joint_h.ParallelJoint;
pub const PrismaticJoint = joint_h.PrismaticJoint;
pub const RevoluteJoint = joint_h.RevoluteJoint;
pub const SphericalJoint = joint_h.SphericalJoint;
pub const WeldJoint = joint_h.WeldJoint;
pub const WheelJoint = joint_h.WheelJoint;
const math_h = @import("box3d/math.zig");
pub const pi = math_h.pi;
pub const deg_to_rad = math_h.deg_to_rad;
pub const rad_to_deg = math_h.rad_to_deg;
pub const min_scale = math_h.min_scale;
pub const Vec2 = math_h.Vec2;
pub const Vec3 = math_h.Vec3;
pub const CosSin = math_h.CosSin;
pub const Quat = math_h.Quat;
pub const Transform = math_h.Transform;
pub const Pos = math_h.Pos;
pub const WorldTransform = math_h.WorldTransform;
pub const Matrix3 = math_h.Matrix3;
pub const AABB = math_h.AABB;
pub const Plane = math_h.Plane;
pub const minInt = math_h.minInt;
pub const maxInt = math_h.maxInt;
pub const clampInt = math_h.clampInt;
pub const absFloat = math_h.absFloat;
pub const minFloat = math_h.minFloat;
pub const maxFloat = math_h.maxFloat;
pub const clampFloat = math_h.clampFloat;
pub const lerpFloat = math_h.lerpFloat;
pub const atan2 = math_h.atan2;
pub const computeCosSin = math_h.computeCosSin;
pub const unwindAngle = math_h.unwindAngle;
pub const add = math_h.add;
pub const sub = math_h.sub;
pub const mul = math_h.mul;
pub const neg = math_h.neg;
pub const dot = math_h.dot;
pub const length = math_h.length;
pub const lengthSquared = math_h.lengthSquared;
pub const distance = math_h.distance;
pub const distanceSquared = math_h.distanceSquared;
pub const normalize = math_h.normalize;
pub const LengthAndNormal = math_h.LengthAndNormal;
pub const getLengthAndNormalize = math_h.getLengthAndNormalize;
pub const perp = math_h.perp;
pub const isNormalized = math_h.isNormalized;
pub const mulAdd = math_h.mulAdd;
pub const mulSub = math_h.mulSub;
pub const mulSV = math_h.mulSV;
pub const cross = math_h.cross;
pub const lerp = math_h.lerp;
pub const blend2 = math_h.blend2;
pub const abs = math_h.abs;
pub const sign = math_h.sign;
pub const min = math_h.min;
pub const max = math_h.max;
pub const clamp = math_h.clamp;
pub const safeScale = math_h.safeScale;
pub const isNormalizedQuat = math_h.isNormalizedQuat;
pub const rotateVector = math_h.rotateVector;
pub const invRotateVector = math_h.invRotateVector;
pub const dotQuat = math_h.dotQuat;
pub const mulQuat = math_h.mulQuat;
pub const invMulQuat = math_h.invMulQuat;
pub const conjugate = math_h.conjugate;
pub const negateQuat = math_h.negateQuat;
pub const normalizeQuat = math_h.normalizeQuat;
pub const makeQuatFromAxisAngle = math_h.makeQuatFromAxisAngle;
pub const AxisAngle = math_h.AxisAngle;
pub const getAxisAngle = math_h.getAxisAngle;
pub const getQuatAngle = math_h.getQuatAngle;
pub const makeQuatFromMatrix = math_h.makeQuatFromMatrix;
pub const computeQuatBetweenUnitVectors = math_h.computeQuatBetweenUnitVectors;
pub const getTwistAngle = math_h.getTwistAngle;
pub const getSwingAngle = math_h.getSwingAngle;
pub const nLerp = math_h.nLerp;
pub const mulTransforms = math_h.mulTransforms;
pub const invMulTransforms = math_h.invMulTransforms;
pub const invertTransform = math_h.invertTransform;
pub const transformPoint = math_h.transformPoint;
pub const invTransformPoint = math_h.invTransformPoint;
pub const toPos = math_h.toPos;
pub const toVec3 = math_h.toVec3;
pub const roundDownFloat = math_h.roundDownFloat;
pub const roundUpFloat = math_h.roundUpFloat;
pub const subPos = math_h.subPos;
pub const PosScalar = math_h.PosScalar;
pub const offsetPos = math_h.offsetPos;
pub const lerpPosition = math_h.lerpPosition;
pub const transformWorldPoint = math_h.transformWorldPoint;
pub const invTransformWorldPoint = math_h.invTransformWorldPoint;
pub const mulWorldTransforms = math_h.mulWorldTransforms;
pub const invMulWorldTransforms = math_h.invMulWorldTransforms;
pub const toRelativeTransform = math_h.toRelativeTransform;
pub const makeWorldTransform = math_h.makeWorldTransform;
pub const offsetAABB = math_h.offsetAABB;
pub const det = math_h.det;
pub const mulMV = math_h.mulMV;
pub const negateMat3 = math_h.negateMat3;
pub const addMM = math_h.addMM;
pub const subMM = math_h.subMM;
pub const mulSM = math_h.mulSM;
pub const mulMM = math_h.mulMM;
pub const transpose = math_h.transpose;
pub const invertMatrix = math_h.invertMatrix;
pub const solve3 = math_h.solve3;
pub const invertT = math_h.invertT;
pub const absMatrix3 = math_h.absMatrix3;
pub const makeMatrixFromQuat = math_h.makeMatrixFromQuat;
pub const steiner = math_h.steiner;
pub const makeAABB = math_h.makeAABB;
pub const aabbContains = math_h.aabbContains;
pub const aabbArea = math_h.aabbArea;
pub const aabbCenter = math_h.aabbCenter;
pub const aabbExtents = math_h.aabbExtents;
pub const aabbUnion = math_h.aabbUnion;
pub const aabbInflate = math_h.aabbInflate;
pub const aabbOverlaps = math_h.aabbOverlaps;
pub const aabbTransform = math_h.aabbTransform;
pub const closestPointToAABB = math_h.closestPointToAABB;
pub const SegmentDistanceResult = math_h.SegmentDistanceResult;
pub const pointToSegmentDistance = math_h.pointToSegmentDistance;
pub const lineDistance = math_h.lineDistance;
pub const segmentDistance = math_h.segmentDistance;
pub const isValidFloat = math_h.isValidFloat;
pub const isValidVec3 = math_h.isValidVec3;
pub const isValidQuat = math_h.isValidQuat;
pub const isValidTransform = math_h.isValidTransform;
pub const isValidMatrix3 = math_h.isValidMatrix3;
pub const isValidAABB = math_h.isValidAABB;
pub const isBoundedAABB = math_h.isBoundedAABB;
pub const isSaneAABB = math_h.isSaneAABB;
pub const isValidPlane = math_h.isValidPlane;
pub const isValidPosition = math_h.isValidPosition;
pub const isValidWorldTransform = math_h.isValidWorldTransform;
const mover_h = @import("box3d/mover.zig");
pub const PlaneResult = mover_h.PlaneResult;
pub const CollisionPlane = mover_h.CollisionPlane;
pub const PlaneSolverResult = mover_h.PlaneSolverResult;
pub const BodyPlaneResult = mover_h.BodyPlaneResult;
pub const BodyTOIResult = mover_h.BodyTOIResult;
pub const PlaneResultFcn = mover_h.PlaneResultFcn;
pub const MoverFilterFcn = mover_h.MoverFilterFcn;
pub const solvePlanes = mover_h.solvePlanes;
pub const clipVector = mover_h.clipVector;
const query_h = @import("box3d/query.zig");
pub const QueryFilter = query_h.QueryFilter;
pub const defaultQueryFilter = query_h.defaultQueryFilter;
pub const RayCastInput = query_h.RayCastInput;
pub const RayResult = query_h.RayResult;
pub const ShapeProxy = query_h.ShapeProxy;
pub const ShapeCastInput = query_h.ShapeCastInput;
pub const BoxCastInput = query_h.BoxCastInput;
pub const CastOutput = query_h.CastOutput;
pub const BodyCastResult = query_h.BodyCastResult;
pub const SimplexCache = query_h.SimplexCache;
pub const ShapeCastPairInput = query_h.ShapeCastPairInput;
pub const DistanceInput = query_h.DistanceInput;
pub const DistanceOutput = query_h.DistanceOutput;
pub const SimplexVertex = query_h.SimplexVertex;
pub const Simplex = query_h.Simplex;
pub const Sweep = query_h.Sweep;
pub const TOIInput = query_h.TOIInput;
pub const TOIState = query_h.TOIState;
pub const TOIOutput = query_h.TOIOutput;
pub const MeshQueryFcn = query_h.MeshQueryFcn;
pub const shapeDistance = query_h.shapeDistance;
pub const shapeCast = query_h.shapeCast;
pub const timeOfImpact = query_h.timeOfImpact;
pub const WorldCastOutput = query_h.WorldCastOutput;
const recording_h = @import("box3d/recording.zig");
pub const Recording = recording_h.Recording;
pub const validateReplay = recording_h.validateReplay;
pub const RecPlayer = recording_h.RecPlayer;
pub const RecPlayerInfo = recording_h.RecPlayerInfo;
pub const RecQueryType = recording_h.RecQueryType;
pub const RecQueryInfo = recording_h.RecQueryInfo;
pub const RecQueryHit = recording_h.RecQueryHit;
const shape_h = @import("box3d/shape.zig");
pub const Shape = shape_h.Shape;
pub const Filter = shape_h.Filter;
pub const defaultFilter = shape_h.defaultFilter;
pub const SurfaceMaterial = shape_h.SurfaceMaterial;
pub const defaultSurfaceMaterial = shape_h.defaultSurfaceMaterial;
pub const ShapeType = shape_h.ShapeType;
pub const ShapeDef = shape_h.ShapeDef;
pub const defaultShapeDef = shape_h.defaultShapeDef;
pub const createSphereShape = shape_h.createSphereShape;
pub const createCapsuleShape = shape_h.createCapsuleShape;
pub const createHullShape = shape_h.createHullShape;
pub const createTransformedHullShape = shape_h.createTransformedHullShape;
pub const createMeshShape = shape_h.createMeshShape;
pub const createHeightFieldShape = shape_h.createHeightFieldShape;
pub const createBakedCompoundShape = shape_h.createBakedCompoundShape;
const tree_h = @import("box3d/tree.zig");
pub const TreeNode = tree_h.TreeNode;
pub const TreeProxy = tree_h.TreeProxy;
pub const DynamicTree = tree_h.DynamicTree;
pub const TreeStats = tree_h.TreeStats;
pub const TreeQueryCallbackFcn = tree_h.TreeQueryCallbackFcn;
pub const TreeQueryClosestCallbackFcn = tree_h.TreeQueryClosestCallbackFcn;
pub const TreeBoxCastCallbackFcn = tree_h.TreeBoxCastCallbackFcn;
pub const TreeRayCastCallbackFcn = tree_h.TreeRayCastCallbackFcn;
const world_h = @import("box3d/world.zig");
pub const World = world_h.World;
pub const TaskCallback = world_h.TaskCallback;
pub const EnqueueTaskCallback = world_h.EnqueueTaskCallback;
pub const FinishTaskCallback = world_h.FinishTaskCallback;
pub const FrictionCallback = world_h.FrictionCallback;
pub const RestitutionCallback = world_h.RestitutionCallback;
pub const CustomFilterFcn = world_h.CustomFilterFcn;
pub const PreSolveFcn = world_h.PreSolveFcn;
pub const OverlapResultFcn = world_h.OverlapResultFcn;
pub const CastResultFcn = world_h.CastResultFcn;
pub const Capacity = world_h.Capacity;
pub const WorldDef = world_h.WorldDef;
pub const defaultWorldDef = world_h.defaultWorldDef;
pub const Profile = world_h.Profile;
pub const Counters = world_h.Counters;
pub const ExplosionDef = world_h.ExplosionDef;
pub const defaultExplosionDef = world_h.defaultExplosionDef;
pub const createWorld = world_h.createWorld;
pub const getWorldCount = world_h.getWorldCount;
pub const getMaxWorldCount = world_h.getMaxWorldCount;

const modules = .{
    base_h,
    constants_h,
    math_h,
    world_h,
    events_h,
    recording_h,
    body_h,
    shape_h,
    joint_h,
    contact_h,
    query_h,
    tree_h,
    mover_h,
    geometry_h,
    collision_h,
    debug_draw_h,
};

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
