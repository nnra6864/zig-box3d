//! Debug draw (types.h)

const b3 = @import("../box3d.zig");
const AABB = b3.AABB;
const Capsule = b3.Capsule;
const CompoundData = b3.CompoundData;
const HeightFieldData = b3.HeightFieldData;
const HullData = b3.HullData;
const Mesh = b3.Mesh;
const Pos = b3.Pos;
const Shape = b3.Shape;
const ShapeType = b3.ShapeType;
const Sphere = b3.Sphere;
const Vec3 = b3.Vec3;
const WorldTransform = b3.WorldTransform;

/// The user needs to be able to create debug draw shapes for multi-pass rendering to work efficiently.
/// These user shapes are created and destroyed via callback so they can be bound to shape lifetime and scaling updates.
pub const CreateDebugShapeCallback = *const fn (debugShape: *const DebugShape, userContext: ?*anyopaque) callconv(.c) ?*anyopaque;

pub const DestroyDebugShapeCallback = *const fn (userShape: ?*anyopaque, userContext: ?*anyopaque) callconv(.c) void;

/// These colors are used for debug draw and mostly match the named SVG colors.
/// See https://www.rapidtables.com/web/color/index.html
/// https://johndecember.com/html/spec/colorsvg.html
/// https://upload.wikimedia.org/wikipedia/commons/2/2b/SVG_Recognized_color_keyword_names.svg
pub const HexColor = enum(c_int) {
    alice_blue = 0xF0F8FF,
    antique_white = 0xFAEBD7,
    aqua = 0x00FFFF,
    aquamarine = 0x7FFFD4,
    azure = 0xF0FFFF,
    beige = 0xF5F5DC,
    bisque = 0xFFE4C4,
    black = 0x000000,
    blanched_almond = 0xFFEBCD,
    blue = 0x0000FF,
    blue_violet = 0x8A2BE2,
    brown = 0xA52A2A,
    burlywood = 0xDEB887,
    cadet_blue = 0x5F9EA0,
    chartreuse = 0x7FFF00,
    chocolate = 0xD2691E,
    coral = 0xFF7F50,
    cornflower_blue = 0x6495ED,
    cornsilk = 0xFFF8DC,
    crimson = 0xDC143C,
    dark_blue = 0x00008B,
    dark_cyan = 0x008B8B,
    dark_golden_rod = 0xB8860B,
    dark_gray = 0xA9A9A9,
    dark_green = 0x006400,
    dark_khaki = 0xBDB76B,
    dark_magenta = 0x8B008B,
    dark_olive_green = 0x556B2F,
    dark_orange = 0xFF8C00,
    dark_orchid = 0x9932CC,
    dark_red = 0x8B0000,
    dark_salmon = 0xE9967A,
    dark_sea_green = 0x8FBC8F,
    dark_slate_blue = 0x483D8B,
    dark_slate_gray = 0x2F4F4F,
    dark_turquoise = 0x00CED1,
    dark_violet = 0x9400D3,
    deep_pink = 0xFF1493,
    deep_sky_blue = 0x00BFFF,
    dim_gray = 0x696969,
    dodger_blue = 0x1E90FF,
    fire_brick = 0xB22222,
    floral_white = 0xFFFAF0,
    forest_green = 0x228B22,
    fuchsia = 0xFF00FF,
    gainsboro = 0xDCDCDC,
    ghost_white = 0xF8F8FF,
    gold = 0xFFD700,
    golden_rod = 0xDAA520,
    gray = 0x808080,
    green = 0x008000,
    green_yellow = 0xADFF2F,
    honey_dew = 0xF0FFF0,
    hot_pink = 0xFF69B4,
    indian_red = 0xCD5C5C,
    indigo = 0x4B0082,
    ivory = 0xFFFFF0,
    khaki = 0xF0E68C,
    lavender = 0xE6E6FA,
    lavender_blush = 0xFFF0F5,
    lawn_green = 0x7CFC00,
    lemon_chiffon = 0xFFFACD,
    light_blue = 0xADD8E6,
    light_coral = 0xF08080,
    light_cyan = 0xE0FFFF,
    light_golden_rod_yellow = 0xFAFAD2,
    light_gray = 0xD3D3D3,
    light_green = 0x90EE90,
    light_pink = 0xFFB6C1,
    light_salmon = 0xFFA07A,
    light_sea_green = 0x20B2AA,
    light_sky_blue = 0x87CEFA,
    light_slate_gray = 0x778899,
    light_steel_blue = 0xB0C4DE,
    light_yellow = 0xFFFFE0,
    lime = 0x00FF00,
    lime_green = 0x32CD32,
    linen = 0xFAF0E6,
    maroon = 0x800000,
    medium_aqua_marine = 0x66CDAA,
    medium_blue = 0x0000CD,
    medium_orchid = 0xBA55D3,
    medium_purple = 0x9370DB,
    medium_sea_green = 0x3CB371,
    medium_slate_blue = 0x7B68EE,
    medium_spring_green = 0x00FA9A,
    medium_turquoise = 0x48D1CC,
    medium_violet_red = 0xC71585,
    midnight_blue = 0x191970,
    mint_cream = 0xF5FFFA,
    misty_rose = 0xFFE4E1,
    moccasin = 0xFFE4B5,
    navajo_white = 0xFFDEAD,
    navy = 0x000080,
    old_lace = 0xFDF5E6,
    olive = 0x808000,
    olive_drab = 0x6B8E23,
    orange = 0xFFA500,
    orange_red = 0xFF4500,
    orchid = 0xDA70D6,
    pale_golden_rod = 0xEEE8AA,
    pale_green = 0x98FB98,
    pale_turquoise = 0xAFEEEE,
    pale_violet_red = 0xDB7093,
    papaya_whip = 0xFFEFD5,
    peach_puff = 0xFFDAB9,
    peru = 0xCD853F,
    pink = 0xFFC0CB,
    plum = 0xDDA0DD,
    powder_blue = 0xB0E0E6,
    purple = 0x800080,
    rebecca_purple = 0x663399,
    red = 0xFF0000,
    rosy_brown = 0xBC8F8F,
    royal_blue = 0x4169E1,
    saddle_brown = 0x8B4513,
    salmon = 0xFA8072,
    sandy_brown = 0xF4A460,
    sea_green = 0x2E8B57,
    sea_shell = 0xFFF5EE,
    sienna = 0xA0522D,
    silver = 0xC0C0C0,
    sky_blue = 0x87CEEB,
    slate_blue = 0x6A5ACD,
    slate_gray = 0x708090,
    snow = 0xFFFAFA,
    spring_green = 0x00FF7F,
    steel_blue = 0x4682B4,
    tan = 0xD2B48C,
    teal = 0x008080,
    thistle = 0xD8BFD8,
    tomato = 0xFF6347,
    turquoise = 0x40E0D0,
    violet = 0xEE82EE,
    wheat = 0xF5DEB3,
    white = 0xFFFFFF,
    white_smoke = 0xF5F5F5,
    yellow = 0xFFFF00,
    yellow_green = 0x9ACD32,
    box2d_red = 0xDC3132,
    box2d_blue = 0x30AEBF,
    box2d_green = 0x8CC924,
    box2d_yellow = 0xFFEE8C,
    _,

    /// Same as `aqua`.
    pub const cyan: HexColor = .aqua;
    /// Same as `fuchsia`.
    pub const magenta: HexColor = .fuchsia;

    /// Make a color from an RGB value such as 0xFF8800.
    pub fn rgb(value: u24) HexColor {
        return @fromBackingInt(value);
    }

    /// Pack an RGB color with a material preset for debug draw. The preset rides in
    /// the high byte where the color converters ignore it.
    pub fn withMaterial(color: HexColor, material: DebugMaterial) HexColor {
        const bits: u32 = @bitCast(@backingInt(color));
        const mat: u32 = @intCast(@backingInt(material));
        return @fromBackingInt(@bitCast((bits & 0x00FF_FFFF) | (mat << 24)));
    }
};

