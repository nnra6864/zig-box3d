//! Contact (box3d.h, types.h)

const b3 = @import("../box3d.zig");
const Shape = b3.Shape;
const Vec3 = b3.Vec3;

/// Contact id references a contact instance. This should be treated as an opaque handle.
pub const Contact = extern struct {
    index1: i32 = 0,
    world0: u16 = 0,
    padding: i16 = 0,
    generation: u32 = 0,

    /// A null id. Zero initialization also gives a null id.
    pub const null_id: Contact = .{};

    /// Is this id null?
    pub fn isNull(id: Contact) bool {
        return id.index1 == 0;
    }

    /// Is this id non-null?
    pub fn isNonNull(id: Contact) bool {
        return id.index1 != 0;
    }

    /// Compare two ids for equality.
    pub fn eql(a: Contact, b: Contact) bool {
        return a.index1 == b.index1 and a.world0 == b.world0 and a.generation == b.generation;
    }

    /// Store a contact id into three u32 values.
    pub fn store(id: Contact) [3]u32 {
        return .{ @bitCast(id.index1), id.world0, id.generation };
    }

    /// Load a contact id from three u32 values.
    pub fn load(values: [3]u32) Contact {
        return .{ .index1 = @bitCast(values[0]), .world0 = @truncate(values[1]), .padding = 0, .generation = values[2] };
    }

    /// Contact identifier validation. Provides validation for up to 2^32 allocations.
    pub const isValid = b3Contact_IsValid;
    extern fn b3Contact_IsValid(id: Contact) bool;

    /// Get the manifolds for a contact. The manifold may have no points if the contact is not touching.
    pub const getData = b3Contact_GetData;
    extern fn b3Contact_GetData(contactId: Contact) ContactData;
};

/// The contact data for two shapes. By convention the manifold normal points
/// from shape A to shape B.
/// See `Shape.getContactData` and `Body.getContactData`.
pub const ContactData = extern struct {
    /// The contact id. You may hold onto this to track a contact across time steps.
    /// This id may become orphaned. Use `Contact.isValid` before using it for other functions.
    contactId: Contact,
    /// The first shape id.
    shapeIdA: Shape,
    /// The second shape id.
    shapeIdB: Shape,
    /// The contact manifold. This points to internal data and may become invalid. Do not store
    /// this pointer.
    manifolds: ?[*]const Manifold,
    /// The number of contact manifolds. For mesh and height-field collision there can be multiple manifolds.
    manifoldCount: c_int,

    /// The contact manifolds. This points to internal data and may become invalid. Do not store it.
    pub fn getManifolds(data: ContactData) []const Manifold {
        const ptr = data.manifolds orelse return &.{};
        return ptr[0..@intCast(data.manifoldCount)];
    }
};

/// A manifold point is a contact point belonging to a contact manifold.
/// It holds details related to the geometry and dynamics of the contact points.
/// Box3D uses speculative collision so some contact points may be separated.
/// You may use the maxNormalImpulse to determine if there was an interaction during
/// the time step.
pub const ManifoldPoint = extern struct {
    /// Location of the contact point relative to the bodyA center of mass in world space.
    anchorA: Vec3,
    /// Location of the contact point relative to the bodyB center of mass in world space.
    anchorB: Vec3,
    /// The separation of the contact point, negative if penetrating
    separation: f32,
    /// The impulse along the manifold normal vector. Since Box3D uses sub-stepping, this is
    /// result from the final sub-step.
    normalImpulse: f32,
    /// The total normal impulse applied across sub-stepping and restitution. This is important
    /// to identify speculative contact points that had an interaction in the time step.
    /// This includes the warm starting impulse, the sub-step delta impulse, and the restitution
    /// impulse.
    totalNormalImpulse: f32,
    /// Relative normal velocity pre-solve. Negative when approaching. This is only
    /// computed if hit events are enabled.
    normalVelocity: f32,
    /// Cached separation used for contact recycling
    baseSeparation: f32,
    /// Local point for matching
    /// Uniquely identifies a contact point between two shapes
    featureId: u32,
    /// Triangle index if one of the shapes is a mesh or height field
    triangleIndex: c_int,
    /// Did this contact point exist in the previous step?
    persisted: bool,
};

/// A contact manifold describes the contact points between colliding shapes.
/// Note: Box3D uses speculative collision so some contact points may be separated.
pub const Manifold = extern struct {
    /// The manifold points. There may be 1 to 4 valid points.
    points: [b3.max_manifold_points]ManifoldPoint,
    /// The unit normal vector in world space, points from shape A to shape B
    normal: Vec3,
    /// Central friction angular impulse (applied about the normal)
    twistImpulse: f32,
    /// Central friction linear impulse
    frictionImpulse: Vec3,
    /// Rolling resistance angular impulse
    rollingImpulse: Vec3,
    /// The number of contact points, will be 0 to 4
    pointCount: c_int,
};
