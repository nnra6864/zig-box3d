//! World event types (types.h)

const b3 = @import("../box3d.zig");
const Body = b3.Body;
const Contact = b3.Contact;
const Joint = b3.Joint;
const Pos = b3.Pos;
const Shape = b3.Shape;
const Vec3 = b3.Vec3;
const WorldTransform = b3.WorldTransform;

/// A begin-touch event is generated when a shape starts to overlap a sensor shape.
pub const SensorBeginTouchEvent = extern struct {
    /// The id of the sensor shape
    sensorShapeId: Shape,
    /// The id of the shape that began touching the sensor shape
    visitorShapeId: Shape,
};

/// An end touch event is generated when a shape stops overlapping a sensor shape.
/// These include things like setting the transform, destroying a body or shape, or changing
/// a filter. You will also get an end event if the sensor or visitor are destroyed.
/// Therefore you should always confirm the shape id is valid using `Shape.isValid`.
pub const SensorEndTouchEvent = extern struct {
    /// The id of the sensor shape
    /// Warning: this shape may have been destroyed
    /// See `Shape.isValid`.
    sensorShapeId: Shape,
    /// The id of the shape that stopped touching the sensor shape
    /// Warning: this shape may have been destroyed
    /// See `Shape.isValid`.
    visitorShapeId: Shape,
};

/// Sensor events are buffered in the world and are available
/// as begin/end overlap event arrays after the time step is complete.
/// Note: these may become invalid if bodies and/or shapes are destroyed
pub const SensorEvents = struct {
    /// Array of sensor begin touch events
    beginEvents: []const SensorBeginTouchEvent,
    /// Array of sensor end touch events
    endEvents: []const SensorEndTouchEvent,

    /// The C layout of these events.
    pub const Extern = extern struct {
        beginEvents: ?[*]const SensorBeginTouchEvent,
        endEvents: ?[*]const SensorEndTouchEvent,
        beginCount: c_int,
        endCount: c_int,
    };
};

/// A begin-touch event is generated when two shapes begin touching.
pub const ContactBeginTouchEvent = extern struct {
    /// Id of the first shape
    shapeIdA: Shape,
    /// Id of the second shape
    shapeIdB: Shape,
    /// The transient contact id. This contact may be destroyed automatically when the world is modified or simulated.
    /// Use `Contact.isValid` before using this id.
    contactId: Contact,
};

/// An end touch event is generated when two shapes stop touching.
/// You will get an end event if you do anything that destroys contacts previous to the last
/// world step. These include things like setting the transform, destroying a body
/// or shape, or changing a filter or body type.
pub const ContactEndTouchEvent = extern struct {
    /// Id of the first shape
    /// Warning: this shape may have been destroyed
    /// See `Shape.isValid`.
    shapeIdA: Shape,
    /// Id of the first shape
    /// Warning: this shape may have been destroyed
    /// See `Shape.isValid`.
    shapeIdB: Shape,
    /// Id of the contact.
    /// Warning: this contact may have been destroyed
    /// See `Contact.isValid`.
    contactId: Contact,
};

/// A hit touch event is generated when two shapes collide with a speed faster than the hit speed threshold.
/// This may be reported for speculative contacts that have a confirmed impulse.
pub const ContactHitEvent = extern struct {
    /// Id of the first shape
    shapeIdA: Shape,
    /// Id of the second shape
    shapeIdB: Shape,
    /// Id of the contact.
    /// Warning: this contact may have been destroyed
    /// See `Contact.isValid`.
    contactId: Contact,
    /// Point where the shapes hit at the beginning of the time step.
    /// This is a mid-point between the two surfaces. It could be at speculative
    /// point where the two shapes were not touching at the beginning of the time step.
    point: Pos,
    /// Normal vector pointing from shape A to shape B
    normal: Vec3,
    /// The speed the shapes are approaching. Always positive. Typically in meters per second.
    approachSpeed: f32,
    /// User material on shape A
    userMaterialIdA: u64,
    /// User material on shape B
    userMaterialIdB: u64,
};

/// Contact events are buffered in the world and are available
/// as event arrays after the time step is complete.
/// Note: these may become invalid if bodies and/or shapes are destroyed
pub const ContactEvents = struct {
    /// Array of begin touch events
    beginEvents: []const ContactBeginTouchEvent,
    /// Array of end touch events
    endEvents: []const ContactEndTouchEvent,
    /// Array of hit events
    hitEvents: []const ContactHitEvent,

    /// The C layout of these events.
    pub const Extern = extern struct {
        beginEvents: ?[*]const ContactBeginTouchEvent,
        endEvents: ?[*]const ContactEndTouchEvent,
        hitEvents: ?[*]const ContactHitEvent,
        beginCount: c_int,
        endCount: c_int,
        hitCount: c_int,
    };
};

/// Body move events triggered when a body moves.
/// Triggered when a body moves due to simulation. Not reported for bodies moved by the user.
/// This also has a flag to indicate that the body went to sleep so the application can also
/// sleep that actor/entity/object associated with the body.
/// On the other hand if the flag does not indicate the body went to sleep then the application
/// can treat the actor/entity/object associated with the body as awake.
/// This is an efficient way for an application to update game object transforms rather than
/// calling functions such as `Body.getTransform` because this data is delivered as a contiguous array
/// and it is only populated with bodies that have moved.
/// Note: If sleeping is disabled all dynamic and kinematic bodies will trigger move events.
pub const BodyMoveEvent = extern struct {
    /// The body user data.
    userData: ?*anyopaque,
    /// The body transform.
    transform: WorldTransform,
    /// The body id.
    bodyId: Body,
    /// Did the body fall asleep this time step?
    fellAsleep: bool,
};

/// Body events are buffered in the world and are available
/// as event arrays after the time step is complete.
/// Note: this data becomes invalid if bodies are destroyed
pub const BodyEvents = struct {
    /// Array of move events
    moveEvents: []const BodyMoveEvent,

    /// The C layout of these events.
    pub const Extern = extern struct {
        moveEvents: ?[*]const BodyMoveEvent,
        moveCount: c_int,
    };
};

/// Joint events report joints that are awake and have a force and/or torque exceeding the threshold
/// The observed forces and torques are not returned for efficiency reasons.
pub const JointEvent = extern struct {
    /// The joint id
    jointId: Joint,
    /// The user data from the joint for convenience
    userData: ?*anyopaque,
};

/// Joint events are buffered in the world and are available
/// as event arrays after the time step is complete.
/// Note: this data becomes invalid if joints are destroyed
pub const JointEvents = struct {
    /// Array of events
    jointEvents: []const JointEvent,

    /// The C layout of these events.
    pub const Extern = extern struct {
        jointEvents: ?[*]const JointEvent,
        count: c_int,
    };
};