/// Debug draw material preset. Optionally packed into the unused high byte of a
/// `HexColor` (or `SurfaceMaterial.customColor`) to drive the renderer's PBR
/// roughness and metalness. The low 24 bits stay RGB, so a plain 0xRRGGBB color
/// reads as `DebugMaterial.default` and keeps the renderer's per-body-type look.
pub const DebugMaterial = enum(c_int) {
    default = 0,
    matte,
    soft,
    dead,
    glossy,
    metallic,
};

/// Get the visualization color assigned to a constraint graph color slot. The last index
/// (`graph_color_count` - 1) is the overflow color.
pub const getGraphColor = b3GetGraphColor;
extern fn b3GetGraphColor(index: c_int) HexColor;

/// This is sent to the user for debug shape creation. The user should know the type in case they have
/// custom sphere or capsule rendering.
pub const DebugShape = extern struct {
    /// Shape id.
    shapeId: Shape,
    /// Shape type.
    type: ShapeType,
    /// Tagged union, see `type`.
    shape: extern union {
        capsule: *const Capsule,
        compound: *const CompoundData,
        heightField: *const HeightFieldData,
        hull: *const HullData,
        mesh: *const Mesh,
        sphere: *const Sphere,
    },
};

/// This struct is passed to `World.draw` to draw a debug view of the simulation world.
/// Callbacks receive world coordinates. In large world mode the translation is double precision so
/// it stays accurate far from the origin. Shift into your own camera frame inside the callbacks.
pub const DebugDraw = extern struct {
    /// Draws a user shape. The userShape pointer is owned by the application and is known to Box3D as
    /// an opaque pointer returned from `CreateDebugShapeCallback`. When this is called the drawn shape has
    /// passed a culling test against drawingBounds below.
    DrawShapeFcn: ?*const fn (userShape: ?*anyopaque, transform: WorldTransform, color: HexColor, context: ?*anyopaque) callconv(.c) void,
    /// Draw a line segment.
    DrawSegmentFcn: ?*const fn (p1: Pos, p2: Pos, color: HexColor, context: ?*anyopaque) callconv(.c) void,
    /// Draw a transform. Choose your own length scale.
    DrawTransformFcn: ?*const fn (transform: WorldTransform, context: ?*anyopaque) callconv(.c) void,
    /// Draw a point.
    DrawPointFcn: ?*const fn (p: Pos, size: f32, color: HexColor, context: ?*anyopaque) callconv(.c) void,
    /// Draw a sphere.
    DrawSphereFcn: ?*const fn (p: Pos, radius: f32, color: HexColor, alpha: f32, context: ?*anyopaque) callconv(.c) void,
    /// Draw a capsule.
    DrawCapsuleFcn: ?*const fn (p1: Pos, p2: Pos, radius: f32, color: HexColor, alpha: f32, context: ?*anyopaque) callconv(.c) void,
    /// Draw a bounding box.
    DrawBoundsFcn: ?*const fn (aabb: AABB, color: HexColor, context: ?*anyopaque) callconv(.c) void,
    /// Draw an oriented box.
    DrawBoxFcn: ?*const fn (extents: Vec3, transform: WorldTransform, color: HexColor, context: ?*anyopaque) callconv(.c) void,
    /// Draw a string in world space
    DrawStringFcn: ?*const fn (p: Pos, s: [*:0]const u8, color: HexColor, context: ?*anyopaque) callconv(.c) void,
    /// World bounds to use for debug draw
    drawingBounds: AABB,
    /// Scale to use when drawing forces
    forceScale: f32,
    /// Global scaling for joint drawing
    jointScale: f32,
    /// Option to draw shapes
    drawShapes: bool,
    /// Option to draw joints
    drawJoints: bool,
    /// Option to draw additional information for joints
    drawJointExtras: bool,
    /// Option to draw the bounding boxes for shapes
    drawBounds: bool,
    /// Option to draw the mass and center of mass of dynamic bodies
    drawMass: bool,
    /// Option to draw the sleep information for dynamic and kinematic bodies
    drawSleep: bool,
    /// Option to draw body names
    drawBodyNames: bool,
    /// Option to draw contact points
    drawContacts: bool,
    /// Draw contact anchor A or B
    drawAnchorA: bool,
    /// Option to visualize the graph coloring used for contacts and joints
    drawGraphColors: bool,
    /// Option to draw contact features
    drawContactFeatures: bool,
    /// Option to draw contact normals
    drawContactNormals: bool,
    /// Option to draw contact normal forces
    drawContactForces: bool,
    /// Option to draw islands as bounding boxes
    drawIslands: bool,
    /// User context that is passed as an argument to drawing callback functions
    context: ?*anyopaque,

    /// Create a debug draw struct with default values.
    pub const default = b3DefaultDebugDraw;
    extern fn b3DefaultDebugDraw() DebugDraw;
};

/// Create a debug draw struct with default values.
pub const defaultDebugDraw = DebugDraw.default;
